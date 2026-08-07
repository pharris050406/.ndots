{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.mpd-rpc;
in
{
  options.services.mpd-rpc = {
    enable = lib.mkEnableOption "Discord rich presence for MPD";

    script = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.ndots/config/mpd-rpc.py";
      description = "Path to mpd-rpc.py. Kept out of the store so it stays editable.";
    };

    coverBase = lib.mkOption {
      type = lib.types.str;
      default = "https://music.pharris.io";
      description = "Public base URL mapping onto the MPD music directory. No trailing slash.";
    };

    clientId = lib.mkOption {
      type = lib.types.str;
      default = "677226551607033903";
      description = "Discord application ID to report through.";
    };

    mpdHost = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
    };

    mpdPort = lib.mkOption {
      type = lib.types.port;
      default = 6600;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.mpd-rpc = {
      Unit = {
        Description = "Discord Rich Presence for MPD";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.python3}/bin/python ${cfg.script}";
        Environment = [
          "MPD_RPC_COVER_BASE=${cfg.coverBase}"
          "MPD_RPC_CLIENT_ID=${cfg.clientId}"
          "MPD_HOST=${cfg.mpdHost}"
          "MPD_PORT=${toString cfg.mpdPort}"
        ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
