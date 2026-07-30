import Quickshell
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    // Instantiate the generated theme
    Theme { id: theme }

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 25
    color: theme.colBg

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: 10

        WorkspaceWidget {
            Layout.fillHeight: true
            accentColor: theme.colCyan
            textColor: theme.colFg
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }

        Item { Layout.fillWidth: true }
        
        MusicWidget {
            property int widget_width: 325
            Layout.preferredWidth: widget_width 
            Layout.maximumWidth: widget_width
            Layout.fillHeight: true
            accentColor: theme.colBlue
            textColor: theme.colFg
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }
        
        BluetoothWidget {
            Layout.fillHeight: true
            accentColor: theme.colBlue
            textColor: theme.colFg
            barColor: theme.barColor
            barOpacity: theme.barOpacity
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }
        
        VolumeWidget {
            Layout.fillHeight: true
            accentColor: theme.colYellow
            textColor: theme.colFg
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }
        
        IpWidget {
            Layout.fillHeight: true
            accentColor: theme.colGreen
            textColor: theme.colFg
            barColor: theme.barColor
            barOpacity: theme.barOpacity
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }
        
        MemWidget {
            Layout.fillHeight: true
            accentColor: theme.colPurple
            textColor: theme.colFg
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }        
        
        CpuWidget {
            Layout.fillHeight: true
            accentColor: theme.colOrange
            textColor: theme.colFg
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }
        
        ClockWidget {
            Layout.fillHeight: true
            accentColor: theme.colMuted
            textColor: theme.colFg
            fontName: theme.fontFamily
            fontSize: theme.fontSize
        }
    }
}
