pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int usage: 0
    property bool blinkState: false
    property var prevIdle: 0
    property var prevTotal: 0

    readonly property var blinkTimer: Timer {
        interval: 500
        running: root.usage >= 95
        repeat: true
        onTriggered: root.blinkState = !root.blinkState
        onRunningChanged: if (!running) root.blinkState = false
    }

    readonly property var proc: Process {
        command: ["cat", "/proc/stat"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.split("\n")[0].split(/\s+/);
                const idle = parseInt(parts[4]) + parseInt(parts[5]);
                let total = 0;
                for (let i = 1; i < parts.length && i <= 8; i++) total += parseInt(parts[i]);
                if (root.prevTotal > 0) {
                    const di = idle - root.prevIdle;
                    const dt = total - root.prevTotal;
                    if (dt > 0) root.usage = Math.round((1 - di / dt) * 100);
                }
                root.prevIdle = idle;
                root.prevTotal = total;
            }
        }
    }

    readonly property var poll: Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.proc.running = true
    }
}