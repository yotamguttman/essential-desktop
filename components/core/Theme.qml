import QtQuick

QtObject {
    property color bgPrimary: '#ba222222'
    property color bgSecondary: "#444444"
    property color bgHover: "#777777"
    property color bgBorder: '#333333'

    property color fgPrimary: "#ffffff"
    property color fgMuted: "#aaaaaa"

    property color accent: "#a5a5a5"
    property color urgentColor: "#ff6666"

    property real borderWidth: 1
    property real panelOpacity: 1;
    property real radiusSmall: 10

    // Button stuff
    property real iconSizeSmall: 16
    property real buttonSize: 45

    // Popup stuff
    property real popupMargin: 10
    property real textSizeM: 12
    property real paddingM: 24
}