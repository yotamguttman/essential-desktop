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
    property bool sinkMuted: false

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
    width: controls.implicitWidth + theme.borderWidth
    height: controls.implicitHeight
    color: "transparent"

    Process {
        id: sinkMuteProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                root.sinkMuted = out === "yes"
            }
        }
    }

    Timer {
        id: sinkRefreshTimer
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            sinkMuteProc.exec([
                "sh", "-c",
                "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print ($3==\"[MUTED]\"?\"yes\":\"no\")}'"
            ])
        }
    }

    Row {
        id: controls
        spacing: theme.gapM
    
        SliderControl {
            id: speakerVolumeSlider

            height: root.buttonSize
            inactive: root.sinkMuted
            getCmd: "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}'"
            setCmd: "wpctl set-volume @DEFAULT_AUDIO_SINK@ $VALUE"
        }

        Row {
            id: micControls

            StatusButton {
                id: micStatus

                property bool muted: false
                property string iconPath: muted
                    ? "../../../core/icons/microphone-mute.svg"
                    : "../../../core/icons/microphone-on.svg"

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
                        width: theme.iconSizeSmall
                        height: theme.iconSizeSmall
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
                inactive: micStatus.muted
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