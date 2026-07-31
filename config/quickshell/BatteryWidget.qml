import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io

RowLayout {
    id: root

    property color accentColor: "#9ece6a"
    property color textColor: "#ffffff"
    property string fontName: "JetBrainsMono Nerd Font"
    property int fontSize: 12

    property color barColor: "#1e1e1e"
    property real barOpacity: 0.80

    property int capacity: 0
    property string status: "Discharging"
    property string timeRemaining: "Calculating..."
    property bool isCharging: status === "Charging"

    spacing: 0

    Process {
        id: batProc
        command: [
            "bash", "-c",
            "while true; do " +
            "  cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1); " +
            "  stat=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1); " +
            "  time_est=\"\"; " +
            "  if command -v acpi >/dev/null 2>&1; then " +
            "    time_est=$(acpi -b 2>/dev/null | grep -oP '\\d{2}:\\d{2}(:\\d{2})?' | head -n1); " +
            "  fi; " +
            "  if [ -z \"$time_est\" ] && command -v upower >/dev/null 2>&1; then " +
            "    bat_path=$(upower -e | grep -i bat | head -n1); " +
            "    if [ -n \"$bat_path\" ]; then " +
            "      time_est=$(upower -i \"$bat_path\" | grep -E \"time to (empty|full)\" | awk -F':' '{print $2}' | xargs); " +
            "    fi; " +
            "  fi; " +
            "  if [ -z \"$time_est\" ]; then " +
            "    en=$(cat /sys/class/power_supply/BAT*/energy_now 2>/dev/null | head -n1); " +
            "    pn=$(cat /sys/class/power_supply/BAT*/power_now 2>/dev/null | head -n1); " +
            "    ef=$(cat /sys/class/power_supply/BAT*/energy_full 2>/dev/null | head -n1); " +
            "    if [ -n \"$en\" ] && [ -n \"$pn\" ] && [ \"$pn\" -gt 0 ] 2>/dev/null; then " +
            "      if [ \"$stat\" = \"Discharging\" ]; then " +
            "        secs=$(( en * 3600 / pn )); " +
            "        time_est=$(printf \"%dh %02dm\" $((secs/3600)) $(((secs%3600)/60))); " +
            "      elif [ \"$stat\" = \"Charging\" ] && [ -n \"$ef\" ]; then " +
            "        rem=$(( ef - en )); " +
            "        if [ \"$rem\" -gt 0 ]; then " +
            "          secs=$(( rem * 3600 / pn )); " +
            "          time_est=$(printf \"%dh %02dm\" $((secs/3600)) $(((secs%3600)/60))); " +
            "        fi; " +
            "      fi; " +
            "    fi; " +
            "  fi; " +
            "  [ -z \"$time_est\" ] && time_est=\"Calculating...\"; " +
            "  echo \"${cap:-0}|${stat:-Unknown}|${time_est}\"; " +
            "  sleep 5; " +
            "done"
        ]

        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split('|');
                if (parts.length === 3) {
                    root.capacity = parseInt(parts[0]) || 0;
                    root.status = parts[1];
                    root.timeRemaining = parts[2];
                }
            }
        }

        Component.onCompleted: running = true
    }

    Text {
        text: "[ "
        color: root.accentColor
        font { family: root.fontName; pixelSize: root.fontSize }
    }

    Text {
        id: batText

        text: "BAT:" + String(root.capacity).padStart(3, ' ') + "%" + (root.isCharging ? "+" : " ")
        color: root.textColor
        font { family: root.fontName; pixelSize: root.fontSize }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
        }

        PopupWindow {
            id: batPopup
            visible: mouseArea.containsMouse

            anchor {
                item: batText
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
                    text: root.status === "Full" 
                        ? "[ Fully Charged ]" 
                        : "[ " + (root.isCharging ? "Full in: " : "Time: ") + root.timeRemaining + " ]"
                    font { family: root.fontName; pixelSize: root.fontSize }
                    color: root.textColor
                }
            }
        }
    }

    Text {
        text: " ]"
        color: root.accentColor
        font { family: root.fontName; pixelSize: root.fontSize }
    }
}
