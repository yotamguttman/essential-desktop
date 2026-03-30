import QtQuick
import Quickshell
import "components/bar"
import Niri 0.1

ShellRoot {
    Niri {
        id: niri
    }

    Timer {
        interval: 0
        running: true
        repeat: false
        onTriggered: niri.connect()
    }

    Statusbar {
        id: statusbar
        niri: niri
    }
}