import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            readonly property bool monitorIsFocused: Hyprland.focusedMonitor?.id === monitor?.id

            property string searchQuery: ""
            property int selectedIndex: 0
            property var sortedApps: []
            property var filteredApps: []

            color: "transparent"

            WlrLayershell.namespace: "quickshell:tui:launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            function rebuildList() {
                let apps = [];
                let seen = new Set();
                for (let i = 0; i < sourceRepeater.count; i++) {
                    let item = sourceRepeater.itemAt(i);
                    if (!item || item.modelData.noDisplay) continue;
                    const key = item.modelData.id ?? item.modelData.name ?? "";
                    if (seen.has(key)) continue;
                    seen.add(key);
                    apps.push(item.modelData);
                }
                apps.sort((a, b) => (a.name ?? "").localeCompare(b.name ?? ""));
                sortedApps = apps;
                filterList();
            }

            function filterList() {
                if (searchQuery.length === 0) {
                    filteredApps = sortedApps;
                } else {
                    filteredApps = sortedApps.filter(app =>
                        app.name?.toLowerCase().includes(searchQuery.toLowerCase())
                    );
                }
                selectedIndex = 0;
                appList.currentIndex = 0;
            }

            onSearchQueryChanged: filterList()

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                property bool canBeActive: root.monitorIsFocused
                active: false
                onCleared: () => {
                    if (!active) TuiLauncherState.close();
                }
            }

            Connections {
                target: TuiLauncherState
                function onVisibleChanged() {
                    if (TuiLauncherState.visible) {
                        searchField.text = "";
                        root.searchQuery = "";
                        root.selectedIndex = 0;
                        root.rebuildList();
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
                onTriggered: { if (grab.canBeActive) grab.active = TuiLauncherState.visible; }
            }

            Timer {
                id: focusTimer
                interval: 80
                repeat: false
                onTriggered: searchField.forceActiveFocus()
            }

            Item {
                visible: false
                Repeater {
                    id: sourceRepeater
                    model: DesktopEntries.applications
                    Item { required property var modelData }
                    Component.onCompleted: root.rebuildList()
                    onCountChanged: root.rebuildList()
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: TuiLauncherState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: TuiLauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        TuiLauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.filteredApps.length > 0 && root.selectedIndex < root.filteredApps.length) {
                            root.filteredApps[root.selectedIndex].execute();
                            TuiLauncherState.close();
                        }
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Down) {
                        root.selectedIndex = Math.min(root.selectedIndex + 1, root.filteredApps.length - 1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Up) {
                        root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Backspace) {
                        if (searchField.text.length > 0)
                            searchField.text = searchField.text.slice(0, -1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_U && event.modifiers & Qt.ControlModifier) {
                        searchField.text = "";
                        root.searchQuery = "";
                        event.accepted = true;
                        return;
                    }
                    if (event.text.length > 0 && !event.modifiers) {
                        searchField.text += event.text;
                        event.accepted = true;
                    }
                }

                Item {
                    id: panelClip
                    anchors.top: TuiState.isTop ? parent.top : undefined
                    anchors.bottom: TuiState.isTop ? undefined : parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: TuiState.isTop ? TuiTheme.pad : 0
                    width: 480
                    height: 300
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: TuiTheme.bg
                        border.color: TuiTheme.accent
                        border.width: 2
                        radius: 0

                        Column {
                            anchors.fill: parent
                            anchors.topMargin: 12
                            anchors.bottomMargin: 12
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 6

                            RowLayout {
                                width: parent.width
                                height: 28
                                spacing: 0

                                Text {
                                    text: " > "
                                    color: TuiTheme.accent
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize + 2
                                    font.weight: TuiTheme.fontWeight
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                TextInput {
                                    id: searchField
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: TuiTheme.fg
                                    selectionColor: TuiTheme.accent
                                    selectedTextColor: TuiTheme.bg
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize + 2
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: TextInput.AlignVCenter
                                    clip: true
                                    onTextChanged: root.searchQuery = text.toLowerCase()

                                    Keys.onPressed: event => {
                                        if (event.key === Qt.Key_Escape) {
                                            TuiLauncherState.close();
                                            event.accepted = true;
                                            return;
                                        }
                                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                            if (root.filteredApps.length > 0 && root.selectedIndex < root.filteredApps.length) {
                                                root.filteredApps[root.selectedIndex].execute();
                                                TuiLauncherState.close();
                                            }
                                            event.accepted = true;
                                            return;
                                        }
                                        if (event.key === Qt.Key_Down) {
                                            root.selectedIndex = Math.min(root.selectedIndex + 1, root.filteredApps.length - 1);
                                            event.accepted = true;
                                            return;
                                        }
                                        if (event.key === Qt.Key_Up) {
                                            root.selectedIndex = Math.max(root.selectedIndex - 1, 0);
                                            event.accepted = true;
                                            return;
                                        }
                                        if (event.key === Qt.Key_U && event.modifiers & Qt.ControlModifier) {
                                            searchField.text = "";
                                            root.searchQuery = "";
                                            event.accepted = true;
                                        }
                                    }

                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: "search..."
                                        color: TuiTheme.dim
                                        font.family: searchField.font.family
                                        font.pixelSize: searchField.font.pixelSize
                                        font.weight: searchField.font.weight
                                        visible: searchField.text.length === 0
                                    }

                                    cursorDelegate: Rectangle {
                                        width: 2
                                        height: searchField.height * 0.7
                                        color: TuiTheme.accent
                                    }
                                }
                            }

                            Rectangle {
                                width: parent.width + 24
                                x: -12
                                height: 1
                                color: TuiTheme.dim
                            }

                            ListView {
                                id: appList
                                width: parent.width
                                height: parent.height - 52
                                clip: true
                                model: root.filteredApps
                                currentIndex: root.selectedIndex
                                spacing: 0
                                boundsBehavior: Flickable.StopAtBounds
                                interactive: true

                                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                                delegate: Item {
                                    required property int index
                                    required property var modelData
                                    readonly property bool isSelected: index === root.selectedIndex

                                    width: appList.width
                                    height: 26

                                    Rectangle {
                                        anchors.fill: parent
                                        color: isSelected ? TuiTheme.accent : "transparent"
                                    }

                                    Row {
                                        anchors.left: parent.left
                                        anchors.leftMargin: 6
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 0

                                        Text {
                                            text: isSelected ? ">" : " "
                                            color: isSelected ? TuiTheme.bg : TuiTheme.dim
                                            font.family: TuiTheme.fontFamily
                                            font.pixelSize: TuiTheme.fontSize
                                            font.weight: TuiTheme.fontWeight
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Text {
                                            text: " " + (modelData.name ?? "?")
                                            color: isSelected ? TuiTheme.bg : TuiTheme.fg
                                            font.family: TuiTheme.fontFamily
                                            font.pixelSize: TuiTheme.fontSize
                                            font.weight: TuiTheme.fontWeight
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                            width: appList.width - 40
                                        }
                                    }

                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: root.selectedIndex = index
                                        onClicked: {
                                            modelData.execute();
                                            TuiLauncherState.close();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
