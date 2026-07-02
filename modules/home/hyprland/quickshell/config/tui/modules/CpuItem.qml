import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: cpuRow.implicitWidth + TuiTheme.itemPad * 2
    implicitHeight: TuiTheme.barH

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        color: itemMouse.containsMouse ? TuiTheme.barHover : "transparent"
    }

    Row {
        id: cpuRow
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: "CPU "
            color: TuiTheme.barText
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            text: TuiCpuState.usage + "%"
            color: TuiCpuState.usage >= 95 && TuiCpuState.blinkState ? TuiTheme.warn : TuiTheme.barText
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
        onClicked: TuiSystemMonitorPopupState.toggle()
    }
}
