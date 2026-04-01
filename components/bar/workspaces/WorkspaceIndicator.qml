pragma ComponentBehavior: Bound

import QtQuick
import "../../core"

Rectangle {
    id: root

    Theme {
        id: theme
    }


    property var niri

    radius: 12
    color: theme.bgPrimary
    opacity: theme.panelOpacity
    gradient: theme.bgBorderGradient
    border.width: 0

    Rectangle {
        z: -1
        anchors.fill: parent
        anchors.margins: theme.borderWidth
        color: root.color
        radius: Math.max(0, root.radius - theme.borderWidth)
        topLeftRadius: Math.max(0, root.topLeftRadius - theme.borderWidth)
        topRightRadius: Math.max(0, root.topRightRadius - theme.borderWidth)
        bottomLeftRadius: Math.max(0, root.bottomLeftRadius - theme.borderWidth)
        bottomRightRadius: Math.max(0, root.bottomRightRadius - theme.borderWidth)
    }

    width: 24
    height: content.height + 16

    Behavior on height {
        NumberAnimation { 
            duration: 300
            easing.type: Easing.OutExpo
            }
    }

    Column {
        id: content
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: root.niri ? root.niri.workspaces : null

            Rectangle {
                id: workspaceDot
                required property var model

                width: 10
                height: model.isActive ? 25 : 10
                radius: 100
                visible: model.index < 11

                color: model.isActive
                    ? theme.fgPrimary
                    : model.isUrgent
                        ? theme.urgentColor
                        : hover.containsMouse
                            ? theme.bgHover
                            : theme.bgSecondary

                scale: hover.containsMouse && !model.isActive ? 1.1 : 1.0

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Behavior on scale {
                    NumberAnimation { 
                        duration: 100
                        easing.type: Easing.InOutExpo
                        }
                }

                Behavior on height {
                    NumberAnimation { 
                        duration: 400
                        easing.type: Easing.OutBack
                        }
                }

                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.niri.focusWorkspaceById(workspaceDot.model.id)
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}
