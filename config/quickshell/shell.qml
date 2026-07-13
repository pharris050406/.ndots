import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    property color colBg: "#80000000"
    property color colFg: "#ffffff"
    property color colMuted: "#565f89"   
    property color colBlue: "#7aa2f7"    
    property color colCyan: "#00f7ff"    
    property color colGreen: "#40eb34"   
    property color colYellow: "#e0af68"
    property color colOrange: "#ff8000"  
    property color colRed: "#f7768e"     
    property color colPurple: "#c800ff" 
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 13

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 25
    color: colBg

    // --- MAIN BAR LAYOUT ---
    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
	spacing: 20


        // 1. Workspaces (Aligned Left)
        WorkspaceWidget {
            Layout.fillHeight: true
            accentColor: root.colCyan
            textColor: root.colFg
            fontName: root.fontFamily
            fontSize: root.fontSize
        }

        // Spacer (Pushes remaining items to the right)
        Item { 
            Layout.fillWidth: true 
        }
        

	MusicWidget {
	    property int widget_width: 325
            Layout.preferredWidth: widget_width 
            Layout.maximumWidth: widget_width
            Layout.fillHeight: true
            accentColor: root.colBlue
            textColor: root.colFg
            fontName: root.fontFamily
            fontSize: root.fontSize
        }
	VolumeWidget{
	    Layout.fillHeight: true
	    accentColor: root.colYellow
            textColor: root.colFg
            fontName: root.fontFamily
            fontSize: root.fontSize

	}
	IpWidget{
	    Layout.fillHeight: true
	    accentColor: root.colGreen
            textColor: root.colFg
            fontName: root.fontFamily
            fontSize: root.fontSize

	}
	MemWidget{
	    Layout.fillHeight: true
	    accentColor: root.colPurple
            textColor: root.colFg
            fontName: root.fontFamily
            fontSize: root.fontSize
	}        
        CpuWidget {
            Layout.fillHeight: true
            accentColor: root.colOrange
            textColor: root.colFg
            fontName: root.fontFamily
            fontSize: root.fontSize
        }
	ClockWidget {
            Layout.fillHeight: true
            accentColor: root.colMuted
            textColor: root.colFg
            fontName: root.fontFamily
            fontSize: root.fontSize
        }
    }
}
