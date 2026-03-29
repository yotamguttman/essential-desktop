pragma ComponentBehavior: Bound

import QtQuick
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    property bool hovered: mouse.containsMouse

    width: parent.width
    height: parent.width

    color: mouse.containsMouse ? theme.bgHover : theme.bgPrimary
    border.width: theme.borderWidth
    border.color: theme.bgBorder
    radius: theme.radiusSmall
    opacity: theme.panelOpacity

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    content: Component {
        Image {
            anchors.centerIn: parent
            width: theme.iconSizeSmall
            height: theme.iconSizeSmall
            source: "../core/icons/power.svg"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }
}
