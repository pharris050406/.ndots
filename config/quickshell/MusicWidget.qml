import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: root

    // Theme properties passed from main panel
    property color accentColor: "#7aa2f7"
    property color textColor: "#ffffff"
    property string fontName: "JetBrainsMono Nerd Font"
    property int fontSize: 12

    // Internal state
    property string musicState: ""
    property string musicTrack: "Loading..."
    property real musicPosition: 0
    property real musicLength: 0

    spacing: 0

    function pad2(n) { return (n < 10 ? "0" : "") + n; }

    function formatTime(totalSeconds) {
        var s = Math.max(0, Math.floor(totalSeconds || 0));
        var h = Math.floor(s / 3600);
        var m = Math.floor((s % 3600) / 60);
        var sec = s % 60;
        return h > 0 ? (h + ":" + pad2(m) + ":" + pad2(sec)) : (m + ":" + pad2(sec));
    }

    Process {
        id: musicProc
        command: ["bash", "-c", "exec \"$HOME/.ndots/config/sway/scripts/media-source.sh\""]

        stdout: SplitParser {
            onRead: data => {
                var val = data.trim();

                if (val.indexOf("META|") === 0) {
                    var parts = val.substring(5).split("|");
                    if (parts.length >= 3) {
                        var status = parts[0];
                        var lengthMicro = parseFloat(parts[1]);
                        var track = parts.slice(2).join("|");

                        musicLength = isNaN(lengthMicro) ? 0 : lengthMicro / 1000000;

                        if (status === "Playing") {
                            musicState = "";
                            musicTrack = track;
                        } else if (status === "Paused") {
                            musicState = "";
                            musicTrack = track;
                        } else {
                            musicState = "";
                            musicTrack = "Not Playing";
                            musicPosition = 0;
                            musicLength = 0;
                        }
                    }
                } else if (val.indexOf("POS|") === 0) {
                    var p = parseFloat(val.substring(4));
                    if (!isNaN(p)) musicPosition = p;
                }
            }
        }

        Component.onCompleted: running = true
    }

    // --- LEFT BRACKET ---
    Text {
        text: "[ "
        color: root.accentColor
        font { family: root.fontName; pixelSize: root.fontSize }
    }

    // --- STATIC PART (Icon + Status) ---
    Text {
        Layout.preferredWidth: 35
        text: "󰎇 " + musicState
        color: root.textColor
        font { family: root.fontName; pixelSize: root.fontSize }
    }

// --- SCROLLING PART (Track Title) ---
    Item {
        id: musicContainer
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        property string trackString: musicTrack
        property bool needsScroll: false
        property real scrollDistance: 0

        // 1. Break the binding: Calculate once per track change
        onTrackStringChanged: {
            scrollAnim.stop()
            scrollingRow.x = 0

            // 2. Yield to the layout engine to finish updating text bounds
            Qt.callLater(() => {
                // 3. Force integer math. Wayland/SwayFX often snaps text to integer pixels.
                scrollDistance = Math.ceil(trackText1.implicitWidth + delimiterText.implicitWidth + (scrollingRow.spacing * 2))
                needsScroll = trackText1.implicitWidth > (musicContainer.width - 5) && musicContainer.width > 0

                if (needsScroll) scrollAnim.restart()
            })
        }

        // Catch edge cases where the container resizes
        onWidthChanged: {
            var currentNeedsScroll = trackText1.implicitWidth > (musicContainer.width - 5) && musicContainer.width > 0
            if (!currentNeedsScroll) {
                scrollAnim.stop()
                scrollingRow.x = 0
                needsScroll = false
            } else if (currentNeedsScroll && !scrollAnim.running) {
                needsScroll = true
                scrollAnim.restart()
            }
        }

        Row {
            id: scrollingRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 15

            Text {
                id: trackText1
                text: musicContainer.trackString
                color: root.textColor
                font { family: root.fontName; pixelSize: root.fontSize }
                renderType: Text.QtRendering // 4. Enables smoother subpixel animation
            }

            Text {
                id: delimiterText
                visible: musicContainer.needsScroll
                text: "|"
                color: root.textColor
                font { family: root.fontName; pixelSize: root.fontSize }
                renderType: Text.QtRendering
            }

            Text {
                id: trackText2
                visible: musicContainer.needsScroll
                text: musicContainer.trackString 
                color: root.textColor
                font { family: root.fontName; pixelSize: root.fontSize }
                renderType: Text.QtRendering
            }
        }

        NumberAnimation {
            id: scrollAnim
            target: scrollingRow
            property: "x"
            from: 0
            to: -musicContainer.scrollDistance
            duration: musicContainer.scrollDistance * 20
            easing.type: Easing.Linear // 5. Explicitly enforce linear easing
            loops: Animation.Infinite
            // Removed dynamic 'running' binding; managed manually in signals now
        }
    }
    // --- ELAPSED / TOTAL TIME ---
    Text {
        visible: musicTrack !== "Not Playing" && musicTrack !== "Loading..."
        text: musicLength > 0
            ? "(" + formatTime(musicPosition) + "/" + formatTime(musicLength) + ")"
            : formatTime(musicPosition)
        color: root.textColor
        font { family: root.fontName; pixelSize: root.fontSize }
    }

    // --- RIGHT BRACKET ---
    Text {
        text: " ]"
        color: root.accentColor
        font { family: root.fontName; pixelSize: root.fontSize }
    }
}
