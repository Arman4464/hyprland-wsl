import QtQuick
import Quickshell.Io

Rectangle {
    id: toggleRoot
    width: 120
    height: 40
    radius: height / 2

    property color accent: theme.primary
    property bool isHovered: toggleMouseArea.containsMouse

    color: isHovered ? Qt.alpha(theme.error, 0.25) : Qt.alpha(theme.surface, 0.4)
    border.color: isHovered ? theme.error : Qt.alpha(theme.surface_variant, 0.4)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 150 } }
    Behavior on border.color { ColorAnimation { duration: 150 } }

    Process {
        id: powerProc
    }

    MouseArea {
        id: toggleMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true

        onClicked: {
            powerProc.exec(["qs", "ipc", "call", "pill", "setState", "powermenu"])
        }
    }

    Text {
        anchors.centerIn: parent
        text: "󰐥  Power"

        color: toggleRoot.isHovered ? theme.error : theme.on_surface_variant
        font.pixelSize: 13
        font.weight: Font.DemiBold
        font.letterSpacing: 0.3

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
