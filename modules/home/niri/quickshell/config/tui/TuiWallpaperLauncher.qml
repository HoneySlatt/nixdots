import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "services" as Services

Item {
    id: scope

    property var wallpapers: []
    property int selectedIndex: 0
    property string selectedWallpaper: ""
    property string lastTheme: ""
    property bool lastNsfw: false
    property bool wallpaperThumbnailsReady: false

    readonly property string thumbnailDir: "/home/honey/.cache/quickshell/wallpaper-launcher-tui/" + TuiTheme.currentTheme
    readonly property string selectedPath: wallpapers.length > 0 ? wallpapers[selectedIndex] : ""
    readonly property string selectedFile: selectedPath.length > 0 ? filenameFromPath(selectedPath) : ""

    function filenameFromPath(fullPath) { return fullPath.split("/").pop(); }
    function thumbnailPath(fullPath) { return "file://" + thumbnailDir + "/" + filenameFromPath(fullPath) + ".jpg"; }

    function doScan() {
        if (wallpapers.length > 0 && TuiTheme.currentTheme === lastTheme && TuiTheme.nsfwEnabled === lastNsfw) return;
        lastTheme = TuiTheme.currentTheme;
        lastNsfw = TuiTheme.nsfwEnabled;
        wallpaperThumbnailsReady = false;
        findProc.command = ["find", TuiTheme.wallpaperDir, "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"];
        findProc.running = true;
    }

    function forceRescan() {
        wallpapers = [];
        lastTheme = "";
        lastNsfw = false;
        selectedIndex = 0;
        wallpaperThumbnailsReady = false;
        doScan();
    }

    function select(delta) {
        if (wallpapers.length === 0) return;
        selectedIndex = Math.max(0, Math.min(wallpapers.length - 1, selectedIndex + delta));
    }

    function applySelected() {
        if (selectedPath.length === 0) return;
        selectedWallpaper = selectedPath;
        applyProc.wpPath = selectedPath;
        applyProc.running = true;
    }

    function shuffleSelection() {
        if (wallpapers.length === 0) return;
        let nextIndex = Math.floor(Math.random() * wallpapers.length);
        if (wallpapers.length > 1 && nextIndex === selectedIndex)
            nextIndex = (nextIndex + 1) % wallpapers.length;
        selectedIndex = nextIndex;
    }

    Process {
        id: findProc
        running: false
        property string buffer: ""
        command: ["true"]
        stdout: SplitParser {
            onRead: data => findProc.buffer += data + "\n"
        }
        onExited: {
            let lines = findProc.buffer.trim().split("\n").filter(l => l.length > 0);
            findProc.buffer = "";
            lines = TuiTheme.nsfwEnabled ? lines.filter(l => l.includes("[NSFW]")) : lines.filter(l => !l.includes("[NSFW]"));
            scope.wallpapers = lines;
            scope.selectedIndex = lines.length > 0 ? Math.floor(lines.length / 2) : 0;
            thumbProc.running = true;
        }
    }

    Process {
        id: thumbProc
        command: ["bash", "-c", "src=$1; cache=$2; nsfw=$3; mkdir -p \"$cache\" 2>/dev/null; find \"$src\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print0 | while IFS= read -r -d '' f; do base=${f##*/}; if [ \"$nsfw\" = true ]; then case \"$base\" in *[[]NSFW[]]*) ;; *) continue;; esac; else case \"$base\" in *[[]NSFW[]]*) continue;; esac; fi; out=\"$cache/$base.jpg\"; [ -s \"$out\" ] && continue; magick \"$f\" -auto-orient -thumbnail '1280x720^' -gravity center -extent 1280x720 -quality 90 \"$out\" 2>/dev/null; done", "thumbgen", TuiTheme.wallpaperDir, scope.thumbnailDir, TuiTheme.nsfwEnabled ? "true" : "false"]
        running: false
        onExited: scope.wallpaperThumbnailsReady = true
    }

    Process {
        id: applyProc
        property string wpPath: ""
        command: ["awww", "img", wpPath, "--transition-type", "wave", "--transition-duration", "2"]
        running: false
        onExited: TuiWallpaperLauncherState.close()
    }

    Connections {
        target: TuiTheme
        function onCurrentThemeChanged() { if (TuiWallpaperLauncherState.visible) scope.forceRescan(); }
        function onNsfwEnabledChanged() { if (TuiWallpaperLauncherState.visible) scope.forceRescan(); }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiWallpaperLauncherState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.focusedOutput === root.screen.name

            color: "transparent"

            WlrLayershell.namespace: "quickshell:tui:wallpaperlauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            Component.onCompleted: {
                if (TuiWallpaperLauncherState.visible) {
                    scope.doScan();
                    focusTimer.start();
                }
            }

            Timer {
                id: focusTimer
                interval: 80
                repeat: false
                onTriggered: panel.forceActiveFocus()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: TuiWallpaperLauncherState.close()
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: Math.min(root.width - 96, 1280)
                height: Math.min(root.height - 160, 760)
                color: TuiTheme.barBg
                border.color: TuiTheme.barBorder
                border.width: 1
                focus: TuiWallpaperLauncherState.visible

                readonly property int outerPad: 18
                readonly property int previewHeight: height - 190

                MouseArea { anchors.fill: parent; onClicked: panel.forceActiveFocus() }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        TuiWallpaperLauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        scope.applySelected();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Right || event.key === Qt.Key_Down || event.key === Qt.Key_J || event.key === Qt.Key_L) {
                        scope.select(1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Left || event.key === Qt.Key_Up || event.key === Qt.Key_K || event.key === Qt.Key_H) {
                        scope.select(-1);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_R) {
                        scope.forceRescan();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_S) {
                        scope.shuffleSelection();
                        event.accepted = true;
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    color: "transparent"
                    border.color: TuiTheme.barInnerBorder
                    border.width: 1
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: panel.outerPad
                    spacing: 14

                    Rectangle {
                        width: parent.width
                        height: panel.previewHeight
                        color: "transparent"
                        border.color: TuiTheme.barInnerBorder
                        border.width: 1
                        clip: true

                        Image {
                            anchors.centerIn: parent
                            width: parent.width - 4
                            height: parent.height - 4
                            source: scope.selectedPath.length > 0 && scope.wallpaperThumbnailsReady ? scope.thumbnailPath(scope.selectedPath) : ""
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            mipmap: true
                            sourceSize.width: 1280
                            sourceSize.height: 720
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: scope.wallpapers.length === 0
                            text: "no wallpapers"
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                        }

                        Rectangle {
                            visible: scope.selectedWallpaper === scope.selectedPath && scope.selectedPath.length > 0
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: 18
                            height: 18
                            color: TuiTheme.highlight
                        }
                    }

                    Row {
                        width: parent.width
                        height: 74
                        spacing: 12

                        Rectangle {
                            width: 48
                            height: parent.height
                            color: "transparent"
                            border.color: TuiTheme.barInnerBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "<"
                                color: TuiTheme.barText
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.barIconSize
                                font.weight: TuiTheme.fontWeight
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: scope.select(-1)
                            }
                        }

                        ListView {
                            id: strip
                            width: parent.width - 120
                            height: parent.height
                            orientation: ListView.Horizontal
                            model: scope.wallpapers
                            currentIndex: scope.selectedIndex
                            spacing: 12
                            clip: true
                            interactive: false
                            boundsBehavior: Flickable.StopAtBounds
                            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                            delegate: Rectangle {
                                required property string modelData
                                required property int index
                                width: 132
                                height: 70
                                color: "transparent"
                                border.color: index === scope.selectedIndex ? TuiTheme.highlight : TuiTheme.barInnerBorder
                                border.width: index === scope.selectedIndex ? 2 : 1
                                clip: true

                                Image {
                                    anchors.centerIn: parent
                                    width: parent.width - 6
                                    height: parent.height - 6
                                    source: scope.wallpaperThumbnailsReady ? scope.thumbnailPath(modelData) : ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                    smooth: true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onEntered: scope.selectedIndex = index
                                    onClicked: scope.applySelected()
                                }
                            }
                        }

                        Rectangle {
                            width: 48
                            height: parent.height
                            color: "transparent"
                            border.color: TuiTheme.barInnerBorder
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: ">"
                                color: TuiTheme.barText
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.barIconSize
                                font.weight: TuiTheme.fontWeight
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: scope.select(1)
                            }
                        }
                    }

                    Item {
                        width: parent.width
                        height: 44

                        Row {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 12

                            Rectangle {
                                width: 120
                                height: 36
                                color: "transparent"
                                border.color: TuiTheme.highlight
                                border.width: 2

                                Text {
                                    anchors.centerIn: parent
                                    text: "[ Apply ]"
                                    color: TuiTheme.highlight
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: scope.applySelected()
                                }
                            }

                            Rectangle {
                                width: 136
                                height: 36
                                color: "transparent"
                                border.color: TuiTheme.barInnerBorder
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "[ Shuffle ]"
                                    color: TuiTheme.barText
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: scope.shuffleSelection()
                                }
                            }
                        }

                        Text {
                            anchors.left: parent.left
                            anchors.bottom: parent.bottom
                            text: "Arrows/HJKL: Navigate   Enter: Apply   S: Shuffle   R: Reload   Esc: Cancel"
                            color: TuiTheme.barMuted
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize - 1
                            font.weight: TuiTheme.fontWeight
                        }
                    }
                }
            }
        }
    }
}
