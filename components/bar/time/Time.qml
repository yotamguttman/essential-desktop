pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../core"

StatusButton {
    id: root
    height: parent.width * 1.5

    onClicked: {
        launchClockProc.exec(["gnome-clocks"])
    }
    
    Theme {
        id: theme
    }

    property bool hovered: timeHover.hovered

    Process {
        id: launchClockProc
    }
    
    content: Component {
        Column {
            anchors.centerIn: parent
            spacing: 0

            Text {
                id: hour
                text: Qt.formatDateTime(new Date(), "HH")
                color: theme.fgPrimary
                font.pixelSize: theme.fontS
            }

            Text {
                id: minute
                text: Qt.formatDateTime(new Date(), "mm")
                color: theme.fgPrimary
                font.pixelSize: theme.fontS
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: {
                    hour.text = Qt.formatDateTime(new Date(), "HH")
                    minute.text = Qt.formatDateTime(new Date(), "mm")
                }
            }
        }
    }

    HoverHandler {
        id: timeHover
    }
}