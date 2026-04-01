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
    implicitWidth: timeBody.implicitWidth
    implicitHeight: root.buttonSize
    color: "transparent"

    Process {
        id: openCalendarProcess
    }

    Item {
        id: revealClip
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.expanded ? timeBody.implicitWidth : 0
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: theme.revealDuration * 1.5
                easing.type: theme.revealEasing
            }
        }

        Rectangle {
            id: timeBody
            anchors.fill: parent
            implicitWidth: dateColumn.implicitWidth + theme.paddingL
            radius: theme.radiusSmall
            color: popupMouse.containsMouse ? theme.bgHover : theme.bgPrimary
            gradient: theme.bgBorderGradient
            border.width: theme.borderWidth
            border.color: theme.bgBorder
            opacity: theme.panelOpacity

            Rectangle {
                z: -1
                anchors.fill: parent
                anchors.margins: theme.borderWidth
                color: timeBody.color
                radius: Math.max(0, timeBody.radius - theme.borderWidth)
                topLeftRadius: Math.max(0, timeBody.topLeftRadius - theme.borderWidth)
                topRightRadius: Math.max(0, timeBody.topRightRadius - theme.borderWidth)
                bottomLeftRadius: Math.max(0, timeBody.bottomLeftRadius - theme.borderWidth)
                bottomRightRadius: Math.max(0, timeBody.bottomRightRadius - theme.borderWidth)
            }

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Column {
                id: dateColumn
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
