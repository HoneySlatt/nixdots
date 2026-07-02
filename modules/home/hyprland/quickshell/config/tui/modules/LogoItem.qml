import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: TuiTheme.barH
    implicitHeight: TuiTheme.barH

    Text {
        id: logoText
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: TuiTheme.barIconOffsetX
        anchors.verticalCenterOffset: TuiTheme.barIconOffsetY
        text: TuiDistroState.icon
        color: logoMouse.containsMouse ? TuiTheme.highlight : TuiTheme.barText
        font.family: TuiTheme.fontFamily
        font.pixelSize: TuiTheme.barDistroIconSize
        font.weight: TuiTheme.fontWeight
        verticalAlignment: Text.AlignVCenter
    }

    opacity: logoMouse.containsMouse ? 0.82 : 1.0
    Behavior on opacity { NumberAnimation { duration: 80 } }

    MouseArea {
        id: logoMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: TuiLauncherState.toggle()
    }
}
