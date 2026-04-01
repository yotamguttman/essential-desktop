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

    // Inset for the inner fill so the slider looks nested inside its container.
    property real fillInset: 4

    // Corner radii – override per instance as needed

    width: 200
    height: theme.buttonSize
    clip: true

    topLeftRadius: 0
    bottomLeftRadius: 0
    topRightRadius: theme.radiusSmall
    bottomRightRadius: theme.radiusSmall
    border.width: theme.borderWidth
    border.color: theme.bgBorder

    color: theme.bgPrimary
    opacity: theme.panelOpacity
    gradient: theme.bgBorderGradient

    Rectangle {
        id: background
        z: -1
        anchors.fill: parent
        anchors.margins: theme.borderWidth
        color: root.color
        radius: Math.max(0, root.radius - theme.borderWidth)
        topLeftRadius: Math.max(0, root.topLeftRadius - theme.borderWidth)
        topRightRadius: Math.max(0, root.topRightRadius - theme.borderWidth)
        bottomLeftRadius: Math.max(0, root.bottomLeftRadius - theme.borderWidth)
        bottomRightRadius: Math.max(0, root.bottomRightRadius - theme.borderWidth)
    }

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
        anchors.left: background.left
        anchors.top: background.top
        anchors.bottom: background.bottom
        anchors.leftMargin: root.fillInset
        anchors.topMargin: root.fillInset
        anchors.bottomMargin: root.fillInset
        width: Math.max(0, (background.width - (root.fillInset * 2)) * root.value)
        color: root.inactive ? theme.inactiveTrack : theme.bgSecondary

        Behavior on color {
            ColorAnimation { duration: 200 }
        }

        topRightRadius: Math.max(0, background.topRightRadius - root.fillInset)
        bottomRightRadius: Math.max(0, background.bottomRightRadius - root.fillInset)
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
