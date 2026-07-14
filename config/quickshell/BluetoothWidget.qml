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
    
    property string btState: "off" // "off", "on", "connected"
    property string btDevice: ""
    
    spacing: 0

    Process {
        id: btProc
        command: [
            "sh", "-c",
            "if ! bluetoothctl show 2>/dev/null | grep -q 'Powered: yes'; then " +
            "echo 'off'; " +
            "else " +
            "CONN=$(bluetoothctl devices Connected 2>/dev/null); " +
            "if [ -z \"$CONN\" ]; then " +
            "echo 'on'; " +
            "else " +
            "DEV=$(echo \"$CONN\" | head -n 1 | cut -d ' ' -f 3-); " +
            "COUNT=$(echo \"$CONN\" | grep -c '^'); " +
            "if [ \"$COUNT\" -gt 1 ]; then " +
            "echo \"connected|$DEV (+$((COUNT - 1)))\"; " +
            "else " +
            "echo \"connected|$DEV\"; " +
            "fi; " +
            "fi; " +
            "fi"
        ]

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split('|');
                if (parts.length > 0) {
                    root.btState = parts[0];
                    if (root.btState === "connected" && parts.length > 1) {
                        root.btDevice = parts[1];
                    } else {
                        root.btDevice = "";
                    }
                }
            }
        }

        Component.onCompleted: running = true
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: btProc.running = true
    }

    Process {
        id: togglePower
        command: [
            "sh", "-c", 
            "if bluetoothctl show | grep -q 'Powered: yes'; then " +
            "bluetoothctl power off; " +
            "else " +
            "bluetoothctl power on; " +
            "(sleep 1; for mac in $(bluetoothctl devices Paired | awk '{print $2}'); do bluetoothctl connect $mac >/dev/null 2>&1; done) & " +
            "fi"
        ]
        
        onRunningChanged: {
            if (!running) btProc.running = true 
        }
    }
    
    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }

    Text {
        id: btIcon
        text: root.btState === "off" ? "󰂲" : (root.btState === "connected" ? "󰂱" : "󰂯")
        color: root.btState === "connected" ? root.accentColor : root.textColor
        font { family: root.fontName; pixelSize: root.fontSize }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true 
            
            onClicked: {
                if (root.btState === "off") {
                    root.btState = "on";
                } else {
                    root.btState = "off";
                    root.btDevice = "";
                }
                
                togglePower.running = true;
            }
        }
        PopupWindow {
            id: btPopup
            visible: mouseArea.containsMouse
            
            anchor {
                item: btIcon
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
                    
                    text: {
                        if (root.btState === "off") return "[ Bluetooth: Off ]";
                        if (root.btState === "connected") return "[ Connected: " + root.btDevice + " ]";
                        return "[ Bluetooth: On (Disconnected) ]";
                    }
                    
                    font { family: root.fontName; pixelSize: root.fontSize }
                    color: root.textColor
                }
            }
        }
    }

    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
