import QtQuick
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    id: scope

    function applyTheme(key) {
        TuiTheme.setTheme(key);
        TuiThemeLauncherState.close();
    }

    component PaletteChip: Rectangle {
        property color chipColor: TuiTheme.accent

        width: 34
        height: 14
        color: chipColor
        border.color: TuiTheme.barInnerBorder
        border.width: 1
    }

    component TerminalMock: Rectangle {
        id: mock

        required property var themeData
        property bool compact: false

        color: themeData.bg
        border.color: themeData.dim
        border.width: 1
        clip: true

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: compact ? 18 : 24
            color: themeData.dim
            border.color: themeData.caution
            border.width: 1
        }

        Text {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: compact ? 10 : 14
            anchors.topMargin: compact ? 24 : 34
            text: ">_"
            color: themeData.fg
            font.family: TuiTheme.fontFamily
            font.pixelSize: compact ? TuiTheme.fontSize - 2 : TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
        }

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: compact ? 10 : 14
            anchors.topMargin: compact ? 50 : 70
            width: compact ? 24 : 34
            height: compact ? 18 : 24
            color: themeData.caution
            border.color: themeData.fg
            border.width: 1
        }

        Rectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: compact ? 18 : 24
            width: 1
            color: themeData.dim
        }

        Repeater {
            model: 2

            delegate: Row {
                required property int index

                anchors.left: parent.horizontalCenter
                anchors.leftMargin: compact ? 18 : 30
                anchors.top: parent.top
                anchors.topMargin: compact ? 36 + index * 28 : 52 + index * 42
                spacing: compact ? 14 : 20

                Rectangle {
                    width: compact ? 8 : 12
                    height: width
                    color: index === 0 ? mock.themeData.process : mock.themeData.misc
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: compact ? 42 : 70
                    height: 4
                    color: index === 0 ? mock.themeData.fg : mock.themeData.caution
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiThemeLauncherState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: { if (!Services.NiriData.monitors) return false; const monitors = Services.NiriData.monitors; for (let key in monitors) { if (monitors[key].name === root.screen.name && monitors[key].focused) return true; } return false; }
            readonly property bool monitorIsFocused: { if (!Services.NiriData.monitors) return false; const monitors = Services.NiriData.monitors; for (let key in monitors) { if (monitors[key].name === root.screen.name && monitors[key].focused) return true; } return false; }

            readonly property int cardW: 172
            readonly property int cardH: 198
            readonly property int cardSpacing: 16
            property int selectedIndex: 0
            readonly property string selectedKey: TuiTheme.themeKeys[selectedIndex] ?? TuiTheme.currentTheme
            readonly property var selectedTheme: TuiTheme.themes[selectedKey] ?? TuiTheme.current

            color: "transparent"

            WlrLayershell.namespace: "quickshell:tui:themelauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            function clampSelection() {
                selectedIndex = Math.max(0, Math.min(TuiTheme.themeKeys.length - 1, selectedIndex));
            }

            function selectCurrentTheme() {
                const idx = TuiTheme.themeKeys.indexOf(TuiTheme.currentTheme);
                selectedIndex = idx >= 0 ? idx : 0;
                Qt.callLater(centerThemeList);
            }

            function centerThemeList() {
                themeList.positionViewAtIndex(selectedIndex, ListView.Center);
            }

            onSelectedIndexChanged: Qt.callLater(centerThemeList)

            Connections {
                target: TuiThemeLauncherState
                function onVisibleChanged() {
                    if (TuiThemeLauncherState.visible) {
                        root.selectCurrentTheme();
                        focusTimer.start();
                    } else {
                        focusTimer.stop();
                    }
                }
            }

            Timer {
                id: focusTimer
                interval: 80
                repeat: false
                onTriggered: panel.forceActiveFocus()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: TuiThemeLauncherState.close()
            }

            Rectangle {
                id: panel
                anchors.centerIn: parent
                width: Math.min(root.width - 96, 1260)
                height: Math.min(root.height - 180, 560)
                color: TuiTheme.barBg
                border.color: TuiTheme.barBorder
                border.width: 1
                focus: TuiThemeLauncherState.visible

                MouseArea { anchors.fill: parent; onClicked: panel.forceActiveFocus() }

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                        TuiThemeLauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_A) {
                        scope.applyTheme(root.selectedKey);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_H || event.key === Qt.Key_Left || event.key === Qt.Key_K || event.key === Qt.Key_Up) {
                        root.selectedIndex--;
                        root.clampSelection();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_L || event.key === Qt.Key_Right || event.key === Qt.Key_J || event.key === Qt.Key_Down) {
                        root.selectedIndex++;
                        root.clampSelection();
                        event.accepted = true;
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 4
                    color: "transparent"
                    border.color: TuiTheme.barInnerBorder
                    border.width: 1
                }

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 18
                    anchors.topMargin: 14
                    text: "> QuickShell Theme Launcher"
                    color: TuiTheme.barText
                    font.family: TuiTheme.fontFamily
                    font.pixelSize: TuiTheme.fontSize
                    font.weight: TuiTheme.fontWeight
                }

                Rectangle {
                    id: activePanel
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    anchors.topMargin: 58
                    height: 154
                    color: "transparent"
                    border.color: TuiTheme.barInnerBorder
                    border.width: 1

                    Column {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: parent.width * 0.16
                        spacing: 12

                        Text {
                            text: root.selectedKey === TuiTheme.currentTheme ? "ACTIVE THEME" : "SELECTED THEME"
                            color: TuiTheme.barMuted
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize - 1
                            font.weight: TuiTheme.fontWeight
                        }

                        Text {
                            text: TuiTheme.themeLabel(root.selectedKey)
                            color: root.selectedTheme.highlight
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize + 9
                            font.weight: TuiTheme.fontWeight
                        }

                        Row {
                            spacing: 6
                            Repeater {
                                model: [root.selectedTheme.bg, root.selectedTheme.fg, root.selectedTheme.accent, root.selectedTheme.process, root.selectedTheme.warn]
                                delegate: PaletteChip { required property var modelData; chipColor: modelData; width: 76; height: 18 }
                            }
                        }
                    }

                    TerminalMock {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: parent.width * 0.16
                        width: 280
                        height: 104
                        themeData: root.selectedTheme
                    }
                }

                Rectangle {
                    id: presetsFrame
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: activePanel.bottom
                    anchors.bottom: footer.top
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    anchors.topMargin: 28
                    anchors.bottomMargin: 14
                    color: "transparent"
                    border.color: TuiTheme.barInnerBorder
                    border.width: 1

                    Rectangle {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.leftMargin: 14
                        anchors.topMargin: -1
                        width: titleText.implicitWidth + 16
                        height: 18
                        color: TuiTheme.barBg

                        Text {
                            id: titleText
                            anchors.centerIn: parent
                            text: "THEME PRESETS"
                            color: TuiTheme.barMuted
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize - 1
                            font.weight: TuiTheme.fontWeight
                        }
                    }

                    ListView {
                        id: themeList
                        anchors.fill: parent
                        anchors.margins: 14
                        orientation: ListView.Horizontal
                        model: TuiTheme.themeKeys
                        currentIndex: root.selectedIndex
                        spacing: root.cardSpacing
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                        delegate: Rectangle {
                            id: card
                            required property string modelData
                            required property int index

                            readonly property var t: TuiTheme.themes[modelData]
                            readonly property bool selected: index === root.selectedIndex
                            readonly property bool active: modelData === TuiTheme.currentTheme

                            width: root.cardW
                            height: root.cardH
                            color: t.bg
                            border.color: selected ? t.highlight : TuiTheme.barInnerBorder
                            border.width: selected ? 2 : 1

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                anchors.topMargin: 14
                                text: TuiTheme.themeLabel(card.modelData) + (card.active ? "   *" : "")
                                color: card.t.fg
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize
                                font.weight: TuiTheme.fontWeight
                            }

                            TerminalMock {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                anchors.topMargin: 48
                                height: 94
                                compact: true
                                themeData: card.t
                            }

                            Row {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.leftMargin: 14
                                anchors.rightMargin: 14
                                anchors.bottomMargin: 14
                                spacing: 5

                                Repeater {
                                    model: [card.t.bg, card.t.fg, card.t.dim, card.t.process, card.t.warn]
                                    delegate: PaletteChip { required property var modelData; chipColor: modelData; width: 26; height: 14 }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: root.selectedIndex = card.index
                                onClicked: {
                                    if (root.selectedIndex === card.index) scope.applyTheme(card.modelData);
                                    else root.selectedIndex = card.index;
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    id: footer
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 44
                    color: "transparent"
                    border.color: TuiTheme.barInnerBorder
                    border.width: 1

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 24
                        text: "[A] Apply     Arrows/HJKL: Navigate"
                        color: TuiTheme.barText
                        font.family: TuiTheme.fontFamily
                        font.pixelSize: TuiTheme.fontSize
                        font.weight: TuiTheme.fontWeight
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.rightMargin: 24
                        text: "[Q] Close"
                        color: TuiTheme.barText
                        font.family: TuiTheme.fontFamily
                        font.pixelSize: TuiTheme.fontSize
                        font.weight: TuiTheme.fontWeight
                    }
                }
            }
        }
    }
}
