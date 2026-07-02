pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property bool isTop: true
    readonly property string positionFile: "/home/honey/.config/quickshell/.bar-position"

    function setPosition(position) {
        if (position === "top") isTop = true;
        else if (position === "bottom") isTop = false;
    }

    function writePosition() {
        writer.position = isTop ? "top" : "bottom";
        writer.running = true;
    }

    function togglePosition() {
        isTop = !isTop;
        writePosition();
    }

    readonly property var reader: Process {
        command: ["cat", root.positionFile]
        running: true
        stdout: SplitParser {
            onRead: data => root.setPosition(data.trim())
        }
    }

    readonly property var writer: Process {
        property string position: "top"
        command: ["sh", "-c", "mkdir -p '/home/honey/.config/quickshell' && printf '%s\\n' '" + position + "' > '" + root.positionFile + "'"]
        running: false
    }
}
