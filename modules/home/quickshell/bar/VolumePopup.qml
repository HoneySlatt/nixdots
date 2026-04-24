import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: VolumePopupState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            color: "transparent"
            property bool showDevices: false

            WlrLayershell.namespace: "quickshell:volumepopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            // ── Focus grab ──

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => {
                    if (!active)
                        VolumePopupState.close();
                }
            }

            Connections {
                target: VolumePopupState
                function onVisibleChanged() {
                    if (VolumePopupState.visible) {
                        grabTimer.start();
                    } else {
                        grabTimer.stop();
                        grab.active = false;
                        root.showDevices = false;
                    }
                }
            }

            Timer {
                id: grabTimer
                interval: 50
                repeat: false
                onTriggered: grab.active = VolumePopupState.visible
            }

            // ── Click outside to close ──

            MouseArea {
                anchors.fill: parent
                onClicked: VolumePopupState.close()
            }

            // ── Keyboard handling ──

            FocusScope {
                anchors.fill: parent
                focus: VolumePopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        VolumePopupState.close();
                        event.accepted = true;
                    }
                }

                // ── Popup panel ──

                // Clip container — hides the radius on the bar-side edge
                Item {
                    id: popupClip
                    anchors.top: BarState.isTop ? parent.top : undefined
                    anchors.bottom: BarState.isTop ? undefined : parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 86
                    width: 240
                    height: contentCol.height + 24
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 0
                        anchors.bottomMargin: BarState.isTop ? 0 : -radius
                        height: parent.height + radius
                        color: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, Theme.popupOpacity)
                        radius: 10
                        border.color: Theme.separator
                        border.width: 1
                    }

                    // Block clicks inside from closing
                    MouseArea { anchors.fill: parent }

                    Column {
                        id: contentCol
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        spacing: 8

                        // ── Header ──

                        RowLayout {
                            width: parent.width
                            spacing: 6

                            Item {
                                implicitWidth: iconText.implicitWidth
                                implicitHeight: iconText.implicitHeight

                                Text {
                                    id: iconText
                                    text: {
                                        if (VolumeState.muted) return "\uf026";
                                        if (VolumeState.volume <= 30) return "\uf027";
                                        return "\uf028";
                                    }
                                    color: VolumeState.muted ? Theme.caution : Theme.misc
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize + 2
                                    font.weight: Theme.fontWeight
                                    opacity: muteIconMa.containsMouse ? 0.6 : 1.0
                                    Behavior on opacity { NumberAnimation { duration: 80 } }
                                }

                                MouseArea {
                                    id: muteIconMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: VolumeState.toggleMute()
                                }
                            }

                            Text {
                                text: "Volume"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Font.Bold
                                Layout.fillWidth: true
                            }

                            Text {
                                text: VolumeState.volume + "%"
                                color: Theme.caution
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Theme.fontWeight
                            }
                        }

                        // ── Volume slider ──

                        Item {
                            width: parent.width
                            height: 20

                            Rectangle {
                                id: sliderTrack
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                height: 6
                                radius: 3
                                color: Theme.separator

                                Rectangle {
                                    width: parent.width * (VolumeState.volume / 100)
                                    height: parent.height
                                    radius: parent.radius
                                    color: VolumeState.muted ? Theme.separator : Theme.misc
                                    Behavior on width { NumberAnimation { duration: 60 } }
                                }

                                // Slider handle
                                Rectangle {
                                    x: parent.width * (VolumeState.volume / 100) - width / 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: VolumeState.muted ? Theme.separator : Theme.misc
                                    Behavior on x { NumberAnimation { duration: 60 } }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                preventStealing: true
                                onClicked: function(mouse) {
                                    let pct = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)));
                                    VolumeState.setVolume(pct);
                                }
                                onPositionChanged: function(mouse) {
                                    if (pressed) {
                                        let pct = Math.max(0, Math.min(100, Math.round(mouse.x / width * 100)));
                                        VolumeState.setVolume(pct);
                                    }
                                }
                            }
                        }

                        // ── Output devices button ──

                        Rectangle {
                            width: parent.width
                            height: 28
                            radius: 6
                            color: devicesMa.containsMouse ? Theme.separator : "transparent"

                            Row {
                                anchors.centerIn: parent
                                spacing: 6

                                Text {
                                    text: "\uf025"
                                    color: Theme.misc
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 1
                                    font.weight: Theme.fontWeight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: "Output devices"
                                    color: Theme.text
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 1
                                    font.weight: Theme.fontWeight
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Text {
                                    text: root.showDevices ? "\uf0d8" : "\uf0d7"
                                    color: Theme.misc
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 2
                                    font.weight: Theme.fontWeight
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }

                            MouseArea {
                                id: devicesMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.showDevices = !root.showDevices;
                                    if (root.showDevices)
                                        VolumeState.refreshSinks();
                                }
                            }
                        }

                        // ── Sink list ──

                        Repeater {
                            model: root.showDevices ? VolumeState.sinks : []

                            delegate: Rectangle {
                                required property var modelData
                                width: contentCol.width
                                height: 26
                                radius: 5
                                color: {
                                    if (modelData.active)
                                        return Qt.rgba(Theme.misc.r, Theme.misc.g, Theme.misc.b, 0.18);
                                    if (sinkMa.containsMouse)
                                        return Theme.separator;
                                    return "transparent";
                                }

                                Row {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 6

                                    Text {
                                        text: modelData.active ? "\uf058" : "\uf10c"
                                        color: modelData.active ? Theme.misc : Theme.separator
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 3
                                        font.weight: Theme.fontWeight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: modelData.label
                                        color: modelData.active ? Theme.misc : Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 2
                                        font.weight: Theme.fontWeight
                                        width: parent.width - 22
                                        elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                MouseArea {
                                    id: sinkMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: VolumeState.setDefaultSink(modelData.sinkId)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
