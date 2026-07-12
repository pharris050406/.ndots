import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3

RowLayout {
    id: root

    // Theme properties passed from main panel
    property color accentColor: "#7aa2f7"
    property color textColor: "#ffffff"
    property string fontName: "JetBrainsMono Nerd Font"
    property int fontSize: 12

    spacing: 0

    Repeater {
        model: 10

        Item {
            id: wsSquare
            Layout.preferredWidth: 35
            Layout.fillHeight: true

            property var ws: I3.workspaces.values.find(w => w.number == index + 1)
            property bool isActive: ws ? ws.focused : false

            visible: ws !== undefined

            Text {
                anchors.centerIn: parent
                textFormat: Text.RichText
                
                // Active workspace gets the colored brackets
                text: isActive
                      ? "<font color='" + root.accentColor + "'>[ </font>" + (index + 1) + "<font color='" + root.accentColor + "'> ]</font>"
                      : (index + 1)

                // Inactive workspaces are dimmed
                color: isActive ? root.textColor : "#888888"

                font {
                    family: root.fontName
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: I3.dispatch("workspace " + (index + 1))
            }
        }
    }
}
