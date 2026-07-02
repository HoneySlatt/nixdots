pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int percentage: 0
    property bool blinkState: false

    readonly property var blinkTimer: Timer {
        interval: 500
        running: root.percentage >= 95
        repeat: true
        onTriggered: root.blinkState = !root.blinkState
        onRunningChanged: if (!running) root.blinkState = false
    }

    readonly property var proc: Process {
        command: ["cat", "/proc/meminfo"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n");
                let mt = 0, ma = 0;
                for (let i = 0; i < lines.length; i++) {
                    if (lines[i].startsWith("MemTotal:")) mt = parseInt(lines[i].split(/\s+/)[1]);
                    else if (lines[i].startsWith("MemAvailable:")) ma = parseInt(lines[i].split(/\s+/)[1]);
                }
                if (mt > 0) root.percentage = Math.round((mt - ma) / mt * 100);
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