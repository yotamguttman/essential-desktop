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
    property var device: UPower.displayDevice
    property int batteryPercent: device ? Math.round(device.percentage * 100) : -1

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
    width: batteryInfo.width + theme.paddingM
    height: root.buttonSize
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: theme.bgPrimary
        opacity: theme.panelOpacity
       
        border.width: theme.borderWidth
        border.color: theme.bgBorder
       
        topRightRadius: theme.radiusSmall
        bottomRightRadius: theme.radiusSmall

        Text {
            id: batteryInfo
            anchors.centerIn: parent
            text: root.batteryPercent >= 0 ? root.batteryPercent + "%" : "--%"
            color: theme.fgPrimary
            font.pixelSize: theme.textSizeS
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