pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "../../../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    property bool popupActive: false
    property bool wifiEnabled: false
    property bool connected: false
    property int signalPercent: 0
    property string ssid: ""

    topRightRadius: hovered || popupActive ? 0 : theme.radiusSmall
    bottomRightRadius: hovered || popupActive ? 0 : theme.radiusSmall

    property string iconPath:
        !connected ? "../../../core/icons/wifi-0.svg" :
        signalPercent >= 75 ? "../../../core/icons/wifi-3.svg" :
        signalPercent >= 50 ? "../../../core/icons/wifi-2.svg" :
        signalPercent >= 25 ? "../../../core/icons/wifi-1.svg" :
                            "../../../core/icons/wifi-0.svg"

    

    onClicked: {
        wifiToggleProc.exec(["nmcli", "radio", "wifi", root.wifiEnabled ? "off" : "on"])
        wifiRefreshTimer.restart()
    }

    Process {
        id: wifiProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                const parts = out.split("|")

                if (!out || parts[0] !== "enabled") {
                    root.wifiEnabled = false
                    root.connected = false
                    root.signalPercent = 0
                    root.ssid = ""
                    return
                }

                root.wifiEnabled = true
                root.signalPercent = parseInt(parts[1], 10) || 0
                root.ssid = parts.length > 2 ? parts.slice(2).join("|") : ""
                root.connected = root.ssid.length > 0
            }
        }
    }

    Process {
        id: wifiToggleProc
    }

    Timer {
        id: wifiRefreshTimer
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            wifiProc.exec([
                "sh", "-c",
                "if [ \"$(nmcli -t -f WIFI general 2>/dev/null | head -1)\" != \"enabled\" ]; then echo \"disabled|0|\"; else nmcli -t -f IN-USE,SIGNAL,SSID dev wifi list 2>/dev/null | awk -F: '$1==\"*\"{print \"enabled|\"$2\"|\"$3; found=1} END{if(!found) print \"enabled|0|\"}'; fi"
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
                opacity: root.wifiEnabled ? 1.0 : 0.4
            }
        }
    }
}