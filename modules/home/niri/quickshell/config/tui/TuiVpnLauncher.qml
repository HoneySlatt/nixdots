import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "services" as Services

Item {
    id: scope

    property var allNodes: []

    function refreshNodes() {
        nodesProc.buffer = "";
        nodesProc.running = true;
    }

    Process {
        id: nodesProc
        command: ["bash", "/home/honey/NixOS/modules/home/niri/quickshell/config/scripts/tailscale-exit-nodes.sh"]
        running: false
        property string buffer: ""

        stdout: SplitParser { onRead: data => nodesProc.buffer += data }

        onExited: {
            try {
                scope.allNodes = JSON.parse(nodesProc.buffer);
            } catch (e) {
                scope.allNodes = [];
            }
            nodesProc.buffer = "";
        }
    }

    Component.onCompleted: refreshNodes()

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiVpnLauncherState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.focusedOutput === root.screen.name

            property string searchQuery: ""
            property int selectedIndex: 0
            property var filteredNodes: []
            readonly property var selectedNode: filteredNodes.length > 0 ? filteredNodes[selectedIndex] : null
            readonly property var activeNode: scope.allNodes.find(n => n.selected) ?? null

            color: "transparent"
            WlrLayershell.namespace: "quickshell:tui:vpnlauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors { top: true; bottom: true; left: true; right: true }

            function filterList() {
                const q = searchQuery.toLowerCase();
                filteredNodes = q.length === 0
                    ? scope.allNodes
                    : scope.allNodes.filter(n => (n.host + " " + n.country + " " + n.city + " " + n.ip).toLowerCase().includes(q));
                selectedIndex = Math.max(0, Math.min(selectedIndex, filteredNodes.length - 1));
                nodeList.currentIndex = selectedIndex;
                Qt.callLater(centerSelection);
            }

            function centerSelection() {
                if (filteredNodes.length > 0)
                    nodeList.positionViewAtIndex(selectedIndex, ListView.Contain);
            }

            function initializeLauncher() {
                searchField.text = "";
                searchQuery = "";
                selectedIndex = 0;
                scope.refreshNodes();
                filterList();
                focusTimer.start();
            }

            function setSelectedNode() {
                if (!selectedNode) return;
                setNodeProc.command = ["bash", "/home/honey/NixOS/modules/home/niri/quickshell/config/scripts/toggle-tailscale-exit-node.sh", selectedNode.host];
                setNodeProc.running = true;
            }

            function clearNode() {
                setNodeProc.command = ["bash", "/home/honey/NixOS/modules/home/niri/quickshell/config/scripts/toggle-tailscale-exit-node.sh", "off"];
                setNodeProc.running = true;
            }

            function handleKey(event) {
                if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) { TuiVpnLauncherState.close(); event.accepted = true; return; }
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_A) { setSelectedNode(); event.accepted = true; return; }
                if (event.key === Qt.Key_O || event.key === Qt.Key_Delete) { clearNode(); event.accepted = true; return; }
                if (event.key === Qt.Key_J || event.key === Qt.Key_Down) {
                    if (selectedIndex < filteredNodes.length - 1) selectedIndex++;
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_K || event.key === Qt.Key_Up) {
                    if (selectedIndex > 0) selectedIndex--;
                    event.accepted = true;
                    return;
                }
                if (event.key === Qt.Key_Backspace) { searchField.text = searchField.text.slice(0, -1); event.accepted = true; return; }
                if (event.text.length > 0 && !event.modifiers) { searchField.text += event.text; event.accepted = true; }
            }

            onSelectedIndexChanged: {
                nodeList.currentIndex = selectedIndex;
                centerSelection();
            }
            onSearchQueryChanged: filterList()

            Connections { target: scope; function onAllNodesChanged() { root.filterList(); } }

            Process {
                id: setNodeProc
                running: false
                onExited: {
                    scope.refreshNodes();
                    TuiVpnLauncherState.close();
                }
            }

            Timer { id: focusTimer; interval: 80; repeat: false; onTriggered: panel.forceActiveFocus() }

            MouseArea { anchors.fill: parent; onClicked: TuiVpnLauncherState.close() }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: Math.min(parent.width - 120, 1060)
                height: Math.min(parent.height - 120, 680)
                color: TuiTheme.bg
                border.color: TuiTheme.dim
                border.width: 2
                focus: TuiVpnLauncherState.visible

                MouseArea { anchors.fill: parent; onClicked: panel.forceActiveFocus() }
                Keys.onPressed: event => root.handleKey(event)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 6
                    color: "transparent"
                    border.color: TuiTheme.caution
                    border.width: 1
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 12

                    Rectangle {
                        width: parent.width
                        height: 56
                        color: TuiTheme.dim
                        border.color: TuiTheme.caution
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 18

                            Text {
                                width: 230
                                height: parent.height
                                text: "VPN EXIT NODES"
                                color: TuiTheme.highlight
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize + 3
                                font.weight: TuiTheme.fontWeight
                                verticalAlignment: Text.AlignVCenter
                            }

                            Text {
                                width: parent.width - 400
                                height: parent.height
                                text: root.activeNode ? (root.activeNode.country + " / " + root.activeNode.city + " / " + root.activeNode.host) : "NO EXIT NODE SELECTED"
                                color: root.activeNode ? TuiTheme.accent : TuiTheme.barMuted
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize
                                font.weight: TuiTheme.fontWeight
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }

                            Rectangle {
                                width: 112
                                height: 34
                                anchors.verticalCenter: parent.verticalCenter
                                color: offMouse.containsMouse ? TuiTheme.highlight : TuiTheme.bg
                                border.color: TuiTheme.highlight
                                border.width: 1

                                Text {
                                    anchors.fill: parent
                                    text: "[ OFF ]"
                                    color: offMouse.containsMouse ? TuiTheme.bg : TuiTheme.fg
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }

                                MouseArea { id: offMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.clearNode() }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 42
                        color: TuiTheme.dim
                        border.color: searchField.text.length > 0 ? TuiTheme.accent : TuiTheme.caution
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            Text {
                                width: 22
                                height: parent.height
                                text: ">"
                                color: TuiTheme.bright
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize + 4
                                font.weight: TuiTheme.fontWeight
                                verticalAlignment: Text.AlignVCenter
                            }

                            TextInput {
                                id: searchField
                                width: parent.width - 32
                                height: parent.height
                                readOnly: true
                                color: TuiTheme.fg
                                selectionColor: TuiTheme.accent
                                selectedTextColor: TuiTheme.bg
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize + 2
                                font.weight: TuiTheme.fontWeight
                                verticalAlignment: TextInput.AlignVCenter
                                clip: true
                                onTextChanged: root.searchQuery = text
                                Keys.onPressed: event => root.handleKey(event)

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    text: "search country / city / host / ip..."
                                    color: TuiTheme.barMuted
                                    font.family: searchField.font.family
                                    font.pixelSize: searchField.font.pixelSize
                                    font.weight: searchField.font.weight
                                    visible: searchField.text.length === 0
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 30
                        color: TuiTheme.bg
                        border.color: TuiTheme.dim
                        border.width: 1

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12

                            Text { width: 36; height: parent.height; text: "ST"; color: TuiTheme.barMuted; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter }
                            Text { width: 170; height: parent.height; text: "COUNTRY"; color: TuiTheme.barMuted; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter }
                            Text { width: 180; height: parent.height; text: "CITY"; color: TuiTheme.barMuted; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter }
                            Text { width: parent.width - 620; height: parent.height; text: "HOST"; color: TuiTheme.barMuted; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter }
                            Text { width: 180; height: parent.height; text: "IP"; color: TuiTheme.barMuted; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter }
                        }
                    }

                    ListView {
                        id: nodeList
                        width: parent.width
                        height: Math.max(0, parent.height - 216)
                        model: root.filteredNodes
                        currentIndex: root.selectedIndex
                        clip: true
                        spacing: 4

                        delegate: Rectangle {
                            id: row
                            required property var modelData
                            required property int index

                            width: nodeList.width
                            height: 38
                            color: modelData.selected
                                ? TuiTheme.highlight
                                : index === root.selectedIndex
                                    ? TuiTheme.dim
                                    : TuiTheme.bg
                            border.color: index === root.selectedIndex ? TuiTheme.accent : TuiTheme.dim
                            border.width: 1

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12

                                Text { width: 36; height: parent.height; text: modelData.selected ? "*" : "-"; color: modelData.selected ? TuiTheme.bg : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter }
                                Text { width: 170; height: parent.height; text: modelData.country; color: modelData.selected ? TuiTheme.bg : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { width: 180; height: parent.height; text: modelData.city; color: modelData.selected ? TuiTheme.bg : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { width: parent.width - 620; height: parent.height; text: modelData.host; color: modelData.selected ? TuiTheme.bg : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                                Text { width: 180; height: parent.height; text: modelData.ip; color: modelData.selected ? TuiTheme.bg : TuiTheme.barMuted; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.selectedIndex = index
                                onClicked: root.setSelectedNode()
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 34
                        color: "transparent"
                        border.color: TuiTheme.dim
                        border.width: 1

                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 26

                            Text { text: "j/k navigate"; color: TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                            Text { text: "enter select"; color: TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                            Text { text: "o off"; color: TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                            Text { text: "q/esc close"; color: TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.rightMargin: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: root.filteredNodes.length + " NODES"
                            color: TuiTheme.barMuted
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                        }
                    }
                }
            }
        }
    }
}
