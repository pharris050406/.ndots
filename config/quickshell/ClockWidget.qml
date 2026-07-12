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
    
    spacing: 0

    Text { text: "[ "; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
    Text{
	id: clock
	text: Qt.formatDateTime(new Date(), "MM-dd-yyyy | HH:mm:ss")
	color: root.textColor
	 font { family: root.fontName; pixelSize: root.fontSize }
	
	Timer{
	    interval:1000
	    running:true
	    repeat:true
	    onTriggered: clock.text = Qt.formatDateTime(new Date(),"MM-dd-yyyy | HH:mm:ss" )
	}
    }

    Text { text: " ]"; color: root.accentColor; font { family: root.fontName; pixelSize: root.fontSize } }
}
