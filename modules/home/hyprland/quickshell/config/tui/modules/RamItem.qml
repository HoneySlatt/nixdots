import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: ramRow.implicitWidth + TuiTheme.itemPad * 2
    implicitHeight: TuiTheme.barH

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        color: itemMouse.containsMouse ? TuiTheme.barHover : "transparent"
    }

    Row {
        id: ramRow
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: "RAM "
            color: TuiTheme.barText
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            text: TuiRamState.percentage + "%"
            color: TuiRamState.percentage >= 95 && TuiRamState.blinkState ? TuiTheme.warn : TuiTheme.barText
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
