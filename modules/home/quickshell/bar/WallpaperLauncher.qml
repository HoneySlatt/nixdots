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

    // Read list of wallpapers for current theme
    Process {
        id: findProc
        running: false
        property string buffer: ""
        stdout: SplitParser {
            onRead: data => findProc.buffer += data + "\n"
        }
        onExited: {
            const lines = findProc.buffer.trim().split("\n").filter(l => l.length > 0);
            findProc.buffer = "";
            launcherScope.wallpapers = lines;
        }
    }


    Process {
        id: applyProc
        running: false
        command: []
        onExited: WallpaperLauncherState.close()
    }

    function applyWallpaper(path) {
        applyProc.command = ["awww", "img", path, "--transition-type", "wave", "--transition-duration", "2"];
        applyProc.running = true;
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

            readonly property int cardW: 640
            readonly property int cardH: 360
            property int selectedIndex: 0


            onVisibleChanged: {
                if (visible) {
                    launcherScope.wallpapers = [];
                    root.selectedIndex = 0;
                    const dir = launcherScope.themeDirs[Theme.currentTheme] ?? "Carbonfox";
                    findProc.command = ["find", "/home/honey/Pictures/Wallpapers/" + dir, "-type", "f",
                        "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", ")"];
                    findProc.running = true;
                }
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
                        if (launcherScope.wallpapers.length > 0)
                            launcherScope.applyWallpaper(launcherScope.wallpapers[root.selectedIndex]);
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
                highlightMoveDuration: 0

                preferredHighlightBegin: (width - root.cardW) / 2
                preferredHighlightEnd:   (width + root.cardW) / 2
                highlightRangeMode: ListView.StrictlyEnforceRange

                onCountChanged: {
                    if (count > 0) {
                        Qt.callLater(function() {
                            root.selectedIndex = Math.floor(carousel.count / 2);
                            carousel.positionViewAtIndex(root.selectedIndex, ListView.Center);
                        });
                    }
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
                            if (card.isSelected)
                                launcherScope.applyWallpaper(modelData);
                            else
                                root.selectedIndex = index;
                        }
                    }
                }
            }
        }
    }
}
