import QtQuick
import Quickshell
import Quickshell.Services.UPower
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    onClicked: {
        console.log("battery / quick settings button clicked")
    }

    content: Component {
        Column {
            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter

            property var device: UPower.displayDevice

            property int batteryPercent: device
                ? Math.round(device.percentage * 100)
                : -1

            property bool charging: device
                ? device.state === UPower.DeviceState.Charging
                : false

            property string iconPath:
                charging ? "../core/icons/battery-charging-vertical-fill.svg" :
                batteryPercent >= 90 ? "../core/icons/battery-vertical-full-fill.svg" :
                batteryPercent >= 70 ? "../core/icons/battery-vertical-high-fill.svg" :
                batteryPercent >= 40 ? "../core/icons/battery-vertical-medium-fill.svg" :
                batteryPercent >= 15 ? "../core/icons/battery-vertical-low-fill.svg" :
                batteryPercent >= 0  ? "../core/icons/battery-vertical-empty-fill.svg" :
                "../core/icons/battery-vertical-empty-fill.svg"

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: theme.iconSizeSmall
                height: theme.iconSizeSmall
                source: iconPath
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
    }
}