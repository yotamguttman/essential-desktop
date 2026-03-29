import QtQuick
import Quickshell.Io
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    property bool muted: false
    property int volumePercent: 0

    topRightRadius: hovered ? 0 : theme.radiusSmall
    bottomRightRadius: hovered ? 0 : theme.radiusSmall

    property string iconPath:
        muted ? "../core/icons/volume-mute.svg" :
        volumePercent >= 50 ? "../core/icons/speaker-high.svg" :
        volumePercent > 0 ? "../core/icons/speaker-low.svg" :
        "../core/icons/volume-mute.svg"

    onClicked: {
        toggleProc.exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"])
        refreshTimer.restart()
    }
    

    Process {
        id: volumeProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()

                if (!out) {
                    root.muted = false
                    root.volumePercent = 0
                    return
                }

                const parts = out.split("|")
                root.volumePercent = parseInt(parts[0], 10) || 0
                root.muted = parts[1] === "yes"
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
            volumeProc.exec([
                "sh", "-c",
                "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{vol=int($2*100); muted=($3==\"[MUTED]\"?\"yes\":\"no\"); print vol\"|\"muted}'"
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
