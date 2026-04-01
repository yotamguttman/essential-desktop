import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../../../core"

PopupWindow {
    id: root

    Theme {
        id: theme
    }

    property var anchorWindow
    property int buttonSize: theme.buttonSize
    property bool triggerHovered: false
    property int hoverBridge: 12
    property bool hovered: popupHover.hovered || popupBridge.containsMouse
    property bool expanded: triggerHovered || hovered || closeDelay.running
    property var device: UPower.displayDevice
    property int batteryPercent: device ? Math.round(device.percentage * 100) : -1

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
    implicitWidth: batteryBody.implicitWidth
    implicitHeight: root.buttonSize
    color: "transparent"

    Item {
        id: revealClip
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.expanded ? batteryBody.implicitWidth : 0
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: theme.revealDuration
                easing.type: theme.revealEasing
            }
        }

        Rectangle {
            id: batteryBody
            anchors.fill: parent
            implicitWidth: batteryInfo.implicitWidth + theme.paddingM
            color: theme.bgPrimary
            opacity: theme.panelOpacity
            gradient: theme.bgBorderGradient
            border.width: theme.borderWidth
            border.color: theme.bgBorder

            topRightRadius: theme.radiusSmall
            bottomRightRadius: theme.radiusSmall

            Rectangle {
                z: -1
                anchors.fill: parent
                anchors.margins: theme.borderWidth
                color: batteryBody.color
                radius: Math.max(0, batteryBody.radius - theme.borderWidth)
                topLeftRadius: Math.max(0, batteryBody.topLeftRadius - theme.borderWidth)
                topRightRadius: Math.max(0, batteryBody.topRightRadius - theme.borderWidth)
                bottomLeftRadius: Math.max(0, batteryBody.bottomLeftRadius - theme.borderWidth)
                bottomRightRadius: Math.max(0, batteryBody.bottomRightRadius - theme.borderWidth)
            }

            Text {
                id: batteryInfo
                anchors.centerIn: parent
                text: root.batteryPercent >= 0 ? root.batteryPercent + "%" : "--%"
                color: theme.fgPrimary
                font.pixelSize: theme.textSizeS
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
        height: root.height
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
