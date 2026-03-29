pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../core"

PopupWindow {
    id: root

    Theme {
        id: theme
    }

    signal clicked

    property var anchorWindow
    property int buttonSize: theme.buttonSize
    property int hoverBridge: 12
    property bool triggerHovered: false
    property bool hovered: popupHover.hovered || popupBridge.containsMouse

    Timer {
        id: closeDelay
        interval: 180
        repeat: false
    }

    visible: triggerHovered || hovered || closeDelay.running

    onHoveredChanged: {
        if (triggerHovered || hovered) {
            closeDelay.stop();
        } else {
            closeDelay.restart();
        }
    }

    onTriggerHoveredChanged: {
        if (triggerHovered || hovered) {
            closeDelay.stop();
        } else {
            closeDelay.restart();
        }
    }


    anchor.window: root.anchorWindow
    width: buttons.implicitWidth
    height: buttons.implicitHeight
    color: "transparent"

    Row {
        id: buttons
        spacing: 6

        SliderControl {
            id: brightnessSlider
            height: root.buttonSize
            getCmd: "if command -v brightnessctl >/dev/null 2>&1; then brightnessctl -m | awk -F, '{gsub(/%/, \"\", $4); print int($4)/100}'; else dev=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1); if [ -n \"$dev\" ]; then b=$(cat /sys/class/backlight/$dev/brightness 2>/dev/null); m=$(cat /sys/class/backlight/$dev/max_brightness 2>/dev/null); if [ -n \"$b\" ] && [ -n \"$m\" ] && [ \"$m\" -gt 0 ]; then awk -v b=\"$b\" -v m=\"$m\" 'BEGIN{print b/m}'; fi; fi; fi"
            setCmd: "pct=$(awk 'BEGIN{print int($VALUE*100)}'); if command -v brightnessctl >/dev/null 2>&1; then brightnessctl set ${pct}% >/dev/null; else dev=$(ls -1 /sys/class/backlight 2>/dev/null | head -n1); [ -n \"$dev\" ] && max=$(cat /sys/class/backlight/$dev/max_brightness 2>/dev/null) && echo $(awk -v p=$pct -v m=$max 'BEGIN{print int(p/100*m)}') > /sys/class/backlight/$dev/brightness; fi"
        }

        StatusButton {
            id: themeToggle

            property bool isDark: true

            property string iconPath: isDark
                ? "../core/icons/darkmode.svg"
                : "../core/icons/lightmode.svg"

            width: root.buttonSize
            height: root.buttonSize

            onClicked: {
                themeToggle.isDark = !themeToggle.isDark
                toggleThemeProc.exec(["sh", "/home/yoti/.bin/toggle-theme.sh"])
                verifyTimer.restart()
            }

            Process {
                id: readThemeProc

                stdout: StdioCollector {
                    onStreamFinished: {
                        const out = text.trim().replace(/'/g, "")
                        themeToggle.isDark = (out === "prefer-dark")
                    }
                }
            }

            Process {
                id: toggleThemeProc
            }

            Timer {
                id: verifyTimer
                interval: 400
                repeat: false
                onTriggered: readThemeProc.exec(["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"])
            }

            Timer {
                interval: 0
                running: true
                repeat: false
                onTriggered: readThemeProc.exec(["gsettings", "get", "org.gnome.desktop.interface", "color-scheme"])
            }

            content: Component {
                Image {
                    anchors.centerIn: parent
                    width: theme.iconSizeSmall
                    height: theme.iconSizeSmall
                    source: themeToggle.iconPath
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }
    }

    HoverHandler {
        id: popupHover
    }

    MouseArea {
        id: popupBridge
        x: -root.hoverBridge
        y: 0
        width: root.hoverBridge
        height: parent.height
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}