import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."
import "../services" as Services

Item {
    id: root

    Layout.alignment: Qt.AlignVCenter
    implicitWidth: workspaceRow.implicitWidth + 8
    implicitHeight: Theme.barHeight

    function focusWorkspace(idx) {
        Services.NiriData.dispatch("focus-workspace " + idx);
    }

    Row {
        id: workspaceRow
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 8
        spacing: 0

        Repeater {
            model: {
                let ws = [];
                if (Services.NiriData.workspaces) {
                    for (let i = 0; i < Services.NiriData.workspaces.length; i++) {
                        ws.push(Services.NiriData.workspaces[i]);
                    }
                }
                ws.sort((a, b) => a.idx - b.idx);
                return ws.filter(w => w.idx > 0);
            }

            delegate: Item {
                required property var modelData

                width: 32
                height: Theme.barHeight

                Text {
                    anchors.centerIn: parent
                    text: {
                        if (modelData.name === "magic") return "\uf074";
                        if (modelData.name === "zellij") return "\uf120";
                        if (modelData.idx === 10) return "\u{f02b4}";
                        if (modelData.name === "lock") return "\uf023";
                        return "\uf111";
                    }
                    color: {
                        if (modelData.is_focused)
                            return Theme.text;
                        return Theme.caution;
                    }
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                    font.italic: true

                    Behavior on color {
                        ColorAnimation { duration: 250 }
                    }
                }

                MouseArea {
                    cursorShape: Qt.PointingHandCursor
                    anchors.fill: parent
                    onClicked: root.focusWorkspace(modelData.idx)
                    onWheel: wheel => root.focusWorkspace(wheel.angleDelta.y > 0 ? modelData.idx - 1 : modelData.idx + 1)
                }
            }
        }
    }
}
