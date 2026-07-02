import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: TuiTheme.barH
    implicitHeight: TuiTheme.barH

    Text {
        id: powerText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: TuiTheme.barIconOffsetX
        anchors.verticalCenterOffset: TuiTheme.barIconOffsetY
        text: "\uf011"
        color: powerMouse.containsMouse ? TuiTheme.highlight : TuiTheme.barText
        font.family: TuiTheme.fontFamily
        font.pixelSize: TuiTheme.barIconSize
        font.weight: TuiTheme.fontWeight
        verticalAlignment: Text.AlignVCenter
    }

    opacity: powerMouse.containsMouse ? 0.82 : 1.0
    Behavior on opacity { NumberAnimation { duration: 80 } }

    MouseArea {
        id: powerMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: TuiPowerLauncherState.toggle()
    }
}
