import QtQuick
import Quickshell.Io
import "../core"

StatusButton {
    id: root

    Theme {
        id: theme
    }

    // "Playing", "Paused", or ""
    property string playbackState: ""
    visible: root.playbackState !== ""

    property string iconPath:
        playbackState === "Playing"
            ? "../core/icons/pause.svg"
            : "../core/icons/play.svg"

    onClicked: {
        toggleProc.exec(["playerctl", "play-pause"])
        refreshTimer.restart()
    }

    Process {
        id: statusProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                // playerctl status typically returns Playing / Paused / Stopped.
                // If no player is available, keep it empty.
                if (out === "Playing" || out === "Paused") {
                    root.playbackState = out
                } else {
                    root.playbackState = ""
                }
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
            statusProc.exec(["sh", "-c", "playerctl status 2>/dev/null || true"])
        }
    }

    content: Component {
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