import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    property string currentTheme: ""

    readonly property var themes: [
        { key: "pastelglow",    name: "Pastel Glow",   base: "#F8E9EE", surface: "#EBCFD7", accent: "#E0486B", text: "#3B2730" },
        { key: "rosepine",      name: "Rosé Pine",     base: "#191724", surface: "#26233a", accent: "#c4a7e7", text: "#e0def4" },
        { key: "gruvbox",       name: "Gruvbox Dark",  base: "#282828", surface: "#3c3836", accent: "#fabd2f", text: "#ebdbb2" },
        { key: "gruvbox-light", name: "Gruvbox Light", base: "#fbf1c7", surface: "#ebdbb2", accent: "#d79921", text: "#3c3836" },
        { key: "everforest",    name: "Everforest",    base: "#2d353b", surface: "#343f44", accent: "#a7c080", text: "#d3c6aa" },
        { key: "carbonfox",     name: "Carbonfox",     base: "#161616", surface: "#222222", accent: "#f2f4f8", text: "#f2f4f8" },
    ]

    Process {
        id: readThemeProc
        command: ["cat", "/home/honey/.config/quickshell/.current-theme"]
        running: false
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => readThemeProc.buffer += data
        }
        onExited: {
            launcherScope.currentTheme = readThemeProc.buffer.trim();
            readThemeProc.buffer = "";
            const idx = launcherScope.themes.findIndex(t => t.key === launcherScope.currentTheme);
            if (idx >= 0) {
                carousel.currentIndex = idx;
                carousel.positionViewAtIndex(idx, ListView.Center);
            }
        }
    }

    Process {
        id: switchProc
        running: false
        command: []
        onExited: {
            launcherScope.currentTheme = launcherScope.themes[carousel.currentIndex].key;
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: ThemeLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:themelauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            readonly property int cardW: 190
            readonly property int cardH: 280
            property int selectedIndex: 0

            onVisibleChanged: {
                if (visible) {
                    readThemeProc.running = true;
                    root.selectedIndex = carousel.currentIndex;
                }
            }

            onSelectedIndexChanged: {
                carousel.positionViewAtIndex(selectedIndex, ListView.Center);
            }

            MouseArea {
                anchors.fill: parent
                onClicked: ThemeLauncherState.close()
            }

            Item {
                anchors.fill: parent
                focus: ThemeLauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        ThemeLauncherState.close();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        const t = launcherScope.themes[root.selectedIndex];
                        switchProc.command = ["/home/honey/.config/quickshell/scripts/switch-theme.sh", t.key];
                        switchProc.running = true;
                        ThemeLauncherState.close();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (root.selectedIndex < launcherScope.themes.length - 1)
                            root.selectedIndex++;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        if (root.selectedIndex > 0)
                            root.selectedIndex--;
                        event.accepted = true;
                    }
                }
            }

            ListView {
                id: carousel
                anchors.centerIn: parent
                width: parent.width
                height: root.cardH + 60
                orientation: ListView.Horizontal
                model: launcherScope.themes
                currentIndex: root.selectedIndex
                spacing: 24
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

                    required property var modelData
                    required property int index

                    property int offset: index - carousel.currentIndex
                    property real absOff: Math.abs(offset)
                    property real cardScale: Math.max(0.55, 1.0 - absOff * 0.18)
                    property real cardOpacity: Math.max(0.35, 1.0 - absOff * 0.22)
                    property bool isCurrent: modelData.key === launcherScope.currentTheme
                    property bool isSelected: offset === 0

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
                        radius: 14
                        color: modelData.base

                        // Accent stripe at top
                        Rectangle {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            height: 10
                            radius: 14
                            color: modelData.accent
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.left: parent.left
                                anchors.right: parent.right
                                height: 7
                                color: modelData.accent
                            }
                        }

                        // Surface swatch in the middle
                        Rectangle {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: -16
                            width: parent.width * 0.6
                            height: parent.width * 0.6
                            radius: 10
                            color: modelData.surface
                            border.color: modelData.accent
                            border.width: 1
                            opacity: 0.8
                        }

                        // Theme name
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: card.isCurrent ? 28 : 16
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.name
                            color: modelData.text
                            font.family: Theme.fontFamily
                            font.pointSize: 11
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Active indicator dot
                        Rectangle {
                            visible: card.isCurrent
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 12
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 6
                            height: 6
                            radius: 3
                            color: modelData.accent
                        }

                        // Selected border
                        Rectangle {
                            anchors.fill: parent
                            radius: 14
                            color: "transparent"
                            border.color: modelData.accent
                            border.width: card.isSelected ? 3 : 0
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (card.isSelected) {
                                switchProc.command = ["/home/honey/.config/quickshell/scripts/switch-theme.sh", modelData.key];
                                switchProc.running = true;
                                ThemeLauncherState.close();
                            } else {
                                root.selectedIndex = index;
                            }
                        }
                    }
                }
            }

            // Theme name below carousel
            Text {
                anchors.top: carousel.bottom
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                text: launcherScope.themes[root.selectedIndex]?.name ?? ""
                color: Theme.text
                font.family: Theme.fontFamily
                font.pointSize: 14
                font.bold: true
            }
        }
    }
}
