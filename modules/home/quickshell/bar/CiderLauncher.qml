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
            visible: CiderLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: Hyprland.focusedMonitor?.id === monitor?.id

            color: "transparent"
            WlrLayershell.namespace: "quickshell:cider-launcher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors { top: true; bottom: true; left: true; right: true }

            readonly property int cardW: 240
            readonly property int cardH: 240

            property int selectedIndex: 0
            property var displayItems: []
            property real displayElapsed: 0
            property string currentView: "nowplaying"
            property int playlistIndex: 0

            function buildDisplayItems() {
                if (!CiderState.available) {
                    root.displayItems = [];
                    return;
                }
                let curr = {
                    name: CiderState.title,
                    artistName: CiderState.artist,
                    albumName: CiderState.album,
                    artwork: { url: CiderState.artwork }
                };
                let queue = CiderState.queueItems.filter(i => i.name !== CiderState.title);
                root.displayItems = [...CiderState.historyItems, curr, ...queue];
                root.selectedIndex = CiderState.historyItems.length;
                carousel.currentIndex = root.selectedIndex;
                carousel.positionViewAtIndex(root.selectedIndex, ListView.Center);
            }

            function formatTime(secs) {
                let s = Math.max(0, Math.floor(secs));
                let m = Math.floor(s / 60);
                s = s % 60;
                return m + ":" + (s < 10 ? "0" + s : s);
            }

            onVisibleChanged: {
                if (visible) {
                    root.currentView = "nowplaying";
                    root.displayElapsed = CiderState.elapsed;
                    root.buildDisplayItems();
                    CiderState.refresh();
                    CiderState.fetchPlaylists();
                }
            }

            Connections {
                target: CiderState
                function onTitleChanged() { root.buildDisplayItems(); }
                function onHistoryItemsChanged() { root.buildDisplayItems(); }
                function onQueueItemsChanged() { root.buildDisplayItems(); }
                function onAvailableChanged() { root.buildDisplayItems(); }
                function onElapsedChanged() { root.displayElapsed = CiderState.elapsed; }
            }

            Timer {
                interval: 1000
                running: root.visible && CiderState.isPlaying
                repeat: true
                onTriggered: root.displayElapsed = Math.min(root.displayElapsed + 1, CiderState.duration)
            }

            // dark overlay — click outside closes
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.75)
                MouseArea {
                    anchors.fill: parent
                    onClicked: CiderLauncherState.close()
                }
            }

            // keyboard handler
            Item {
                id: keyboardHandler
                anchors.fill: parent
                focus: CiderLauncherState.visible
                Keys.onPressed: event => {
                    if (root.currentView === "playlists") {
                        if (event.key === Qt.Key_Escape || event.key === Qt.Key_P) {
                            root.currentView = "nowplaying";
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left) {
                            root.playlistIndex = Math.max(0, root.playlistIndex - 1);
                            playlistGrid.positionViewAtIndex(root.playlistIndex, GridView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right) {
                            root.playlistIndex = Math.min(CiderState.playlists.length - 1, root.playlistIndex + 1);
                            playlistGrid.positionViewAtIndex(root.playlistIndex, GridView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            root.playlistIndex = Math.max(0, root.playlistIndex - 3);
                            playlistGrid.positionViewAtIndex(root.playlistIndex, GridView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            root.playlistIndex = Math.min(CiderState.playlists.length - 1, root.playlistIndex + 3);
                            playlistGrid.positionViewAtIndex(root.playlistIndex, GridView.Contain);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.playlistIndex < CiderState.playlists.length) {
                                CiderState.playPlaylist(CiderState.playlists[root.playlistIndex].id);
                                CiderLauncherState.close();
                            }
                            event.accepted = true;
                        }
                    } else {
                        if (event.key === Qt.Key_Escape) {
                            CiderLauncherState.close();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_P) {
                            root.playlistIndex = 0;
                            root.currentView = "playlists";
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Space || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            CiderState.togglePlay();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Right) {
                            CiderState.next();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Left) {
                            CiderState.previous();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Up) {
                            CiderState.volUp();
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Down) {
                            CiderState.volDown();
                            event.accepted = true;
                        }
                    }
                }
            }

            // cider not running
            Text {
                anchors.centerIn: parent
                visible: !CiderState.available
                text: "󰎆  Cider not running"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pointSize: 18
                opacity: 0.4
            }

            // playlist view
            Item {
                anchors.fill: parent
                visible: root.currentView === "playlists"

                Text {
                    id: plTitle
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: parent.height * 0.14
                    text: "Playlists"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pointSize: 22
                    font.bold: true
                }

                Text {
                    visible: CiderState.playlists.length === 0
                    anchors.centerIn: parent
                    text: "Loading..."
                    color: Theme.text
                    opacity: 0.35
                    font.family: Theme.fontFamily
                    font.pointSize: 14
                }

                GridView {
                    id: playlistGrid
                    anchors.top: plTitle.bottom
                    anchors.topMargin: 20
                    anchors.bottom: plHint.top
                    anchors.bottomMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 594
                    cellWidth: 198
                    cellHeight: 218
                    model: CiderState.playlists
                    clip: true
                    interactive: true
                    currentIndex: root.playlistIndex
                    focus: false
                    activeFocusOnTab: false
                    keyNavigationEnabled: false

                    Behavior on contentY { SmoothedAnimation { velocity: 800 } }

                    delegate: Item {
                        id: plCard
                        width: playlistGrid.cellWidth
                        height: playlistGrid.cellHeight

                        property bool isSel: index === root.playlistIndex

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 7
                            radius: 10
                            color: Theme.separator
                            clip: true

                            Image {
                                id: plArt
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                height: parent.width
                                source: modelData.artwork?.url ?? ""
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                            }

                            Text {
                                anchors.centerIn: plArt
                                text: "󰲸"
                                font.family: "BigBlueTerm437 Nerd Font"
                                font.pointSize: 22
                                color: Theme.text
                                opacity: 0.3
                                visible: plArt.status !== Image.Ready
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: parent.height - parent.width
                                color: Qt.rgba(0, 0, 0, 0.55)

                                Text {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    text: modelData.name
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pointSize: 10
                                    font.bold: plCard.isSel
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                color: "transparent"
                                border.color: Theme.highlight
                                border.width: plCard.isSel ? 3 : 0

                                Behavior on border.width { NumberAnimation { duration: 100 } }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (plCard.isSel) {
                                    CiderState.playPlaylist(modelData.id);
                                    CiderLauncherState.close();
                                } else {
                                    root.playlistIndex = index;
                                }
                            }
                        }
                    }
                }

                Text {
                    id: plHint
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "↑↓  navigate     ↵  play     P / Esc  back"
                    color: Theme.text
                    opacity: 0.25
                    font.family: Theme.fontFamily
                    font.pointSize: 10
                }
            }

            // main content
            Item {
                anchors.fill: parent
                visible: CiderState.available && root.currentView === "nowplaying"

                // queue carousel
                ListView {
                    id: carousel
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -90
                    width: parent.width
                    height: root.cardH + 40
                    orientation: ListView.Horizontal
                    model: root.displayItems
                    currentIndex: root.selectedIndex
                    spacing: 24
                    clip: false
                    interactive: false
                    focus: false
                    activeFocusOnTab: false
                    keyNavigationEnabled: false

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
                            radius: 12
                            color: Theme.separator
                            clip: true

                            Image {
                                id: artImg
                                anchors.fill: parent
                                source: {
                                    if (card.offset === 0 && CiderState.localArtwork.length > 0)
                                        return CiderState.localArtwork;
                                    let url = modelData.artwork?.url ?? "";
                                    return url.replace("{w}", "600").replace("{h}", "600");
                                }
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                asynchronous: true
                                cache: false
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰎆"
                                font.family: "BigBlueTerm437 Nerd Font"
                                font.pointSize: 36
                                color: Theme.text
                                opacity: 0.3
                                visible: artImg.status !== Image.Ready
                            }

                            // highlight border + pulse when playing
                            Rectangle {
                                id: borderRect
                                anchors.fill: parent
                                radius: 12
                                color: "transparent"
                                border.color: Theme.highlight
                                border.width: card.offset === 0 ? 3 : 0

                                SequentialAnimation on opacity {
                                    running: card.offset === 0 && CiderState.isPlaying
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.4; duration: 900; easing.type: Easing.InOutSine }
                                    NumberAnimation { to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                                    onStopped: borderRect.opacity = 1.0
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (card.offset < 0) CiderState.previous();
                                else if (card.offset > 0) CiderState.next();
                                else CiderState.togglePlay();
                            }
                        }
                    }
                }

                // track info
                Column {
                    id: trackInfo
                    anchors.top: carousel.bottom
                    anchors.topMargin: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: CiderState.title
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pointSize: 16
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: CiderState.artist
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pointSize: 12
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: CiderState.album
                        color: Theme.misc
                        font.family: Theme.fontFamily
                        font.pointSize: 10
                        opacity: 0.8
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                // progress
                Item {
                    id: progressArea
                    anchors.top: trackInfo.bottom
                    anchors.topMargin: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 420
                    height: 20

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: progressTrack.verticalCenter
                        text: root.formatTime(root.displayElapsed)
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pointSize: 9
                        opacity: 0.6
                    }

                    Rectangle {
                        id: progressTrack
                        anchors.left: parent.left
                        anchors.leftMargin: 40
                        anchors.right: parent.right
                        anchors.rightMargin: 40
                        anchors.verticalCenter: parent.verticalCenter
                        height: 4
                        radius: 2
                        color: Qt.rgba(1, 1, 1, 0.15)

                        Rectangle {
                            width: CiderState.duration > 0
                                ? parent.width * Math.min(1, root.displayElapsed / CiderState.duration)
                                : 0
                            height: parent.height
                            radius: parent.radius
                            color: Theme.highlight
                        }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -8
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                let pct = Math.max(0, Math.min(1, mouse.x / progressTrack.width));
                                CiderState.seek(pct * CiderState.duration);
                            }
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: progressTrack.verticalCenter
                        text: root.formatTime(CiderState.duration)
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pointSize: 9
                        opacity: 0.6
                    }
                }

                // controls
                Row {
                    anchors.top: progressArea.bottom
                    anchors.topMargin: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 36

                    Text {
                        id: prevBtn
                        text: "󰒮"
                        font.family: "BigBlueTerm437 Nerd Font"
                        font.pointSize: 22
                        color: Theme.text
                        opacity: prevMa.containsMouse ? 0.5 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 80 } }
                        MouseArea {
                            id: prevMa
                            anchors.fill: parent
                            anchors.margins: -10
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: CiderState.previous()
                        }
                    }

                    Text {
                        text: CiderState.isPlaying ? "󰏤" : "󰐊"
                        font.family: "BigBlueTerm437 Nerd Font"
                        font.pointSize: 28
                        color: Theme.highlight
                        opacity: playMa.containsMouse ? 0.5 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 80 } }
                        MouseArea {
                            id: playMa
                            anchors.fill: parent
                            anchors.margins: -10
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: CiderState.togglePlay()
                        }
                    }

                    Text {
                        id: nextBtn
                        text: "󰒭"
                        font.family: "BigBlueTerm437 Nerd Font"
                        font.pointSize: 22
                        color: Theme.text
                        opacity: nextMa.containsMouse ? 0.5 : 1.0
                        Behavior on opacity { NumberAnimation { duration: 80 } }
                        MouseArea {
                            id: nextMa
                            anchors.fill: parent
                            anchors.margins: -10
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: CiderState.next()
                        }
                    }
                }
            }
        }
    }
}
