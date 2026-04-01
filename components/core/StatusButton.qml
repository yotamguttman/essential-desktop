import QtQuick
import "."

Rectangle {
    id: root

    Theme {
        id: theme
    }

    property bool hovered: mouse.containsMouse
    property alias content: contentLoader.sourceComponent
    signal clicked

    width: parent.width
    height: parent.width
    radius: theme.radiusSmall
    opacity: theme.panelOpacity

    color: mouse.containsMouse ? theme.bgHover : theme.bgPrimary
    border.width: theme.borderWidth
    border.color: theme.bgBorder

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    // Animate right-side corner transitions used by status buttons with popups.
    Behavior on topRightRadius {
        NumberAnimation { duration: 120; easing.type: theme.revealEasing }
    }
    Behavior on bottomRightRadius {
        NumberAnimation { duration: 120; easing.type: theme.revealEasing }
    }


    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }

    Loader {
        id: contentLoader
        anchors.centerIn: parent
    }
}