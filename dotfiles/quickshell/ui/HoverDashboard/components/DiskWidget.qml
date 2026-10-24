import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color accent: theme.on_background
    property int iconSize: 14
    property int textSize: 13

    property string rootAvail: "--"
    property string cAvail: "--"

    implicitWidth: diskDisplay.implicitWidth
    implicitHeight: diskDisplay.implicitHeight

    Process {
        id: fetchDisk
        command: ["df", "-h", "/", "/mnt/c"]

        stdout: StdioCollector {
            onTextChanged: {
                let lines = text.trim().split("\n");
                if (lines.length >= 2) {
                    let rParts = lines[1].trim().split(/\s+/);
                    if (rParts.length >= 4) {
                        root.rootAvail = rParts[3];
                    }
                }
                if (lines.length >= 3) {
                    let cParts = lines[2].trim().split(/\s+/);
                    if (cParts.length >= 4) {
                        root.cAvail = cParts[3];
                    }
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: root.visible
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            fetchDisk.running = false
            fetchDisk.running = true
        }
    }

    Row {
        id: diskDisplay
        spacing: 6

        Text {
            text: "󰋊"
            color: root.accent
            font.family: "JetBrains Mono Nerd Font Propo"
            font.pixelSize: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.rootAvail + " / " + root.cAvail
            color: theme.on_surface_variant
            font.family: "JetBrains Mono"
            font.pixelSize: root.textSize
            font.bold: true
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
