pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property string currentTheme: "carbonfox"
    property int themeRequestSequence: 0

    readonly property var themes: ({
        "carbonfox": {
            bg: "#161616", fg: "#f2f4f8", dim: "#2a2a2a",
            accent: "#3a3a3a", warn: "#ff0000", bright: "#c6c6c6",
            caution: "#525253", misc: "#808080", process: "#a0a0a0", highlight: "#c6c6c6"
        },
        "everforest": {
            bg: "#2d353b", fg: "#d3c6aa", dim: "#343f44",
            accent: "#a7c080", warn: "#e67e80", bright: "#dbbc7f",
            caution: "#3d484d", misc: "#83c092", process: "#7fbbb3", highlight: "#dbbc7f"
        },
        "rosepine": {
            bg: "#191724", fg: "#e0def4", dim: "#26233a",
            accent: "#c4a7e7", warn: "#eb6f92", bright: "#c4a7e7",
            caution: "#403d52", misc: "#31748f", process: "#9ccfd8", highlight: "#c4a7e7"
        },
        "pastelglow": {
            bg: "#F8E9EE", fg: "#3B2730", dim: "#E2C2CB",
            accent: "#B86EE6", warn: "#E0486B", bright: "#E0486B",
            caution: "#8B6F79", misc: "#63C7C8", process: "#6D8CE3", highlight: "#E0486B"
        },
        "gruvbox": {
            bg: "#282828", fg: "#ebdbb2", dim: "#3c3836",
            accent: "#d3869b", warn: "#fb4934", bright: "#fabd2f",
            caution: "#504945", misc: "#8ec07c", process: "#83a598", highlight: "#fabd2f"
        },
        "gruvbox-light": {
            bg: "#fbf1c7", fg: "#3c3836", dim: "#ebdbb2",
            accent: "#b16286", warn: "#cc241d", bright: "#d79921",
            caution: "#d5c4a1", misc: "#689d6a", process: "#458588", highlight: "#d79921"
        }
    })

    readonly property var current: themes[currentTheme] || themes["carbonfox"]
    readonly property color bg: current.bg
    readonly property color fg: current.fg
    readonly property color dim: current.dim
    readonly property color accent: current.accent
    readonly property color warn: current.warn
    readonly property color bright: current.bright
    readonly property color caution: current.caution
    readonly property color misc: current.misc
    readonly property color process: current.process
    readonly property color highlight: current.highlight

    readonly property color barBg: bg
    readonly property color barBorder: dim
    readonly property color barInnerBorder: caution
    readonly property color barText: fg
    readonly property color barMuted: Qt.tint(dim, Qt.rgba(fg.r, fg.g, fg.b, 0.28))
    readonly property color barHover: Qt.rgba(fg.r, fg.g, fg.b, 0.08)
    readonly property color barActiveBg: Qt.tint(accent, Qt.rgba(highlight.r, highlight.g, highlight.b, 0.26))
    readonly property color barActiveFg: fg

    readonly property string fontFamily: "IosevkaTerm Nerd Font Mono"
    readonly property int fontSize: 14
    readonly property int fontWeight: Font.Bold
    readonly property int barIconSize: 20
    readonly property int barDistroIconSize: 28
    readonly property int barIconOffsetX: 1
    readonly property int barIconOffsetY: 1
    readonly property int barH: 32
    readonly property int pad: 8
    readonly property int barSidePad: 6
    readonly property int itemPad: 9
    readonly property int compactItemPad: 7

    readonly property string themeFile: "/home/honey/.config/quickshell/.current-theme"
    readonly property string nsfwFile: "/home/honey/.config/quickshell/.nsfw-enabled"
    readonly property var themeKeys: Object.keys(themes)
    readonly property var wallpaperDirs: ({
        "carbonfox": "Carbonfox",
        "everforest": "Everforest",
        "rosepine": "RosePine",
        "pastelglow": "PastelGlow",
        "gruvbox": "GruvboxDark",
        "gruvbox-light": "GruvboxLight"
    })
    readonly property string wallpaperDir: "/home/honey/Pictures/Wallpapers/" + (wallpaperDirs[currentTheme] || "Carbonfox")
    readonly property string wallpaperThumbDir: "/home/honey/.cache/quickshell/tuithumbs-large/" + (wallpaperDirs[currentTheme] || "Carbonfox")

    property bool wallpaperThumbnailsReady: false

    property bool nsfwEnabled: false

    function themeLabel(key) {
        if (key === "carbonfox") return "carbonfox";
        if (key === "everforest") return "everforest";
        if (key === "rosepine") return "rose pine";
        if (key === "pastelglow") return "pastel glow";
        if (key === "gruvbox") return "gruvbox dark";
        if (key === "gruvbox-light") return "gruvbox light";
        return key;
    }

    function setTheme(key) {
        if (!themes.hasOwnProperty(key)) return;
        currentTheme = key;
        themeRequestSequence = (themeRequestSequence + 1) % 100;
        const requestId = Math.floor(Date.now() * 100) + themeRequestSequence;
        Quickshell.execDetached(["/home/honey/.config/quickshell/themes/switch-theme.sh", key, requestId.toString()]);
    }

    function toggleNsfw() {
        nsfwEnabled = !nsfwEnabled;
        nsfwWriter.nsfwValue = nsfwEnabled;
        nsfwWriter.running = true;
    }

    readonly property var reader: Process {
        command: ["cat", root.themeFile]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const key = data.trim();
                if (root.themes.hasOwnProperty(key)) root.currentTheme = key;
            }
        }
    }

    readonly property var themePoll: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: { root.reader.running = false; root.reader.running = true; }
    }

    readonly property var nsfwReader: Process {
        command: ["cat", root.nsfwFile]
        running: true
        stdout: SplitParser {
            onRead: data => root.nsfwEnabled = data.trim() === "true"
        }
    }

    readonly property var nsfwPoll: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: { root.nsfwReader.running = false; root.nsfwReader.running = true; }
    }

    readonly property var nsfwWriter: Process {
        property bool nsfwValue: false
        command: ["sh", "-c", "printf '%s\\n' '" + (nsfwValue ? "true" : "false") + "' > '" + root.nsfwFile + "'"]
        running: false
    }

}
