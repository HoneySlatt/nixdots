pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string title: ""
    property string artist: ""
    property string album: ""
    property string artwork: ""
    property string localArtwork: ""
    property bool isPlaying: false
    property real elapsed: 0
    property real duration: 0
    property real volume: 1.0
    property bool available: false

    property var historyItems: []
    property var queueItems: []
    property var playlists: []

    function refresh() {
        root._npProc.running = true;
        root._ipProc.running = true;
    }

    function _fetchQueue() {
        root._qBuf = "";
        root._qProc.running = true;
    }

    // ── now-playing ──────────────────────────────────────────────
    property string _npBuf: ""

    readonly property var _npProc: Process {
        command: ["curl", "-s", "http://localhost:10767/api/v1/playback/now-playing"]
        running: false
        stdout: SplitParser { onRead: data => root._npBuf += data }
        onExited: {
            try {
                let d = JSON.parse(root._npBuf);
                let info = d.info ?? {};
                let newTitle = info.name ?? "";
                let newArtist = info.artistName ?? "";
                let newAlbum = info.albumName ?? "";
                let newArtwork = info.artwork?.url ?? "";
                let newElapsed = info.currentPlaybackTime ?? 0;
                let ms = info.durationInMillis ?? 0;

                if (newTitle.length > 0 && newTitle !== root.title) {
                    let newHistory = root.historyItems.slice();
                    if (root.title.length > 0) {
                        newHistory.push({
                            name: root.title, artistName: root.artist,
                            albumName: root.album, artwork: { url: root.artwork }
                        });
                        if (newHistory.length > 10) newHistory.shift();
                    }
                    let newQueue = root.queueItems.filter(
                        i => !(i.name === newTitle && i.artistName === newArtist)
                    );

                    // title first — prevents duplicate in displayItems binding
                    root.title = newTitle;
                    root.artist = newArtist;
                    root.album = newAlbum;
                    if (newArtwork !== root.artwork) root.artwork = newArtwork;
                    root.historyItems = newHistory;
                    root.queueItems = newQueue;
                    root._fetchQueue();
                } else {
                    root.title = newTitle;
                    root.artist = newArtist;
                    root.album = newAlbum;
                    if (newArtwork !== root.artwork) root.artwork = newArtwork;
                }

                root.elapsed = newElapsed;
                root.duration = ms > 0 ? ms / 1000 : 0;
                let vol = info.currentPlaybackVolume ?? -1;
                if (vol >= 0) root.volume = vol;
                root.available = root.title.length > 0;
            } catch(e) {
                root.available = false;
            }
            root._npBuf = "";
        }
    }

    // ── is-playing ───────────────────────────────────────────────
    property string _ipBuf: ""

    readonly property var _ipProc: Process {
        command: ["curl", "-s", "http://localhost:10767/api/v1/playback/is-playing"]
        running: false
        stdout: SplitParser { onRead: data => root._ipBuf += data }
        onExited: {
            try {
                let d = JSON.parse(root._ipBuf);
                root.isPlaying = d.is_playing ?? false;
            } catch(e) {}
            root._ipBuf = "";
        }
    }

    // ── artwork download ─────────────────────────────────────────
    property string _lastArtUrl: ""

    onArtworkChanged: {
        if (root.artwork.length > 0 && root.artwork !== root._lastArtUrl) {
            root._lastArtUrl = root.artwork;
            root._artProc.command = [
                "curl", "-s", "-L", "--max-time", "5",
                "-o", "/tmp/qs-cider-art.jpg",
                root.artwork
            ];
            root._artProc.running = true;
        }
    }

    readonly property var _artProc: Process {
        running: false
        onExited: root.localArtwork = "file:///tmp/qs-cider-art.jpg?" + Math.random()
    }

    // ── queue ────────────────────────────────────────────────────
    property string _qBuf: ""

    readonly property var _qProc: Process {
        command: ["curl", "-s", "http://localhost:10767/api/v1/playback/queue"]
        running: false
        stdout: SplitParser { onRead: data => root._qBuf += data }
        onExited: {
            try {
                let d = JSON.parse(root._qBuf);
                let r = d.result ?? d;
                let raw = Array.isArray(r) ? r : (r.queue ?? r.items ?? r.nextItems ?? []);

                let normalized = [];
                for (let i = 0; i < raw.length; i++) {
                    let a = raw[i].attributes ?? raw[i];
                    let remaining = typeof a.remainingTime === "number" ? a.remainingTime : 999;
                    let name = a.name ?? "";
                    if (name.length > 0 && remaining > 0 && name !== root.title) {
                        normalized.push({
                            name: name,
                            artistName: a.artistName ?? "",
                            albumName: a.albumName ?? "",
                            artwork: { url: a.artwork?.url ?? "" }
                        });
                    }
                }
                root.queueItems = normalized;
            } catch(e) {}
            root._qBuf = "";
        }
    }

    // ── commands ─────────────────────────────────────────────────
    readonly property var _toggleProc: Process {
        command: ["curl", "-s", "-X", "POST",
                  "http://localhost:10767/api/v1/playback/toggle-play"]
        running: false
        onExited: root._ipProc.running = true
    }

    readonly property var _nextProc: Process {
        command: ["curl", "-s", "-X", "POST",
                  "http://localhost:10767/api/v1/playback/next"]
        running: false
        onExited: {
            root._npProc.running = true;
            root._ipProc.running = true;
        }
    }

    readonly property var _prevProc: Process {
        command: ["curl", "-s", "-X", "POST",
                  "http://localhost:10767/api/v1/playback/previous"]
        running: false
        onExited: {
            root._npProc.running = true;
            root._ipProc.running = true;
        }
    }

    readonly property var _seekProc: Process {
        running: false
    }

    readonly property var _ciderVolProc: Process {
        running: false
    }

    property string _plBuf: ""

    readonly property var _playlistsProc: Process {
        command: [
            "curl", "-s", "-X", "POST",
            "-H", "Content-Type: application/json",
            "-d", "{\"path\":\"v1/me/library/playlists?limit=100\"}",
            "http://localhost:10767/api/v1/amapi/run-v3"
        ]
        running: false
        stdout: SplitParser { onRead: data => root._plBuf += data }
        onExited: {
            try {
                let d = JSON.parse(root._plBuf);
                let raw = (d.data?.data) ?? [];
                let normalized = [];
                for (let i = 0; i < raw.length; i++) {
                    let a = raw[i].attributes ?? {};
                    let name = a.name ?? "";
                    if (name.length > 0) {
                        normalized.push({
                            id: raw[i].id ?? "",
                            name: name,
                            artwork: { url: a.artwork?.url ?? "" }
                        });
                    }
                }
                root.playlists = normalized;
            } catch(e) {}
            root._plBuf = "";
        }
    }

    readonly property var _playPlaylistProc: Process {
        running: false
    }

    function fetchPlaylists() {
        root._plBuf = "";
        root._playlistsProc.running = true;
    }

    function playPlaylist(id) {
        root._playPlaylistProc.command = [
            "curl", "-s", "-X", "POST",
            "-H", "Content-Type: application/json",
            "-d", JSON.stringify({ id: id, type: "library-playlists" }),
            "http://localhost:10767/api/v1/playback/play-item"
        ];
        root._playPlaylistProc.running = true;
    }

    function togglePlay() { root._toggleProc.running = true; }
    function next() { root._nextProc.running = true; }
    function previous() { root._prevProc.running = true; }
    function volUp() {
        let v = Math.min(1.0, root.volume + 0.05);
        root.volume = v;
        root._ciderVolProc.command = [
            "curl", "-s", "-X", "POST",
            "-H", "Content-Type: application/json",
            "-d", JSON.stringify({ volume: parseFloat(v.toFixed(2)) }),
            "http://localhost:10767/api/v1/playback/volume"
        ];
        root._ciderVolProc.running = true;
    }
    function volDown() {
        let v = Math.max(0.0, root.volume - 0.05);
        root.volume = v;
        root._ciderVolProc.command = [
            "curl", "-s", "-X", "POST",
            "-H", "Content-Type: application/json",
            "-d", JSON.stringify({ volume: parseFloat(v.toFixed(2)) }),
            "http://localhost:10767/api/v1/playback/volume"
        ];
        root._ciderVolProc.running = true;
    }
    function seek(position) {
        root._seekProc.command = [
            "curl", "-s", "-X", "POST",
            "-H", "Content-Type: application/json",
            "-d", JSON.stringify({ position: Math.floor(position) }),
            "http://localhost:10767/api/v1/playback/seek"
        ];
        root._seekProc.running = true;
    }

    // ── timers ───────────────────────────────────────────────────
    readonly property var _npTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root._npProc.running = true;
            root._ipProc.running = true;
        }
    }

    readonly property var _qTimer: Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root._fetchQueue()
    }
}
