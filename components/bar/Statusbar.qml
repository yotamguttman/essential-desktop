import QtQuick
import Quickshell
import "../core"
import "./workspaces"
import "./status/buttons"
import "./time"
import "./power"
import "./status/popups"

PanelWindow {
    id: statusbar
    property var niri

    property alias batteryItem: batteryStatus
    property alias batteryHovered: batteryStatus.hovered

    property alias comsItem: comsStatus
    property alias comsHovered: comsStatus.hovered

    property alias brightnessItem: brightnessStatus
    property alias brightnessHovered: brightnessStatus.hovered
    
    property alias audioItem: audioStatus
    property alias audioHovered: audioStatus.hovered
    
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

    implicitWidth: 37
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
            spacing: theme.gapM

            BatteryStatus {
                id: batteryStatus
            }

            ComsStatus {
                id: comsStatus
            }

            BrightnessStatus {
                id: brightnessStatus
            }

            AudioStatus {
                id: audioStatus
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
            spacing: theme.gapM

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

    BatteryPopup {
        id: batteryPopup
        anchorWindow: statusbar
        buttonSize: batteryStatus.height
        triggerHovered: statusbar.batteryHovered

        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width
        anchor.rect.y: wrapper.y + topStack.y + batteryStatus.y
    }

    Binding {
        target: batteryStatus
        property: "popupActive"
        value: batteryPopup.visible
    }

    ComsPopup {
        id: comsPopup
        anchorWindow: statusbar
        buttonSize: comsStatus.height
        triggerHovered: statusbar.comsHovered

        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width
        anchor.rect.y: wrapper.y + topStack.y + comsStatus.y
    }

    Binding {
        target: comsPopup
        property: "wifiEnabled"
        value: comsStatus.wifiEnabled
    }

    Binding {
        target: comsStatus
        property: "popupActive"
        value: comsPopup.visible
    }

    BrightnessPopup {
        id: brightnessPopup
        anchorWindow: statusbar
        buttonSize: brightnessStatus.height
        triggerHovered: statusbar.brightnessHovered

        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width
        anchor.rect.y: wrapper.y + topStack.y + brightnessStatus.y
    }

    Binding {
        target: brightnessStatus
        property: "popupActive"
        value: brightnessPopup.visible
    }

    AudioPopup {
        id: audioPopup
        anchorWindow: statusbar
        buttonSize: audioStatus.height
        triggerHovered: statusbar.audioHovered

        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width
        anchor.rect.y: wrapper.y + topStack.y + audioStatus.y
    }

    Binding {
        target: audioStatus
        property: "popupActive"
        value: audioPopup.visible
    }


        // Temporary stuff
    MediaPopup {
        id: mediaPopup
        anchorWindow: statusbar
        buttonSize: mediaStatus.height
        triggerHovered: statusbar.mediaHovered
    
        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width
        anchor.rect.y: wrapper.y + topStack.y + mediaStatus.y
    }

    Binding {
        target: mediaStatus
        property: "popupActive"
        value: mediaPopup.visible
    }


        // Bottom Stack

    TimePopup {
        id: timePopup
        anchorWindow: statusbar
        buttonSize: time.height
        triggerHovered: statusbar.timeHovered
    
        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width + theme.gapM
        anchor.rect.y: wrapper.y + bottomStack.y + time.y
    }

    PowerPopup {
        id: powerPopup
        anchorWindow: statusbar
        powerButton: statusbar.powerItem
        buttonSize: powerMenu.height
        triggerHovered: statusbar.powerHovered
    
        anchor.adjustment: PopupAdjustment.None
        anchor.rect.x: statusbar.width
        anchor.rect.y: wrapper.y + bottomStack.y + powerMenu.y
    }

    Binding {
        target: powerMenu
        property: "popupActive"
        value: powerPopup.visible
    }


}