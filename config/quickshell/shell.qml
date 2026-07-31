import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

PanelWindow {
    id: root

    // Instantiate the generated theme
    Theme { id: theme }

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 25
    color: theme.colBg

    property bool hasBattery: false

    Process {
        id: batteryCheck
        command: ["sh", "-c", "test -e /sys/class/power_supply/BAT0 -o -e /sys/class/power_supply/BAT1 && echo yes || echo no"]
        running: true
        stdout: SplitParser {
            onRead: data => root.hasBattery = data.trim() === "yes"
        }
    }

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

        Loader {
            id: batteryLoader
            Layout.fillHeight: true
            active: root.hasBattery
            visible: active // Prevents ghost spacing in RowLayout when inactive
            source: "BatteryWidget.qml"

            Binding { target: batteryLoader.item; property: "accentColor"; value: theme.colGreen; when: batteryLoader.status === Loader.Ready }
            Binding { target: batteryLoader.item; property: "textColor"; value: theme.colFg; when: batteryLoader.status === Loader.Ready }
            Binding { target: batteryLoader.item; property: "barColor"; value: theme.barColor; when: batteryLoader.status === Loader.Ready }
            Binding { target: batteryLoader.item; property: "barOpacity"; value: theme.barOpacity; when: batteryLoader.status === Loader.Ready }
            Binding { target: batteryLoader.item; property: "fontName"; value: theme.fontFamily; when: batteryLoader.status === Loader.Ready }
            Binding { target: batteryLoader.item; property: "fontSize"; value: theme.fontSize; when: batteryLoader.status === Loader.Ready }
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
