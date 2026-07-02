import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: volRow.implicitWidth + TuiTheme.itemPad * 2
    implicitHeight: TuiTheme.barH

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        color: itemMouse.containsMouse ? TuiTheme.barHover : "transparent"
    }

    Row {
        id: volRow
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: "VOL "
            color: TuiTheme.barText
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            text: TuiVolumeState.muted ? "MUTE" : TuiVolumeState.volume + "%"
            color: TuiVolumeState.muted ? TuiTheme.warn : TuiTheme.barText
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
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) TuiVolumePopupState.toggle()
            else if (mouse.button === Qt.RightButton) TuiVolumeState.toggleMute()
        }
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) TuiVolumeState.volUp()
            else TuiVolumeState.volDown()
        }
    }
}
