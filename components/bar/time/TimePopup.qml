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
    property int buttonSize: theme.buttonSize
    property bool triggerHovered: false
    property int hoverBridge: 12
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
    width: dateLabel.width + theme.paddingL
    height: root.buttonSize
    color: "transparent"

    Process {
        id: openCalendarProcess
    }

    Rectangle {
        anchors.fill: parent
        radius: theme.radiusSmall
        color: popupMouse.containsMouse ? theme.bgHover : theme.bgPrimary
        border.width: theme.borderWidth
        border.color: theme.bgBorder
        opacity: theme.panelOpacity

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        Column {
            anchors.centerIn: parent
            spacing: theme.gapS
            
            Text {
                id: dateLabel
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(new Date(), "dddd dd")
                color: theme.fgPrimary
                font.pixelSize: theme.textSizeL
                horizontalAlignment: Text.AlignHCenter
            }

            Text {
                id: dateLabelone
                anchors.horizontalCenter: parent.horizontalCenter
                text: Qt.formatDateTime(new Date(), "MMMM yyyy")
                color: theme.fgPrimary
                font.pixelSize: theme.textSizeS
                horizontalAlignment: Text.AlignHCenter
            }
        }


        Timer {
            interval: 60000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: dateLabel.text = Qt.formatDateTime(new Date(), "dddd dd")
        }

        MouseArea {
            id: popupMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: openCalendarProcess.exec(["gnome-calendar"])
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