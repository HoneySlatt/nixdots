import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import ".."

Item {
    id: root
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: workspaceRow.implicitWidth + TuiTheme.compactItemPad
    implicitHeight: TuiTheme.barH

    function focusWorkspace(value) {
        if (Hyprland.usingLua) {
            const workspace = typeof value === "number" ? value : JSON.stringify(value);
            Hyprland.dispatch("hl.dsp.focus({ workspace = " + workspace + " })");
        } else {
            Hyprland.dispatch("workspace " + value);
        }
    }

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: 9

            delegate: Item {
                required property int index
                readonly property int wsId: index + 1
                readonly property bool active: wsId === Hyprland.focusedMonitor?.activeWorkspace?.id
                readonly property bool occupied: {
                    if (!Hyprland.workspaces) return false;
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        if (Hyprland.workspaces.values[i].id === wsId) return true;
                    }
                    return false;
                }

                width: 28
                height: TuiTheme.barH

                Rectangle {
                    visible: active
                    anchors.fill: parent
                    anchors.topMargin: 4
                    anchors.bottomMargin: 4
                    color: TuiTheme.barActiveBg
                    border.color: TuiTheme.barInnerBorder
                    border.width: 1
                }

                Text {
                    anchors.centerIn: parent
                    text: wsId
                    color: active ? TuiTheme.barActiveFg : (occupied ? TuiTheme.barText : TuiTheme.barMuted)
                    font.family: TuiTheme.fontFamily
                    font.pixelSize: TuiTheme.fontSize
                    font.weight: TuiTheme.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.focusWorkspace(wsId)
                    onWheel: wheel => root.focusWorkspace(wheel.angleDelta.y > 0 ? "e-1" : "e+1")
                }
            }
        }

        Repeater {
            model: {
                let ws = [];
                if (Hyprland.workspaces) {
                    for (let i = 0; i < Hyprland.workspaces.values.length; i++) {
                        let w = Hyprland.workspaces.values[i];
                        if (w.id < 0) ws.push(w);
                    }
                }
                return ws;
            }

            delegate: Item {
                required property var modelData
                property bool blink: false
                readonly property bool active: modelData.id === Hyprland.focusedMonitor?.activeWorkspace?.id

                width: 28
                height: TuiTheme.barH

                Text {
                    anchors.centerIn: parent
                    text: "{" + wsl(modelData) + "}"
                    color: active ? (blink ? TuiTheme.highlight : TuiTheme.barActiveFg) : TuiTheme.barMuted
                    font.family: TuiTheme.fontFamily
                    font.pixelSize: TuiTheme.fontSize
                    font.weight: TuiTheme.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }

                function wsl(w) {
                    if (w.name === "magic") return "M";
                    if (w.name === "zellij") return "Z";
                    if (w.name === "lock") return "L";
                    return w.id.toString();
                }

                Timer {
                    interval: 500
                    running: active
                    repeat: true
                    onTriggered: parent.blink = !parent.blink
                    onRunningChanged: if (!running) parent.blink = false
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("togglespecialworkspace " + modelData.name)
                    onWheel: wheel => root.focusWorkspace(wheel.angleDelta.y > 0 ? "e-1" : "e+1")
                }
            }
        }
    }
}
