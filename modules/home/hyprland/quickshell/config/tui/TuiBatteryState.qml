pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string text: "--"
    property bool hasBattery: false

    readonly property var proc: Process {
        command: ["bash", "-c", "for d in /sys/class/power_supply/*; do [ -e \"$d/capacity\" ] || continue; [ \"$(cat \"$d/type\" 2>/dev/null)\" = Battery ] || continue; base=${d##*/}; case \"$base\" in hidpp_*|ps-controller-*) continue;; esac; cat \"$d/capacity\"; exit 0; done; echo --"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim();
                root.hasBattery = value !== "--";
                root.text = value === "--" ? "--" : value + "%";
            }
        }
    }

    readonly property var poll: Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.proc.running = true
    }
}
