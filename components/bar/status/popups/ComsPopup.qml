pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core"

PopupWindow {
    id: root

    Theme {
        id: theme
    }

    property var anchorWindow
    property int buttonSize: theme.buttonSize
    property int hoverBridge: 12
    property bool triggerHovered: false
    property bool hovered: popupHover.hovered || popupBridge.containsMouse
    property bool bluetoothEnabled: false

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
    width: controlsWrapper.implicitWidth + theme.borderWidth
    height: controlsWrapper.implicitHeight
    color: "transparent"

    Process {
        id: launcherProcess
    }

    Process {
        id: bluetoothManagerProcess
    }

    Process {
        id: bluetoothStatusProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.bluetoothEnabled = text.trim() === "yes"
            }
        }
    }

    Process {
        id: bluetoothToggleProcess
    }

    Timer {
        id: bluetoothRefreshTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            bluetoothStatusProcess.exec(["sh", "-c", "bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print tolower($2)}'"])
        }
    }

    Row {
        id: controlsWrapper
        spacing: theme.gapM
        
            Rectangle {
                id: launcherLabel
                

                width: launcherText.implicitWidth + theme.paddingL
                height: root.buttonSize
                radius: theme.radiusSmall

                color: launcherMouse.containsMouse ? theme.bgHover : theme.bgPrimary
                opacity: theme.panelOpacity
                border.width: theme.borderWidth
                border.color: theme.bgBorder

                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: theme.radiusSmall
                bottomRightRadius: theme.radiusSmall

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                MouseArea {
                    id: launcherMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: launcherProcess.exec(["yufi"])
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    id: launcherText
                    anchors.centerIn: parent
                    text: "Connect"
                    color: theme.fgPrimary
                    font.pixelSize: theme.textSizeS
                }
            }
            
        Row {
            id: connectivityControls
            spacing: 0

            StatusButton {
                id: bluetoothStatus

                width: root.buttonSize
                height: root.buttonSize

                topLeftRadius: theme.radiusSmall
                bottomLeftRadius: theme.radiusSmall
                topRightRadius: 0
                bottomRightRadius: 0

                onClicked: {
                    bluetoothToggleProcess.exec(["bluetoothctl", "power", root.bluetoothEnabled ? "off" : "on"])
                    bluetoothRefreshTimer.restart()
                }

                content: Component {
                    Image {
                        width: theme.iconSizeSmall
                        height: theme.iconSizeSmall
                        source: root.bluetoothEnabled
                            ? "../../../core/icons/bluetooth.svg"
                            : "../../../core/icons/bluetooth-off.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        opacity: root.bluetoothEnabled ? 1.0 : 0.4
                    }
                }
            }

            Rectangle {
                id: bluetoothConnect

                width: bluetoothConnectLabel.width + theme.paddingL
                height: root.buttonSize
                radius: theme.radiusSmall

                color: bluetoothConnectMouse.containsMouse ? theme.bgHover : theme.bgPrimary
                opacity: theme.panelOpacity
                border.width: theme.borderWidth
                border.color: theme.bgBorder

                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: theme.radiusSmall
                bottomRightRadius: theme.radiusSmall

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                MouseArea {
                    id: bluetoothConnectMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: bluetoothManagerProcess.exec(['blueman-manager'])
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    id: bluetoothConnectLabel
                    anchors.centerIn: parent
                    text: "Connect"
                    color: theme.fgPrimary
                    font.pixelSize: theme.textSizeS
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