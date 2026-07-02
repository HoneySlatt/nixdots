pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var windowList: []
    property var workspaces: []
    property var activeWorkspace: null
    property var monitors: []

    function updateWindowList() {
        getClients.running = true;
    }

    function updateMonitors() {
        getMonitors.running = true;
    }

    function updateWorkspaces() {
        getWorkspaces.running = true;
    }

    function updateAll() {
        updateWindowList();
        updateMonitors();
        updateWorkspaces();
    }

    function dispatch(action) {
        niriDispatch.command = ["niri", "msg", "action", action];
        niriDispatch.running = true;
    }

    Component.onCompleted: {
        updateAll();
        refreshTimer.start();
    }

    Timer {
        id: refreshTimer
        interval: 1000
        repeat: true
        onTriggered: root.updateAll()
    }

    Process {
        id: getClients
        command: ["niri", "msg", "--json", "windows"]
        stdout: StdioCollector {
            id: clientsCollector
            onStreamFinished: {
                root.windowList = JSON.parse(clientsCollector.text);
            }
        }
    }

    Process {
        id: getMonitors
        command: ["niri", "msg", "--json", "outputs"]
        stdout: StdioCollector {
            id: monitorsCollector
            onStreamFinished: {
                root.monitors = JSON.parse(monitorsCollector.text);
            }
        }
    }

    Process {
        id: getWorkspaces
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            id: workspacesCollector
            onStreamFinished: {
                const wsData = JSON.parse(workspacesCollector.text);
                root.workspaces = wsData;
                for (let i = 0; i < wsData.length; i++) {
                    if (wsData[i].is_focused) {
                        root.activeWorkspace = wsData[i];
                        break;
                    }
                }
            }
        }
    }

    Process {
        id: niriDispatch
        running: false
    }
}
