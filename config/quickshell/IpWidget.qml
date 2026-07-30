import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

RowLayout {
    id: root

    property color accentColor: "#e0af68"
    property color textColor: "#ffffff"
    property string fontName: "JetBrainsMono Nerd Font"
    property int fontSize: 12
    
    property color barColor: "#1e1e1e" 
    property real barOpacity: 0.80

    property string ipAddr: "0.0.0.0"
    property string downSpeed: "0 B/s"
    property string upSpeed: "0 B/s"
    
    spacing: 0

   Process {
    id: ipProc
    command: [
	"bash", "-c",
	"while true; do " +
	"  IFACE=$(ip route | grep default | awk '{print $5}' | head -n1); " +
	"  if [ -z \"$IFACE\" ]; then echo '0.0.0.0|     0B|     0B'; sleep 2; continue; fi; " +
	"  IP=$(hostname -I | awk '{print $1}'); " +
	"  read r1 t1 < <(awk -v i=\"$IFACE:\" '$1 == i {print $2, $10}' /proc/net/dev); " +
	"  sleep 1; " +
	"  read r2 t2 < <(awk -v i=\"$IFACE:\" '$1 == i {print $2, $10}' /proc/net/dev); " +
	"  awk -v ip=\"$IP\" -v rx1=\"$r1\" -v rx2=\"$r2\" -v tx1=\"$t1\" -v tx2=\"$t2\" ' " +
	"  function fmt(v) { " +
	"    if (v < 1024) res = v \"B\"; " +
	"    else if (v < 1048576) res = sprintf(\"%.0fK\", v/1024); " +
	"    else res = sprintf(\"%.1fM\", v/1048576); " +
	"    return sprintf(\"%6s\", res); " +
	"  } " +
	"  BEGIN { print ip \"|\" fmt(rx2-rx1) \"|\" fmt(tx2-tx1); }'; " +
	"done"
    ]
    
    stdout: SplitParser {
	onRead: data => {
	    let parts = data.trim().split('|');
	    if (parts.length === 3) {
		root.ipAddr = parts[0];
		root.downSpeed = parts[1].replace(/ /g, '\u00A0');
		root.upSpeed = parts[2].replace(/ /g, '\u00A0');
	    }
	}
    }

    Component.onCompleted: running = true
} 
    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    
    Text { 
        id: netText
        
	Layout.preferredWidth: 125

        horizontalAlignment: Text.AlignHCenter
        
        text: "▼ " + root.downSpeed + " ▲ " + root.upSpeed
        color: root.textColor
        font { family: root.fontName; pixelSize: root.fontSize } 
        
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true 
        }
        
        PopupWindow {
            id: ipPopup
            visible: mouseArea.containsMouse
            
            anchor {
                item: netText
                edges: Edges.Bottom 
                gravity: Edges.Bottom 
            }
            
            width: popupText.implicitWidth + 24
            height: popupText.implicitHeight + 12 
            
            color: "transparent"

            Rectangle {
                anchors.fill: parent 
                color: Qt.rgba(root.barColor.r, root.barColor.g, root.barColor.b, root.barOpacity)

                Text {
                    id: popupText
                    anchors.centerIn: parent
                    text: "[ IP: " + root.ipAddr + " ]"
                    font { family: root.fontName; pixelSize: root.fontSize }
                    color: root.textColor
                }
            }
        }
    }
    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
