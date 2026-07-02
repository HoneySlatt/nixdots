import QtQuick
import QtQuick.Layouts
import ".."
import "../services" as Services

Item {
    id: root
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: workspaceRow.implicitWidth + TuiTheme.compactItemPad
    implicitHeight: TuiTheme.barH

    function focusWorkspace(idx) {
        Services.NiriData.dispatch("focus-workspace " + idx);
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
                readonly property bool active: {
                    if (!Services.NiriData.activeWorkspace) return false;
                    return wsId === Services.NiriData.activeWorkspace.idx;
                }
                readonly property bool occupied: {
                    if (!Services.NiriData.workspaces) return false;
                    for (let i = 0; i < Services.NiriData.workspaces.length; i++) {
                        if (Services.NiriData.workspaces[i].idx === wsId) return true;
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
                    onWheel: wheel => root.focusWorkspace(wheel.angleDelta.y > 0 ? wsId - 1 : wsId + 1)
                }
            }
        }
    }
}
