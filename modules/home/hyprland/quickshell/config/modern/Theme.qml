pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    // ── Theme switching ──
    property string currentTheme: "pastelglow"
    property int _themeRequestSequence: 0

    readonly property var themes: ({
        "carbonfox": {
            name: "Carbonfox",
            background: "#161616",
            text: "#f2f4f8",
            separator: "#2a2a2a",
            warning: "#ff0000",
            caution: "#525253",
            misc: "#808080",
            process: "#a0a0a0",
            accent: "#3a3a3a",
            highlight: "#c6c6c6"
        },
        "catppuccin-mocha": {
            name: "Catppuccin Mocha",
            background: "#1e1e2e",
            text: "#cdd6f4",
            separator: "#313244",
            warning: "#f38ba8",
            caution: "#45475a",
            misc: "#94e2d5",
            process: "#89b4fa",
            accent: "#b4befe",
            highlight: "#b4befe"
        },
        "miasma": {
            name: "Miasma",
            background: "#222222",
            text: "#c2c2b0",
            separator: "#383838",
            warning: "#b36d43",
            caution: "#43492a",
            misc: "#c9a554",
            process: "#5f875f",
            accent: "#78824b",
            highlight: "#d7c483"
        },
        "onedark": {
            name: "OneDark",
            background: "#282C34",
            text: "#ABB2BF",
            separator: "#2C323C",
            warning: "#E06C75",
            caution: "#3E4451",
            misc: "#56B6C2",
            process: "#61AFEF",
            accent: "#61AFEF",
            highlight: "#E5C07B"
        },
        "tokyonight": {
            name: "TokyoNight", background: "#1A1B26", text: "#C0CAF5", separator: "#292E42",
            warning: "#F7768E", caution: "#3B4261", misc: "#73DACA", process: "#7AA2F7",
            accent: "#7AA2F7", highlight: "#E0AF68"
        },
        "kanagawa": {
            name: "Kanagawa",
            background: "#1F1F28",
            text: "#DCD7BA",
            separator: "#2A2A37",
            warning: "#E82424",
            caution: "#363646",
            misc: "#6A9589",
            process: "#7E9CD8",
            accent: "#D27E99",
            highlight: "#E6C384"
        },
        "kanagawa-lotus": {
            name: "Kanagawa Lotus",
            background: "#F2ECBC",
            text: "#545464",
            separator: "#E5DDB0",
            warning: "#C84053",
            caution: "#DCD5AC",
            misc: "#5E857A",
            process: "#4D699B",
            accent: "#B35B79",
            highlight: "#DE9800"
        },
        "sakura": {
            name: "Sakura",
            background: "#191719",
            text: "#D6C1C5",
            separator: "#252326",
            warning: "#C5505E",
            caution: "#2F2B30",
            misc: "#759886",
            process: "#878FB9",
            accent: "#C58EA7",
            highlight: "#BC8EC6"
        },
        "everforest": {
            name: "Everforest Dark",
            background: "#2d353b",
            text: "#d3c6aa",
            separator: "#343f44",
            warning: "#e67e80",
            caution: "#3d484d",
            misc: "#83c092",
            process: "#7fbbb3",
            accent: "#a7c080",
            highlight: "#dbbc7f"
        },
        "rosepine": {
            name: "Ros\u00e9 Pine",
            background: "#191724",
            text: "#e0def4",
            separator: "#26233a",
            warning: "#eb6f92",
            caution: "#403d52",
            misc: "#31748f",
            process: "#9ccfd8",
            accent: "#c4a7e7",
            highlight: "#c4a7e7"
        },
        "pastelglow": {
            name: "Pastel Glow",
            background: "#F8E9EE",
            text: "#3B2730",
            separator: "#E2C2CB",
            warning: "#E0486B",
            caution: "#8B6F79",
            misc: "#63C7C8",
            process: "#6D8CE3",
            accent: "#B86EE6",
            highlight: "#E0486B"
        },
        "gruvbox": {
            name: "Gruvbox Dark",
            background: "#282828",
            text: "#ebdbb2",
            separator: "#3c3836",
            warning: "#fb4934",
            caution: "#504945",
            misc: "#8ec07c",
            process: "#83a598",
            accent: "#d3869b",
            highlight: "#fabd2f"
        },
        "gruvbox-light": {
            name: "Gruvbox Light",
            background: "#fbf1c7",
            text: "#3c3836",
            separator: "#ebdbb2",
            warning: "#cc241d",
            caution: "#d5c4a1",
            misc: "#689d6a",
            process: "#458588",
            accent: "#b16286",
            highlight: "#d79921"
        }
    })

    readonly property var _current: themes[currentTheme] || themes["pastelglow"]

    // ── Colors (reactive) ──
    readonly property color background: _current.background
    readonly property color text: _current.text
    readonly property color separator: _current.separator
    readonly property color warning: _current.warning
    readonly property color caution: _current.caution
    readonly property color misc: _current.misc
    readonly property color process: _current.process
    readonly property color accent: _current.accent
    readonly property color highlight: _current.highlight

    // ── Derived UI tokens ──
    readonly property color panel: Qt.tint(background, Qt.rgba(text.r, text.g, text.b, 0.045))
    readonly property color card: Qt.tint(background, Qt.rgba(text.r, text.g, text.b, 0.075))
    readonly property color cardHover: Qt.tint(background, Qt.rgba(text.r, text.g, text.b, 0.115))
    readonly property color muted: Qt.tint(text, Qt.rgba(background.r, background.g, background.b, 0.42))
    readonly property color subtle: Qt.tint(separator, Qt.rgba(background.r, background.g, background.b, 0.35))
    readonly property color glow: Qt.rgba(accent.r, accent.g, accent.b, 0.35)

    readonly property var themeKeys: Object.keys(themes).sort()

    // ── Wallpaper directories ──
    readonly property var wallpaperDirs: ({
        "pastelglow": "PastelGlow",
        "catppuccin-mocha": "CatppuccinMocha",
        "miasma": "Miasma",
        "onedark": "OneDark",
        "tokyonight": "TokyoNight",
        "kanagawa": "Kanagawa",
        "kanagawa-lotus": "KanagawaLotus",
        "sakura": "Sakura",
        "rosepine": "RosePine",
        "everforest": "Everforest",
        "carbonfox": "Carbonfox",
        "gruvbox": "GruvboxDark",
        "gruvbox-light": "GruvboxLight"
    })
    readonly property string wallpaperDir: "/home/honey/Pictures/Wallpapers/" + (wallpaperDirs[currentTheme] || "CatppuccinMocha")

    // ── Font settings ──
    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int fontWeight: Font.DemiBold

    // ── Dimensions ──
    readonly property int barHeight: 30
    readonly property int margin: 6
    readonly property real barOpacity: 0.9
    readonly property real popupOpacity: 0.955
    readonly property int borderRadius: 12
    readonly property int modulePadding: 8

    // ── Persistence ──
    readonly property string _themeFile: "/home/honey/.config/quickshell/.current-theme"
    readonly property string _nsfwFile: "/home/honey/.config/quickshell/.nsfw-enabled"

    property bool nsfwEnabled: false

    readonly property var _reader: Process {
        command: ["cat", _themeFile]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let key = data.trim();
                if (themes.hasOwnProperty(key)) currentTheme = key;
            }
        }
    }

    readonly property var _nsfwReader: Process {
        command: ["cat", _nsfwFile]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let val = data.trim();
                nsfwEnabled = (val === "true");
            }
        }
    }

    readonly property var _nsfwTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            _nsfwReader.running = false;
            _nsfwReader.running = true;
        }
    }

    readonly property var _nsfwWriter: Process {
        property bool nsfwValue: false
        command: ["sh", "-c", "echo '" + (nsfwValue ? "true" : "false") + "' > '" + _nsfwFile + "'"]
        running: false
    }

    function toggleNsfw() {
        nsfwEnabled = !nsfwEnabled;
        _nsfwWriter.nsfwValue = nsfwEnabled;
        _nsfwWriter.running = true;
    }

    function setTheme(key) {
        if (themes.hasOwnProperty(key)) {
            currentTheme = key;
            _themeRequestSequence = (_themeRequestSequence + 1) % 100;
            const requestId = Math.floor(Date.now() * 100) + _themeRequestSequence;
            Quickshell.execDetached(["/home/honey/.config/quickshell/themes/switch-theme.sh", key, requestId.toString()]);
        }
    }
}
