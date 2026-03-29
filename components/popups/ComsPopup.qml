import QtQuick
import Quickshell
import Quickshell.Bluetooth
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

    Process {
        id: bluetoothManagerProcess
    }

    Row {
        id: buttons
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
                if (Bluetooth.defaultAdapter) {
                    Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
                }
            }

            content: Component {
                Image {
                    width: 16
                    height: 16
                    source: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled)
                        ? "../core/icons/bluetooth.svg"
                        : "../core/icons/bluetooth-off.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: (Bluetooth.defaultAdapter && Bluetooth.defaultAdapter.enabled) ? 1.0 : 0.4
                }
            }
        }

        Rectangle {
            id: bluetoothConnect

            width: bluetoothConnectLabel.width + 16
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
                font.pixelSize: theme.textSizeM
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