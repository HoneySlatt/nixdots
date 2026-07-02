pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var processes: []
    property var cpuHistory: []
    property var gpuHistory: []
    property var ramHistory: []

    function pushHistory(list, value) {
        let next = list.slice();
        next.push(Math.max(0, Math.min(100, value)));
        while (next.length > 28) next.shift();
        return next;
    }

    function refresh() {
        root.cpuHistory = pushHistory(root.cpuHistory, TuiCpuState.usage);
        root.gpuHistory = pushHistory(root.gpuHistory, TuiGpuState.tempC);
        root.ramHistory = pushHistory(root.ramHistory, TuiRamState.percentage);
        root.processProc.running = true;
    }

    function killProcess(pid) {
        let processId = parseInt(pid);
        if (isNaN(processId) || processId <= 0) return;
        root.killProc.command = ["kill", String(processId)];
        root.killProc.running = true;
    }

    readonly property var processProc: Process {
        command: ["ps", "-eo", "pid=,comm=,pcpu=,pmem=", "--sort=-pcpu"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let rows = [];
                let lines = this.text.trim().split("\n");
                for (let i = 0; i < lines.length && rows.length < 80; i++) {
                    let parts = lines[i].trim().split(/\s+/);
                    if (parts.length < 4) continue;
                    rows.push({
                        pid: parseInt(parts[0]),
                        name: parts[1],
                        cpu: parseFloat(parts[2]).toFixed(1),
                        mem: parseFloat(parts[3]).toFixed(1)
                    });
                }
                root.processes = rows;
            }
        }
    }

    readonly property var killProc: Process {
        command: ["true"]
        running: false
        onExited: root.refresh()
    }

    readonly property var poll: Timer {
        interval: 2000
        running: TuiSystemMonitorPopupState.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
