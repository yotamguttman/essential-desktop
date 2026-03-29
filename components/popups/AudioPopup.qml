pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import "../core"

PopupWindow {
    id: root

    Theme {
        id: theme
    }

    signal clicked

    property var anchorWindow
    property int buttonSize: theme.buttonSize
    property int hoverBridge: 12
    property bool triggerHovered: false
    property bool hovered: popupHover.hovered || popupBridge.containsMouse

    Timer {
        id: closeDelay
        interval: 180
        repeat: false
    }

    visible: triggerHovered || hovered || closeDelay.running

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
    width: buttons.implicitWidth
    height: buttons.implicitHeight
    color: "transparent"

    Row {
        id: buttons
        spacing: 6
    
        Rectangle {
            id: bluetoothConnect

            property real volume: 0.5

            function clampVolume(v) {
                return Math.max(0, Math.min(1, v));
            }

            function updateVolumeFromX(xPos) {
                const local = xPos - volumeTrack.x;
                const ratio = local / volumeTrack.width;
                volume = clampVolume(ratio);
            }

            function applySystemVolume() {
                setVolumeProc.exec([
                    "wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", volume.toFixed(2)
                ]);
            }

            width: 200
            height: root.buttonSize
            radius: theme.radiusSmall
            opacity: theme.panelOpacity

            color: volumeMouse.containsMouse ? theme.bgHover : theme.bgPrimary
            border.width: theme.borderWidth
            border.color: theme.bgBorder

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            Process {
                id: getVolumeProc

                stdout: StdioCollector {
                    onStreamFinished: {
                        const out = text.trim();
                        if (!out)
                            return;

                        const parsed = parseFloat(out);
                        if (!Number.isNaN(parsed))
                            bluetoothConnect.volume = bluetoothConnect.clampVolume(parsed);
                    }
                }
            }

            Process {
                id: setVolumeProc
            }

            Timer {
                id: volumePoll
                interval: 800
                running: !volumeMouse.pressed
                repeat: true
                triggeredOnStart: true

                onTriggered: {
                    getVolumeProc.exec([
                        "sh", "-c",
                        "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"
                    ]);
                }
            }

            Rectangle {
                id: volumeTrack
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 14
                anchors.right: parent.right
                anchors.rightMargin: 14
                height: 4
                radius: 2
                color: theme.bgSecondary
            }

            Rectangle {
                anchors.left: volumeTrack.left
                anchors.verticalCenter: volumeTrack.verticalCenter
                width: volumeTrack.width * bluetoothConnect.volume
                height: volumeTrack.height
                radius: volumeTrack.radius
                color: theme.accent
            }

            Rectangle {
                id: volumeKnob
                width: 14
                height: 14
                radius: 7
                color: theme.fgPrimary
                border.width: 1
                border.color: theme.bgBorder
                x: volumeTrack.x + (volumeTrack.width * bluetoothConnect.volume) - (width / 2)
                y: (parent.height - height) / 2
            }

            MouseArea {
                id: volumeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                onPressed: function(mouse) {
                    bluetoothConnect.updateVolumeFromX(mouse.x);
                    bluetoothConnect.applySystemVolume();
                }

                onPositionChanged: function(mouse) {
                    if (pressed) {
                        bluetoothConnect.updateVolumeFromX(mouse.x);
                        bluetoothConnect.applySystemVolume();
                    }
                }

                onReleased: bluetoothConnect.applySystemVolume()
            }
        }
        
        StatusButton {
            id: micStatus

            property bool muted: false
            property string iconPath: muted
                ? "../core/icons/microphone-mute.svg"
                : "../core/icons/microphone-on.svg"

            width: root.buttonSize
            height: root.buttonSize

            onClicked: {
                toggleProc.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"])
                refreshTimer.restart()
            }

            Process {
                id: micProc

                stdout: StdioCollector {
                    onStreamFinished: {
                        const out = text.trim()

                        if (!out) {
                            micStatus.muted = false
                            return
                        }

                        micStatus.muted = out === "yes"
                    }
                }
            }

            Process {
                id: toggleProc
            }

            Timer {
                id: refreshTimer
                interval: 500
                running: true
                repeat: true
                triggeredOnStart: true

                onTriggered: {
                    micProc.exec([
                        "sh", "-c",
                        "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print ($3==\"[MUTED]\"?\"yes\":\"no\")}'"
                    ])
                }
            }

            content: Component {
                Image {
                    width: 16
                    height: 16
                    source: micStatus.iconPath
                    fillMode: Image.PreserveAspectFit
                    smooth: true
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