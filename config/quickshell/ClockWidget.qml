import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    property color accentColor: "#e0af68"
    property color textColor: "#ffffff"
    property string fontName: "JetBrainsMono Nerd Font"
    property int fontSize: 12

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    component BracketText: Text {
        color: root.accentColor
        font.family: root.fontName
        font.pixelSize: root.fontSize
    }

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

    property var now: new Date()

    Timer {
	id: clockTimer
	running: true
	repeat: true
	triggeredOnStart: true
	interval: 1000 - (Date.now() % 1000)
	onTriggered: {
	    root.now = new Date()
	    interval = 1000 - (Date.now() % 1000)
	}
    }
    readonly property string clockText: state.showActual
        ? Qt.formatDateTime(root.now, "MM-dd-yyyy")
        : Qt.formatDateTime(root.now, "HH:mm:ss")

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: state.showActual = !state.showActual
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        spacing: 0

        BracketText { text: "[ " }
        Text {
            text: root.clockText
            color: root.textColor
            font.family: root.fontName
            font.pixelSize: root.fontSize
        }
        BracketText { text: " ]" }
    }
}
