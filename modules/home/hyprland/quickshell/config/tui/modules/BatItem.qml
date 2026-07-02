import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: batRow.implicitWidth + TuiTheme.itemPad * 2
    implicitHeight: TuiTheme.barH

    visible: TuiBatteryState.hasBattery

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        color: itemMouse.containsMouse ? TuiTheme.barHover : "transparent"
    }

    Row {
        id: batRow
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: "BAT "
            color: TuiTheme.barText
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            text: TuiBatteryState.text
            color: TuiTheme.barText
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            text: " \uf240"
            color: TuiTheme.barMuted
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: TuiPowerLauncherState.toggle()
    }
}
