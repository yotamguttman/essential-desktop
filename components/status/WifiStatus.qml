import QtQuick
import Quickshell.Io
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    property bool connected: false
    property int signalPercent: 0
    property string ssid: ""

    property string iconPath:
        !connected ? "../core/icons/wifi-0.svg" :
        signalPercent >= 75 ? "../core/icons/wifi-3.svg" :
        signalPercent >= 50 ? "../core/icons/wifi-2.svg" :
        signalPercent >= 25 ? "../core/icons/wifi-1.svg" :
                            "../core/icons/wifi-0.svg"

    onClicked: {
        console.log("wifi / quick settings button clicked")
    }

    Process {
        id: wifiProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()

                if (!out || out.startsWith("off|")) {
                    root.connected = false
                    root.signalPercent = 0
                    root.ssid = ""
                    return
                }

                const parts = out.split("|")
                root.signalPercent = parseInt(parts[0], 10) || 0
                root.ssid = parts.length > 1 ? parts.slice(1).join("|") : ""
                root.connected = true
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            wifiProc.exec([
                "sh", "-c",
                "nmcli -t -f IN-USE,SIGNAL,SSID dev wifi list | awk -F: '$1==\"*\"{print $2\"|\"$3; found=1} END{if(!found) print \"off|\"}'"
            ])
        }
    }

    content: Component {
        Column {
            spacing: 2
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: theme.iconSizeSmall
                height: theme.iconSizeSmall
                source: root.iconPath
                fillMode: Image.PreserveAspectFit
                smooth: true
            }
        }
    }
}