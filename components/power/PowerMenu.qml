pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    property bool hovered: mouse.containsMouse
    property real holdProgress: 0
    property int holdDurationMs: 2200
    property bool shutdownTriggered: false

    width: parent.width
    height: parent.width

    color: mouse.containsMouse ? theme.bgHover : theme.bgPrimary
    border.width: theme.borderWidth
    border.color: theme.bgBorder
    opacity: theme.panelOpacity
    
    topRightRadius: mouse.containsMouse ? 0 : theme.radiusSmall
    bottomRightRadius: mouse.containsMouse ? 0 : theme.radiusSmall

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    Behavior on holdProgress {
        NumberAnimation {
            duration: 20
            easing.type: Easing.OutCubic
        }
    }

    Process {
        id: shutdownProc
    }

    Timer {
        id: holdTimer
        interval: 16
        repeat: true

        onTriggered: {
            if (!mouse.pressed || root.shutdownTriggered)
                return

            root.holdProgress = Math.min(1, root.holdProgress + interval / root.holdDurationMs)
            if (root.holdProgress >= 1) {
                root.shutdownTriggered = true
                stop()
                shutdownProc.exec(["systemctl", "poweroff"])
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            if (root.shutdownTriggered)
                return

            holdTimer.restart()
        }

        onReleased: {
            if (root.shutdownTriggered)
                return

            holdTimer.stop()
            root.holdProgress = 0
        }

        onCanceled: {
            if (root.shutdownTriggered)
                return

            holdTimer.stop()
            root.holdProgress = 0
        }
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
