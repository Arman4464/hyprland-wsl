import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: storageRoot
    height: 40
    width: 390

    property color accent: theme.primary

    property string rootAvail: "--"
    property string rootUsedPct: "0%"
    property real rootPct: 0.0

    property string cAvail: "--"
    property string cUsedPct: "0%"
    property real cPct: 0.0

    Process {
        id: fetchDisk
        command: ["df", "-h", "/", "/mnt/c"]

        stdout: StdioCollector {
            onTextChanged: {
                let lines = text.trim().split("\n");
                if (lines.length >= 2) {
                    let rParts = lines[1].trim().split(/\s+/);
                    if (rParts.length >= 5) {
                        storageRoot.rootAvail = rParts[3];
                        storageRoot.rootUsedPct = rParts[4];
                        let p = parseInt(rParts[4]);
                        if (!isNaN(p)) storageRoot.rootPct = p / 100.0;
                    }
                }
                if (lines.length >= 3) {
                    let cParts = lines[2].trim().split(/\s+/);
                    if (cParts.length >= 5) {
                        storageRoot.cAvail = cParts[3];
                        storageRoot.cUsedPct = cParts[4];
                        let p = parseInt(cParts[4]);
                        if (!isNaN(p)) storageRoot.cPct = p / 100.0;
                    }
                }
            }
        }
    }

    Timer {
        interval: 10000
        running: storageRoot.visible
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            fetchDisk.running = false
            fetchDisk.running = true
        }
    }

    Rectangle {
        id: track
        anchors.fill: parent
        color: Qt.alpha(theme.surface, 0.4)
        border.color: Qt.alpha(theme.surface_variant, 0.4)
        border.width: 1
        radius: height / 2
        clip: true

        // Subtle background fill indicating root disk usage
        Rectangle {
            id: fillBar
            height: parent.height
            width: parent.width * Math.max(0.05, Math.min(storageRoot.rootPct, 1.0))
            color: Qt.alpha(storageRoot.accent, 0.25)
            radius: parent.radius

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: clickArea
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true

            onClicked: {
                fetchDisk.running = false
                fetchDisk.running = true
            }
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8
            z: 2

            Text {
                text: "󰋊"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 18
                color: storageRoot.accent
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "/: " + storageRoot.rootAvail + " free"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: theme.on_surface
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 6
            z: 2

            Text {
                text: "󰟀"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 14
                color: theme.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "C: " + storageRoot.cAvail + " free"
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: theme.on_surface_variant
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }
}
