import QtQuick
import Quickshell.Networking

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    signal requestSubView(string viewName)

    property color accent: theme.primary

    readonly property bool isOnline: {
        try {
            return Networking.wifiEnabled || (Networking.devices ? Networking.devices.values.some(d => d.connected) : false)
        } catch (e) {
            return false
        }
    }

    color: isOnline ? accent : Qt.alpha(theme.surface, 0.4)
    border.color: isOnline ? accent : Qt.alpha(theme.surface_variant, 0.4)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    MouseArea {
        id: toggleMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: (mouse) => {
            if (mouse.button === Qt.RightButton) {
                toggleRoot.requestSubView("wifi_expanded")
            } else {
                try {
                    Networking.wifiEnabled = !Networking.wifiEnabled
                } catch (e) {}
            }
        }

        onDoubleClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                toggleRoot.requestSubView("wifi_expanded")
            }
        }
    }

    Text {
        anchors.centerIn: parent
        text: toggleRoot.isOnline ? "󰈀  Online" : "󰤭  Offline"
        color: toggleRoot.isOnline ? theme.on_primary : theme.on_surface_variant
        font.pixelSize: 13
        font.weight: toggleRoot.isOnline ? Font.DemiBold : Font.Normal
        font.letterSpacing: 0.3
    }
}
