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

    Process {
        id: lockProc
    }

    Process {
        id: logoutProc
    }

    Process {
        id: rebootProc
    }

    Process {
        id: suspendProc
    }

    Row {
        id: buttons
        spacing: 6

        StatusButton {
            id: lock

            width: root.buttonSize
            height: root.buttonSize

            onClicked: lockProc.exec(["loginctl", "lock-session"])

            content: Component {
                Image {
                    anchors.centerIn: parent
                    width: theme.iconSizeSmall
                    height: theme.iconSizeSmall
                    source: "../core/icons/lock.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }

        StatusButton {
            id: logout

            width: root.buttonSize
            height: root.buttonSize

            onClicked: logoutProc.exec(["loginctl", "logout"])

            content: Component {
                Image {
                    anchors.centerIn: parent
                    width: theme.iconSizeSmall
                    height: theme.iconSizeSmall
                    source: "../core/icons/logout.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }

        StatusButton {
            id: reboot

            width: root.buttonSize
            height: root.buttonSize

            onClicked: rebootProc.exec(["systemctl", "reboot"])

            content: Component {
                Image {
                    anchors.centerIn: parent
                    width: theme.iconSizeSmall
                    height: theme.iconSizeSmall
                    source: "../core/icons/reboot.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }

        StatusButton {
            id: suspend

            width: root.buttonSize
            height: root.buttonSize

            onClicked: suspendProc.exec(["systemctl", "suspend"])

            content: Component {
                Image {
                    anchors.centerIn: parent
                    width: theme.iconSizeSmall
                    height: theme.iconSizeSmall
                    source: "../core/icons/suspend.svg"
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