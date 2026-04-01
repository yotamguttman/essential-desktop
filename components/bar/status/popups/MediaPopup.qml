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
    property int maxTitleWidth: 320
    property bool triggerHovered: false
    property bool hovered: popupHover.hovered || popupBridge.containsMouse
    property bool expanded: triggerHovered || hovered || closeDelay.running
    property string mediaTitle: "No media"

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
    implicitWidth: mediaControls.implicitWidth
    implicitHeight: mediaControls.implicitHeight
    color: "transparent"

    Process {
        id: previousTrackProcess
    }

    Process {
        id: nextTrackProcess
    }

    Process {
        id: mediaMetadataProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim()
                root.mediaTitle = (out !== "" && out !== " - ") ? out : "No media"
            }
        }
    }

    Timer {
        id: mediaRefreshTimer
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            mediaMetadataProcess.exec(["sh", "-c", "playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null || true"])
        }
    }

    Item {
        id: revealClip
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.expanded ? root.implicitWidth : 0
        clip: true

        Behavior on width {
            NumberAnimation {
                duration: theme.revealDuration * 2
                easing.type: theme.revealEasing
            }
        }

        Row {
            id: mediaControls
            spacing: theme.gapM

            Rectangle {
                id: mediaLabel

                width: Math.min(mediaTitleLabel.implicitWidth, root.maxTitleWidth) + theme.paddingM * 2
                height: root.buttonSize
                radius: theme.radiusSmall

                color: theme.bgPrimary
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
                    color: mediaLabel.color
                    radius: Math.max(0, mediaLabel.radius - theme.borderWidth)
                    topLeftRadius: Math.max(0, mediaLabel.topLeftRadius - theme.borderWidth)
                    topRightRadius: Math.max(0, mediaLabel.topRightRadius - theme.borderWidth)
                    bottomLeftRadius: Math.max(0, mediaLabel.bottomLeftRadius - theme.borderWidth)
                    bottomRightRadius: Math.max(0, mediaLabel.bottomRightRadius - theme.borderWidth)
                }

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }

                Text {
                    id: mediaTitleLabel
                    anchors.centerIn: parent
                    text: root.mediaTitle
                    color: theme.fgPrimary
                    font.pixelSize: theme.textSizeS
                    elide: Text.ElideRight
                    width: Math.min(root.maxTitleWidth, implicitWidth)
                }
            }

            Row {
                id: transportControls
                spacing: 0

                StatusButton {
                    id: backButton

                    width: root.buttonSize
                    height: root.buttonSize

                    topRightRadius: 0
                    bottomRightRadius: 0

                    onClicked: {
                        previousTrackProcess.exec(["playerctl", "previous"])
                        mediaRefreshTimer.restart()
                    }

                    content: Component {
                        Image {
                            width: theme.iconSizeSmall
                            height: theme.iconSizeSmall
                            source: "../../../core/icons/media-back.svg"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            opacity: 1.0
                        }
                    }
                }

                StatusButton {
                    id: skipButton

                    width: root.buttonSize
                    height: root.buttonSize

                    topLeftRadius: 0
                    bottomLeftRadius: 0

                    onClicked: {
                        nextTrackProcess.exec(["playerctl", "next"])
                        mediaRefreshTimer.restart()
                    }

                    content: Component {
                        Image {
                            width: theme.iconSizeSmall
                            height: theme.iconSizeSmall
                            source: "../../../core/icons/media-skip.svg"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            opacity: 1.0
                        }
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
