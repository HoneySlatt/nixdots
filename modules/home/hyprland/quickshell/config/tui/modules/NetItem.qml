import QtQuick
import QtQuick.Layouts
import ".."

Item {
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: netRow.implicitWidth + TuiTheme.itemPad * 2
    implicitHeight: TuiTheme.barH

    Rectangle {
        anchors.fill: parent
        anchors.margins: 3
        color: itemMouse.containsMouse ? TuiTheme.barHover : "transparent"
    }

    readonly property string status: {
        if (TuiNetworkState.netType === "ethernet") return "\uf6ff";
        if (TuiNetworkState.netType === "wifi") return "\uf1eb";
        return "\uf1eb";
    }

    Row {
        id: netRow
        anchors.centerIn: parent
        height: TuiTheme.barH
        spacing: 0

        Text {
            height: TuiTheme.barH
            text: "NET "
            color: TuiTheme.barText
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiTheme.fontSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
        Text {
            height: TuiTheme.barH
            text: TuiNetworkState.vpnConnected ? "VPN" : status
            color: TuiNetworkState.netType === "offline" ? TuiTheme.warn : TuiTheme.barText
            font.family: TuiTheme.fontFamily
            font.pixelSize: TuiNetworkState.vpnConnected ? TuiTheme.fontSize : TuiTheme.barIconSize
            font.weight: TuiTheme.fontWeight
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: itemMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: TuiNetworkPopupState.toggle()
    }
}
