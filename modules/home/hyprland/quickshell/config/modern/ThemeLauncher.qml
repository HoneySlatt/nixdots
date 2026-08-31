import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    function applyTheme(key) {
        Theme.setTheme(key);
        ThemeLauncherState.close();
    }

    component GlassPanel: Rectangle {
        property color fillColor: Theme.card
        property color accentColor: Theme.accent

        radius: 24
        color: "transparent"
        border.color: Qt.tint(Theme.separator, Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.34))
        border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.tint(fillColor, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.06)) }
            GradientStop { position: 0.58; color: fillColor }
            GradientStop { position: 1.0; color: Qt.tint(fillColor, Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.20)) }
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
            color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.16)
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.10)
            border.width: 1
        }
    }

    component ColorChip: Rectangle {
        property color chipColor: Theme.accent

        width: 28
        height: 14
        radius: 4
        color: chipColor
        border.color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.10)
        border.width: 1
    }

    component ThemeCard: Rectangle {
        id: themeCard

        required property string themeKey
        required property int cardIndex

        property var themeData: Theme.themes[themeKey]
        property color themeBg: themeData.background
        property color themeText: themeData.text
        property color themeSeparator: themeData.separator
        property color themeWarning: themeData.warning
        property color themeCaution: themeData.caution
        property color themeMisc: themeData.misc
        property color themeProcess: themeData.process
        property color themeAccent: themeData.accent
        property bool selected: root.selectedIndex === cardIndex
        property bool active: Theme.currentTheme === themeKey

        signal selectedClicked()
        signal hovered()

        width: root.cardW
        height: root.cardH
        radius: 18
        color: Qt.rgba(themeBg.r, themeBg.g, themeBg.b, selected ? 0.76 : 0.58)
        border.color: selected
            ? Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.88)
            : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.46)
        border.width: selected ? 2 : 1

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }

        Rectangle {
            visible: selected
            anchors.fill: parent
            anchors.margins: -5
            radius: parent.radius + 5
            color: "transparent"
            border.color: Qt.rgba(themeAccent.r, themeAccent.g, themeAccent.b, 0.24)
            border.width: 2
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 18
            anchors.rightMargin: 18
            anchors.topMargin: 1
            height: 1
            radius: 1
            color: Qt.rgba(themeText.r, themeText.g, themeText.b, 0.13)
        }

        Column {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 16

            Text {
                width: parent.width
                text: themeData.name
                color: themeText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.Bold
                elide: Text.ElideRight
            }

            Row {
                spacing: 5
                ColorChip { chipColor: themeBg }
                ColorChip { chipColor: themeText }
                ColorChip { chipColor: themeSeparator }
                ColorChip { chipColor: themeWarning }
            }

            Rectangle {
                width: parent.width
                height: 30
                radius: 8
                color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.42)

                Row {
                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        text: "Aa"
                        color: themeText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle { width: 18; height: 9; radius: 3; color: themeProcess; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 18; height: 9; radius: 3; color: themeMisc; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 18; height: 9; radius: 3; color: themeWarning; anchors.verticalCenter: parent.verticalCenter }
                    Rectangle { width: 18; height: 9; radius: 3; color: themeAccent; anchors.verticalCenter: parent.verticalCenter }
                }
            }

            Item { width: 1; height: 18 }

            Item {
                width: parent.width
                height: 38

                Rectangle {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    radius: 12
                    color: "transparent"
                    border.color: selected ? themeAccent : Qt.rgba(themeText.r, themeText.g, themeText.b, 0.34)
                    border.width: selected ? 2 : 1

                    Rectangle {
                        visible: selected
                        anchors.centerIn: parent
                        width: 8
                        height: 8
                        radius: 4
                        color: themeAccent
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: themeCard.hovered()
            onClicked: themeCard.selectedClicked()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: ThemeLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: Hyprland.focusedMonitor?.id == monitor?.id
            onMonitorIsFocusedChanged: if (!monitorIsFocused) ThemeLauncherState.close()

            color: "transparent"

            WlrLayershell.namespace: "quickshell:themelauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            exclusionMode: ExclusionMode.Ignore

            anchors { top: true; bottom: true; left: true; right: true }

            readonly property int cardW: 154
            readonly property int cardH: 210
            readonly property int cardSpacing: 14
            property int selectedIndex: 0
            readonly property string selectedKey: Theme.themeKeys[selectedIndex] ?? Theme.currentTheme
            readonly property var selectedTheme: Theme.themes[selectedKey] ?? Theme.themes[Theme.currentTheme]
            readonly property color selectedBg: selectedTheme.background
            readonly property color selectedText: selectedTheme.text
            readonly property color selectedSeparator: selectedTheme.separator
            readonly property color selectedWarning: selectedTheme.warning
            readonly property color selectedCaution: selectedTheme.caution
            readonly property color selectedMisc: selectedTheme.misc
            readonly property color selectedProcess: selectedTheme.process
            readonly property color selectedAccent: selectedTheme.accent

            function clampSelection() {
                selectedIndex = Math.max(0, Math.min(Theme.themeKeys.length - 1, selectedIndex));
            }

            function selectCurrentTheme() {
                const idx = Theme.themeKeys.indexOf(Theme.currentTheme);
                selectedIndex = idx >= 0 ? idx : 0;
            }

            onVisibleChanged: {
                if (visible) {
                    selectCurrentTheme();
                    focusTimer.start();
                    grabTimer.start();
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => {
                    if (!active) ThemeLauncherState.close();
                }
            }

            Connections {
                target: ThemeLauncherState
                function onVisibleChanged() {
                    if (!ThemeLauncherState.visible) {
                        focusTimer.stop();
                        grabTimer.stop();
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: grabTimer
                interval: 50
                repeat: false
                onTriggered: grab.active = ThemeLauncherState.visible
            }

            Timer {
                id: focusTimer
                interval: 80
                repeat: false
                onTriggered: keyLayer.forceActiveFocus()
            }

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.58)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: ThemeLauncherState.close()
            }

            Item {
                id: keyLayer
                anchors.fill: parent
                focus: ThemeLauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        ThemeLauncherState.close();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        launcherScope.applyTheme(root.selectedKey);
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                        root.selectedIndex--;
                        root.clampSelection();
                        event.accepted = true;
                        return;
                    }
                    if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                        root.selectedIndex++;
                        root.clampSelection();
                        event.accepted = true;
                    }
                }
            }

            GlassPanel {
                id: mainPanel
                anchors.centerIn: parent
                anchors.verticalCenterOffset: 42
                width: Math.min(parent.width - 80, 1080)
                height: 360
                radius: 24
                fillColor: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.62)
                accentColor: root.selectedAccent

                MouseArea { anchors.fill: parent; onClicked: keyLayer.forceActiveFocus() }

                Text {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.leftMargin: 26
                    anchors.topMargin: 32
                    text: "Themes"
                    color: Theme.text
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 4
                    font.weight: Font.Bold
                }

                ListView {
                    id: themeList
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: 24
                    anchors.rightMargin: 24
                    anchors.bottomMargin: 28
                    height: root.cardH
                    orientation: ListView.Horizontal
                    model: Theme.themeKeys
                    currentIndex: root.selectedIndex
                    spacing: root.cardSpacing
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Center)

                    delegate: ThemeCard {
                        required property string modelData
                        required property int index

                        themeKey: modelData
                        cardIndex: index
                        onHovered: root.selectedIndex = index
                        onSelectedClicked: {
                            if (root.selectedIndex === index) launcherScope.applyTheme(modelData);
                            else root.selectedIndex = index;
                        }
                    }
                }
            }

            GlassPanel {
                id: previewPanel
                anchors.horizontalCenter: parent.horizontalCenter
                y: mainPanel.y - 86
                width: 470
                height: 190
                radius: 24
                fillColor: Qt.rgba(root.selectedBg.r, root.selectedBg.g, root.selectedBg.b, 0.82)
                accentColor: root.selectedAccent

                Column {
                    anchors.fill: parent
                    anchors.margins: 24
                    spacing: 18

                    RowLayout {
                        width: parent.width
                        height: 26
                        spacing: 10

                        Text {
                            text: root.selectedTheme.name
                            color: root.selectedText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 6
                            font.weight: Font.Bold
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Rectangle {
                            visible: root.selectedKey === Theme.currentTheme
                            Layout.alignment: Qt.AlignVCenter
                            width: activeLabel.implicitWidth + 16
                            height: 22
                            radius: 11
                            color: root.selectedAccent

                            Text {
                                id: activeLabel
                                anchors.centerIn: parent
                                text: "active"
                                color: root.selectedBg
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 3
                                font.weight: Font.Bold
                            }
                        }
                    }

                    Row {
                        spacing: 7
                        ColorChip { width: 42; height: 16; chipColor: root.selectedBg }
                        ColorChip { width: 42; height: 16; chipColor: root.selectedText }
                        ColorChip { width: 42; height: 16; chipColor: root.selectedAccent }
                        ColorChip { width: 42; height: 16; chipColor: root.selectedProcess }
                        ColorChip { width: 42; height: 16; chipColor: root.selectedWarning }
                    }

                    Rectangle {
                        width: parent.width
                        height: 32
                        radius: 8
                        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.42)

                        Row {
                            anchors.centerIn: parent
                            spacing: 12

                            Text {
                                text: "Aa"
                                color: root.selectedText
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                font.weight: Font.Bold
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Rectangle { width: 24; height: 10; radius: 3; color: root.selectedProcess; anchors.verticalCenter: parent.verticalCenter }
                            Rectangle { width: 24; height: 10; radius: 3; color: root.selectedMisc; anchors.verticalCenter: parent.verticalCenter }
                            Rectangle { width: 24; height: 10; radius: 3; color: root.selectedWarning; anchors.verticalCenter: parent.verticalCenter }
                            Rectangle { width: 24; height: 10; radius: 3; color: root.selectedAccent; anchors.verticalCenter: parent.verticalCenter }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: launcherScope.applyTheme(root.selectedKey)
                }
            }
        }
    }
}
