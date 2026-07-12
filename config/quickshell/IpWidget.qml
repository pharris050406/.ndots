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
        command: ["sh", "-c", "hostname -I | awk '{print $1}'"]
        
        // SplitParser splits by newlines ("\n") by default automatically
        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim();
                if (trimmed.length > 0) {
                    root.ipAddr = trimmed;
                }
            }
        }

        onRunningChanged: {
            if (!running) {
                loopTimer.start()
            }
        }

        Component.onCompleted: running = true
    }
    
    Timer {
        id: loopTimer
        interval: 2000
        repeat: false
        onTriggered: ipProc.running = true
    }

    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: root.ipAddr.padStart(13, ' '); color: root.textColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
