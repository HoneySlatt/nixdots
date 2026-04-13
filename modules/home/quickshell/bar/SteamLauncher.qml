import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    Process {
        id: gamesProc
        command: ["steam-games"]
        running: false
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => gamesProc.buffer += data
        }
        onExited: {
            try {
                launcherScope.allGames = JSON.parse(gamesProc.buffer);
            } catch (e) {
                launcherScope.allGames = [];
            }
            gamesProc.buffer = "";
        }
    }

    property var allGames: []

    Component.onCompleted: {
        gamesProc.running = true;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: SteamLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:steam-launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            property int selectedIndex: 0
            property string searchQuery: ""
            property var filteredGames: []

            readonly property int cardW: 220
            readonly property int cardH: 330

            function filterList() {
                if (searchQuery.length === 0) {
                    filteredGames = launcherScope.allGames;
                    selectedIndex = Math.floor(filteredGames.length / 2);
                } else {
                    filteredGames = launcherScope.allGames.filter(g =>
                        g.name?.toLowerCase().includes(searchQuery)
                    );
                    selectedIndex = 0;
                }
                carousel.currentIndex = selectedIndex;
                carousel.positionViewAtIndex(selectedIndex, ListView.Center);
            }

            function launchGame(appid) {
                Qt.openUrlExternally("steam://rungameid/" + appid);
                SteamLauncherState.close();
            }

            onVisibleChanged: {
                if (visible) {
                    searchField.text = "";
                    root.searchQuery = "";
                    // Don't reassign filteredGames here — that resets the ListView model
                    // and breaks the currentIndex binding. filterList() already kept it up to date.
                    root.selectedIndex = Math.floor(root.filteredGames.length / 2);
                }
            }

            Connections {
                target: launcherScope
                function onAllGamesChanged() { root.filterList(); }
            }

            onSearchQueryChanged: filterList()

            onSelectedIndexChanged: {
                carousel.positionViewAtIndex(selectedIndex, ListView.Center);
            }

            // Dark overlay — click outside closes
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.75)
                MouseArea {
                    anchors.fill: parent
                    onClicked: SteamLauncherState.close()
                }
            }

            // Keyboard handler
            Item {
                anchors.fill: parent
                focus: SteamLauncherState.visible
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        SteamLauncherState.close();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.filteredGames.length > 0)
                            root.launchGame(root.filteredGames[root.selectedIndex].appid);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (root.selectedIndex < root.filteredGames.length - 1)
                            root.selectedIndex++;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        if (root.selectedIndex > 0)
                            root.selectedIndex--;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Backspace) {
                        searchField.text = searchField.text.slice(0, -1);
                        event.accepted = true;
                    } else if (event.text.length > 0 && !event.modifiers) {
                        searchField.text += event.text;
                        event.accepted = true;
                    }
                }
            }

            // Carousel
            ListView {
                id: carousel
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -30
                width: parent.width
                height: root.cardH + 40
                orientation: ListView.Horizontal
                model: root.filteredGames
                currentIndex: root.selectedIndex
                spacing: 20
                clip: false
                interactive: false

                preferredHighlightBegin: (width - root.cardW) / 2
                preferredHighlightEnd:   (width + root.cardW) / 2
                highlightRangeMode: ListView.StrictlyEnforceRange

                Behavior on contentX {
                    SmoothedAnimation { velocity: 1200 }
                }

                delegate: Item {
                    id: card
                    width: root.cardW
                    height: root.cardH

                    property int offset: index - carousel.currentIndex
                    property real absOff: Math.abs(offset)
                    property real cardScale: Math.max(0.55, 1.0 - absOff * 0.18)
                    property real cardOpacity: Math.max(0.35, 1.0 - absOff * 0.22)

                    opacity: cardOpacity
                    z: 10 - absOff

                    transform: [
                        Rotation {
                            origin.x: root.cardW / 2
                            origin.y: root.cardH / 2
                            angle: -(offset < 0 ? -1 : offset > 0 ? 1 : 0) * Math.pow(absOff, 1.5) * 3.46
                        },
                        Scale {
                            origin.x: root.cardW / 2
                            origin.y: root.cardH / 2
                            xScale: card.cardScale
                            yScale: card.cardScale
                        }
                    ]

                    Rectangle {
                        anchors.fill: parent
                        radius: 0
                        color: Theme.separator
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: modelData.art ? "file://" + modelData.art : ""
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                        }

                        // Fallback icon
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.family: "BigBlueTerm437 Nerd Font"
                            font.pointSize: 36
                            color: Theme.text
                            opacity: 0.3
                            visible: parent.children[0].status !== Image.Ready
                        }

                        // Selected highlight border
                        Rectangle {
                            anchors.fill: parent
                            radius: 0
                            color: "transparent"
                            border.color: Theme.highlight
                            border.width: card.offset === 0 ? 3 : 0
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (card.offset === 0)
                                root.launchGame(modelData.appid);
                            else
                                root.selectedIndex = index;
                        }
                    }
                }
            }

            // Game name below carousel
            Text {
                anchors.top: carousel.bottom
                anchors.topMargin: 16
                anchors.horizontalCenter: parent.horizontalCenter
                text: root.filteredGames[root.selectedIndex]?.name ?? ""
                color: Theme.text
                font.family: Theme.fontFamily
                font.pointSize: 16
                font.bold: true
                horizontalAlignment: Text.AlignHCenter
            }

            // Search bar
            Rectangle {
                anchors.bottom: carousel.top
                anchors.bottomMargin: 24
                anchors.horizontalCenter: parent.horizontalCenter
                width: 420
                height: 36
                radius: 8
                color: Qt.rgba(0, 0, 0, 0.5)
                border.color: Qt.rgba(1, 1, 1, 0.15)
                border.width: 1

                TextInput {
                    id: searchField
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    verticalAlignment: TextInput.AlignVCenter
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pointSize: 12
                    clip: true
                    onTextChanged: root.searchQuery = text.toLowerCase()

                    Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        text: "> Search games..."
                        color: Theme.text
                        opacity: 0.3
                        font: searchField.font
                        visible: searchField.text.length === 0
                    }
                }
            }
        }
    }
}
