pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool enabled: false

    readonly property var proc: Process {
        command: ["hyprctl", "monitors"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: root.enabled = this.text.includes("cm, hdr") || this.text.includes("hdr: true")
        }
    }

    readonly property var poll: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.proc.running = true
    }
}