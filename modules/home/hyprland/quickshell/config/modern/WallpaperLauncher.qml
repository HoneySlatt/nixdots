import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    property var wallpapers: []
    property string lastTheme: ""
    property bool lastNsfw: false
    property bool wallpaperThumbnailsReady: false
    readonly property string thumbnailDir: "/home/honey/.cache/quickshell/wallpaper-launcher/" + Theme.currentTheme

    function filenameFromPath(fullPath) {
        return fullPath.split("/").pop();
    }

    function thumbnailPath(fullPath) {
        return "file://" + thumbnailDir + "/" + filenameFromPath(fullPath) + ".jpg";
    }

    function doScan() {
        if (wallpapers.length > 0 && Theme.currentTheme === lastTheme && Theme.nsfwEnabled === lastNsfw) return;
        lastTheme = Theme.currentTheme;
        lastNsfw = Theme.nsfwEnabled;
        wallpaperThumbnailsReady = false;
        const dir = Theme.wallpaperDir;
        findProc.command = ["find", dir, "-type", "f",
            "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")"];
        findProc.running = true;
    }

    function forceRescan() {
        wallpapers = [];
        lastTheme = "";
        lastNsfw = false;
        wallpaperThumbnailsReady = false;
        doScan();
    }

    function applyWallpaper(path) {
        applyProc.command = ["awww", "img", path, "--transition-type", "wave", "--transition-duration", "2"];
        applyProc.running = true;
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
            if (Theme.nsfwEnabled) {
                lines = lines.filter(l => l.includes("[NSFW]"));
            } else {
                lines = lines.filter(l => !l.includes("[NSFW]"));
            }
            launcherScope.wallpapers = lines;
            thumbProc.running = true;
        }
    }

    Process {
        id: thumbProc
        command: ["bash", "-c",
            "src=$1; cache=$2; nsfw=$3; mkdir -p \"$cache\" 2>/dev/null; find \"$src\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print0 | while IFS= read -r -d '' f; do base=${f##*/}; if [ \"$nsfw\" = true ]; then case \"$base\" in *[[]NSFW[]]*) ;; *) continue;; esac; else case \"$base\" in *[[]NSFW[]]*) continue;; esac; fi; out=\"$cache/$base.jpg\"; [ -s \"$out\" ] && continue; magick \"$f\" -auto-orient -thumbnail '1280x720^' -gravity center -extent 1280x720 -quality 90 \"$out\" 2>/dev/null; done",
            "thumbgen", Theme.wallpaperDir, launcherScope.thumbnailDir, Theme.nsfwEnabled ? "true" : "false"
        ]
        running: false
        onExited: launcherScope.wallpaperThumbnailsReady = true
    }

    Process {
        id: applyProc
        running: false
        command: []
        onExited: WallpaperLauncherState.close()
    }

    Connections {
        target: Theme
        function onCurrentThemeChanged() {
            if (WallpaperLauncherState.visible) launcherScope.forceRescan();
        }
        function onNsfwEnabledChanged() {
            if (WallpaperLauncherState.visible) launcherScope.forceRescan();
        }
    }

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

    component ArrowButton: Rectangle {
        id: arrowBtn

        property string icon: ""
        signal clicked()

        width: 50
        height: 66
        radius: 14
        color: arrowMouse.containsMouse
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
            : Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.28)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.34)
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: arrowBtn.icon
            color: arrowMouse.containsMouse ? Theme.text : Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 9
            font.weight: Font.Bold
        }

        MouseArea {
            id: arrowMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: arrowBtn.clicked()
        }
    }

    component ActionButton: Rectangle {
        id: actionButton

        property string icon: ""
        property string label: ""
        property bool primary: false
        signal clicked()

        width: 138
        height: 46
        radius: 12
        color: primary
            ? (buttonMouse.containsMouse ? Qt.tint(Theme.accent, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.14)) : Theme.accent)
            : (buttonMouse.containsMouse ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.075) : Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.30))
        border.color: primary
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.62)
            : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.24)
        border.width: 1

        RowLayout {
            anchors.centerIn: parent
            spacing: 9

            Text {
                text: actionButton.icon
                color: primary ? Theme.background : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 3
                font.weight: Font.Bold
            }

            Text {
                text: actionButton.label
                color: primary ? Theme.background : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.Bold
            }
        }

        MouseArea {
            id: buttonMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actionButton.clicked()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: WallpaperLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: Hyprland.focusedMonitor?.id == monitor?.id
            onMonitorIsFocusedChanged: if (!monitorIsFocused) WallpaperLauncherState.close()

            color: "transparent"

            WlrLayershell.namespace: "quickshell:wallpaperlauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore

            anchors { top: true; bottom: true; left: true; right: true }

            property int selectedIndex: 0
            function currentWallpaper() {
                if (launcherScope.wallpapers.length === 0) return "";
                return launcherScope.wallpapers[selectedIndex];
            }

            function centerThumbnails() {
                if (launcherScope.wallpapers.length > 0)
                    thumbList.positionViewAtIndex(selectedIndex, ListView.Center);
            }

            function selectMiddle() {
                if (launcherScope.wallpapers.length > 0) {
                    selectedIndex = Math.floor(launcherScope.wallpapers.length / 2);
                    Qt.callLater(centerThumbnails);
                } else {
                    selectedIndex = 0;
                }
            }

            function shuffleSelection() {
                if (launcherScope.wallpapers.length === 0) return;
                selectedIndex = Math.floor(Math.random() * launcherScope.wallpapers.length);
                centerThumbnails();
            }

            onVisibleChanged: {
                if (visible) {
                    launcherScope.doScan();
                    selectMiddle();
                    focusTimer.start();
                }
            }

            onSelectedIndexChanged: centerThumbnails()

            Connections {
                target: launcherScope
                function onWallpapersChanged() {
                    if (WallpaperLauncherState.visible) root.selectMiddle();
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => {
                    if (!active) WallpaperLauncherState.close();
                }
            }

            Connections {
                target: WallpaperLauncherState
                function onVisibleChanged() {
                    if (WallpaperLauncherState.visible) {
                        grabTimer.start();
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
                onTriggered: grab.active = WallpaperLauncherState.visible
            }

            Timer {
                id: focusTimer
                interval: 80
                repeat: false
                onTriggered: panel.forceActiveFocus()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.58)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: WallpaperLauncherState.close()
            }

            GlassPanel {
                id: panel
                anchors.centerIn: parent
                width: Math.min(parent.width - 80, 1180)
                height: Math.min(parent.height - 72, 790)
                focus: WallpaperLauncherState.visible
                fillColor: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, Theme.popupOpacity)

                MouseArea { anchors.fill: parent; onClicked: panel.forceActiveFocus() }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        WallpaperLauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.currentWallpaper() !== "") launcherScope.applyWallpaper(root.currentWallpaper());
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                        if (root.selectedIndex > 0) root.selectedIndex--;
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                        if (root.selectedIndex < launcherScope.wallpapers.length - 1) root.selectedIndex++;
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_S) {
                        root.shuffleSelection();
                        event.accepted = true;
                    }
                }

                Rectangle {
                    id: previewFrame
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.topMargin: 32
                    anchors.leftMargin: 82
                    anchors.rightMargin: 82
                    height: Math.max(260, parent.height - 262)
                    radius: 16
                    color: Theme.separator
                    clip: true

                    Image {
                        anchors.fill: parent
                        source: root.currentWallpaper() !== "" && launcherScope.wallpaperThumbnailsReady
                            ? launcherScope.thumbnailPath(root.currentWallpaper())
                            : ""
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        asynchronous: true
                        cache: true
                        sourceSize: Qt.size(1280, 720)
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: launcherScope.wallpapers.length === 0
                        text: "No wallpapers found"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        font.weight: Theme.fontWeight
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "transparent"
                        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.30)
                        border.width: 1
                    }
                }

                Row {
                    id: thumbnailStrip
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: previewFrame.bottom
                    anchors.topMargin: 26
                    anchors.leftMargin: 28
                    anchors.rightMargin: 28
                    height: 88
                    spacing: 18

                    ArrowButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "\uf053"
                        onClicked: if (root.selectedIndex > 0) root.selectedIndex--
                    }

                    ListView {
                        id: thumbList
                        width: parent.width - 136
                        height: parent.height
                        anchors.verticalCenter: parent.verticalCenter
                        orientation: ListView.Horizontal
                        model: launcherScope.wallpapers
                        currentIndex: root.selectedIndex
                        spacing: 16
                        clip: true
                        interactive: false
                        highlight: Item {}
                        highlightFollowsCurrentItem: true
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                        delegate: Item {
                            id: thumbCard

                            required property string modelData
                            required property int index

                            width: 150
                            height: 84
                            property bool isSelected: index === root.selectedIndex

                            Rectangle {
                                visible: thumbCard.isSelected
                                anchors.fill: thumbFrame
                                anchors.margins: -5
                                radius: thumbFrame.radius + 5
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.14)
                                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.28)
                                border.width: 2
                            }

                            Rectangle {
                                id: thumbFrame
                                anchors.fill: parent
                                radius: 12
                                color: Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.34)
                                clip: true

                                Image {
                                    anchors.fill: parent
                                    source: launcherScope.wallpaperThumbnailsReady
                                        ? launcherScope.thumbnailPath(thumbCard.modelData)
                                        : "file://" + thumbCard.modelData
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    asynchronous: true
                                    cache: true
                                    sourceSize: Qt.size(360, 240)
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: parent.radius
                                    color: "transparent"
                                    border.color: thumbCard.isSelected
                                        ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.90)
                                        : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.12)
                                    border.width: thumbCard.isSelected ? 2 : 1
                                }

                                Rectangle {
                                    visible: thumbCard.isSelected
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: -1
                                    anchors.rightMargin: -1
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.96)

                                    Text {
                                        anchors.centerIn: parent
                                        text: "\uf00c"
                                        color: Theme.background
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize + 5
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (thumbCard.isSelected) launcherScope.applyWallpaper(thumbCard.modelData);
                                    else root.selectedIndex = thumbCard.index;
                                }
                            }
                        }
                    }

                    ArrowButton {
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "\uf054"
                        onClicked: if (root.selectedIndex < launcherScope.wallpapers.length - 1) root.selectedIndex++
                    }
                }

                Rectangle {
                    id: separator
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: thumbnailStrip.bottom
                    anchors.topMargin: 16
                    anchors.leftMargin: 28
                    anchors.rightMargin: 28
                    height: 1
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22)
                }

                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: separator.bottom
                    anchors.topMargin: 10
                    anchors.leftMargin: 40
                    anchors.rightMargin: 28
                    height: 48

                    Item { Layout.fillWidth: true }

                    Row {
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 12

                        ActionButton {
                            icon: "\uf00c"
                            label: "Apply"
                            primary: true
                            onClicked: if (root.currentWallpaper() !== "") launcherScope.applyWallpaper(root.currentWallpaper())
                        }

                        ActionButton {
                            icon: "\uf074"
                            label: "Shuffle"
                            onClicked: root.shuffleSelection()
                        }
                    }
                }
            }
        }
    }
}
