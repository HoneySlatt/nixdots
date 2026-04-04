import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    property var wallpapers: []

    readonly property var themeDirs: ({
        "pastelglow":    "PastelGlow",
        "rosepine":      "RosePine",
        "carbonfox":     "Carbonfox",
        "gruvbox":       "GruvboxDark",
        "gruvbox-light": "GruvboxLight",
        "everforest":    "Everforest"
    })

    Process {
        id: findProc
        running: false
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => findProc.buffer += data + "\n"
        }
        onExited: {
            const lines = findProc.buffer.trim().split("\n").filter(l => l.length > 0);
            launcherScope.wallpapers = lines;
            findProc.buffer = "";
            const mid = Math.floor(lines.length / 2);
            carousel.currentIndex = mid;
            carousel.positionViewAtIndex(mid, ListView.Center);
        }
    }

    Process {
        id: applyProc
        running: false
        command: []
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: WallpaperLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:wallpaperlauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            readonly property int cardW: 320
            readonly property int cardH: 180
            property int selectedIndex: 0

            onVisibleChanged: {
                if (visible) {
                    launcherScope.wallpapers = [];
                    root.selectedIndex = 0;
                    const dir = launcherScope.themeDirs[Theme.currentTheme] ?? "Carbonfox";
                    const path = "/home/honey/Pictures/Wallpapers/" + dir;
                    findProc.command = ["find", path, "-type", "f",
                        "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", ")"];
                    findProc.running = true;
                }
            }

            onSelectedIndexChanged: {
                carousel.positionViewAtIndex(selectedIndex, ListView.Center);
            }

            MouseArea {
                anchors.fill: parent
                onClicked: WallpaperLauncherState.close()
            }

            Item {
                anchors.fill: parent
                focus: WallpaperLauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        WallpaperLauncherState.close();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (launcherScope.wallpapers.length > 0) {
                            applyProc.command = ["awww", "img", launcherScope.wallpapers[root.selectedIndex],
                                "--transition-type", "wave", "--transition-duration", "2"];
                            applyProc.running = true;
                            WallpaperLauncherState.close();
                        }
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (root.selectedIndex < launcherScope.wallpapers.length - 1)
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
                model: launcherScope.wallpapers
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

                    required property string modelData
                    required property int index

                    property int offset: index - carousel.currentIndex
                    property real absOff: Math.abs(offset)
                    property real cardScale: Math.max(0.55, 1.0 - absOff * 0.18)
                    property real cardOpacity: Math.max(0.35, 1.0 - absOff * 0.22)
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
                        radius: 10
                        color: Theme.separator
                        clip: true

                        Image {
                            anchors.fill: parent
                            source: "file://" + modelData
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: "transparent"
                            border.color: Theme.highlight
                            border.width: card.isSelected ? 3 : 0
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (card.isSelected) {
                                applyProc.command = ["awww", "img", modelData,
                                    "--transition-type", "wave", "--transition-duration", "2"];
                                applyProc.running = true;
                                WallpaperLauncherState.close();
                            } else {
                                root.selectedIndex = index;
                            }
                        }
                    }
                }
            }

            // Wallpaper filename below carousel
            Text {
                anchors.top: carousel.bottom
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                text: {
                    const p = launcherScope.wallpapers[root.selectedIndex] ?? "";
                    return p.split("/").pop();
                }
                color: Theme.text
                font.family: Theme.fontFamily
                font.pointSize: 12
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
