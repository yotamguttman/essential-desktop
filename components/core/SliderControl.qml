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

    // Visual cue for hardware states such as mute. Input remains interactive.
    property bool inactive: false

    // Corner radii – override per instance as needed
    topLeftRadius: 0
    bottomLeftRadius: 0
    topRightRadius: theme.radiusSmall
    bottomRightRadius: theme.radiusSmall

    width: 200
    height: theme.buttonSize
    clip: true

    color: theme.bgPrimary
    opacity: theme.panelOpacity
    border.width: theme.borderWidth
    border.color: theme.bgBorder

    // ── internal helpers ────────────────────────────────────────────────────

    function clamp(v) {
        return Math.max(0, Math.min(1, v));
    }

    function updateFromX(xPos) {
        root.value = clamp(xPos / root.width);
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
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.width * root.value
        color: root.inactive ? theme.inactiveTrack : theme.bgSecondary
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
