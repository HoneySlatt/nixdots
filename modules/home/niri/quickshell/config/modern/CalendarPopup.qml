import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "services" as Services
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: calendarPopup

    property date now: new Date()
    property color coverAccentColor: Theme.accent
    property var cavaValues: []
    property var wallpaperList: []
    property int wallpaperPage: 0
    readonly property string wallpaperThumbnailDir: "/home/honey/.cache/quickshell/wallpapers/" + Theme.currentTheme
    readonly property int wallpapersPerPage: 12
    readonly property int wallpaperTotalPages: Math.max(1, Math.ceil(wallpaperList.length / wallpapersPerPage))
    property string selectedWallpaper: ""
    property bool wallpaperThumbnailsReady: false
    property string uptimeText: ""
    property string hostname: "System"
    property real currentPosition: player ? player.position : 0

    Process {
        id: hostnameProc
        command: ["hostname"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const h = this.text.trim();
                if (h.length > 0) calendarPopup.hostname = h;
            }
        }
    }

    Component.onCompleted: hostnameProc.running = true

    readonly property MprisPlayer player: {
        const players = Mpris.players.values;
        if (players.length === 0) return null;
        const playing = players.find(p => p.playbackState === MprisPlaybackState.Playing);
        return playing ?? players[0];
    }

    readonly property real trackLength: {
        if (!player) return 0;
        const length = player.length;
        if (isNaN(length) || length < 0) return 0;
        return length > 86400 ? length / 1000000 : length;
    }

    readonly property var tabItems: [
        { label: "Media", icon: "\uf001", idx: 1 },
        { label: "Wallpapers", icon: "\uf03e", idx: 2 },
        { label: "Themes", icon: "\uf1fc", idx: 3 }
    ]

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0 || seconds > 86400) return "--:--";
        const minutes = Math.floor(seconds / 60);
        const remaining = Math.floor(seconds % 60);
        return minutes + ":" + (remaining < 10 ? "0" : "") + remaining;
    }

    function resetWallpaperScan() {
        wallpaperList = [];
        wallpaperPage = 0;
        selectedWallpaper = "";
        wallpaperThumbnailsReady = false;
        if (CalendarPopupState.visible && CalendarPopupState.activeTab === 2)
            wallpaperScanProc.running = true;
    }

    function wallpaperThumbnailPath(filename) {
        return wallpaperThumbnailDir + "/" + filename + ".jpg";
    }

    function applyWallpaper(filename) {
        selectedWallpaper = filename;
        wallpaperApplyProc.wallpaperPath = Theme.wallpaperDir + "/" + filename;
        wallpaperApplyProc.running = true;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: calendarPopup.now = new Date()
    }

    Process {
        id: wallpaperScanProc
        command: ["find", Theme.wallpaperDir, "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.png", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.webp", ")", "-printf", "%f\n"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let files = this.text.trim().split("\n").filter(f => f.length > 0);
                files = Theme.nsfwEnabled ? files.filter(f => f.includes("[NSFW]")) : files.filter(f => !f.includes("[NSFW]"));
                files.sort();
                calendarPopup.wallpaperList = files;
                calendarPopup.wallpaperThumbnailsReady = false;
                wallpaperThumbProc.running = true;
            }
        }
    }

    Process {
        id: wallpaperThumbProc
        command: [
            "bash", "-c",
            "src=$1; cache=$2; nsfw=$3; mkdir -p \"$cache\" || exit 0; find \"$src\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print0 | while IFS= read -r -d '' f; do base=${f##*/}; if [ \"$nsfw\" = true ]; then case \"$base\" in *[[]NSFW[]]*) ;; *) continue;; esac; else case \"$base\" in *[[]NSFW[]]*) continue;; esac; fi; out=\"$cache/$base.jpg\"; [ -s \"$out\" ] && continue; magick \"$f\" -auto-orient -thumbnail '360x240^' -gravity center -extent 360x240 -quality 82 \"$out\" 2>/dev/null; done",
            "thumbgen", Theme.wallpaperDir, calendarPopup.wallpaperThumbnailDir, Theme.nsfwEnabled ? "true" : "false"
        ]
        running: false
        onExited: calendarPopup.wallpaperThumbnailsReady = true
    }

    Process {
        id: wallpaperApplyProc
        property string wallpaperPath: ""
        command: ["awww", "img", wallpaperPath, "--transition-type", "wave", "--transition-duration", "2"]
        running: false
    }

    Process {
        id: uptimeProc
        command: ["/bin/sh", "-c", "awk '{s=int($1); printf \"%dh %dm\\n\", s/3600, (s%3600)/60}' /proc/uptime"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                const raw = this.text.trim();
                if (raw.length > 0) calendarPopup.uptimeText = raw;
            }
        }
    }

    Timer {
        interval: 60000
        running: CalendarPopupState.visible
        repeat: true
        triggeredOnStart: true
        onTriggered: uptimeProc.running = true
    }

    Timer {
        interval: 1000
        running: CalendarPopupState.visible && calendarPopup.player !== null && calendarPopup.player.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: {
            if (calendarPopup.player) calendarPopup.currentPosition = calendarPopup.player.position;
        }
    }

    Process {
        command: ["bash", "-c", "cava -p <(printf '[general]\\nbars = 32\\nframerate = 30\\n\\n[output]\\nmethod = raw\\nraw_target = /dev/stdout\\ndata_format = ascii\\nascii_max_range = 20\\n')"]
        running: CalendarPopupState.visible && CalendarPopupState.activeTab === 1
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const trimmed = data.trim();
                if (trimmed.length > 0) calendarPopup.cavaValues = trimmed.split(";").map(v => parseInt(v) || 0);
            }
        }
        onRunningChanged: {
            if (!running) calendarPopup.cavaValues = [];
        }
    }

    Connections {
        target: Theme
        function onCurrentThemeChanged() { calendarPopup.resetWallpaperScan(); }
        function onNsfwEnabledChanged() { calendarPopup.resetWallpaperScan(); }
    }

    Connections {
        target: CalendarPopupState
        function onVisibleChanged() {
            if (CalendarPopupState.visible && calendarPopup.wallpaperList.length === 0)
                wallpaperScanProc.running = true;
        }
        function onActiveTabChanged() {
            if (CalendarPopupState.visible && CalendarPopupState.activeTab === 2 && calendarPopup.wallpaperList.length === 0)
                wallpaperScanProc.running = true;
        }
    }

    component GlassCard: Rectangle {
        property color fillColor: Theme.card

        radius: 22
        color: "transparent"
        border.color: Qt.tint(Theme.separator, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.26))
        border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.tint(fillColor, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.060)) }
            GradientStop { position: 0.55; color: fillColor }
            GradientStop { position: 1.0; color: Qt.tint(fillColor, Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.18)) }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 20
            anchors.rightMargin: 20
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
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.10)
            border.width: 1
        }
    }

    component GlowNumber: Item {
        id: glowNumber

        property string value: ""
        property int pixelSize: 42
        property bool active: false

        implicitWidth: face.implicitWidth + 10
        implicitHeight: face.implicitHeight

        Text {
            visible: glowNumber.active
            anchors.centerIn: parent
            text: glowNumber.value
            color: Theme.accent
            opacity: 0.24
            scale: 1.16
            font.family: Theme.fontFamily
            font.pixelSize: glowNumber.pixelSize
            font.weight: Font.Bold
        }

        Text {
            visible: glowNumber.active
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 1
            text: glowNumber.value
            color: Theme.accent
            opacity: 0.18
            scale: 1.08
            font.family: Theme.fontFamily
            font.pixelSize: glowNumber.pixelSize
            font.weight: Font.Bold
        }

        Text {
            id: face
            anchors.centerIn: parent
            text: glowNumber.value
            color: glowNumber.active ? Qt.tint(Theme.accent, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.26)) : Theme.accent
            font.family: Theme.fontFamily
            font.pixelSize: glowNumber.pixelSize
            font.weight: Font.Bold
        }
    }

    component RailButton: Rectangle {
        id: railButton

        property string icon: ""
        property bool active: false
        signal clicked()

        width: 58
        height: 58
        radius: 29
        color: railMouse.containsMouse && !active ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.035) : "transparent"
        border.color: "transparent"

        Rectangle {
            visible: railButton.active
            anchors.centerIn: parent
            width: 54
            height: 54
            radius: 27
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16)
        }

        Rectangle {
            visible: railButton.active
            anchors.centerIn: parent
            width: 34
            height: 34
            radius: 17
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22)
        }

        Text {
            anchors.centerIn: parent
            text: railButton.icon
            color: railButton.active ? Theme.accent : Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 10
            font.weight: Font.Bold
        }

        MouseArea {
            id: railMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: railButton.clicked()
        }
    }

    component RoundImage: Item {
        id: roundImage

        property string source: ""
        property string fallbackIcon: "\uf001"
        property color backgroundColor: Theme.subtle
        property color borderColor: Theme.separator
        property bool circle: true

        Rectangle {
            anchors.fill: parent
            radius: circle ? width / 2 : 16
            color: backgroundColor
            border.color: borderColor
            border.width: 1
        }

        Canvas {
            anchors.fill: parent
            anchors.margins: 3
            renderTarget: Canvas.FramebufferObject
            smooth: true
            property string artUrl: roundImage.source

            onArtUrlChanged: {
                if (artUrl !== "") loadImage(artUrl);
                requestPaint();
            }
            onImageLoaded: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                if (roundImage.circle) {
                    const r = width / 2;
                    ctx.beginPath();
                    ctx.arc(r, r, r, 0, 2 * Math.PI);
                    ctx.clip();
                }
                if (artUrl !== "" && isImageLoaded(artUrl)) ctx.drawImage(artUrl, 0, 0, width, height);
            }
            Component.onCompleted: {
                if (artUrl !== "") loadImage(artUrl);
            }
        }

        Text {
            anchors.centerIn: parent
            visible: roundImage.source === ""
            text: roundImage.fallbackIcon
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Math.min(parent.width, parent.height) * 0.36
        }
    }

    component StatBar: Column {
        id: statBar

        property string icon: ""
        property string label: ""
        property real value: 0
        property color accentColor: Theme.accent

        width: 34
        spacing: 8

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 11
            height: 230
            radius: 6
            color: Qt.rgba(Theme.subtle.r, Theme.subtle.g, Theme.subtle.b, 0.56)

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: Math.max(8, parent.height * Math.max(0, Math.min(1, statBar.value)))
                radius: parent.radius
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.tint(statBar.accentColor, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.18)) }
                    GradientStop { position: 1.0; color: statBar.accentColor }
                }
                Behavior on height { NumberAnimation { duration: 120 } }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: statBar.icon
            color: Theme.text
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 5
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: statBar.label
            color: Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 3
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: CalendarPopupState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.activeWorkspace !== null && Services.NiriData.activeWorkspace.output === root.screen.name
            onMonitorIsFocusedChanged: if (!monitorIsFocused) CalendarPopupState.close()
            

            color: "transparent"
            WlrLayershell.namespace: "quickshell:calendarpopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                onClicked: CalendarPopupState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: CalendarPopupState.visible
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        CalendarPopupState.close();
                        event.accepted = true;
                    }
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: BarState.isTop ? parent.top : undefined
                    anchors.bottom: BarState.isTop ? undefined : parent.bottom
                    width: Math.min(920, parent.width - 48)
                    height: Math.min(540, parent.height - 72)
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.bottomMargin: BarState.isTop ? 0 : -radius
                        height: parent.height + (BarState.isTop ? 0 : radius)
                        radius: 24
                        color: "transparent"
                        border.color: Qt.tint(Theme.separator, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.34))
                        border.width: 1
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.rgba(Theme.panel.r, Theme.panel.g, Theme.panel.b, Theme.popupOpacity) }
                            GradientStop { position: 0.48; color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, Theme.popupOpacity) }
                            GradientStop { position: 1.0; color: Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.84) }
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
                            color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.18)
                        }

                        Rectangle {
                            width: parent.width * 0.42
                            height: parent.height * 0.18
                            radius: height / 2
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.topMargin: -height * 0.5
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.10)
                        }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 1
                            radius: parent.radius - 1
                            color: "transparent"
                            border.color: Theme.glow
                            border.width: 1
                            opacity: 0.45
                        }
                    }

                    MouseArea { anchors.fill: parent }

                    Row {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 14

                        GlassCard {
                            id: rail
                            width: 110
                            height: parent.height
                            fillColor: Qt.rgba(Theme.panel.r, Theme.panel.g, Theme.panel.b, 0.88)

                            Column {
                                anchors.fill: parent
                                anchors.topMargin: 20
                                anchors.bottomMargin: 20
                                spacing: 18

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 78
                                    height: 150
                                    radius: 18
                                    color: clockMouse.containsMouse && CalendarPopupState.activeTab !== 0 ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.035) : "transparent"

                                    Rectangle {
                                        visible: CalendarPopupState.activeTab === 0
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.topMargin: 13
                                        anchors.rightMargin: 10
                                        width: 12
                                        height: 12
                                        radius: 6
                                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
                                    }

                                    Rectangle {
                                        visible: CalendarPopupState.activeTab === 0
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.topMargin: 16
                                        anchors.rightMargin: 13
                                        width: 6
                                        height: 6
                                        radius: 3
                                        color: Qt.tint(Theme.accent, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.35))
                                    }

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: -2

                                        GlowNumber {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            value: Qt.formatDateTime(calendarPopup.now, "HH")
                                            active: CalendarPopupState.activeTab === 0
                                            pixelSize: 42
                                        }

                                        GlowNumber {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            value: Qt.formatDateTime(calendarPopup.now, "mm")
                                            active: CalendarPopupState.activeTab === 0
                                            pixelSize: 42
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: Qt.formatDateTime(calendarPopup.now, "MMM dd")
                                            color: Theme.muted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 1
                                            font.weight: Theme.fontWeight
                                        }

                                        Text {
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            text: Qt.formatDateTime(calendarPopup.now, "ddd")
                                            color: Theme.muted
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 1
                                            font.weight: Theme.fontWeight
                                        }
                                    }

                                    MouseArea {
                                        id: clockMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: CalendarPopupState.activeTab = 0
                                    }
                                }

                                Item { width: 1; height: 4 }

                                Repeater {
                                    model: calendarPopup.tabItems
                                    delegate: RailButton {
                                        required property var modelData
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        icon: modelData.icon
                                        active: CalendarPopupState.activeTab === modelData.idx
                                        onClicked: CalendarPopupState.activeTab = modelData.idx
                                    }
                                }
                            }
                        }

                        Column {
                            width: parent.width - rail.width - parent.spacing
                            height: parent.height
                            spacing: 14

                            RowLayout {
                                visible: CalendarPopupState.activeTab === 0
                                width: parent.width
                                height: visible ? 86 : 0
                                spacing: 14

                                GlassCard {
                                    Layout.preferredWidth: 284
                                    Layout.fillHeight: true
                                    fillColor: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, 0.82)

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 20
                                        anchors.rightMargin: 20
                                        spacing: 14

                                        Text {
                                            text: WeatherState.icon
                                            color: Theme.accent
                                            font.family: Theme.fontFamily
                                            font.pixelSize: 32
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Column {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            spacing: 3

                                            Text {
                                                text: WeatherState.temperature
                                                color: Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize + 8
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                width: parent.width
                                                text: WeatherState.description
                                                color: Theme.muted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 1
                                                font.weight: Theme.fontWeight
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }

                                GlassCard {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    fillColor: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, 0.82)

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 20
                                        anchors.rightMargin: 18
                                        spacing: 14

                                        RoundImage {
                                            Layout.preferredWidth: 54
                                            Layout.preferredHeight: 54
                                            Layout.alignment: Qt.AlignVCenter
                                            source: "file:///home/honey/Pictures/Others/Honey.png"
                                            fallbackIcon: "\uf007"
                                            borderColor: Theme.glow
                                        }

                                        Column {
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            spacing: 2

                                            Text {
                                                text: "Honey"
                                                color: Theme.text
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize + 6
                                                font.weight: Font.Bold
                                            }

                                            Text {
                                                width: parent.width
                                                text: DistroState.icon + " on " + DistroState.wmName + "  •  up " + calendarPopup.uptimeText
                                                color: Theme.muted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 1
                                                font.weight: Theme.fontWeight
                                                elide: Text.ElideRight
                                            }
                                        }

                                        Row {
                                            Layout.alignment: Qt.AlignVCenter
                                            spacing: 16

                                            Text {
                                                text: "\uf04a"
                                                color: headerPrev.containsMouse ? Theme.text : Theme.muted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize + 5
                                                anchors.verticalCenter: parent.verticalCenter
                                                MouseArea {
                                                    id: headerPrev
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (calendarPopup.player) calendarPopup.player.previous();
                                                    }
                                                }
                                            }

                                            Rectangle {
                                                width: 42
                                                height: 42
                                                radius: 21
                                                color: Theme.text
                                                anchors.verticalCenter: parent.verticalCenter
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: calendarPopup.player && calendarPopup.player.playbackState === MprisPlaybackState.Playing ? "\uf04c" : "\uf04b"
                                                    color: Theme.background
                                                    font.family: Theme.fontFamily
                                                    font.pixelSize: Theme.fontSize + 2
                                                }
                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (calendarPopup.player) calendarPopup.player.togglePlaying();
                                                    }
                                                }
                                            }

                                            Text {
                                                text: "\uf04e"
                                                color: headerNext.containsMouse ? Theme.text : Theme.muted
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize + 5
                                                anchors.verticalCenter: parent.verticalCenter
                                                MouseArea {
                                                    id: headerNext
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: {
                                                        if (calendarPopup.player) calendarPopup.player.next();
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: parent.height - (CalendarPopupState.activeTab === 0 ? 100 : 0)

                                Loader { active: CalendarPopupState.activeTab === 0; anchors.fill: parent; sourceComponent: dashboardPage }
                                Loader { active: CalendarPopupState.activeTab === 1; anchors.fill: parent; sourceComponent: mediaPage }
                                Loader {
                                    active: CalendarPopupState.visible
                                    visible: CalendarPopupState.activeTab === 2
                                    anchors.fill: parent
                                    sourceComponent: wallpapersPage
                                }
                                Loader { active: CalendarPopupState.activeTab === 3; anchors.fill: parent; sourceComponent: themesPage }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: dashboardPage

        RowLayout {
            spacing: 14

            GlassCard {
                id: calendarCard
                Layout.fillWidth: true
                Layout.fillHeight: true
                fillColor: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, 0.78)

                property int displayMonth: calendarPopup.now.getMonth()
                property int displayYear: calendarPopup.now.getFullYear()
                readonly property var monthNames: ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]

                function prevMonth() {
                    if (displayMonth === 0) {
                        displayMonth = 11;
                        displayYear--;
                    } else {
                        displayMonth--;
                    }
                }

                function nextMonth() {
                    if (displayMonth === 11) {
                        displayMonth = 0;
                        displayYear++;
                    } else {
                        displayMonth++;
                    }
                }

                function calendarDays() {
                    const days = [];
                    const first = new Date(displayYear, displayMonth, 1);
                    const startDay = first.getDay();
                    const daysInMonth = new Date(displayYear, displayMonth + 1, 0).getDate();
                    const prevMonthDays = new Date(displayYear, displayMonth, 0).getDate();
                    for (let i = startDay - 1; i >= 0; i--) days.push({ day: prevMonthDays - i, current: false });
                    for (let day = 1; day <= daysInMonth; day++) days.push({ day: day, current: true });
                    const rowsNeeded = Math.max(5, Math.ceil(days.length / 7));
                    for (let next = 1; days.length < rowsNeeded * 7; next++) days.push({ day: next, current: false });
                    return days;
                }

                Column {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 12

                    RowLayout {
                        width: parent.width
                        height: 34

                        Text {
                            text: "\uf053"
                            color: prevMonthMouse.containsMouse ? Theme.text : Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 7
                            MouseArea {
                                id: prevMonthMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarCard.prevMonth()
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: calendarCard.monthNames[calendarCard.displayMonth] + "  " + calendarCard.displayYear
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 8
                            font.weight: Font.Bold
                        }

                        Text {
                            text: "\uf054"
                            color: nextMonthMouse.containsMouse ? Theme.text : Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 7
                            MouseArea {
                                id: nextMonthMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarCard.nextMonth()
                            }
                        }
                    }

                    Rectangle { width: parent.width; height: 1; color: Theme.separator }

                    Row {
                        width: parent.width
                        height: 24
                        Repeater {
                            model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                            Text {
                                required property string modelData
                                width: parent.width / 7
                                text: modelData
                                horizontalAlignment: Text.AlignHCenter
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Theme.fontWeight
                            }
                        }
                    }

                    Grid {
                        id: dayGrid
                        width: parent.width
                        height: parent.height - 72
                        columns: 7
                        spacing: 0
                        readonly property var calDays: calendarCard.calendarDays()
                        readonly property int rowsCount: Math.ceil(calDays.length / 7)
                        readonly property int todayDay: calendarPopup.now.getDate()
                        readonly property int todayMonth: calendarPopup.now.getMonth()
                        readonly property int todayYear: calendarPopup.now.getFullYear()

                        Repeater {
                            model: dayGrid.calDays
                            delegate: Item {
                                required property var modelData
                                width: dayGrid.width / 7
                                height: dayGrid.height / dayGrid.rowsCount
                                readonly property bool isToday: modelData.current && modelData.day === dayGrid.todayDay && calendarCard.displayMonth === dayGrid.todayMonth && calendarCard.displayYear === dayGrid.todayYear

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 34
                                    height: 34
                                    radius: 17
                                    color: isToday ? Theme.accent : "transparent"
                                    opacity: isToday ? 0.95 : 1
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.day
                                    color: isToday ? Theme.background : modelData.current ? Theme.text : Theme.muted
                                    opacity: modelData.current ? 1.0 : 0.46
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize + 1
                                    font.weight: isToday ? Font.Bold : Theme.fontWeight
                                }
                            }
                        }
                    }
                }
            }

            GlassCard {
                Layout.preferredWidth: 154
                Layout.fillHeight: true
                fillColor: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, 0.78)

                Column {
                    anchors.centerIn: parent
                    anchors.verticalCenterOffset: -18
                    width: parent.width - 26
                    spacing: 18

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: calendarPopup.hostname
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 6
                        font.weight: Font.Bold
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 8
                        StatBar { icon: "\uf2db"; label: Math.round(CpuState.usage) + "%"; value: CpuState.usage / 100; accentColor: CpuState.usage >= 90 ? Theme.warning : Theme.process }
                        StatBar { icon: "\uf2c8"; label: GpuState.tempC + "°C"; value: Math.min(GpuState.tempC / 100, 1); accentColor: GpuState.tempC >= 80 ? Theme.warning : Theme.misc }
                        StatBar { icon: "\uefc5"; label: Math.round(RamState.percentage) + "%"; value: RamState.percentage / 100; accentColor: RamState.percentage >= 90 ? Theme.warning : Theme.text }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "CPU     GPU     RAM"
                        color: Theme.muted
                        opacity: 0.68
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 4
                        font.weight: Theme.fontWeight
                    }
                }
            }
        }
    }

    Component {
        id: mediaPage

        GlassCard {
            fillColor: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, 0.78)

            RowLayout {
                anchors.fill: parent
                anchors.margins: 26
                spacing: 34

                Item {
                    Layout.preferredWidth: 250
                    Layout.preferredHeight: 250
                    Layout.alignment: Qt.AlignVCenter

                    Canvas {
                        width: 8
                        height: 8
                        visible: false
                        property string artUrl: calendarPopup.player ? calendarPopup.player.trackArtUrl : ""
                        onArtUrlChanged: {
                            if (artUrl) {
                                loadImage(artUrl);
                                requestPaint();
                            } else {
                                calendarPopup.coverAccentColor = Theme.accent;
                            }
                        }
                        onImageLoaded: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            if (!artUrl || !isImageLoaded(artUrl)) return;
                            ctx.drawImage(artUrl, 0, 0, 8, 8);
                            try {
                                const data = ctx.getImageData(0, 0, 8, 8).data;
                                let r = 0, g = 0, b = 0, n = data.length / 4;
                                for (let i = 0; i < data.length; i += 4) {
                                    r += data[i]; g += data[i + 1]; b += data[i + 2];
                                }
                                calendarPopup.coverAccentColor = Qt.rgba(r / n / 255, g / n / 255, b / n / 255, 1.0);
                            } catch(e) {
                                calendarPopup.coverAccentColor = Theme.accent;
                            }
                        }
                    }

                    Canvas {
                        anchors.fill: parent
                        property var values: calendarPopup.cavaValues
                        property color themeColor: calendarPopup.coverAccentColor
                        onValuesChanged: requestPaint()
                        onThemeColorChanged: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d");
                            ctx.reset();
                            if (!values || values.length === 0) return;
                            const cx = width / 2;
                            const cy = height / 2;
                            const innerR = 92;
                            const n = values.length;
                            const step = 2 * Math.PI / n;
                            const gap = step * 0.16;
                            for (let i = 0; i < n; i++) {
                                const value = Math.min(values[i] / 20.0, 1.0);
                                const barH = value * 38;
                                if (barH < 1) continue;
                                const midAngle = (i / n) * 2 * Math.PI - Math.PI / 2;
                                const a0 = midAngle - step / 2 + gap;
                                const a1 = midAngle + step / 2 - gap;
                                ctx.beginPath();
                                ctx.arc(cx, cy, innerR + barH, a0, a1);
                                ctx.arc(cx, cy, innerR, a1, a0, true);
                                ctx.closePath();
                                ctx.fillStyle = themeColor;
                                ctx.fill();
                            }
                        }
                    }

                    RoundImage {
                        anchors.centerIn: parent
                        width: 176
                        height: 176
                        source: calendarPopup.player ? calendarPopup.player.trackArtUrl : ""
                        fallbackIcon: "\uf001"
                        borderColor: calendarPopup.coverAccentColor
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 18

                    Text {
                        width: parent.width
                        text: calendarPopup.player ? calendarPopup.player.trackTitle : "No media playing"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 12
                        font.weight: Font.Bold
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: calendarPopup.player ? calendarPopup.player.trackArtist : "Start playback in any MPRIS player"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 1
                        font.weight: Theme.fontWeight
                        elide: Text.ElideRight
                    }

                    Column {
                        width: parent.width
                        spacing: 8

                        Rectangle {
                            width: parent.width
                            height: 7
                            radius: 4
                            color: Theme.subtle

                            Rectangle {
                                width: !calendarPopup.player || calendarPopup.trackLength <= 0 ? 0 : parent.width * Math.min(calendarPopup.currentPosition / calendarPopup.trackLength, 1)
                                height: parent.height
                                radius: parent.radius
                                color: calendarPopup.coverAccentColor
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    if (calendarPopup.player && calendarPopup.player.canSeek)
                                        calendarPopup.player.position = (mouse.x / parent.width) * calendarPopup.trackLength;
                                }
                            }
                        }

                        RowLayout {
                            width: parent.width
                            Text { text: calendarPopup.formatTime(calendarPopup.currentPosition); color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1 }
                            Item { Layout.fillWidth: true }
                            Text { text: calendarPopup.formatTime(calendarPopup.trackLength); color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1 }
                        }
                    }

                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 32

                        Text {
                            text: "\uf04a"
                            color: mediaPrev.containsMouse ? Theme.text : Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 10
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: mediaPrev
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (calendarPopup.player) calendarPopup.player.previous();
                                }
                            }
                        }

                        Rectangle {
                            width: 58
                            height: 58
                            radius: 29
                            color: Theme.text
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                anchors.centerIn: parent
                                text: calendarPopup.player && calendarPopup.player.playbackState === MprisPlaybackState.Playing ? "\uf04c" : "\uf04b"
                                color: Theme.background
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 6
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (calendarPopup.player) calendarPopup.player.togglePlaying();
                                }
                            }
                        }

                        Text {
                            text: "\uf04e"
                            color: mediaNext.containsMouse ? Theme.text : Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 10
                            anchors.verticalCenter: parent.verticalCenter
                            MouseArea {
                                id: mediaNext
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (calendarPopup.player) calendarPopup.player.next();
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: wallpapersPage

        GlassCard {
            fillColor: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, 0.78)
            Component.onCompleted: {
                if (calendarPopup.wallpaperList.length === 0) wallpaperScanProc.running = true;
            }

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 12

                Grid {
                    id: wallpaperGrid
                    columns: 4
                    rows: 3
                    spacing: 10
                    width: parent.width
                    height: parent.height - wallpaperFooter.height - parent.spacing
                    readonly property real cellWidth: (width - (columns - 1) * spacing) / columns
                    readonly property real cellHeight: (height - (rows - 1) * spacing) / rows

                    Repeater {
                        model: {
                            const start = calendarPopup.wallpaperPage * calendarPopup.wallpapersPerPage;
                            const end = Math.min(start + calendarPopup.wallpapersPerPage, calendarPopup.wallpaperList.length);
                            const items = [];
                            for (let i = start; i < end; i++) items.push(calendarPopup.wallpaperList[i]);
                            return items;
                        }

                        delegate: Rectangle {
                            required property string modelData
                            width: wallpaperGrid.cellWidth
                            height: wallpaperGrid.cellHeight
                            radius: 14
                            color: Theme.subtle
                            border.color: calendarPopup.selectedWallpaper === modelData ? Theme.accent : wallpaperMouse.containsMouse ? Theme.glow : "transparent"
                            border.width: calendarPopup.selectedWallpaper === modelData ? 3 : 1
                            clip: true

                            Image {
                                anchors.fill: parent
                                anchors.margins: 2
                                source: calendarPopup.wallpaperThumbnailsReady
                                    ? Qt.resolvedUrl("file://" + calendarPopup.wallpaperThumbnailPath(modelData))
                                    : Qt.resolvedUrl("file://" + Theme.wallpaperDir + "/" + modelData)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                smooth: true
                                sourceSize.width: Math.min(wallpaperGrid.cellWidth, 240)
                                sourceSize.height: Math.min(wallpaperGrid.cellHeight, 160)
                            }

                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: wallpaperName.implicitHeight + 12
                                color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.72)
                                visible: wallpaperMouse.containsMouse || calendarPopup.selectedWallpaper === modelData
                                Text {
                                    id: wallpaperName
                                    anchors.centerIn: parent
                                    width: parent.width - 12
                                    text: modelData
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                    font.weight: Theme.fontWeight
                                    elide: Text.ElideMiddle
                                    horizontalAlignment: Text.AlignHCenter
                                }
                            }

                            MouseArea {
                                id: wallpaperMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: calendarPopup.applyWallpaper(modelData)
                            }
                        }
                    }
                }

                RowLayout {
                    id: wallpaperFooter
                    width: parent.width
                    height: 36
                    spacing: 10

                    Rectangle {
                        Layout.preferredWidth: nsfwText.implicitWidth + 24
                        Layout.fillHeight: true
                        radius: 12
                        color: Theme.nsfwEnabled ? Theme.warning : Theme.subtle
                        Text {
                            id: nsfwText
                            anchors.centerIn: parent
                            text: Theme.nsfwEnabled ? "\uf06e  NSFW" : "\uf070  NSFW"
                            color: Theme.nsfwEnabled ? Theme.background : Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            font.weight: Font.Bold
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Theme.toggleNsfw() }
                    }

                    Item { Layout.fillWidth: true }
                    Text { text: calendarPopup.wallpaperList.length + " wallpapers  •  " + (calendarPopup.wallpaperPage + 1) + " / " + calendarPopup.wallpaperTotalPages; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; Layout.alignment: Qt.AlignVCenter }
                    Text { text: "\uf053"; visible: calendarPopup.wallpaperPage > 0; color: wpPrev.containsMouse ? Theme.text : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 4; Layout.alignment: Qt.AlignVCenter; MouseArea { id: wpPrev; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: calendarPopup.wallpaperPage = Math.max(0, calendarPopup.wallpaperPage - 1) } }
                    Text { text: "\uf054"; visible: calendarPopup.wallpaperPage < calendarPopup.wallpaperTotalPages - 1; color: wpNext.containsMouse ? Theme.text : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 4; Layout.alignment: Qt.AlignVCenter; MouseArea { id: wpNext; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: calendarPopup.wallpaperPage = Math.min(calendarPopup.wallpaperTotalPages - 1, calendarPopup.wallpaperPage + 1) } }
                }
            }
        }
    }

    Component {
        id: themesPage

        GlassCard {
            fillColor: Qt.rgba(Theme.card.r, Theme.card.g, Theme.card.b, 0.78)

            Column {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                RowLayout {
                    width: parent.width
                    height: 32
                    Text { text: "Color Themes"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 5; font.weight: Font.Bold }
                    Item { Layout.fillWidth: true }
                    Text { text: Theme.themes[Theme.currentTheme].name; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Theme.fontWeight }
                }

                Flickable {
                    id: themeFlick
                    width: parent.width
                    height: parent.height - 46
                    contentWidth: width
                    contentHeight: themeGrid.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Grid {
                        id: themeGrid
                        width: themeFlick.width
                        height: Math.ceil(Theme.themeKeys.length / columns) * cellHeight + Math.max(0, Math.ceil(Theme.themeKeys.length / columns) - 1) * spacing
                        columns: 2
                        spacing: 12
                        readonly property real cellWidth: (width - spacing) / columns
                        readonly property real cellHeight: (themeFlick.height - spacing * 2) / 3

                        Repeater {
                            model: Theme.themeKeys
                            delegate: Rectangle {
                            required property string modelData
                            width: themeGrid.cellWidth
                            height: themeGrid.cellHeight
                            radius: 16
                            color: Theme.themes[modelData].separator
                            border.color: Theme.currentTheme === modelData ? Theme.themes[modelData].accent : "transparent"
                            border.width: Theme.currentTheme === modelData ? 3 : 1

                            Column {
                                anchors.fill: parent
                                anchors.margins: 12
                                spacing: 9

                                RowLayout {
                                    width: parent.width
                                    Text { Layout.fillWidth: true; text: Theme.themes[modelData].name; color: Theme.themes[modelData].text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 1; font.weight: Font.Bold; elide: Text.ElideRight }
                                    Rectangle {
                                        visible: Theme.currentTheme === modelData
                                        Layout.preferredWidth: activeThemeText.implicitWidth + 14
                                        Layout.preferredHeight: activeThemeText.implicitHeight + 6
                                        radius: 9
                                        color: Theme.themes[modelData].accent
                                        Text { id: activeThemeText; anchors.centerIn: parent; text: "active"; color: Theme.themes[modelData].background; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 3; font.weight: Font.Bold }
                                    }
                                }

                                Row {
                                    width: parent.width
                                    spacing: 5
                                    Repeater {
                                        model: [Theme.themes[modelData].background, Theme.themes[modelData].separator, Theme.themes[modelData].caution, Theme.themes[modelData].text, Theme.themes[modelData].accent, Theme.themes[modelData].process, Theme.themes[modelData].misc, Theme.themes[modelData].warning]
                                        delegate: Rectangle { required property var modelData; width: (parent.width - 7 * parent.spacing) / 8; height: 18; radius: 5; color: modelData }
                                    }
                                }

                                Rectangle {
                                    width: parent.width
                                    height: 34
                                    radius: 10
                                    color: Theme.themes[modelData].background
                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 12
                                        Text { text: "Aa"; color: Theme.themes[modelData].text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Bold }
                                        Rectangle { width: 22; height: 12; radius: 4; color: Theme.themes[modelData].accent; anchors.verticalCenter: parent.verticalCenter }
                                        Rectangle { width: 22; height: 12; radius: 4; color: Theme.themes[modelData].process; anchors.verticalCenter: parent.verticalCenter }
                                        Rectangle { width: 22; height: 12; radius: 4; color: Theme.themes[modelData].misc; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                }
                            }

                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Theme.setTheme(modelData) }
                            }
                        }
                    }
                }
            }
        }
    }
}
