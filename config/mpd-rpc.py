#!/usr/bin/env python3
"""Event-driven Discord rich presence for MPD.

Updates on MPD player events rather than on a poll timer, and pulls album
art from your own webserver instead of the Cover Art Archive.

No third-party dependencies -- MPD speaks line-based text over a socket and
Discord's IPC is a length-prefixed JSON frame, both of which the standard
library handles directly.
"""

import json
import os
import socket
import struct
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid
from posixpath import dirname

# ---------------------------------------------------------------- config ---

MPD_HOST = os.environ.get("MPD_HOST", "127.0.0.1")
MPD_PORT = int(os.environ.get("MPD_PORT", "6600"))

# Discord application to report through. This is mpd-discord-rpc's app, which
# is why the status reads "Listening to music". Register your own at
# discord.com/developers if you want a different label.
CLIENT_ID = os.environ.get("MPD_RPC_CLIENT_ID", "677226551607033903")

# Public base URL that maps onto your ~/Music tree. No trailing slash.
COVER_BASE = os.environ.get("MPD_RPC_COVER_BASE", "https://music.pharris.io")
COVER_NAME = os.environ.get("MPD_RPC_COVER_NAME", "cover.jpg")

# Asset key used when no cover is reachable. "" disables the image entirely.
FALLBACK_IMAGE = "notes"

# urllib's default UA gets blocked by Cloudflare's bot rules.
USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/126.0 Safari/537.36"
)

# Discord rate-limits presence updates; don't push faster than this.
MIN_INTERVAL = 4.0

IPC_PATH = os.path.join(
    os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}"),
    "discord-ipc-0",
)


def log(*args):
    print(*args, flush=True)


# ------------------------------------------------------------------ mpd ---


class MPD:
    """Minimal MPD client: enough for status, currentsong and idle."""

    def __init__(self, host, port):
        self.sock = socket.create_connection((host, port), timeout=10)
        self.f = self.sock.makefile("rb")
        greeting = self.f.readline().decode("utf-8", "replace").strip()
        if not greeting.startswith("OK MPD"):
            raise ConnectionError(f"unexpected MPD greeting: {greeting!r}")

    def close(self):
        try:
            self.sock.close()
        except OSError:
            pass

    def _command(self, cmd):
        self.sock.sendall(cmd.encode("utf-8") + b"\n")
        result = {}
        while True:
            line = self.f.readline()
            if not line:
                raise ConnectionError("MPD closed the connection")
            text = line.decode("utf-8", "replace").rstrip("\n")
            if text == "OK":
                return result
            if text.startswith("ACK "):
                raise ConnectionError(f"MPD error: {text}")
            key, _, value = text.partition(": ")
            # MPD capitalizes tag names ("Artist", "Album") but not protocol
            # keys ("file", "elapsed"), so normalize. First occurrence wins;
            # currentsong repeats keys for multi-valued tags.
            result.setdefault(key.lower(), value)

    def status(self):
        return self._command("status")

    def currentsong(self):
        return self._command("currentsong")

    def idle_player(self):
        """Block until MPD reports a player event."""
        self.sock.settimeout(None)
        try:
            return self._command("idle player")
        finally:
            self.sock.settimeout(10)


# -------------------------------------------------------------- discord ---


class DiscordIPC:
    """Minimal Discord RPC client over the local IPC socket.

    Frames are: 4-byte little-endian opcode, 4-byte little-endian payload
    length, then UTF-8 JSON. Opcode 0 is HANDSHAKE, 1 is FRAME.
    """

    def __init__(self, client_id, path):
        self.client_id = client_id
        self.path = path
        self.sock = None

    def connect(self):
        self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.sock.settimeout(10)
        self.sock.connect(self.path)
        self._send(0, {"v": 1, "client_id": self.client_id})
        self._recv()

    def close(self):
        if self.sock is not None:
            try:
                self.sock.close()
            except OSError:
                pass
            self.sock = None

    def _send(self, op, payload):
        data = json.dumps(payload).encode("utf-8")
        self.sock.sendall(struct.pack("<II", op, len(data)) + data)

    def _recv_exactly(self, n):
        buf = b""
        while len(buf) < n:
            chunk = self.sock.recv(n - len(buf))
            if not chunk:
                raise ConnectionError("Discord closed the connection")
            buf += chunk
        return buf

    def _recv(self):
        header = self._recv_exactly(8)
        _op, length = struct.unpack("<II", header)
        return json.loads(self._recv_exactly(length).decode("utf-8"))

    def set_activity(self, activity):
        self._send(
            1,
            {
                "cmd": "SET_ACTIVITY",
                "args": {"pid": os.getpid(), "activity": activity},
                "nonce": str(uuid.uuid4()),
            },
        )
        self._recv()


# --------------------------------------------------------------- covers ---

_cover_cache = {}


def cover_url(song_file):
    """Map an MPD file path to a cover URL, or None if it isn't reachable.

    MPD reports paths relative to music_directory, e.g.
    "denn/rottenteeth/rottenteeth.mp3", so the album directory falls straight
    out of dirname() -- no reconstruction from tags, which means no mismatches
    when a folder name and an album tag disagree.
    """
    album_dir = dirname(song_file)
    if not album_dir:
        return None
    if album_dir in _cover_cache:
        return _cover_cache[album_dir]

    url = f"{COVER_BASE}/{urllib.parse.quote(album_dir)}/{COVER_NAME}"
    ok = False
    definitive = False
    why = ""
    # Cloudflare and similar front ends reject urllib's default user agent,
    # and some reject HEAD outright, so send a normal UA and fall back to a
    # one-byte ranged GET.
    for headers in (
        {"User-Agent": USER_AGENT},
        {"User-Agent": USER_AGENT, "Range": "bytes=0-0"},
    ):
        method = "HEAD" if "Range" not in headers else "GET"
        try:
            req = urllib.request.Request(url, method=method, headers=headers)
            with urllib.request.urlopen(req, timeout=5) as resp:
                if resp.status in (200, 206):
                    ok = True
                    break
                why = f"HTTP {resp.status}"
        except urllib.error.HTTPError as err:
            why = f"HTTP {err.code}"
            # 404 means the file genuinely isn't there. 5xx and friends are
            # transient (tunnel hiccup, origin restart) and must not be
            # remembered, or one blip hides the cover until the next restart.
            if err.code == 404:
                definitive = True
                break
        except (urllib.error.URLError, OSError) as err:
            why = str(err)

    if ok:
        _cover_cache[album_dir] = url
    elif definitive:
        _cover_cache[album_dir] = None
        log(f"no cover ({why}) at {url}")
    else:
        # Not cached: retried on the next play of this album.
        log(f"cover lookup failed ({why}), will retry: {url}")
        return None

    return _cover_cache[album_dir]


# ------------------------------------------------------------- activity ---


def pad(text):
    """Discord rejects presence strings shorter than two characters."""
    text = (text or "").strip()
    return text if len(text) >= 2 else (text + "\u2000")[:2].ljust(2, "\u2000")


def build_activity(mpd):
    status = mpd.status()
    if status.get("state") != "play":
        return None

    song = mpd.currentsong()
    if not song:
        return None

    path = song.get("file", "")
    title = song.get("title") or os.path.basename(path) or "Unknown"
    artist = song.get("artist") or song.get("albumartist") or "Unknown artist"
    album = song.get("album") or "Unknown album"

    activity = {
        "type": 2,  # "Listening to". Drop this line for "Playing".
        "details": pad(title),
        "state": pad(f"{artist} / {album}"),
    }

    try:
        elapsed = float(status.get("elapsed", 0))
        duration = float(status.get("duration", 0))
    except ValueError:
        elapsed = duration = 0.0

    start = int(time.time() - elapsed)
    timestamps = {"start": start}
    if duration:
        timestamps["end"] = start + int(duration)
    activity["timestamps"] = timestamps

    art = cover_url(path)
    if art:
        activity["assets"] = {"large_image": art, "large_text": pad(album)}
    elif FALLBACK_IMAGE:
        activity["assets"] = {"large_image": FALLBACK_IMAGE}

    return activity


# ----------------------------------------------------------------- main ---


def main():
    rpc = DiscordIPC(CLIENT_ID, IPC_PATH)
    mpd = None
    last_update = 0.0

    while True:
        try:
            if rpc.sock is None:
                rpc.connect()
                log(f"connected to Discord at {IPC_PATH}")
            if mpd is None:
                mpd = MPD(MPD_HOST, MPD_PORT)
                log(f"connected to MPD at {MPD_HOST}:{MPD_PORT}")

            activity = build_activity(mpd)

            gap = MIN_INTERVAL - (time.time() - last_update)
            if gap > 0:
                time.sleep(gap)

            rpc.set_activity(activity)
            last_update = time.time()

            # Blocks until MPD reports a player event. This is the whole
            # point: no polling interval to tune.
            mpd.idle_player()

        except (ConnectionError, OSError, json.JSONDecodeError) as err:
            log(f"reconnecting after: {err}")
            if mpd is not None:
                mpd.close()
                mpd = None
            rpc.close()
            time.sleep(5)


if __name__ == "__main__":
    main()
