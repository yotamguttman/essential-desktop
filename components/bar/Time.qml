pragma ComponentBehavior: Bound

import QtQuick
import "../core"

StatusButton {
    id: root
    
    Theme {
        id: theme
    }

    property bool hovered: timeHover.hovered
    
    content: Component {
        Item {
            width: parent.width
            height: parent.height

            Text {
                id: label
                anchors.centerIn: parent
                text: Qt.formatDateTime(new Date(), "HH:mm")
                color: theme.fgPrimary
                font.pixelSize: 11
            }

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: label.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }
    }

    HoverHandler {
        id: timeHover
    }
}