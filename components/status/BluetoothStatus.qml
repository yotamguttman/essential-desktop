import QtQuick
import Quickshell.Bluetooth
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }
    
    property string iconPath:
        !enabled ? "../core/icons/bluetooth-off.svg" :
        "../core/icons/bluetooth.svg"

    property bool enabled: Bluetooth.defaultAdapter
        ? Bluetooth.defaultAdapter.enabled
        : false

    property int connectedCount: Bluetooth.devices
        ? Bluetooth.devices.count
        : 0

    onClicked: {
        console.log("bluetooth / quick settings button clicked")
    }

    content: Component {
        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: theme.iconSizeSmall
            height: theme.iconSizeSmall
            source: root.iconPath
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: root.enabled ? 1.0 : 0.4
        }
    }
}