import QtQuick
import "../core"

Rectangle {
    id: root

    Theme {
        id: theme
    }


    property var niri

    radius: 12
    color: theme.bgPrimary
    opacity: theme.panelOpacity
    border.width: theme.borderWidth
    border.color: theme.bgBorder

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
                    onClicked: root.niri.focusWorkspaceById(model.id)
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }
}