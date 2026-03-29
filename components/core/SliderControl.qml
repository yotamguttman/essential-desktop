pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import "."

Rectangle {
    id: root

    Theme {
        id: theme
    }

    // The current value, 0.0–1.0. Can be set externally to initialise.
    property real value: 0.5

    // Shell command that prints the current value as a number in [0,1].
    property string getCmd: ""

    // Shell command that applies the value. Use the placeholder "$VALUE"
    // which will be replaced with the actual 0.0–1.0 floating-point string.
    // e.g. "wpctl set-volume @DEFAULT_AUDIO_SINK@ $VALUE"
    property string setCmd: ""

    // Corner radii – override per instance as needed
    topLeftRadius: 0
    bottomLeftRadius: 0
    topRightRadius: theme.radiusSmall
    bottomRightRadius: theme.radiusSmall

    width: 200
    height: theme.buttonSize

    color: sliderMouse.containsMouse ? theme.bgHover : theme.bgPrimary
    opacity: theme.panelOpacity
    border.width: theme.borderWidth
    border.color: theme.bgBorder

    Behavior on color {
        ColorAnimation { duration: 120 }
    }

    // ── internal helpers ────────────────────────────────────────────────────

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    function updateFromX(xPos) {
        const local = xPos - sliderTrack.x;
        root.value = clamp(local / sliderTrack.width);
    }

    function applyValue() {
        if (root.setCmd === "")
            return;
        const cmd = root.setCmd.replace(/\$VALUE/g, root.value.toFixed(2));
        setProc.exec(["sh", "-c", cmd]);
    }

    // ── processes ───────────────────────────────────────────────────────────

    Process {
        id: getProc

        stdout: StdioCollector {
            onStreamFinished: {
                const out = text.trim();
                const parsed = parseFloat(out);
                if (!Number.isNaN(parsed))
                    root.value = root.clamp(parsed);
            }
        }
    }

    Process {
        id: setProc
    }

    // ── poll ────────────────────────────────────────────────────────────────

    Timer {
        id: pollTimer
        interval: 800
        running: !sliderMouse.pressed && root.getCmd !== ""
        repeat: true
        triggeredOnStart: true

        onTriggered: getProc.exec(["sh", "-c", root.getCmd])
    }

    // ── visuals ─────────────────────────────────────────────────────────────

    Rectangle {
        id: sliderTrack
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
        anchors.left: sliderTrack.left
        anchors.verticalCenter: sliderTrack.verticalCenter
        width: sliderTrack.width * root.value
        height: sliderTrack.height
        radius: sliderTrack.radius
        color: theme.accent
    }

    Rectangle {
        id: sliderKnob
        width: 14
        height: 14
        radius: 7
        color: theme.fgPrimary
        border.width: 1
        border.color: theme.bgBorder
        x: sliderTrack.x + (sliderTrack.width * root.value) - (width / 2)
        y: (parent.height - height) / 2
    }

    MouseArea {
        id: sliderMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPressed: function(mouse) {
            root.updateFromX(mouse.x);
            root.applyValue();
        }

        onPositionChanged: function(mouse) {
            if (pressed) {
                root.updateFromX(mouse.x);
                root.applyValue();
            }
        }

        onReleased: root.applyValue()
    }
}
