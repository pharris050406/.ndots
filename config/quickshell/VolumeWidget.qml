import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout {
    id: root

    property color accentColor: "#e0af68"
    property color textColor: "#ffffff"
    property string fontName: "JetBrainsMono Nerd Font"
    property int fontSize: 12
    
    property string volumeStr: "0%"
    property string volIcon: "󰕾"

    spacing: 0

    function updateVolume() {
        getVolProc.running = true
    }

    Process {
        id: getVolProc
        command: [
            "sh", "-c", 
            "VOL=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}'); " +
            "MUTE=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'); " +
            "PORT=$(pactl get-sink-port @DEFAULT_SINK@ 2>/dev/null || echo 'speaker'); " +
            "echo \"$VOL|$MUTE|$PORT\""
        ]
        
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim();
                if (!trimmed) return;
                
                let parts = trimmed.split('|');
                if (parts.length < 3) return;
                
                let vol = parts[0];
                let isMuted = (parts[1] === "yes");
                let port = parts[2].toLowerCase();
                
                root.volumeStr = vol;

                if (isMuted) {
                    root.volIcon = "󰝟";
                } else if (port.includes("bluez") || port.includes("bluetooth") || port.includes("a2dp")) {
                    root.volIcon = "󰂰";
                } else if (port.includes("headphone") || port.includes("headset")) {
                    root.volIcon = "󰋋";
                } else if (port.includes("hdmi") || port.includes("hdmi-output")) {
                    root.volIcon = "󰽟";
                } else {
                    root.volIcon = "󰕾";
                }
            }
        }
    }

    Process {
        id: volListener
        command: ["pactl", "subscribe"]
        
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("sink") || data.includes("server")) {
                    root.updateVolume()
                }
            }
        }

        Component.onCompleted: {
            running = true;       
            root.updateVolume();  
        }
    }

    Process {
        id: toggleMuteProc
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
    }

    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: root.volIcon + " "; color: root.textColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: root.volumeStr.padStart(4, ' '); color: root.textColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: toggleMuteProc.running = true
    }
}
