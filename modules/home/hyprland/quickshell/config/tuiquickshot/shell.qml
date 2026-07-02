import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import QtCore

import "src"
import "."

FreezeScreen {
    id: root

    visible: false

    property var activeScreen: null
    property var hyprlandMonitor: Hyprland.focusedMonitor
    property string tempPath: ""
    property string mode: "region"
    property bool recordMode: false

    targetScreen: activeScreen

    function prepareScreen() {
        const monitor = Hyprland.focusedMonitor;
        if (!monitor) return;

        root.hyprlandMonitor = monitor;
        for (const screen of Quickshell.screens) {
            if (screen.name !== monitor.name) continue;

            root.activeScreen = screen;
            const timestamp = Date.now();
            const path = Quickshell.cachePath(`tuiquickshot-${timestamp}.png`);
            root.tempPath = path;
            Quickshell.execDetached(["grim", "-g", `${screen.x},${screen.y} ${screen.width}x${screen.height}`, path]);
            showTimer.start();
            return;
        }
    }

    function cancel() {
        if (root.tempPath.length > 0) Quickshell.execDetached(["rm", "-f", root.tempPath]);
        Qt.quit();
    }

    function setMode(nextMode) {
        root.mode = nextMode;
        if (nextMode === "screen") processCurrentScreen();
    }

    function toggleRecordMode() {
        root.recordMode = !root.recordMode;
    }

    function processCurrentScreen() {
        if (!root.targetScreen) return;
        if (root.recordMode) {
            processRecording(0, 0, root.targetScreen.width, root.targetScreen.height);
        } else {
            processScreenshot(0, 0, root.targetScreen.width, root.targetScreen.height);
        }
    }

    function processScreenshot(x, y, width, height) {
        const scale = root.hyprlandMonitor.scale;
        const scaledX = Math.round(x * scale);
        const scaledY = Math.round(y * scale);
        const scaledWidth = Math.round(width * scale);
        const scaledHeight = Math.round(height * scale);

        const picturesDir = Quickshell.env("HQS_DIR") || Quickshell.env("XDG_SCREENSHOTS_DIR") || Quickshell.env("XDG_PICTURES_DIR") || (Quickshell.env("HOME") + "/Pictures");
        const screenshotsDir = `${picturesDir}/Screenshots`;

        actionProcess.command = ["sh", "-c",
            `dir="${screenshotsDir}"; ` +
            `mkdir -p "$dir"; ` +
            `last=$(ls "$dir"/Screenshot_*.png 2>/dev/null | grep -oE '[0-9]+\\.png' | grep -oE '^[0-9]+' | sort -n | tail -1); ` +
            `last=$((10#\${last:-0})); ` +
            `n=$(( last + 1 )); ` +
            `out="$dir/Screenshot_$(printf "%02d" $n).png"; ` +
            `magick "${root.tempPath}" -crop ${scaledWidth}x${scaledHeight}+${scaledX}+${scaledY} "$out" && ` +
            `wl-copy < "$out" && ` +
            `rm -f "${root.tempPath}" && ` +
            `notify-send -i "$out" "Screenshot" "Screenshot_$(printf "%02d" $n).png"`
        ];

        actionProcess.running = true;
        root.visible = false;
    }

    function processRecording(x, y, width, height) {
        const videosDir = Quickshell.env("XDG_VIDEOS_DIR") || (Quickshell.env("HOME") + "/Videos");
        const screencastsDir = `${videosDir}/Screencasts`;
        const screenX = root.activeScreen ? root.activeScreen.x : 0;
        const screenY = root.activeScreen ? root.activeScreen.y : 0;

        const baseCmd = `AUDIO=$(pactl get-default-sink).monitor; dir="${screencastsDir}"; mkdir -p "$dir"; last=$(ls "$dir"/Screencast_*.mp4 2>/dev/null | grep -oE '[0-9]+\\.mp4' | grep -oE '^[0-9]+' | sort -n | tail -1); last=$((10#\${last:-0})); n=$(( last + 1 )); out="$dir/Screencast_$(printf "%02d" $n).mp4"; `;
        const wfFlags = `--audio="$AUDIO" -c libx264rgb -x bgr0 -p crf=15 -p preset=ultrafast`;
        const notifyCmd = `; notify-send -i video-x-generic "Screencast" "Screencast_$(printf "%02d" $n).mp4"`;
        const cmd = root.mode === "screen"
            ? ["sh", "-c", baseCmd + `wf-recorder -o '${root.hyprlandMonitor.name}' ${wfFlags} -f "$out"` + notifyCmd]
            : ["sh", "-c", baseCmd + `wf-recorder -g '${screenX + x},${screenY + y} ${width}x${height}' ${wfFlags} -f "$out"` + notifyCmd];

        Quickshell.execDetached(["rm", "-f", root.tempPath]);
        Quickshell.execDetached(cmd);
        root.visible = false;
        Qt.quit();
    }

    Component.onCompleted: prepareScreen()

    Connections {
        target: Hyprland
        enabled: root.activeScreen === null
        function onFocusedMonitorChanged() { root.prepareScreen(); }
    }

    Shortcut { sequence: "Escape"; onActivated: root.cancel() }
    Shortcut { sequence: "1"; onActivated: root.setMode("region") }
    Shortcut { sequence: "2"; onActivated: root.setMode("window") }
    Shortcut { sequence: "3"; onActivated: root.setMode("screen") }
    Shortcut { sequence: "Tab"; onActivated: root.toggleRecordMode() }
    Shortcut {
        sequence: "Return"
        onActivated: {
            if (root.mode === "screen") root.processCurrentScreen();
        }
    }

    Timer {
        id: showTimer
        interval: 50
        repeat: false
        onTriggered: root.visible = true
    }

    Process {
        id: actionProcess
        running: false
        onExited: Qt.quit()

        stdout: StdioCollector { onStreamFinished: console.log(this.text) }
        stderr: StdioCollector { onStreamFinished: console.log(this.text) }
    }

    RegionSelector {
        visible: root.mode === "region"
        anchors.fill: parent

        onRegionSelected: (x, y, width, height) => {
            if (root.recordMode) root.processRecording(x, y, width, height);
            else root.processScreenshot(x, y, width, height);
        }
    }

    WindowSelector {
        visible: root.mode === "window"
        anchors.fill: parent
        monitor: root.hyprlandMonitor

        onRegionSelected: (x, y, width, height) => {
            if (root.recordMode) root.processRecording(x, y, width, height);
            else root.processScreenshot(x, y, width, height);
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 36
        width: 620
        height: 92
        color: TuiQuickshotTheme.bg
        border.color: TuiQuickshotTheme.accent
        border.width: 2

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Row {
                width: parent.width
                height: 18
                spacing: 0

                Text {
                    text: "quickshot"
                    color: TuiQuickshotTheme.bright
                    font.family: TuiQuickshotTheme.fontFamily
                    font.pixelSize: TuiQuickshotTheme.fontSize
                    font.weight: TuiQuickshotTheme.fontWeight
                }

                Text {
                    text: " :: " + (root.recordMode ? "record" : "shot") + " :: " + root.mode
                    color: root.recordMode ? TuiQuickshotTheme.warn : TuiQuickshotTheme.fg
                    font.family: TuiQuickshotTheme.fontFamily
                    font.pixelSize: TuiQuickshotTheme.fontSize
                    font.weight: TuiQuickshotTheme.fontWeight
                }
            }

            Row {
                spacing: 8

                Repeater {
                    model: [
                        { key: "1", mode: "region" },
                        { key: "2", mode: "window" },
                        { key: "3", mode: "screen" }
                    ]

                    Rectangle {
                        required property var modelData

                        width: 128
                        height: 30
                        color: root.mode === modelData.mode ? TuiQuickshotTheme.accent : "transparent"
                        border.color: root.mode === modelData.mode ? TuiQuickshotTheme.bright : TuiQuickshotTheme.dim
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "[" + modelData.key + "] " + modelData.mode
                            color: root.mode === modelData.mode ? TuiQuickshotTheme.bg : TuiQuickshotTheme.fg
                            font.family: TuiQuickshotTheme.fontFamily
                            font.pixelSize: TuiQuickshotTheme.fontSize
                            font.weight: TuiQuickshotTheme.fontWeight
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.setMode(modelData.mode)
                        }
                    }
                }

                Rectangle {
                    width: 92
                    height: 30
                    color: root.recordMode ? TuiQuickshotTheme.warn : "transparent"
                    border.color: root.recordMode ? TuiQuickshotTheme.warn : TuiQuickshotTheme.dim
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "[tab] " + (root.recordMode ? "rec" : "shot")
                        color: root.recordMode ? TuiQuickshotTheme.bg : TuiQuickshotTheme.fg
                        font.family: TuiQuickshotTheme.fontFamily
                        font.pixelSize: TuiQuickshotTheme.fontSize
                        font.weight: TuiQuickshotTheme.fontWeight
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleRecordMode()
                    }
                }
            }

            Text {
                text: "drag: select region/window  |  enter: capture screen  |  esc: cancel"
                color: TuiQuickshotTheme.dim
                font.family: TuiQuickshotTheme.fontFamily
                font.pixelSize: TuiQuickshotTheme.fontSize - 1
                font.weight: TuiQuickshotTheme.fontWeight
            }
        }
    }
}
