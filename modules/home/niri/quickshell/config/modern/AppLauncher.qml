import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    id: launcherScope

    component GlassPanel: Rectangle {
        property color fillColor: Theme.card

        radius: 28
        color: "transparent"
        border.color: Qt.tint(Theme.separator, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.38))
        border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.tint(fillColor, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.055)) }
            GradientStop { position: 0.55; color: fillColor }
            GradientStop { position: 1.0; color: Qt.tint(fillColor, Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.20)) }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 28
            anchors.rightMargin: 28
            anchors.topMargin: 1
            height: 1
            radius: 1
            color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.16)
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)
            border.width: 1
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: LauncherState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.activeWorkspace !== null && Services.NiriData.activeWorkspace.output === root.screen.name
            onMonitorIsFocusedChanged: if (!monitorIsFocused) LauncherState.close()
            

            property string searchQuery: ""
            property int selectedIndex: 0
            property var sortedApps: []
            property var filteredApps: []

            color: "transparent"

            WlrLayershell.namespace: "quickshell:applauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            function rebuildList() {
                let apps = [];
                let seen = new Set();
                for (let i = 0; i < sourceRepeater.count; i++) {
                    const item = sourceRepeater.itemAt(i);
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
                        app.name?.toLowerCase().includes(searchQuery)
                    );
                }
                selectedIndex = Math.min(selectedIndex, Math.max(filteredApps.length - 1, 0));
                if (filteredApps.length > 0 && selectedIndex < 0) selectedIndex = 0;
                appList.currentIndex = selectedIndex;
            }

            function launchSelected() {
                if (filteredApps.length === 0 || selectedIndex < 0 || selectedIndex >= filteredApps.length)
                    return;
                filteredApps[selectedIndex].execute();
                LauncherState.close();
            }

            onSearchQueryChanged: filterList()
            onSelectedIndexChanged: {
                appList.currentIndex = selectedIndex;
                appList.positionViewAtIndex(selectedIndex, ListView.Contain);
            }

            Connections {
                target: LauncherState
                function onVisibleChanged() {
                    if (LauncherState.visible) {
                        searchField.text = "";
                        root.searchQuery = "";
                        root.selectedIndex = 0;
                        root.rebuildList();
                        searchFocusTimer.start();
                    } else {
                        searchFocusTimer.stop();
                    }
                }
            }

            Timer {
                id: searchFocusTimer
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
                onClicked: LauncherState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: LauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        LauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.launchSelected();
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
                }

                Item {
                    id: panelClip
                    anchors.top: BarState.isTop ? parent.top : undefined
                    anchors.bottom: BarState.isTop ? undefined : parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: BarState.isTop ? Theme.margin : 0
                    width: 380
                    height: 430
                    clip: true

                    GlassPanel {
                        anchors.fill: parent
                        anchors.topMargin: 0
                        anchors.bottomMargin: BarState.isTop ? 0 : -radius
                        height: parent.height + radius
                        radius: BarState.isTop ? 24 : 0
                        fillColor: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.90)
                    }

                    MouseArea { anchors.fill: parent }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 16

                        Rectangle {
                            id: searchBar
                            width: parent.width
                            height: 48
                            radius: 24
                            color: Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.56)
                            border.color: searchField.activeFocus
                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.65)
                                : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22)
                            border.width: 1

                            Rectangle {
                                visible: searchField.activeFocus
                                anchors.fill: parent
                                anchors.margins: -3
                                radius: parent.radius + 3
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08)
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 16
                                anchors.rightMargin: 12
                                spacing: 10

                                Text {
                                    text: "\uf002"
                                    color: Theme.accent
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize + 4
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                TextInput {
                                    id: searchField
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    verticalAlignment: TextInput.AlignVCenter
                                    color: Theme.text
                                    selectionColor: Theme.accent
                                    selectedTextColor: Theme.background
                                    clip: true
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize + 1
                                    font.weight: Theme.fontWeight

                                    onTextChanged: root.searchQuery = text.toLowerCase()

                                    Text {
                                        anchors.fill: parent
                                        verticalAlignment: Text.AlignVCenter
                                        text: "Search"
                                        color: Theme.muted
                                        opacity: 0.72
                                        font.family: searchField.font.family
                                        font.pixelSize: searchField.font.pixelSize
                                        font.weight: searchField.font.weight
                                        visible: searchField.text.length === 0
                                    }
                                }

                            }
                        }

                        ListView {
                            id: appList
                            width: parent.width
                            height: parent.height - searchBar.height - parent.spacing
                            clip: true
                            model: root.filteredApps
                            currentIndex: root.selectedIndex
                            spacing: 4
                            boundsBehavior: Flickable.StopAtBounds
                            interactive: true

                            delegate: Rectangle {
                                id: appRow

                                required property var modelData
                                required property int index

                                width: appList.width
                                height: 44
                                radius: 14
                                color: appMouse.containsMouse || index === root.selectedIndex
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.11)
                                    : "transparent"
                                border.color: index === root.selectedIndex
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.20)
                                    : "transparent"
                                border.width: 1

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    spacing: 12

                                    Item {
                                        Layout.preferredWidth: 28
                                        Layout.preferredHeight: 28
                                        Layout.alignment: Qt.AlignVCenter

                                        Image {
                                            id: appIcon
                                            anchors.fill: parent
                                            source: {
                                                const icon = appRow.modelData.icon ?? "";
                                                return icon.startsWith("/") ? icon : Quickshell.iconPath(icon || "application-x-executable", "application-x-executable");
                                            }
                                            sourceSize: Qt.size(28, 28)
                                            smooth: true
                                            asynchronous: true
                                            visible: status === Image.Ready
                                        }

                                        Text {
                                            anchors.centerIn: parent
                                            visible: appIcon.status !== Image.Ready
                                            text: "\uf1b2"
                                            color: Theme.accent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize + 6
                                        }
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        text: appRow.modelData.name ?? ""
                                        color: Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize + 1
                                        font.weight: Font.Bold
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: "\uf054"
                                        color: index === root.selectedIndex ? Theme.accent : Theme.muted
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 1
                                        Layout.alignment: Qt.AlignVCenter
                                    }
                                }

                                MouseArea {
                                    id: appMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: root.selectedIndex = index
                                    onClicked: {
                                        appRow.modelData.execute();
                                        LauncherState.close();
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: root.filteredApps.length === 0
                                text: "No applications found"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Theme.fontWeight
                            }
                        }
                    }
                }
            }
        }
    }
}
