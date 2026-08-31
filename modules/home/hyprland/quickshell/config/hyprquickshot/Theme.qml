pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    property string currentTheme: "pastelglow"

    readonly property var themes: ({
        "pastelglow": {
            background: "#F8E9EE", text: "#3B2730", separator: "#E2C2CB",
            warning: "#E0486B", caution: "#8B6F79", misc: "#63C7C8",
            process: "#6D8CE3", accent: "#B86EE6", highlight: "#E0486B"
        },
        "rosepine": {
            background: "#191724", text: "#e0def4", separator: "#26233a",
            warning: "#eb6f92", caution: "#403d52", misc: "#31748f",
            process: "#9ccfd8", accent: "#c4a7e7", highlight: "#c4a7e7"
        },
        "gruvbox": {
            background: "#282828", text: "#ebdbb2", separator: "#3c3836",
            warning: "#fb4934", caution: "#504945", misc: "#8ec07c",
            process: "#83a598", accent: "#d3869b", highlight: "#fabd2f"
        },
        "everforest": {
            background: "#2d353b", text: "#d3c6aa", separator: "#343f44",
            warning: "#e67e80", caution: "#3d484d", misc: "#83c092",
            process: "#7fbbb3", accent: "#a7c080", highlight: "#dbbc7f"
        },
        "carbonfox": {
            background: "#161616", text: "#f2f4f8", separator: "#2a2a2a",
            warning: "#ff0000", caution: "#525253", misc: "#808080",
            process: "#a0a0a0", accent: "#3a3a3a", highlight: "#c6c6c6"
        },
        "catppuccin-mocha": {
            background: "#1e1e2e", text: "#cdd6f4", separator: "#313244",
            warning: "#f38ba8", caution: "#45475a", misc: "#94e2d5",
            process: "#89b4fa", accent: "#b4befe", highlight: "#b4befe"
        },
        "miasma": {
            background: "#222222", text: "#c2c2b0", separator: "#383838",
            warning: "#b36d43", caution: "#43492a", misc: "#c9a554",
            process: "#5f875f", accent: "#78824b", highlight: "#d7c483"
        },
        "onedark": {
            background: "#282C34", text: "#ABB2BF", separator: "#2C323C",
            warning: "#E06C75", caution: "#3E4451", misc: "#56B6C2",
            process: "#61AFEF", accent: "#61AFEF", highlight: "#E5C07B"
        },
        "tokyonight": {
            background: "#1A1B26", text: "#C0CAF5", separator: "#292E42",
            warning: "#F7768E", caution: "#3B4261", misc: "#73DACA",
            process: "#7AA2F7", accent: "#7AA2F7", highlight: "#E0AF68"
        },
        "kanagawa": {
            background: "#1F1F28", text: "#DCD7BA", separator: "#2A2A37",
            warning: "#E82424", caution: "#363646", misc: "#6A9589",
            process: "#7E9CD8", accent: "#D27E99", highlight: "#E6C384"
        },
        "kanagawa-lotus": {
            background: "#F2ECBC", text: "#545464", separator: "#E5DDB0",
            warning: "#C84053", caution: "#DCD5AC", misc: "#5E857A",
            process: "#4D699B", accent: "#B35B79", highlight: "#DE9800"
        },
        "sakura": {
            background: "#191719", text: "#D6C1C5", separator: "#252326",
            warning: "#C5505E", caution: "#2F2B30", misc: "#759886",
            process: "#878FB9", accent: "#C58EA7", highlight: "#BC8EC6"
        },
        "gruvbox-light": {
            background: "#fbf1c7", text: "#3c3836", separator: "#ebdbb2",
            warning: "#cc241d", caution: "#d5c4a1", misc: "#689d6a",
            process: "#458588", accent: "#b16286", highlight: "#d79921"
        }
    })

    readonly property var _current: themes[currentTheme] || themes["pastelglow"]

    readonly property color background: _current.background
    readonly property color text: _current.text
    readonly property color separator: _current.separator
    readonly property color warning: _current.warning
    readonly property color caution: _current.caution
    readonly property color accent: _current.accent
    readonly property color process: _current.process

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 12
    readonly property int fontWeight: Font.DemiBold

    readonly property string _themeFile: "/home/honey/.config/quickshell/.current-theme"

    readonly property var _reader: Process {
        command: ["cat", _themeFile]
        running: true
        stdout: SplitParser {
            onRead: data => {
                const key = data.trim()
                if (themes.hasOwnProperty(key)) currentTheme = key
            }
        }
    }
}
