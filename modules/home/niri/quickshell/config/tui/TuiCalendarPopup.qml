import QtQuick
import Quickshell
import Quickshell.Wayland
import "services" as Services
import Quickshell.Io
import Quickshell.Services.Mpris

Item {
    id: scope

    property date now: new Date()
    property string uptimeText: ""
    property var wallpaperList: []
    property int wallpaperPage: 0
    property int wallpaperIndex: 0
    property string selectedWallpaper: ""
    property real currentPosition: player ? player.position : 0
    property int displayMonth: now.getMonth()
    property int displayYear: now.getFullYear()

    readonly property int wallpapersPerPage: 6
    readonly property int wallpaperTotalPages: Math.max(1, Math.ceil(wallpaperList.length / wallpapersPerPage))
    readonly property int wallpaperCols: 3
    readonly property var monthNames: ["january","february","march","april","may","june","july","august","september","october","november","december"]
    readonly property var dayNames: ["sun","mon","tue","wed","thu","fri","sat"]
    readonly property MprisPlayer player: {
        var ps = Mpris.players.values;
        if (ps.length === 0) return null;
        var playing = ps.find(function(p) { return p.playbackState === MprisPlaybackState.Playing; });
        return playing ? playing : ps[0];
    }
    readonly property real trackLength: {
        if (!player) return 0;
        var l = player.length;
        if (isNaN(l) || l < 0) return 0;
        return l > 86400 ? l / 1000000 : l;
    }

    function fmtTime(s) {
        if (isNaN(s) || s < 0) return "--:--";
        var m = Math.floor(s / 60);
        var r = Math.floor(s % 60);
        return m + ":" + (r < 10 ? "0" : "") + r;
    }

    function barStr(val) {
        var c = Math.max(0, Math.min(10, Math.round(val / 10)));
        var s = "";
        for (var i = 0; i < c; i++) s += "#";
        for (var i = c; i < 10; i++) s += "-";
        return s;
    }

    function prevMonth() {
        if (displayMonth === 0) { displayMonth = 11; displayYear--; }
        else displayMonth--;
    }

    function nextMonth() {
        if (displayMonth === 11) { displayMonth = 0; displayYear++; }
        else displayMonth++;
    }

    function calDays() {
        var days = [];
        var first = new Date(displayYear, displayMonth, 1);
        var startDay = first.getDay();
        var dim = new Date(displayYear, displayMonth + 1, 0).getDate();
        var prevDim = new Date(displayYear, displayMonth, 0).getDate();
        for (var i = startDay - 1; i >= 0; i--) days.push({day: prevDim - i, cur: false});
        for (var d = 1; d <= dim; d++) days.push({day: d, cur: true});
        var rows = Math.max(5, Math.ceil(days.length / 7));
        for (var n = 1; days.length < rows * 7; n++) days.push({day: n, cur: false});
        return days;
    }

    function pageWps() {
        var s = wallpaperPage * wallpapersPerPage;
        return wallpaperList.slice(s, Math.min(s + wallpapersPerPage, wallpaperList.length));
    }

    function wpThumbPath(fn) {
        return TuiTheme.wallpaperThumbDir + "/" + fn + ".jpg";
    }

    function scanWps() {
        wallpaperList = [];
        wallpaperPage = 0;
        wallpaperIndex = 0;
        selectedWallpaper = "";
        TuiTheme.wallpaperThumbnailsReady = false;
        wpScanProc.running = true;
    }

    function selectWp(delta) {
        if (wallpaperList.length === 0) return;
        wallpaperIndex = Math.max(0, Math.min(wallpaperList.length - 1, wallpaperIndex + delta));
    }

    function applySelectedWp() {
        if (wallpaperIndex >= 0 && wallpaperIndex < wallpaperList.length)
            applyWp(wallpaperList[wallpaperIndex]);
    }

    function applyWp(fn) {
        selectedWallpaper = fn;
        wpApplyProc.wpPath = TuiTheme.wallpaperDir + "/" + fn;
        wpApplyProc.running = true;
    }

    // ── Timers & Processes ──

    Timer { interval: 1000; running: true; repeat: true; triggeredOnStart: true; onTriggered: scope.now = new Date() }

    Timer { interval: 60000; running: true; repeat: true; triggeredOnStart: true; onTriggered: uptimeProc.running = true }

    Timer {
        interval: 1000
        running: TuiCalendarPopupState.visible && scope.player !== null && scope.player.playbackState === MprisPlaybackState.Playing
        repeat: true
        onTriggered: if (scope.player) scope.currentPosition = scope.player.position
    }

    Process {
        id: uptimeProc
        command: ["/bin/sh", "-c", "awk '{s=int($1); printf \"%dh %dm\", s/3600, (s%3600)/60}' /proc/uptime"]
        running: false
        stdout: StdioCollector { onStreamFinished: { var t = this.text.trim(); if (t.length > 0) scope.uptimeText = t; } }
    }

    Process {
        id: wpScanProc
        command: ["find", TuiTheme.wallpaperDir, "-maxdepth", "1", "-type", "f", "(", "-iname", "*.jpg", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.png", "-o", "-iname", "*.webp", ")", "-printf", "%f\\n"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var files = this.text.trim().split("\n").filter(function(f) { return f.length > 0; });
                files = TuiTheme.nsfwEnabled ? files.filter(function(f) { return f.indexOf("[NSFW]") >= 0; }) : files.filter(function(f) { return f.indexOf("[NSFW]") < 0; });
                files.sort();
                scope.wallpaperList = files;
                wpThumbProc.running = true;
            }
        }
    }

    Process {
        id: wpThumbProc
        command: ["bash", "-c", "src=$1; cache=$2; nsfw=$3; mkdir -p \"$cache\" || exit 0; find \"$src\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \\) -print0 | while IFS= read -r -d '' f; do base=${f##*/}; if [ \"$nsfw\" = true ]; then case \"$base\" in *[[]NSFW[]]*) ;; *) continue;; esac; else case \"$base\" in *[[]NSFW[]]*) continue;; esac; fi; out=\"$cache/$base.jpg\"; [ -s \"$out\" ] && continue; magick \"$f\" -auto-orient -resize '900x420>' -quality 92 \"$out\" 2>/dev/null; done", "thumbgen", TuiTheme.wallpaperDir, TuiTheme.wallpaperThumbDir, TuiTheme.nsfwEnabled ? "true" : "false"]
        running: false
        onExited: TuiTheme.wallpaperThumbnailsReady = true
    }

    Process {
        id: wpApplyProc
        property string wpPath: ""
        command: ["awww", "img", wpPath, "--transition-type", "wave", "--transition-duration", "2"]
        running: false
    }

    Process {
        id: powerProc
        property string execCommand: "true"
        command: ["sh", "-c", execCommand + " >/dev/null 2>&1 &"]
        running: false
        onExited: TuiCalendarPopupState.close()
    }

    Connections {
        target: TuiTheme
        function onCurrentThemeChanged() { scope.scanWps(); }
        function onNsfwEnabledChanged() { scope.scanWps(); }
    }

    Connections {
        target: TuiCalendarPopupState
        function onActiveTabChanged() {
            if (TuiCalendarPopupState.visible && TuiCalendarPopupState.activeTab === 2)
                scope.scanWps();
        }
    }

    // ── Popup Window ──

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root
            required property var modelData
            screen: modelData
            visible: TuiCalendarPopupState.visible && monitorIsFocused
            readonly property bool monitorIsFocused: Services.NiriData.focusedOutput === root.screen.name
            color: "transparent"
            WlrLayershell.namespace: "quickshell:tui:calendar"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors { top: true; bottom: true; left: true; right: true }

            Connections {
                target: TuiCalendarPopupState
                function onVisibleChanged() {
                    if (TuiCalendarPopupState.visible) {
                        scope.displayMonth = scope.now.getMonth();
                        scope.displayYear = scope.now.getFullYear();
                        uptimeProc.running = true;
                        if (scope.wallpaperList.length === 0) scope.scanWps();
                    }
                }
            }

            MouseArea { anchors.fill: parent; onClicked: TuiCalendarPopupState.close() }

            FocusScope {
                anchors.fill: parent
                focus: TuiCalendarPopupState.visible
                Keys.onPressed: function(ev) {
                    if (ev.key === Qt.Key_Escape) {
                        TuiCalendarPopupState.close();
                        ev.accepted = true;
                        return;
                    }
                    if (TuiCalendarPopupState.activeTab === 2) {
                        if (ev.key === Qt.Key_Down) {
                            scope.selectWp(1);
                            ev.accepted = true;
                            return;
                        }
                        if (ev.key === Qt.Key_Up) {
                            scope.selectWp(-1);
                            ev.accepted = true;
                            return;
                        }
                        if (ev.key === Qt.Key_Return || ev.key === Qt.Key_Enter) {
                            scope.applySelectedWp();
                            ev.accepted = true;
                            return;
                        }
                    }
                }

                Item {
                    id: popupClip
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: TuiState.isTop ? parent.top : undefined
                    anchors.bottom: TuiState.isTop ? undefined : parent.bottom
                    width: 720
                    height: 430
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: TuiTheme.bg
                        border.color: TuiTheme.accent
                        border.width: 2

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            // ── Left Rail ──
                            Column {
                                id: rail
                                width: 126
                                height: parent.height
                                spacing: 6

                                Text { text: " tui"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                Text { text: " " + Qt.formatDateTime(scope.now, "hh:mm ap").toLowerCase(); color: TuiTheme.bright; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                Text { text: " " + Qt.formatDateTime(scope.now, "ddd dd").toLowerCase(); color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                Text { text: " up:" + (scope.uptimeText || "--"); color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }

                                Item { width: 1; height: 18 }

                                Repeater {
                                    model: [
                                        { label: "calendar", tab: 0 },
                                        { label: "media", tab: 1 },
                                        { label: "walls", tab: 2 },
                                        { label: "themes", tab: 3 },
                                        { label: "power", tab: 4 }
                                    ]
                                    delegate: Item {
                                        required property var modelData
                                        width: rail.width
                                        height: 24
                                        Rectangle { anchors.fill: parent; color: TuiCalendarPopupState.activeTab === modelData.tab ? TuiTheme.accent : "transparent" }
                                        Text {
                                            anchors.centerIn: parent
                                            text: (TuiCalendarPopupState.activeTab === modelData.tab ? "> " : "  ") + modelData.label
                                            color: TuiCalendarPopupState.activeTab === modelData.tab ? TuiTheme.bg : TuiTheme.fg
                                            font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight
                                        }
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: TuiCalendarPopupState.activeTab = modelData.tab }
                                    }
                                }
                            }

                            // ── Divider ──
                            Rectangle { width: 1; height: parent.height; color: TuiTheme.dim }

                            // ── Content ──
                            Loader {
                                width: parent.width - rail.width - 1 - parent.spacing * 2
                                height: parent.height
                                sourceComponent: {
                                    var t = TuiCalendarPopupState.activeTab;
                                    if (t === 1) return mediaPage;
                                    if (t === 2) return wallsPage;
                                    if (t === 3) return themesPage;
                                    if (t === 4) return powerPage;
                                    return calPage;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Calendar Tab ──

    Component {
        id: calPage

        Rectangle {
            color: "transparent"
            border.color: TuiTheme.dim
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Row {
                    spacing: 10
                    Text { text: " < "; color: prevMM.containsMouse ? TuiTheme.bright : TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter; MouseArea { id: prevMM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: scope.prevMonth() } }
                    Text { text: scope.monthNames[scope.displayMonth] + " " + scope.displayYear; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; width: 460; horizontalAlignment: Text.AlignHCenter }
                    Text { text: " > "; color: nextMM.containsMouse ? TuiTheme.bright : TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; verticalAlignment: Text.AlignVCenter; MouseArea { id: nextMM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: scope.nextMonth() } }
                }

                Row {
                    spacing: 0
                    Repeater {
                        model: scope.dayNames
                        delegate: Text { required property string modelData; text: modelData; color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; width: 72; horizontalAlignment: Text.AlignHCenter }
                    }
                }

                Grid {
                    columns: 7
                    spacing: 0
                    readonly property var days: scope.calDays()
                    readonly property int td: scope.now.getDate()
                    readonly property int tm: scope.now.getMonth()
                    readonly property int ty: scope.now.getFullYear()

                    Repeater {
                        model: parent.days
                        delegate: Text {
                            required property var modelData
                            readonly property bool isToday: modelData.cur && modelData.day === parent.td && scope.displayMonth === parent.tm && scope.displayYear === parent.ty
                            text: isToday ? "[" + (modelData.day < 10 ? "0" : "") + modelData.day + "]" : " " + (modelData.day < 10 ? "0" : "") + modelData.day + " "
                            width: 72; height: 48
                            color: isToday ? TuiTheme.accent : (modelData.cur ? TuiTheme.fg : TuiTheme.dim)
                            font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: isToday ? Font.Bold : TuiTheme.fontWeight
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    // ── Media Tab ──

    Component {
        id: mediaPage

        Rectangle {
            color: "transparent"
            border.color: TuiTheme.dim
            border.width: 1

            Item {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 14
                height: contentCol.implicitHeight

                Column {
                    id: contentCol
                    width: parent.width
                    spacing: 12

                    Text { text: "media"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                    Text { text: scope.player ? scope.player.trackTitle : "no mpris player"; color: TuiTheme.bright; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize + 2; font.weight: TuiTheme.fontWeight; width: parent.width; elide: Text.ElideRight }
                    Text { text: scope.player ? scope.player.trackArtist : "start playback in an mpris app"; color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; width: parent.width; elide: Text.ElideRight }

                    Rectangle {
                        width: parent.width; height: 72
                        color: "transparent"; border.color: TuiTheme.dim; border.width: 1
                        Column {
                            anchors.fill: parent; anchors.margins: 10; spacing: 6
                            Text { text: "pos " + scope.fmtTime(scope.currentPosition) + " / " + scope.fmtTime(scope.trackLength); color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                            Rectangle {
                                width: parent.width; height: 18
                                color: "transparent"; border.color: TuiTheme.dim; border.width: 1
                                Rectangle { x: 1; y: 1; height: parent.height - 2; width: (!scope.player || scope.trackLength <= 0) ? 0 : (parent.width - 2) * Math.min(scope.currentPosition / scope.trackLength, 1); color: TuiTheme.accent }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: function(m) { if (scope.player && scope.player.canSeek) scope.player.position = (m.x / parent.width) * scope.trackLength; } }
                            }
                        }
                    }

                    Row {
                        spacing: 12
                        Text { text: "[prev]"; color: prevM.containsMouse ? TuiTheme.bright : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; MouseArea { id: prevM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (scope.player) scope.player.previous() } }
                        Text { text: scope.player && scope.player.playbackState === MprisPlaybackState.Playing ? "[pause]" : "[play]"; color: playM.containsMouse ? TuiTheme.bright : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; MouseArea { id: playM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (scope.player) scope.player.togglePlaying() } }
                        Text { text: "[next]"; color: nextM.containsMouse ? TuiTheme.bright : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; MouseArea { id: nextM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: if (scope.player) scope.player.next() } }
                    }
                }
            }
        }
    }

    // ── Walls Tab ──

    Component {
        id: wallsPage

        Rectangle {
            color: "transparent"
            border.color: TuiTheme.dim
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Row {
                    spacing: 12
                    Text { text: "walls"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                    Text { text: TuiTheme.nsfwEnabled ? "[nsfw:on]" : "[nsfw:off]"; color: TuiTheme.nsfwEnabled ? TuiTheme.warn : TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: TuiTheme.toggleNsfw() } }
                }

                ListView {
                    id: wallsList
                    width: parent.width
                    height: parent.height - 56
                    clip: true
                    spacing: 8
                    model: scope.wallpaperList
                    currentIndex: scope.wallpaperIndex
                    boundsBehavior: Flickable.StopAtBounds
                    interactive: true
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                    delegate: Rectangle {
                        required property string modelData
                        required property int index
                        width: wallsList.width
                        height: 240
                        color: "transparent"
                        border.color: index === scope.wallpaperIndex ? TuiTheme.accent : (wpThumbM.containsMouse ? TuiTheme.bright : TuiTheme.dim)
                        border.width: index === scope.wallpaperIndex ? 2 : 1
                        clip: true

                        Image {
                            anchors.centerIn: parent
                            width: parent.width - 4
                            height: parent.height - 4
                            source: TuiTheme.wallpaperThumbnailsReady ? Qt.resolvedUrl("file://" + scope.wpThumbPath(modelData)) : Qt.resolvedUrl("file://" + TuiTheme.wallpaperDir + "/" + modelData)
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            cache: true
                            smooth: true
                            mipmap: true
                            sourceSize.width: 900
                            sourceSize.height: 420
                        }

                        Rectangle {
                            visible: scope.selectedWallpaper === modelData
                            anchors.left: parent.left
                            anchors.top: parent.top
                            width: 16
                            height: 16
                            color: TuiTheme.accent
                        }

                        MouseArea {
                            id: wpThumbM
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onEntered: scope.wallpaperIndex = index
                            onClicked: scope.applyWp(modelData)
                        }
                    }
                }

                Row {
                    spacing: 12
                    Text { text: "up/down: select"; color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                    Text { text: "enter: apply"; color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                    Text { text: "[rescan]"; color: wpScan.containsMouse ? TuiTheme.bright : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; MouseArea { id: wpScan; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: scope.scanWps() } }
                }
            }
        }
    }

    // ── Themes Tab ──

    Component {
        id: themesPage

        Rectangle {
            color: "transparent"
            border.color: TuiTheme.dim
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text { text: "themes"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }

                Flickable {
                    id: themeFlick
                    width: parent.width
                    height: parent.height - 34
                    contentWidth: width
                    contentHeight: themeGrid.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Grid {
                        id: themeGrid
                        width: themeFlick.width
                        height: Math.ceil(TuiTheme.themeKeys.length / columns) * 86 + Math.max(0, Math.ceil(TuiTheme.themeKeys.length / columns) - 1) * spacing
                        columns: 2
                        spacing: 10

                        Repeater {
                            model: TuiTheme.themeKeys
                            delegate: Rectangle {
                            required property string modelData
                            width: (themeGrid.width - themeGrid.spacing) / themeGrid.columns; height: 86
                            color: TuiTheme.themes[modelData].bg
                            border.color: TuiTheme.currentTheme === modelData ? TuiTheme.accent : TuiTheme.dim
                            border.width: TuiTheme.currentTheme === modelData ? 2 : 1
                            Column {
                                anchors.fill: parent; anchors.margins: 8; spacing: 6
                                Text { text: (TuiTheme.currentTheme === modelData ? "> " : "  ") + TuiTheme.themeLabel(modelData); color: TuiTheme.themes[modelData].fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                Row {
                                    spacing: 4
                                    Repeater {
                                        model: [TuiTheme.themes[modelData].bg, TuiTheme.themes[modelData].fg, TuiTheme.themes[modelData].dim, TuiTheme.themes[modelData].accent, TuiTheme.themes[modelData].warn, TuiTheme.themes[modelData].bright]
                                        delegate: Rectangle { required property var modelData; width: 32; height: 16; color: modelData; border.color: TuiTheme.dim; border.width: 1 }
                                    }
                                }
                                Text { text: "bg fg dim accent warn bright"; color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize - 2; font.weight: TuiTheme.fontWeight }
                            }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: TuiTheme.setTheme(modelData) }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Power Tab ──

    Component {
        id: powerPage

        Rectangle {
            color: "transparent"
            border.color: TuiTheme.dim
            border.width: 1

            Column {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 10

                Text { text: "power"; color: TuiTheme.warn; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                Repeater {
                    model: [
                        { label: "lock", cmd: "lock-screen", mark: "o" },
                        { label: "suspend", cmd: "systemctl suspend", mark: "o" },
                        { label: "hibernate", cmd: "systemctl hibernate", mark: "o" },
                        { label: "reboot", cmd: "systemctl reboot", mark: "o" },
                        { label: "shutdown", cmd: "systemctl poweroff", mark: "*" }
                    ]
                    delegate: Item {
                        required property var modelData
                        width: 260; height: 28
                        Text { anchors.verticalCenter: parent.verticalCenter; x: 8; text: "  " + modelData.mark + " " + modelData.label; color: modelData.label === "shutdown" ? TuiTheme.warn : (pwrM.containsMouse ? TuiTheme.bright : TuiTheme.fg); font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                        MouseArea { id: pwrM; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { powerProc.execCommand = modelData.cmd; powerProc.running = true; } }
                    }
                }
            }
        }
    }
}
