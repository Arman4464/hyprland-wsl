import QtQuick

// Desktop stub - battery not present on workstation
Row {
    id: root
    visible: false
    width: 0
    height: 0
    spacing: 0

    property color accent: theme.primary
    property color dangerAccent: theme.error
    property color warningAccent: theme.tertiary
    property color mutedAccent: theme.on_surface_variant

    readonly property bool available: false
    readonly property int percentage: 100
    readonly property bool charging: false
}
