pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string currentTheme: "carbonfox"

    readonly property var themes: ({
        "carbonfox": {
            bg: "#161616", fg: "#f2f4f8", dim: "#2a2a2a",
            accent: "#3a3a3a", warn: "#ff0000", bright: "#c6c6c6"
        },
        "everforest": {
            bg: "#2d353b", fg: "#d3c6aa", dim: "#343f44",
            accent: "#a7c080", warn: "#e67e80", bright: "#dbbc7f"
        },
        "rosepine": {
            bg: "#191724", fg: "#e0def4", dim: "#26233a",
            accent: "#c4a7e7", warn: "#eb6f92", bright: "#c4a7e7"
        },
        "pastelglow": {
            bg: "#F8E9EE", fg: "#3B2730", dim: "#E2C2CB",
            accent: "#B86EE6", warn: "#E0486B", bright: "#E0486B"
        },
        "gruvbox": {
            bg: "#282828", fg: "#ebdbb2", dim: "#3c3836",
            accent: "#d3869b", warn: "#fb4934", bright: "#fabd2f"
        },
        "gruvbox-light": {
            bg: "#fbf1c7", fg: "#3c3836", dim: "#ebdbb2",
            accent: "#b16286", warn: "#cc241d", bright: "#d79921"
        }
    })

    readonly property var current: themes[currentTheme] || themes["carbonfox"]
    readonly property color bg: current.bg
    readonly property color fg: current.fg
    readonly property color dim: current.dim
    readonly property color accent: current.accent
    readonly property color warn: current.warn
    readonly property color bright: current.bright

    readonly property string fontFamily: "IosevkaTerm Nerd Font Mono"
    readonly property int fontSize: 13
    readonly property int fontWeight: Font.Bold
    readonly property string themeFile: "/home/honey/.config/quickshell/.current-theme"

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
}
