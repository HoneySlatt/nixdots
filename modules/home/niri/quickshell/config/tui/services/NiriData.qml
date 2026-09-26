pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var workspaces: []
    property var activeWorkspace: null

    // Name of the output holding the focused workspace (niri outputs have no "focused" field).
    readonly property string focusedOutput: activeWorkspace ? activeWorkspace.output : ""

    // Workspaces shown in the bar, like Hyprland: those with windows or visible on an output.
    readonly property var barWorkspaces: {
        const list = (workspaces || []).filter(ws => ws.active_window_id !== null || ws.is_active);
        const key = ws => {
            const n = parseInt(ws.name);
            return isNaN(n) ? 1000 + ws.id : n;
        };
        list.sort((a, b) => key(a) - key(b));
        return list;
    }

    function updateWorkspaces() {
        refresh(getWorkspaces);
    }

    // Re-run a query, or queue one more run if it is already in flight.
    function refresh(proc) {
        if (proc.running)
            proc.pending = true;
        else
            proc.running = true;
    }

    // Accepts an argv array (["focus-workspace", "3"]) or a space-separated string.
    function dispatch(action) {
        const args = Array.isArray(action) ? action : String(action).trim().split(/\s+/);
        Quickshell.execDetached(["niri", "msg", "action"].concat(args));
    }

    function focusWorkspace(ws) {
        if (!ws)
            return;
        if (ws.name) {
            dispatch(["focus-workspace", ws.name]);
        } else if (ws.active_window_id !== null) {
            dispatch(["focus-window", "--id", String(ws.active_window_id)]);
        } else {
            Quickshell.execDetached(["sh", "-c", "niri msg action focus-monitor \"$1\" && niri msg action focus-workspace \"$2\"", "sh", ws.output, String(ws.idx)]);
        }
    }

    function focusWorkspaceByName(name) {
        dispatch(["focus-workspace", String(name)]);
    }

    // Next/previous workspace in bar order, across outputs (Hyprland "e+1" / "e-1").
    function focusRelative(delta) {
        const list = barWorkspaces;
        if (!activeWorkspace || list.length === 0)
            return;
        const i = list.findIndex(ws => ws.id === activeWorkspace.id);
        const target = list[i + delta];
        if (i >= 0 && target)
            focusWorkspace(target);
    }

    Component.onCompleted: updateWorkspaces()

    // Refresh on every compositor event instead of polling.
    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: true
        stdout: SplitParser {
            onRead: debounce.restart()
        }
        onExited: restartStream.start()
    }

    Timer {
        id: restartStream
        interval: 1000
        onTriggered: eventStream.running = true
    }

    Timer {
        id: debounce
        interval: 30
        onTriggered: root.updateWorkspaces()
    }

    Process {
        id: getWorkspaces
        property bool pending: false
        command: ["niri", "msg", "--json", "workspaces"]
        stdout: StdioCollector {
            id: workspacesCollector
            onStreamFinished: {
                const wsData = JSON.parse(workspacesCollector.text);
                root.workspaces = wsData;
                root.activeWorkspace = wsData.find(ws => ws.is_focused) || null;
            }
        }
        onExited: if (pending) { pending = false; running = true; }
    }
}
