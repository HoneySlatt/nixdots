import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

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
            visible: SmallLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)
            onMonitorIsFocusedChanged: if (!monitorIsFocused) SmallLauncherState.close()

            color: "transparent"

            WlrLayershell.namespace: "quickshell:small-launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            property string searchQuery: ""
            property var sortedApps: []
            property var filteredApps: []
            property int selectedIndex: 0

            readonly property int cardW: 96
            readonly property int cardH: 116
            readonly property int cellW: 110
            readonly property int cellH: 130
            readonly property int appsContentWidth: root.filteredApps.length * root.cellW

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
                    root.selectedIndex = Math.floor(filteredApps.length / 2);
                } else {
                    filteredApps = sortedApps.filter(app =>
                        app.name?.toLowerCase().includes(searchQuery)
                    );
                    root.selectedIndex = 0;
                }
                if (appGrid) {
                    appGrid.positionViewAtIndex(root.selectedIndex, ListView.Center);
                }
            }

            onSelectedIndexChanged: {
                if (appGrid) {
                    appGrid.positionViewAtIndex(root.selectedIndex, ListView.Center);
                }
            }

            onSearchQueryChanged: filterList()

            Connections {
                target: SmallLauncherState
                function onVisibleChanged() {
                    if (SmallLauncherState.visible) {
                        searchField.text = "";
                        root.searchQuery = "";
                        root.rebuildList();
                    }
                }
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
                onClicked: SmallLauncherState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: SmallLauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        SmallLauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.filteredApps.length > 0 && root.selectedIndex >= 0) {
                            root.filteredApps[root.selectedIndex].execute();
                            SmallLauncherState.close();
                        }
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Left) {
                        root.selectedIndex = Math.max(0, root.selectedIndex - 1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Right) {
                        root.selectedIndex = Math.min(root.filteredApps.length - 1, root.selectedIndex + 1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Backspace) {
                        searchField.text = searchField.text.slice(0, -1);
                        event.accepted = true;
                        return;
                    }
                    if (event.text.length > 0 && !event.modifiers) {
                        searchField.text += event.text;
                        event.accepted = true;
                        return;
                    }
                }

                GlassPanel {
                    id: panel
                    anchors.centerIn: parent
                    width: Math.min(parent.width - 40, 720)
                    height: 24 + 48 + 16 + root.cellH + 24
                    fillColor: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.92)

                    MouseArea { anchors.fill: parent }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 24
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
                                        text: "Search..."
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
                            id: appGrid
                            width: parent.width
                            height: root.cellH
                            orientation: ListView.Horizontal
                            model: root.filteredApps
                            clip: true
                            interactive: false
                            boundsBehavior: Flickable.StopAtBounds
                            focus: false
                            currentIndex: root.selectedIndex

                            preferredHighlightBegin: (width - root.cardW) / 2
                            preferredHighlightEnd: (width + root.cardW) / 2
                            highlightRangeMode: ListView.StrictlyEnforceRange

                            delegate: Item {
                                width: root.cellW
                                height: root.cellH

                                Rectangle {
                                    id: appCard
                                    anchors.centerIn: parent
                                    width: root.cardW
                                    height: root.cardH
                                    radius: 16
                                    color: appMouse.containsMouse || index === root.selectedIndex
                                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08)
                                        : Theme.card
                                    border.color: index === root.selectedIndex
                                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.45)
                                        : "transparent"
                                    border.width: 1.5

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        Item {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            width: 48
                                            height: 48

                                            Image {
                                                id: appIcon
                                                anchors.fill: parent
                                                source: {
                                                    const icon = modelData.icon ?? "";
                                                    return icon.startsWith("/") ? icon : Quickshell.iconPath(icon || "application-x-executable", "application-x-executable");
                                                }
                                                sourceSize: Qt.size(48, 48)
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
                                                font.pixelSize: Theme.fontSize + 10
                                            }
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: modelData.name ?? ""
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Font.Bold
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                            width: appCard.width - 8
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }

                                    MouseArea {
                                        id: appMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: root.selectedIndex = index
                                        onClicked: {
                                            modelData.execute();
                                            SmallLauncherState.close();
                                        }
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
