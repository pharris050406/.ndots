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

    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    
    spacing: 0

    Process {
        id: cpuProc
        command: ["sh", "-c", "while true; do head -1 /proc/stat; sleep 2; done"]
        stdout: SplitParser {
            onRead: data => {
                var p = data.trim().split(/\s+/)
                var idle = parseInt(p[4]) + parseInt(p[5])
                var total = p.slice(1,8).reduce((a, b) => a + parseInt(b), 0)

                if(lastCpuTotal > 0){
                    cpuUsage = Math.round(100 * (1-(idle - lastCpuIdle) / (total - lastCpuTotal)))
                }
                lastCpuTotal = total
                lastCpuIdle = idle
            }
        }
        Component.onCompleted: running = true
    }
    
    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: "CPU:" + String(root.cpuUsage).padStart(3, ' ') + "%"; color: root.textColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
