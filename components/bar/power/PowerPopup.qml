pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../../core"

PopupWindow {
    id: root

    Theme {
        id: theme
    }

    property var anchorWindow
    property var powerButton
    property int buttonSize: theme.buttonSize
    property int hoverBridge: 12
    property bool triggerHovered: false
    property bool hovered: popupHover.hovered || popupBridge.containsMouse
    property bool expanded: triggerHovered || hovered || closeDelay.running

    Timer {
        id: closeDelay
        interval: 180
        repeat: false
    }

    visible: expanded || revealClip.width > 0

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
    implicitWidth: buttons.implicitWidth
    implicitHeight: buttons.implicitHeight
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

    Item {
        id: revealClip
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.expanded ? buttons.implicitWidth : 0
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: theme.revealDuration * 2
                easing.type: theme.revealEasing
            }
        }

        Row {
            id: buttons
            spacing: theme.gapM

            Rectangle {
                id: shutdownLabelContainer

                width: shutdownLabel.implicitWidth + theme.paddingM
                height: root.buttonSize

                color: theme.bgPrimary
                gradient: theme.bgBorderGradient
                border.width: theme.borderWidth
                border.color: theme.bgBorder
                opacity: theme.panelOpacity
            
                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: theme.radiusSmall
                bottomRightRadius: theme.radiusSmall
                clip: true

                Rectangle {
                    z: -1
                    anchors.fill: parent
                    anchors.margins: theme.borderWidth
                    color: shutdownLabelContainer.color
                    radius: Math.max(0, shutdownLabelContainer.radius - theme.borderWidth)
                    topLeftRadius: Math.max(0, shutdownLabelContainer.topLeftRadius - theme.borderWidth)
                    topRightRadius: Math.max(0, shutdownLabelContainer.topRightRadius - theme.borderWidth)
                    bottomLeftRadius: Math.max(0, shutdownLabelContainer.bottomLeftRadius - theme.borderWidth)
                    bottomRightRadius: Math.max(0, shutdownLabelContainer.bottomRightRadius - theme.borderWidth)
                }

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.margins: theme.borderWidth
                    width: (parent.width - (theme.borderWidth * 2)) * (root.powerButton ? root.powerButton.holdProgress : 0)
                    color: theme.urgentColor
                    opacity: 0.35
                }

                Text {
                    id: shutdownLabel

                    anchors.centerIn: parent
                    color: theme.fgPrimary
                    font.pixelSize: theme.textSizeS

                    text: "Hold to shutdown"
                }
            }

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
                        source: "../../core/icons/lock.svg"
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
                    source: "../../core/icons/logout.svg"
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
                    source: "../../core/icons/reboot.svg"
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
                    source: "../../core/icons/suspend.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
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
