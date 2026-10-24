import QtQuick

// Desktop stub - backlight controls not present on workstation
Item {
    id: root

    property var stateEngine
    property real currentBrightness: 1.0
    property bool bootGuard: false

    function setBrightness(percent: real) {
        // No-op on desktop workstation
    }
}
