import QtQuick
import Quickshell
import "../core"
import "../status"
import "../power"
import "../popups"

PanelWindow {
    id: statusbar
    property var niri

    property alias batteryItem: batteryStatus
    property alias batteryHovered: batteryStatus.hovered

    property alias wifiItem: wifiStatus
    property alias wifiHovered: wifiStatus.hovered
    
    property alias volumeItem: volumeStatus
    property alias volumeHovered: volumeStatus.hovered

    
    property alias mediaItem: mediaStatus
    property alias mediaHovered: mediaStatus.hovered

    property alias timeItem: time
    property alias timeHovered: time.hovered

    property alias powerItem: powerMenu
    property alias powerHovered: powerMenu.hovered

    Theme {
        id: theme
    }

    anchors {
        top: true
        bottom: true
        left: true
    }

    implicitWidth: 45
    color: "transparent"

    Rectangle { // Background gradient
        anchors.fill: parent

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: "#66000000"
            }
            GradientStop {
                position: 1.0
                color: "#00000000"
            }
        }
    }

    Rectangle { // Components
        id: wrapper
        anchors.fill: parent
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        anchors.leftMargin: 5
        color: "transparent"
        clip: false

        Column {
            id: topStack
            width: parent.width
            anchors.top: parent.top
            spacing: 4

            BatteryStatus {
                id: batteryStatus
            }

            WifiStatus {
                id: wifiStatus
            }

            VolumeStatus {
                id: volumeStatus
            }

            MediaStatus {
                id: mediaStatus
            }
        }

        WorkspaceIndicator {
            anchors.centerIn: parent
            niri: statusbar.niri
        }

        Column {
            id: bottomStack

            width: parent.width
            anchors.bottom: parent.bottom
            spacing: 4

            Time {
                id: time
            }

            PowerMenu {
                id: powerMenu
            }
        }
    }


    // Popups
        // Top Stack

    ComsPopup {
        id: comsPopup
        anchorWindow: statusbar
        buttonSize: wifiStatus.height
        triggerHovered: statusbar.wifiHovered

        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width + 8
        anchor.rect.y: wrapper.y + topStack.y + wifiStatus.y
    }

    BatteryPopup {
        id: batteryPopup
        anchorWindow: statusbar
        buttonSize: batteryStatus.height
        triggerHovered: statusbar.batteryHovered

        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width + 8
        anchor.rect.y: wrapper.y + topStack.y + batteryStatus.y
    }

    AudioPopup {
        id: audioPopup
        anchorWindow: statusbar
        buttonSize: volumeStatus.height
        triggerHovered: statusbar.volumeHovered

        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width + 8
        anchor.rect.y: wrapper.y + topStack.y + volumeStatus.y
    }


        // Bottom Stack

    TimePopup {
        id: timePopup
        anchorWindow: statusbar
        buttonSize: time.height
        triggerHovered: statusbar.timeHovered
    
        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width + 8
        anchor.rect.y: wrapper.y + bottomStack.y + time.y
    }

    PowerPopup {
        id: powerPopup
        anchorWindow: statusbar
        buttonSize: powerMenu.height
        triggerHovered: statusbar.powerHovered
    
        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width + 8
        anchor.rect.y: wrapper.y + bottomStack.y + powerMenu.y
    }


}


/*
    PopupWindow {
        id: batteryTestPopup
        anchor.window: statusbar
        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width + 8
        anchor.rect.y: wrapper.y + topStack.y + batteryStatus.y
        width: 140
        height: batteryStatus.height
        visible: true
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            color: "#ccff0000"
            border.width: 1
            border.color: "#ff0000"
            radius: 8
        }
    }
*/