pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int tempC: 0
    property string hwmonPath: ""

    readonly property var findProc: Process {
        command: ["bash", "-c", "for d in /sys/class/hwmon/hwmon*/; do if [ \"$(cat \"$d/name\" 2>/dev/null)\" = \"amdgpu\" ]; then echo \"${d}temp1_input\"; exit 0; fi; done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const p = this.text.trim();
                if (p.length > 0) root.hwmonPath = p;
            }
        }
    }

    readonly property var proc: Process {
        command: ["cat", root.hwmonPath]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const v = parseInt(this.text.trim());
                if (!isNaN(v)) root.tempC = Math.round(v / 1000);
            }
        }
    }

    readonly property var poll: Timer {
        interval: 10000
        running: root.hwmonPath !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: root.proc.running = true
    }
}