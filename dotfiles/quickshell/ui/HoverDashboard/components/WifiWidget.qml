import QtQuick
import Quickshell.Networking

Row {
    id: root
    spacing: 6

    property color accent: theme.primary

    readonly property var wifiDevice: {
        try {
            return Networking.devices ? Networking.devices.values.find(d => d.type === DeviceType.Wifi) : null
        } catch (e) {
            return null
        }
    }

    readonly property var ethernetDevice: {
        try {
            return Networking.devices ? Networking.devices.values.find(d => d.type === DeviceType.Ethernet) : null
        } catch (e) {
            return null
        }
    }

    readonly property var active: wifiDevice ? wifiDevice.networks.values.find(n => n.connected) : null
    readonly property real signal: active ? active.signalStrength : 0
    readonly property bool isEthernetConnected: (ethernetDevice && ethernetDevice.connected) || (Networking.devices && Networking.devices.values.some(d => d.connected))

    readonly property string icons: {
        if (active) {
            let tier = signal > 0.75 ? "󰤨"
            : signal > 0.50 ? "󰤥"
            : signal > 0.25 ? "󰤢"
            : "󰤠"
            return tier
        }
        if (isEthernetConnected) return "󰈀"
        return "󰤮"
    }

    Text {
        text: root.icons
        font.family: "JetBrains Mono Nerd Font Propo"
        font.pixelSize: 14
        color: root.accent
    }

    Text {
        text: {
            if (root.active) return root.active.name
            if (root.isEthernetConnected) return "ONLINE"
            return "OFFLINE"
        }

        font.family: "JetBrains Mono"
        font.pixelSize: 13
        font.bold: true
        color: theme.on_surface_variant
    }
}
