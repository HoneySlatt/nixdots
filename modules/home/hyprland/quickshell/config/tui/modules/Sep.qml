import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: sepText.implicitWidth + (heavy ? 12 : 10)
    implicitHeight: TuiTheme.barH

    property bool heavy: false

    Text {
        id: sepText
        anchors.centerIn: parent
        text: "|"
        color: TuiTheme.barMuted
        font.family: TuiTheme.fontFamily
        font.pixelSize: TuiTheme.fontSize
        font.weight: TuiTheme.fontWeight
        verticalAlignment: Text.AlignVCenter
    }
}
