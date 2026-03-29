import QtQuick
import Quickshell.Io
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    property bool muted: false

    property string iconPath:
        muted ? "../core/icons/microphone-mute.svg"
            : "../core/icons/microphone-on.svg"

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
                    root.muted = false
                    return
                }

                root.muted = out === "yes"
            }
        }
    }

    Process {
        id: toggleProc
    }

    Timer {
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