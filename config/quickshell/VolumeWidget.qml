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
    
    // Properties to store dynamic states
    property string volumeStr: "0%"
    property string volIcon: "󰕾" // Default fallback speaker icon

    spacing: 0

    function updateVolume() {
        getVolProc.running = true
    }

    Process {
        id: getVolProc
        // Shell pipeline that queries volume, mute status, and port type, returning them separated by a pipe '|'
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
                
                // Split the output pipeline: [Volume, MuteState, PortName]
                let parts = trimmed.split('|');
                if (parts.length < 3) return;
                
                let vol = parts[0];
                let isMuted = (parts[1] === "yes");
                let port = parts[2].toLowerCase();
                
                root.volumeStr = vol;

                // Icon selection logic mirroring Waybar
                if (isMuted) {
                    root.volIcon = "󰝟"; // Muted Icon
                } else if (port.includes("bluez") || port.includes("bluetooth") || port.includes("a2dp")) {
                    root.volIcon = "󰂰"; // Bluetooth Audio Icon
                } else if (port.includes("headphone") || port.includes("headset")) {
                    root.volIcon = "󰋋"; // Headphones Icon
                } else if (port.includes("hdmi") || port.includes("hdmi-output")) {
                    root.volIcon = "󰽟"; // TV/HDMI Icon
                } else {
                    root.volIcon = "󰕾"; // Default Speaker Icon
                }
            }
        }
    }

    Process {
        id: volListener
        command: ["pactl", "subscribe"]
        
        stdout: SplitParser {
            onRead: data => {
                // Now matching both sink volumes and server context shifts (like plugging in headphones)
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

    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    // Displays the dynamic Nerd Font Icon
    Text { text: root.volIcon + " "; color: root.textColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: root.volumeStr.padStart(4, ' '); color: root.textColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
