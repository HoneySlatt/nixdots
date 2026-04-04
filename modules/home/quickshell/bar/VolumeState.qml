pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property int volume: 0
    property bool muted: false
    property var sinks: []

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

    function setDefaultSink(sinkId) {
        root._setDefaultSinkProc.command = ["wpctl", "set-default", sinkId];
        root._setDefaultSinkProc.running = true;
    }

    function refreshSinks() {
        root._sinksProc.running = true;
    }

    readonly property var _sinksProc: Process {
        command: ["sh", "-c", "wpctl status | awk '/^Audio/{a=1} a && /Sinks:/{b=1; next} a && b && /[0-9]+\\./{isdef=($0~/\\*/?\"1\":\"0\"); match($0,/[0-9]+\\./); nid=substr($0,RSTART,RLENGTH-1); rest=substr($0,RSTART+RLENGTH); gsub(/ \\[vol:.*/,\"\",rest); gsub(/^[ \\t]+|[ \\t]+$/,\"\",rest); print nid \"\\t\" isdef \"\\t\" rest} a && b && /Sources:/{exit}'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = this.text.trim().split("\n").filter(l => l.trim() !== "");
                root.sinks = lines.map(l => {
                    let parts = l.split("\t");
                    return { sinkId: parts[0] || "", active: parts[1] === "1", label: parts[2] || "" };
                }).filter(s => s.label !== "");
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
