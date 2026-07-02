pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string hostname: "?"
    property string icon: "\uf17c"

    readonly property var hostProc: Process {
        command: ["hostname"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const h = this.text.trim();
                if (h.length > 0) root.hostname = h;
            }
        }
    }

    readonly property var distroProc: Process {
        command: ["cat", "/etc/os-release"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const match = this.text.match(/^ID=(.*)$/m);
                const id = match ? match[1].replace(/"/g, "").toLowerCase() : "";
                const icons = {
                    "arch":        "\uf303",
                    "nixos":       "\u{f1105}",
                    "ubuntu":      "\uf31b",
                    "debian":      "\uf306",
                    "fedora":      "\uf30a",
                    "manjaro":     "\uf312",
                    "opensuse":    "\uf314",
                    "gentoo":      "\uf30d",
                    "void":        "\uf32f",
                    "alpine":      "\uf300",
                    "artix":       "\uf31f",
                    "endeavouros": "\uf322",
                    "garuda":      "\uf337",
                    "mint":        "\uf30f",
                    "pop":         "\uf32a",
                    "zorin":       "\uf33f",
                }
                root.icon = icons[id] ?? "\uf17c"
            }
        }
    }
}
