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