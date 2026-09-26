import QtQuick
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    id: scope

    function bar(value, cells) {
        let filled = Math.max(0, Math.min(cells, Math.round(value / 100 * cells)));
        let out = "";
        for (let i = 0; i < filled; i++) out += "#";
        for (let i = filled; i < cells; i++) out += "-";
        return out;
    }

    function spark(values) {
        if (!values || values.length === 0) return "----------------------------";
        let out = "";
        for (let i = 0; i < values.length; i++) {
            let v = Math.max(0, Math.min(100, values[i]));
            out += v >= 75 ? "#" : v >= 45 ? "+" : v >= 15 ? ":" : ".";
        }
        return out;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiSystemMonitorPopupState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.focusedOutput === root.screen.name

            color: "transparent"

            WlrLayershell.namespace: "quickshell:tui:systemmonitor"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            Connections {
                target: TuiSystemMonitorPopupState
                function onVisibleChanged() {
                    if (TuiSystemMonitorPopupState.visible) {
                        TuiSystemMonitorState.refresh();
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: TuiSystemMonitorPopupState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: TuiSystemMonitorPopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        TuiSystemMonitorPopupState.close();
                        event.accepted = true;
                    }
                }

                Item {
                    id: popupClip
                    anchors.top: TuiState.isTop ? parent.top : undefined
                    anchors.bottom: TuiState.isTop ? undefined : parent.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    width: 760
                    height: 300
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: TuiTheme.bg
                        border.color: TuiTheme.accent
                        border.width: 2

                        MouseArea { anchors.fill: parent }

                        Row {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 14

                            Column {
                                width: 310
                                spacing: 8

                                Text { text: "system monitor"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }

                                Text { text: "cpu " + TuiCpuState.usage + "% [" + scope.bar(TuiCpuState.usage, 18) + "]"; color: TuiCpuState.usage >= 95 ? TuiTheme.warn : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                Text { text: "    " + scope.spark(TuiSystemMonitorState.cpuHistory); color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }

                                Text { text: "gpu " + TuiGpuState.tempC + "c [" + scope.bar(Math.min(TuiGpuState.tempC, 100), 18) + "]"; color: TuiGpuState.tempC >= 85 ? TuiTheme.warn : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                Text { text: "    " + scope.spark(TuiSystemMonitorState.gpuHistory); color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }

                                Text { text: "ram " + TuiRamState.percentage + "% [" + scope.bar(TuiRamState.percentage, 18) + "]"; color: TuiRamState.percentage >= 95 ? TuiTheme.warn : TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                Text { text: "    " + scope.spark(TuiSystemMonitorState.ramHistory); color: TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                            }

                            Rectangle { width: 1; height: parent.height; color: TuiTheme.dim }

                            Column {
                                width: parent.width - 325
                                spacing: 6

                                Row {
                                    spacing: 0
                                    Text { width: 245; text: "process"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight }
                                    Text { width: 58; text: "cpu%"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; horizontalAlignment: Text.AlignRight }
                                    Text { width: 58; text: "mem%"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; horizontalAlignment: Text.AlignRight }
                                    Text { width: 32; text: "kill"; color: TuiTheme.accent; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; horizontalAlignment: Text.AlignRight }
                                }

                                Rectangle { width: parent.width; height: 1; color: TuiTheme.dim }

                                ListView {
                                    id: processList
                                    width: parent.width
                                    height: 230
                                    clip: true
                                    model: TuiSystemMonitorState.processes
                                    spacing: 0
                                    boundsBehavior: Flickable.StopAtBounds

                                    delegate: Item {
                                        required property var modelData
                                        width: processList.width
                                        height: 22

                                        Rectangle { anchors.fill: parent; color: rowMouse.containsMouse ? TuiTheme.dim : "transparent" }

                                        Row {
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 0

                                            Text { width: 245; text: modelData.name; color: TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; elide: Text.ElideRight }
                                            Text { width: 58; text: modelData.cpu; color: TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; horizontalAlignment: Text.AlignRight }
                                            Text { width: 58; text: modelData.mem; color: TuiTheme.fg; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; horizontalAlignment: Text.AlignRight }
                                            Text { width: 32; text: "x"; color: killMouse.containsMouse ? TuiTheme.warn : TuiTheme.dim; font.family: TuiTheme.fontFamily; font.pixelSize: TuiTheme.fontSize; font.weight: TuiTheme.fontWeight; horizontalAlignment: Text.AlignRight; MouseArea { id: killMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: TuiSystemMonitorState.killProcess(modelData.pid) } }
                                        }

                                        MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
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
