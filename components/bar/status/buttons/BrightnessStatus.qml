pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    property bool popupActive: false
    property int brightnessPercent: 50
    property real iconSize: theme.iconSizeSmall

    topRightRadius: hovered || popupActive ? 0 : theme.radiusSmall
    bottomRightRadius: hovered || popupActive ? 0 : theme.radiusSmall

    property string iconPath:
        brightnessPercent < 34 ? "../../../core/icons/brightness-low.svg" :
        brightnessPercent < 67 ? "../../../core/icons/brightness-medium.svg" :
                                "../../../core/icons/brightness-high.svg"

    Process {
        id: brightnessProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                const value = parseInt(out, 10)

                if (!isNaN(value))
                    root.brightnessPercent = Math.max(0, Math.min(100, value))
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            brightnessProc.exec([
                "sh", "-c",
                "if command -v brightnessctl >/dev/null 2>&1; then brightnessctl -m | awk -F, '{gsub(/%/, \"\", $4); print int($4)}'; else dev=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1); if [ -n \"$dev\" ]; then b=$(cat /sys/class/backlight/$dev/brightness 2>/dev/null); m=$(cat /sys/class/backlight/$dev/max_brightness 2>/dev/null); if [ -n \"$b\" ] && [ -n \"$m\" ] && [ \"$m\" -gt 0 ]; then awk -v b=\"$b\" -v m=\"$m\" 'BEGIN{print int((b/m)*100)}'; fi; fi; fi"
            ])
        }
    }

    content: Component {
        Column {
            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: root.iconSize
                height: root.iconSize
                source: root.iconPath
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
    }
}