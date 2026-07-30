import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

RowLayout{
    id: root

    property color accentColor: "#e0af68"
    property color textColor: "#ffffff"
    property string fontName: "JetBrainsMono Nerd Font"
    property int fontSize: 12

    property int memUsage: 0
    property real memActualGiB: 0

    // Reads/writes to ~/.local/state/quickshell/by-shell/<shell-id>/memWidgetState.json
    FileView {
        id: stateFile
        path: Quickshell.statePath("memWidgetState.json")
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()

        JsonAdapter {
            id: state
            property bool showActual: false
        }
    }

    Process{
        id:memProc
        command: ["sh", "-c", "while true; do free | grep Mem; sleep 2; done"]
        stdout: SplitParser{
            onRead: data => {
                var parts = data.trim().split(/\s+/)
                var total = parseInt(parts[1]) || 1
                var used = parseInt(parts[2]) || 0
                
                root.memUsage = Math.round(100 * used / total)
                root.memActualGiB = used / 1048576 
            }
        }
        Component.onCompleted: running = true
    }

    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: state.showActual = !state.showActual 
    }


    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    
    Text { 
        text: state.showActual 
              ? "Mem: " + root.memActualGiB.toFixed(2) + " GiB"
              : "Mem:" + String(root.memUsage).padStart(3, ' ') + "%"
        color: root.textColor; 
        font { family: root.fontName; pixelSize: root.fontSize } 
    }
    
    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
