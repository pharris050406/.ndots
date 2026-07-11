import Quickshell
import Quickshell.Wayland
import Quickshell.I3
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow{
    id: root

    property color colBg: "#1a1b26"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property string fontFamily: "JetBrainsMono Nerd Font"

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 25
    color: colBg

    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0

    Process{
	id: cpuProc
	command: ["sh", "-c", "head -1 /proc/stat"]

	stdout: SplitParser{
	    onRead: data => {
		var p = data.trim().split(/\s+/)
		var idle = parseInt(p[4]) + parseInt(p[5])
		var total = p.slice(1,8).reduce((a, b) => a + parseInt(b), 0)

		if(lastCpuTotal >0){
		    cpuUsage = Math.round(100 * (1-(idle - lastCpuIdle) / (total - lastCpuTotal)))
		}
		lastCpuTotal = total
		lastCpuIdle = idle
	    }
	}
	Component.onCompleted: running = true
    }
	
    Timer{
	interval: 2000
	running: true
	repeat: true
	onTriggered: cpuProc.running = true
    }


RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing:0 
	Repeater {
            model: 10

            Rectangle {
                id: wsSquare
                Layout.preferredWidth: 20 // Width of your square
                Layout.fillHeight: true   // Stretches to fit the panel height

                property var ws: I3.workspaces.values.find(w => w.number == index + 1)
                property bool isActive: ws ? ws.focused : false

                color: isActive ? root.colCyan : (ws ? "#24283b" : "transparent")

                Text {
                    anchors.centerIn: parent // 3. Pins the number exactly in the center of the square
                    text: index + 1
                    
		    color: wsSquare.isActive ? root.colBg : (wsSquare.ws ? root.colBlue : "#444b6a")
                    
                    font.pixelSize: 11
                    font.bold: true
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: I3.dispatch("workspace " + (index + 1))
                }
            }
        }
	Item{Layout.fillWidth: true}
	
	Text{
	    text: "CPU: " + cpuUsage + "%"
	    color: root.colYellow
	    font{
		family: root.fontFamily
		pixelSize: root.fontSize
		bold: true
	    }
	}
    }
}


