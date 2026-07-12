import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // Base Colors & Typography
    property color colBg: "#80000000"
    property color colFg: "#ffffff"
    property color colMuted: "#565f89"   // dim/inactive text, separators, secondary info
    property color colBlue: "#7aa2f7"    // neutral info — media, workspace focus, generic accents
    property color colCyan: "#7dcfff"    // network/wifi, connectivity
    property color colGreen: "#40eb34"   // good state — battery ok, connected, low load
    property color colYellow: "#e0af68"  // caution — moderate CPU/mem, medium battery
    property color colOrange: "#ff9e64"  // elevated warning, between yellow and red
    property color colRed: "#f7768e"     // critical — low battery, high temp/CPU, disconnected
    property color colPurple: "#bb9af7"  // reserved for something distinct — maybe a "now playing" glyph
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 12 

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

        // 2. Spacer (Pushes remaining items to the right)
        Item { 
            Layout.fillWidth: true 
        }
        

        // 3. Music Player (Aligned Right)
	MusicWidget {
	    property int widget_width: 300
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
        // 4. CPU Monitor (Aligned Far Right)
        CpuWidget {
            Layout.fillHeight: true
            accentColor: root.colYellow
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
