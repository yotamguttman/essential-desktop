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
        spacing: theme.gapM
    
        SliderControl {
            id: volumeSlider

            height: root.buttonSize
            getCmd: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"
            setCmd: "wpctl set-volume @DEFAULT_AUDIO_SINK@ $VALUE"
        }

        Row {
            id: micControls

            StatusButton {
                id: micStatus

                property bool muted: false
                property string iconPath: muted
                    ? "../core/icons/microphone-mute.svg"
                    : "../core/icons/microphone-on.svg"

                width: root.buttonSize
                height: root.buttonSize

                topRightRadius: 0
                bottomRightRadius: 0

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

            SliderControl {
                id: micVolumeSlider

                height: root.buttonSize
                width: 160
                getCmd: "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2}'"
                setCmd: "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ $VALUE"
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