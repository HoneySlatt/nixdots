import QtQuick
import ".."

Row {
    spacing: 0

    Text {
        text: TuiDistroState.hostname
        color: TuiTheme.accent
        font.family: TuiTheme.fontFamily
        font.pixelSize: TuiTheme.fontSize
        font.weight: TuiTheme.fontWeight
        verticalAlignment: Text.AlignVCenter
    }
}