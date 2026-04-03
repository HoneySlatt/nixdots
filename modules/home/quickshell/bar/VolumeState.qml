pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int volume: 0
    property bool muted: false
    property var sinks: []
    property string defaultSink: ""

    function volUp() { root._volUpProc.running = true; }
    function volDown() { root._volDownProc.running = true; }
    function toggleMute() { root._muteProc.running = true; }
    function setVolume(percent) {
        root._setVolProc.command = ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", (Math.max(0, Math.min(100, percent)) / 100).toFixed(2)];
        root._setVolProc.running = true;
    }

    readonly property var _volumeProc: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                let line = this.text.trim();
                root.muted = line.includes("[MUTED]");
                let match = line.match(/Volume:\s+([\d.]+)/);
                if (match) {
                    root.volume = Math.round(parseFloat(match[1]) * 100);
                }
            }
        }
    }

    readonly property var _volUpProc: Process {
        command: ["wpctl", "set-volume", "-l", "1.0", "@DEFAULT_AUDIO_SINK@", "5%+"]
        running: false
        onExited: root._volumeProc.running = true
    }

    readonly property var _volDownProc: Process {
        command: ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
        running: false
        onExited: root._volumeProc.running = true
    }

    readonly property var _muteProc: Process {
        command: ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
        running: false
        onExited: root._volumeProc.running = true
    }

    readonly property var _setVolProc: Process {
        running: false
        onExited: root._volumeProc.running = true
    }

    function setDefaultSink(name) {
        root._setDefaultSinkProc.command = ["pactl", "set-default-sink", name];
        root._setDefaultSinkProc.running = true;
    }

    function refreshSinks() {
        root._sinksProc.running = true;
        root._defaultSinkProc.running = true;
    }

    readonly property var _sinksProc: Process {
        command: ["pactl", "list", "short", "sinks"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n").filter(l => l.trim() !== "");
                root.sinks = lines.map(l => {
                    let parts = l.split("\t");
                    return { id: parts[0] || "", name: parts[1] || "" };
                });
            }
        }
    }

    readonly property var _defaultSinkProc: Process {
        command: ["pactl", "get-default-sink"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.defaultSink = this.text.trim();
            }
        }
    }

    readonly property var _setDefaultSinkProc: Process {
        running: false
        onExited: {
            root.refreshSinks();
            root._volumeProc.running = true;
        }
    }

    readonly property var _subscribeProc: Process {
        command: ["pactl", "subscribe"]
        running: true
        onExited: root._subscribeProc.running = true
        stdout: SplitParser {
            onRead: data => {
                if (data.includes("'change'"))
                    root._volumeProc.running = true
            }
        }
    }

    readonly property var _startupTimer: Timer {
        interval: 2000
        running: true
        repeat: false
        onTriggered: root._volumeProc.running = true
    }

    readonly property var _pollTimer: Timer {
        interval: 500
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._volumeProc.running = true
    }
}
