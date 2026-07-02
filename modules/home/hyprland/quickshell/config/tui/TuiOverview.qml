import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: scope

    property var clients: []
    property var workspaces: []
    property int activeWorkspaceId: Hyprland.focusedMonitor?.activeWorkspace?.id ?? 1
    property int selectedWorkspaceId: activeWorkspaceId
    property bool syncSelectionWithActive: true

    readonly property int columns: 5
    readonly property int rows: 2
    readonly property int workspaceCount: columns * rows
    readonly property int groupBase: Math.floor((activeWorkspaceId - 1) / workspaceCount) * workspaceCount + 1

    function refresh(syncSelection) {
        if (syncSelection) syncSelectionWithActive = true;
        if (!clientsProc.running) clientsProc.running = true;
        if (!workspacesProc.running) workspacesProc.running = true;
        if (!activeProc.running) activeProc.running = true;
    }

    function workspaceIdAt(index) {
        return groupBase + index;
    }

    function workspaceClients(workspaceId) {
        return clients.filter(client => client.workspace?.id === workspaceId);
    }

    function workspaceExists(workspaceId) {
        for (let i = 0; i < workspaces.length; i++) {
            if (workspaces[i].id === workspaceId) return true;
        }
        return workspaceId === activeWorkspaceId;
    }

    function moveSelection(delta) {
        let current = selectedWorkspaceId - groupBase;
        current = Math.max(0, Math.min(workspaceCount - 1, current + delta));
        selectedWorkspaceId = groupBase + current;
    }

    function switchToSelected() {
        if (Hyprland.usingLua) {
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + selectedWorkspaceId + " })");
        } else {
            Hyprland.dispatch("workspace " + selectedWorkspaceId);
        }
        TuiOverviewState.close();
    }

    Timer {
        id: refreshTimer
        interval: 80
        repeat: false
        onTriggered: scope.refresh(false)
    }

    Process {
        id: clientsProc
        command: ["hyprctl", "clients", "-j"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try { scope.clients = JSON.parse(this.text); }
                catch (e) { scope.clients = []; }
            }
        }
    }

    Process {
        id: workspacesProc
        command: ["hyprctl", "workspaces", "-j"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try { scope.workspaces = JSON.parse(this.text); }
                catch (e) { scope.workspaces = []; }
            }
        }
    }

    Process {
        id: activeProc
        command: ["hyprctl", "activeworkspace", "-j"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let ws = JSON.parse(this.text);
                    scope.activeWorkspaceId = ws.id ?? scope.activeWorkspaceId;
                    if (scope.syncSelectionWithActive
                        || scope.selectedWorkspaceId < scope.groupBase
                        || scope.selectedWorkspaceId >= scope.groupBase + scope.workspaceCount) {
                        scope.selectedWorkspaceId = scope.activeWorkspaceId;
                    }
                    scope.syncSelectionWithActive = false;
                } catch (e) {}
            }
        }
    }

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (TuiOverviewState.visible) refreshTimer.restart();
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiOverviewState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            readonly property bool monitorIsFocused: Hyprland.focusedMonitor?.id === monitor?.id

            color: "transparent"

            WlrLayershell.namespace: "quickshell:tui:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            Component.onCompleted: {
                if (TuiOverviewState.visible) {
                    scope.refresh(true);
                    grabTimer.start();
                    focusTimer.start();
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => {
                    if (!active) TuiOverviewState.close();
                }
                onActiveChanged: if (active) focusTimer.start()
            }

            Connections {
                target: TuiOverviewState
                function onVisibleChanged() {
                    if (TuiOverviewState.visible) {
                        scope.refresh(true);
                        grabTimer.start();
                        focusTimer.start();
                    } else {
                        grabTimer.stop();
                        focusTimer.stop();
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: grabTimer
                interval: 50
                repeat: false
                onTriggered: grab.active = TuiOverviewState.visible
            }

            Timer {
                id: focusTimer
                interval: 80
                repeat: false
                onTriggered: panel.forceActiveFocus()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: TuiOverviewState.close()
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: 940
                height: 300
                color: TuiTheme.bg
                border.color: TuiTheme.accent
                border.width: 2
                focus: TuiOverviewState.visible

                MouseArea { anchors.fill: parent; onClicked: panel.forceActiveFocus() }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        TuiOverviewState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        scope.switchToSelected();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                        scope.moveSelection(-1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                        scope.moveSelection(1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
                        scope.moveSelection(-scope.columns);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
                        scope.moveSelection(scope.columns);
                        event.accepted = true;
                        return;
                    }
                    if (event.key >= Qt.Key_1 && event.key <= Qt.Key_9) {
                        scope.selectedWorkspaceId = scope.groupBase + (event.key - Qt.Key_1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_0) {
                        scope.selectedWorkspaceId = scope.groupBase + 9;
                        event.accepted = true;
                    }
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8

                    Row {
                        width: parent.width
                        height: 20
                        spacing: 0

                        Text {
                            text: "overview"
                            color: TuiTheme.accent
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Grid {
                        columns: scope.columns
                        rows: scope.rows
                        columnSpacing: 8
                        rowSpacing: 8

                        Repeater {
                            model: scope.workspaceCount

                            delegate: Rectangle {
                                id: wsCell

                                required property int index

                                readonly property int workspaceId: scope.workspaceIdAt(index)
                                readonly property bool active: workspaceId === scope.activeWorkspaceId
                                readonly property bool selected: workspaceId === scope.selectedWorkspaceId
                                readonly property bool populated: scope.workspaceExists(workspaceId)
                                readonly property var wins: scope.workspaceClients(workspaceId)

                                width: 175
                                height: 108
                                color: selected ? TuiTheme.accent : "transparent"
                                border.color: active ? TuiTheme.bright : (populated ? TuiTheme.dim : TuiTheme.bg)
                                border.width: active ? 2 : 1

                                Column {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 4

                                    Row {
                                        width: parent.width
                                        spacing: 4

                                        Text {
                                            text: (wsCell.active ? "*" : " ") + String(wsCell.workspaceId).padStart(2, "0")
                                            color: wsCell.selected ? TuiTheme.bg : (wsCell.active ? TuiTheme.bright : TuiTheme.fg)
                                            font.family: TuiTheme.fontFamily
                                            font.pixelSize: TuiTheme.fontSize
                                            font.weight: TuiTheme.fontWeight
                                        }
                                        Text {
                                            text: "[" + wsCell.wins.length + "]"
                                            color: wsCell.selected ? TuiTheme.bg : TuiTheme.dim
                                            font.family: TuiTheme.fontFamily
                                            font.pixelSize: TuiTheme.fontSize
                                            font.weight: TuiTheme.fontWeight
                                        }
                                    }

                                    Rectangle {
                                        width: parent.width
                                        height: 1
                                        color: wsCell.selected ? TuiTheme.bg : TuiTheme.dim
                                    }

                                    Repeater {
                                        model: wsCell.wins.slice(0, 3)

                                        delegate: Text {
                                            required property var modelData
                                            width: wsCell.width - 16
                                            text: (modelData.class || modelData.title || "window").toLowerCase()
                                            color: wsCell.selected ? TuiTheme.bg : TuiTheme.fg
                                            font.family: TuiTheme.fontFamily
                                            font.pixelSize: TuiTheme.fontSize - 1
                                            font.weight: TuiTheme.fontWeight
                                            elide: Text.ElideRight
                                        }
                                    }

                                    Text {
                                        visible: wsCell.wins.length > 3
                                        width: parent.width
                                        text: "+" + (wsCell.wins.length - 3) + " more"
                                        color: wsCell.selected ? TuiTheme.bg : TuiTheme.dim
                                        font.family: TuiTheme.fontFamily
                                        font.pixelSize: TuiTheme.fontSize - 1
                                        font.weight: TuiTheme.fontWeight
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: scope.selectedWorkspaceId = wsCell.workspaceId
                                    onClicked: scope.switchToSelected()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
