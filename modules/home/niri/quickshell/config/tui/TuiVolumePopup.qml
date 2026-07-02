import QtQuick
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    id: popupScope

    property int barCells: 24

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiVolumePopupState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: { if (!Services.NiriData.monitors) return false; const monitors = Services.NiriData.monitors; for (let key in monitors) { if (monitors[key].name === root.screen.name && monitors[key].focused) return true; } return false; }
            property bool showDevices: false
            property bool showApps: false

            color: "transparent"

            WlrLayershell.namespace: "quickshell:tui:volume"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            Connections {
                target: TuiVolumePopupState
                function onVisibleChanged() {
                    if (TuiVolumePopupState.visible) {
                        TuiVolumeState.refreshSinks();
                        TuiVolumeState.refreshAppStreams();
                    } else {
                        root.showDevices = false;
                        root.showApps = false;
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: TuiVolumePopupState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: TuiVolumePopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        TuiVolumePopupState.close();
                        event.accepted = true;
                    }
                }

                Item {
                    id: popupClip
                    anchors.top: TuiState.isTop ? parent.top : undefined
                    anchors.bottom: TuiState.isTop ? undefined : parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 68
                    width: 300
                    height: contentCol.implicitHeight + 24
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: TuiTheme.bg
                        border.color: TuiTheme.accent
                        border.width: 2

                        Column {
                            id: contentCol
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Row {
                                spacing: 0
                                width: parent.width

                                Text {
                                    text: " audio "
                                    color: TuiTheme.accent
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: TuiVolumeState.toggleMute()
                                    }
                                }
                                Text {
                                    text: " "
                                    color: TuiTheme.dim
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: TuiVolumeState.muted ? "mute" : TuiVolumeState.volume + "%"
                                    color: TuiVolumeState.muted ? TuiTheme.warn : TuiTheme.bright
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: TuiVolumeState.toggleMute()
                                    }
                                }
                            }

                            Item {
                                width: parent.width
                                height: volBar.height + 4

                                Row {
                                    id: volBar
                                    y: 2
                                    spacing: 0

                                    Text {
                                        text: "["
                                        color: TuiTheme.dim
                                        font.family: TuiTheme.fontFamily
                                        font.pixelSize: TuiTheme.fontSize
                                        font.weight: TuiTheme.fontWeight
                                        verticalAlignment: Text.AlignVCenter
                                    }

                                    Repeater {
                                        model: popupScope.barCells

                                        delegate: Text {
                                            required property int index
                                            property bool filled: index < Math.round(TuiVolumeState.volume / 100 * popupScope.barCells)
                                            text: filled ? "\u2588" : "\u2591"
                                            color: TuiVolumeState.muted ? TuiTheme.warn : (filled ? TuiTheme.accent : TuiTheme.dim)
                                            font.family: TuiTheme.fontFamily
                                            font.pixelSize: TuiTheme.fontSize
                                            font.weight: TuiTheme.fontWeight
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                    }

                                    Text {
                                        text: "]"
                                        color: TuiTheme.dim
                                        font.family: TuiTheme.fontFamily
                                        font.pixelSize: TuiTheme.fontSize
                                        font.weight: TuiTheme.fontWeight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    preventStealing: true
                                    onPressed: mouse => {
                                        let relX = mouse.x - volBar.x;
                                        TuiVolumeState.setVolume(Math.max(0, Math.min(100, Math.round(relX / volBar.width * 100))));
                                    }
                                    onPositionChanged: mouse => {
                                        if (pressed) {
                                            let relX = mouse.x - volBar.x;
                                            TuiVolumeState.setVolume(Math.max(0, Math.min(100, Math.round(relX / volBar.width * 100))));
                                        }
                                    }
                                }
                            }

                            Text {
                                text: " \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                color: TuiTheme.dim
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize
                                font.weight: TuiTheme.fontWeight
                            }

                            Text {
                                text: root.showDevices ? " \u25BE output device" : " \u25B8 output device"
                                color: volDevMouse.containsMouse ? TuiTheme.bright : TuiTheme.fg
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize
                                font.weight: TuiTheme.fontWeight

                                MouseArea {
                                    id: volDevMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.showDevices = !root.showDevices;
                                        if (root.showDevices) TuiVolumeState.refreshSinks();
                                    }
                                }
                            }

                            Column {
                                visible: root.showDevices
                                width: parent.width
                                spacing: 0

                                Repeater {
                                    model: TuiVolumeState.sinks

                                    delegate: Text {
                                        required property var modelData
                                        text: (modelData.active ? "   \u25CF " : "   \u25CB ") + modelData.label
                                        color: modelData.active ? TuiTheme.accent : TuiTheme.fg
                                        font.family: TuiTheme.fontFamily
                                        font.pixelSize: TuiTheme.fontSize
                                        font.weight: TuiTheme.fontWeight
                                        elide: Text.ElideRight

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: TuiVolumeState.setDefaultSink(modelData.sinkId)
                                        }
                                    }
                                }
                            }

                            Text {
                                text: " \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                color: TuiTheme.dim
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize
                                font.weight: TuiTheme.fontWeight
                            }

                            Text {
                                text: root.showApps ? " \u25BE app volumes" : " \u25B8 app volumes"
                                color: volAppMouse.containsMouse ? TuiTheme.bright : TuiTheme.fg
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize
                                font.weight: TuiTheme.fontWeight

                                MouseArea {
                                    id: volAppMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.showApps = !root.showApps;
                                        if (root.showApps) TuiVolumeState.refreshAppStreams();
                                    }
                                }
                            }

                            Column {
                                visible: root.showApps
                                width: parent.width
                                spacing: 0

                                Text {
                                    visible: TuiVolumeState.appStreams.length === 0
                                    text: "   no app streams"
                                    color: TuiTheme.dim
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                }

                                Repeater {
                                    model: TuiVolumeState.appStreams

                                    delegate: Item {
                                        required property var modelData
                                        property int localVolume: modelData.volume
                                        width: contentCol.width - 24
                                        height: appRow.height + 4

                                        Row {
                                            id: appRow
                                            y: 2
                                            spacing: 0

                                            Text {
                                                text: "  "
                                                color: TuiTheme.dim
                                                font.family: TuiTheme.fontFamily
                                                font.pixelSize: TuiTheme.fontSize
                                                font.weight: TuiTheme.fontWeight
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                            Text {
                                                text: modelData.label
                                                color: TuiTheme.fg
                                                font.family: TuiTheme.fontFamily
                                                font.pixelSize: TuiTheme.fontSize
                                                font.weight: TuiTheme.fontWeight
                                                verticalAlignment: Text.AlignVCenter
                                                elide: Text.ElideRight
                                                width: 80
                                            }
                                            Text {
                                                text: " "
                                                color: TuiTheme.dim
                                                font.family: TuiTheme.fontFamily
                                                font.pixelSize: TuiTheme.fontSize
                                                font.weight: TuiTheme.fontWeight
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            Row {
                                                id: appBar
                                                spacing: 0

                                                Text {
                                                    text: "["
                                                    color: TuiTheme.dim
                                                    font.family: TuiTheme.fontFamily
                                                    font.pixelSize: TuiTheme.fontSize
                                                    font.weight: TuiTheme.fontWeight
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                                Repeater {
                                                    model: 16

                                                    delegate: Text {
                                                        required property int index
                                                         property bool filled: index < Math.round(localVolume / 100 * 16)
                                                        text: filled ? "\u2588" : "\u2591"
                                                        color: modelData.muted ? TuiTheme.warn : (filled ? TuiTheme.accent : TuiTheme.dim)
                                                        font.family: TuiTheme.fontFamily
                                                        font.pixelSize: TuiTheme.fontSize
                                                        font.weight: TuiTheme.fontWeight
                                                        verticalAlignment: Text.AlignVCenter
                                                    }
                                                }
                                                Text {
                                                    text: "]"
                                                    color: TuiTheme.dim
                                                    font.family: TuiTheme.fontFamily
                                                    font.pixelSize: TuiTheme.fontSize
                                                    font.weight: TuiTheme.fontWeight
                                                    verticalAlignment: Text.AlignVCenter
                                                }
                                            }

                                            Text {
                                                text: " " + localVolume + "%"
                                                color: TuiTheme.dim
                                                font.family: TuiTheme.fontFamily
                                                font.pixelSize: TuiTheme.fontSize
                                                font.weight: TuiTheme.fontWeight
                                                verticalAlignment: Text.AlignVCenter
                                                width: 40
                                            }
                                            Text {
                                                text: modelData.muted ? "[m]" : ""
                                                color: TuiTheme.warn
                                                font.family: TuiTheme.fontFamily
                                                font.pixelSize: TuiTheme.fontSize
                                                font.weight: TuiTheme.fontWeight
                                                verticalAlignment: Text.AlignVCenter

                                                MouseArea {
                                                    anchors.fill: parent
                                                    cursorShape: Qt.PointingHandCursor
                                                    visible: modelData.muted
                                                    onClicked: TuiVolumeState.toggleAppMute(modelData.streamId)
                                                }
                                            }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            preventStealing: true
                                            onPressed: mouse => {
                                                let mapped = appBar.mapToItem(parent, 0, 0);
                                                let relX = mouse.x - mapped.x;
                                                if (relX >= 0 && relX <= appBar.width) {
                                                    let vol = Math.max(0, Math.min(100, Math.round(relX / appBar.width * 100)));
                                                    parent.localVolume = vol;
                                                    TuiVolumeState.setAppVolume(modelData.streamId, vol);
                                                }
                                            }
                                            onPositionChanged: mouse => {
                                                if (pressed) {
                                                    let mapped = appBar.mapToItem(parent, 0, 0);
                                                    let relX = mouse.x - mapped.x;
                                                    if (relX >= 0 && relX <= appBar.width) {
                                                        let vol = Math.max(0, Math.min(100, Math.round(relX / appBar.width * 100)));
                                                        parent.localVolume = vol;
                                                        TuiVolumeState.setAppVolume(modelData.streamId, vol);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
