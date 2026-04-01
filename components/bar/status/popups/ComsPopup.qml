pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../../../core"

PopupWindow {
    id: root

    Theme {
        id: theme
    }

    property var anchorWindow
    property int buttonSize: theme.buttonSize
    property int hoverBridge: 12
    property bool triggerHovered: false
    property bool hovered: popupHover.hovered || popupBridge.containsMouse
    property bool expanded: triggerHovered || hovered || closeDelay.running
    property bool wifiEnabled: false
    property bool bluetoothEnabled: false
    property string connectedBluetoothDevice: "disconnected"
    property string connectedNetwork: "disconnected"

    Timer {
        id: closeDelay
        interval: 180
        repeat: false
    }

    visible: expanded || revealClip.width > 0

    onHoveredChanged: {
        if (triggerHovered || hovered) {
            closeDelay.stop();
        } else {
            closeDelay.restart();
        }
    }

    onTriggerHoveredChanged: {
        if (triggerHovered || hovered) {
            closeDelay.stop();
        } else {
            closeDelay.restart();
        }
    }


    anchor.window: root.anchorWindow
    implicitWidth: controlsWrapper.implicitWidth
    implicitHeight: controlsWrapper.implicitHeight
    color: "transparent"

    Process {
        id: launcherProcess
    }

    Process {
        id: bluetoothManagerProcess
    }

    Process {
        id: bluetoothStatusProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.bluetoothEnabled = text.trim() === "yes"
            }
        }
    }

    Process {
        id: bluetoothToggleProcess
    }

    Process {
        id: bluetoothDeviceProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                root.connectedBluetoothDevice = out.length > 0 ? out : "disconnected"
            }
        }
    }

    Process {
        id: wifiStatusProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                root.connectedNetwork = out.length > 0 ? out : "disconnected"
            }
        }
    }

    Timer {
        id: bluetoothRefreshTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            bluetoothStatusProcess.exec(["sh", "-c", "bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/ {print tolower($2)}'"])
            bluetoothDeviceProcess.exec(["sh", "-c", "bluetoothctl devices Connected 2>/dev/null | head -1 | cut -d ' ' -f 3-"])
            wifiStatusProcess.exec(["sh", "-c", "nmcli -t -f ACTIVE,SSID dev wifi 2>/dev/null | awk -F: '$1 == \"yes\" { print $2; exit }'"])
        }
    }

    Item {
        id: revealClip
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.expanded ? controlsWrapper.implicitWidth : 0
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: theme.revealDuration * 3
                easing.type: theme.revealEasing
            }
        }

        Row {
            id: controlsWrapper
            spacing: theme.gapM

            Rectangle {
                id: wifiLabel


                width: wifiLabelText.implicitWidth + theme.iconSizeSmall + theme.gapS + (theme.paddingL * 2)
                height: root.buttonSize
                radius: theme.radiusSmall

                color: launcherMouse.containsMouse ? theme.bgHover : theme.bgPrimary
                opacity: theme.panelOpacity
                gradient: theme.bgBorderGradient
                border.width: theme.borderWidth
                border.color: theme.bgBorder

                topLeftRadius: 0
                bottomLeftRadius: 0
                topRightRadius: theme.radiusSmall
                bottomRightRadius: theme.radiusSmall

                Rectangle {
                    z: -1
                    anchors.fill: parent
                    anchors.margins: theme.borderWidth
                    color: wifiLabel.color
                    radius: Math.max(0, wifiLabel.radius - theme.borderWidth)
                    topLeftRadius: Math.max(0, wifiLabel.topLeftRadius - theme.borderWidth)
                    topRightRadius: Math.max(0, wifiLabel.topRightRadius - theme.borderWidth)
                    bottomLeftRadius: Math.max(0, wifiLabel.bottomLeftRadius - theme.borderWidth)
                    bottomRightRadius: Math.max(0, wifiLabel.bottomRightRadius - theme.borderWidth)
                }

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                MouseArea {
                    id: launcherMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: launcherProcess.exec(["yufi"])
                    cursorShape: Qt.PointingHandCursor
                }

                Text {
                    id: wifiLabelText
                    anchors.left: parent.left
                    anchors.leftMargin: theme.paddingL
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.connectedNetwork
                    color: theme.fgPrimary
                    font.pixelSize: theme.textSizeS
                }

                Image {
                    width: theme.iconSizeSmall
                    height: theme.iconSizeSmall
                    anchors.right: wifiLabel.right
                    anchors.rightMargin: theme.paddingS
                    anchors.verticalCenter: parent.verticalCenter
                    source: "../../../core/icons/settings.svg"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    opacity: root.wifiEnabled ? 1.0 : 0.4
                }
            }
            
            Row {
                id: bluetoothControls
                spacing: 0

                StatusButton {
                    id: bluetoothStatus

                    width: root.buttonSize
                    height: root.buttonSize

                    topLeftRadius: theme.radiusSmall
                    bottomLeftRadius: theme.radiusSmall
                    topRightRadius: 0
                    bottomRightRadius: 0

                    onClicked: {
                        bluetoothToggleProcess.exec(["bluetoothctl", "power", root.bluetoothEnabled ? "off" : "on"])
                        bluetoothRefreshTimer.restart()
                    }

                    content: Component {
                        Image {
                            width: theme.iconSizeSmall
                            height: theme.iconSizeSmall
                            source: root.bluetoothEnabled
                                ? "../../../core/icons/bluetooth.svg"
                                : "../../../core/icons/bluetooth-off.svg"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            opacity: root.bluetoothEnabled ? 1.0 : 0.4
                        }
                    }
                }

                Rectangle {
                    id: bluetoothConnect

                    width: bluetoothConnectLabel.implicitWidth + theme.iconSizeSmall + theme.gapS + (theme.paddingL * 2)
                    height: root.buttonSize
                    radius: theme.radiusSmall

                    color: bluetoothConnectMouse.containsMouse ? theme.bgHover : theme.bgPrimary
                    opacity: theme.panelOpacity
                    gradient: theme.bgBorderGradient
                    border.width: theme.borderWidth
                    border.color: theme.bgBorder

                    topLeftRadius: 0
                    bottomLeftRadius: 0
                    topRightRadius: theme.radiusSmall
                    bottomRightRadius: theme.radiusSmall

                    Rectangle {
                        z: -1
                        anchors.fill: parent
                        anchors.margins: theme.borderWidth
                        color: bluetoothConnect.color
                        radius: Math.max(0, bluetoothConnect.radius - theme.borderWidth)
                        topLeftRadius: Math.max(0, bluetoothConnect.topLeftRadius - theme.borderWidth)
                        topRightRadius: Math.max(0, bluetoothConnect.topRightRadius - theme.borderWidth)
                        bottomLeftRadius: Math.max(0, bluetoothConnect.bottomLeftRadius - theme.borderWidth)
                        bottomRightRadius: Math.max(0, bluetoothConnect.bottomRightRadius - theme.borderWidth)
                    }

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }

                    MouseArea {
                        id: bluetoothConnectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: bluetoothManagerProcess.exec(['blueman-manager'])
                        cursorShape: Qt.PointingHandCursor
                    }

                    Text {
                        id: bluetoothConnectLabel
                        anchors.left: parent.left
                        anchors.leftMargin: theme.paddingL
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.connectedBluetoothDevice
                        color: theme.fgPrimary
                        font.pixelSize: theme.textSizeS
                    }

                    Image {
                        width: theme.iconSizeSmall
                        height: theme.iconSizeSmall
                        anchors.right: parent.right
                        anchors.rightMargin: theme.paddingS
                        anchors.verticalCenter: parent.verticalCenter
                        source: "../../../core/icons/settings.svg"
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        opacity: root.bluetoothEnabled ? 1.0 : 0.4
                    }
                }
            }
        }
    }

    HoverHandler {
        id: popupHover
    }

    MouseArea {
        id: popupBridge
        x: -root.hoverBridge
        y: 0
        width: root.hoverBridge
        height: parent.height
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }
}
