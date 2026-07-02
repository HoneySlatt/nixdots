pragma Singleton

import QtQuick
import Quickshell.Io
import "services" as Services

QtObject {
    id: root

    property bool enabled: false

    readonly property var _timer: Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (Services.NiriData.monitors) {
                const monitors = Services.NiriData.monitors;
                for (let key in monitors) {
                    if (monitors[key].name === "DP-2" && monitors[key].hdr_enabled) {
                        root.enabled = true;
                        return;
                    }
                }
            }
            root.enabled = false;
        }
    }
}
