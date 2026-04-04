import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    id: launcherScope

    function applyTheme(key) {
        Theme.setTheme(key);
        ThemeLauncherState.close();
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: ThemeLauncherState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"

            WlrLayershell.namespace: "quickshell:themelauncher"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            readonly property int cardW: 340
            readonly property int cardH: 140
            property int selectedIndex: 0

            onVisibleChanged: {
                if (visible) {
                    const idx = Theme.themeKeys.indexOf(Theme.currentTheme);
                    root.selectedIndex = idx >= 0 ? idx : 0;
                    carousel.currentIndex = root.selectedIndex;
                    carousel.positionViewAtIndex(root.selectedIndex, ListView.Center);
                }
            }

            onSelectedIndexChanged: {
                carousel.positionViewAtIndex(selectedIndex, ListView.Center);
            }

            MouseArea {
                anchors.fill: parent
                onClicked: ThemeLauncherState.close()
            }

            Item {
                anchors.fill: parent
                focus: ThemeLauncherState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        ThemeLauncherState.close();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        launcherScope.applyTheme(Theme.themeKeys[root.selectedIndex]);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        if (root.selectedIndex < Theme.themeKeys.length - 1)
                            root.selectedIndex++;
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        if (root.selectedIndex > 0)
                            root.selectedIndex--;
                        event.accepted = true;
                    }
                }
            }

            ListView {
                id: carousel
                anchors.centerIn: parent
                width: parent.width
                height: root.cardH + 60
                orientation: ListView.Horizontal
                model: Theme.themeKeys
                currentIndex: root.selectedIndex
                spacing: 24
                clip: false
                interactive: false

                preferredHighlightBegin: (width - root.cardW) / 2
                preferredHighlightEnd:   (width + root.cardW) / 2
                highlightRangeMode: ListView.StrictlyEnforceRange

                Behavior on contentX {
                    SmoothedAnimation { velocity: 1200 }
                }

                delegate: Item {
                    id: card
                    width: root.cardW
                    height: root.cardH

                    required property string modelData
                    required property int index

                    property int offset: index - carousel.currentIndex
                    property real absOff: Math.abs(offset)
                    property real cardScale: Math.max(0.55, 1.0 - absOff * 0.18)
                    property real cardOpacity: Math.max(0.35, 1.0 - absOff * 0.22)
                    property bool isCurrent: Theme.currentTheme === modelData
                    property bool isSelected: offset === 0
                    property var t: Theme.themes[modelData]

                    opacity: cardOpacity
                    z: 10 - absOff

                    transform: [
                        Rotation {
                            origin.x: root.cardW / 2
                            origin.y: root.cardH / 2
                            angle: -(offset < 0 ? -1 : offset > 0 ? 1 : 0) * Math.pow(absOff, 1.5) * 3.46
                        },
                        Scale {
                            origin.x: root.cardW / 2
                            origin.y: root.cardH / 2
                            xScale: card.cardScale
                            yScale: card.cardScale
                        }
                    ]

                    Rectangle {
                        anchors.fill: parent
                        radius: 12
                        color: card.t.separator
                        border.color: card.isSelected ? card.t.text : "transparent"
                        border.width: card.isSelected ? 2 : 0

                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 8

                            // Theme name + active badge
                            Row {
                                spacing: 8
                                width: parent.width

                                Text {
                                    text: card.t.name
                                    color: card.t.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize + 1
                                    font.weight: Font.Bold
                                }

                                Rectangle {
                                    visible: card.isCurrent
                                    width: activeLabel.implicitWidth + 10
                                    height: activeLabel.implicitHeight + 4
                                    radius: 8
                                    color: card.t.accent
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        id: activeLabel
                                        anchors.centerIn: parent
                                        text: "active"
                                        color: card.t.background
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 3
                                        font.weight: Font.Bold
                                    }
                                }
                            }

                            // Color palette row
                            Row {
                                spacing: 4
                                width: parent.width

                                Repeater {
                                    model: [
                                        card.t.background,
                                        card.t.separator,
                                        card.t.caution,
                                        card.t.text,
                                        card.t.accent,
                                        card.t.process,
                                        card.t.misc,
                                        card.t.warning
                                    ]

                                    delegate: Rectangle {
                                        required property var modelData
                                        width: (parent.width - 7 * 4) / 8
                                        height: 16
                                        radius: 4
                                        color: modelData
                                    }
                                }
                            }

                            // Preview bar
                            Rectangle {
                                width: parent.width
                                height: 32
                                radius: 8
                                color: card.t.background

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 12

                                    Text {
                                        text: "Aa"
                                        color: card.t.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                        font.weight: Font.Bold
                                    }

                                    Rectangle {
                                        width: 20; height: 12; radius: 3
                                        color: card.t.process
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        width: 20; height: 12; radius: 3
                                        color: card.t.misc
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        width: 20; height: 12; radius: 3
                                        color: card.t.warning
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Rectangle {
                                        width: 20; height: 12; radius: 3
                                        color: card.t.accent
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (card.isSelected)
                                launcherScope.applyTheme(modelData);
                            else
                                root.selectedIndex = index;
                        }
                    }
                }
            }

            // Theme name below carousel
            Text {
                anchors.top: carousel.bottom
                anchors.topMargin: 12
                anchors.horizontalCenter: parent.horizontalCenter
                text: Theme.themes[Theme.themeKeys[root.selectedIndex]]?.name ?? ""
                color: Theme.text
                font.family: Theme.fontFamily
                font.pointSize: 14
                font.bold: true
            }
        }
    }
}
