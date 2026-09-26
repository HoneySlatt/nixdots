import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "modules" as M
import "services" as Services

PanelWindow {
    id: root

    property bool manuallyVisible: true
    readonly property bool isTop: TuiState.isTop
    readonly property bool isFocused: Services.NiriData.focusedOutput === root.screen.name

    visible: manuallyVisible
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: isTop ? TuiTheme.barH + TuiTheme.pad : TuiTheme.barH - 1
    implicitHeight: TuiTheme.barH

    anchors {
        top: isTop
        bottom: !isTop
        left: true
        right: true
    }

    margins {
        top: isTop ? TuiTheme.pad : 0
        bottom: 0
        left: isTop ? TuiTheme.pad : 0
        right: isTop ? TuiTheme.pad : 0
    }

    Rectangle {
        id: barFrame
        anchors.fill: parent
        color: TuiTheme.barBg
        border.color: TuiTheme.barBorder
        border.width: root.isTop ? 1 : 0
        clip: true

        Rectangle {
            anchors.fill: parent
            anchors.margins: 2
            color: "transparent"
            border.color: TuiTheme.barInnerBorder
            border.width: root.isTop ? 1 : 0
        }

        Item {
            anchors.centerIn: parent
            implicitWidth: clockRow.implicitWidth + 18
            implicitHeight: TuiTheme.barH

            Rectangle {
                anchors.fill: parent
                anchors.margins: 3
                color: clockMouse.containsMouse ? TuiTheme.barHover : "transparent"
                border.color: clockMouse.containsMouse ? TuiTheme.barInnerBorder : "transparent"
                border.width: 1
            }

            Row {
                id: clockRow
                anchors.centerIn: parent
                spacing: 0

                Text {
                    text: Qt.formatDateTime(clockTimer.ts, "hh:mm ap").toUpperCase()
                    color: TuiTheme.barText
                    font.family: TuiTheme.fontFamily
                    font.pixelSize: TuiTheme.fontSize
                    font.weight: TuiTheme.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: " | "
                    color: TuiTheme.barMuted
                    font.family: TuiTheme.fontFamily
                    font.pixelSize: TuiTheme.fontSize
                    font.weight: TuiTheme.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }
                Text {
                    text: Qt.formatDateTime(clockTimer.ts, "ddd dd")
                    color: TuiTheme.barText
                    font.family: TuiTheme.fontFamily
                    font.pixelSize: TuiTheme.fontSize
                    font.weight: TuiTheme.fontWeight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                id: clockMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: TuiCalendarPopupState.toggle()
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: TuiTheme.barSidePad
            anchors.rightMargin: TuiTheme.barSidePad
            spacing: 0

            // === LEFT SECTION ===
            RowLayout {
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                spacing: 0

                M.LogoItem {}
                M.Sep {}
                M.WsItem {}
                M.Sep {}
                M.CpuItem {}
                M.Sep {}
                M.GpuItem {}
                M.Sep {}
                M.RamItem {}
            }

            Item { Layout.fillWidth: true }

            // === RIGHT SECTION ===
            RowLayout {
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                spacing: 0

                M.TrayItem { rootWindow: root }
                M.Sep {}
                M.VolItem {}
                M.Sep {}
                M.NetItem {}
                M.Sep {}
                M.BatItem {}
                M.Sep {}
                M.PowerItem {}
            }
        }

        QtObject {
            id: clockTimer
            property date ts: new Date()
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: clockTimer.ts = new Date()
        }
    }
}
