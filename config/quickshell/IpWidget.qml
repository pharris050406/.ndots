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
    property string ipAddr: "0.0.0.0"
    
    spacing: 0

    Process {
        id: ipProc
        command: ["sh", "-c", "while true; do hostname -I | awk '{print $1}'; sleep 10; done"]
        
        // SplitParser splits by newlines ("\n") by default automatically
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim();
                if (trimmed.length > 0) {
                    root.ipAddr = trimmed;
                }
            }
        }

        Component.onCompleted: running = true
    }
    
    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: root.ipAddr.padStart(13, ' '); color: root.textColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
