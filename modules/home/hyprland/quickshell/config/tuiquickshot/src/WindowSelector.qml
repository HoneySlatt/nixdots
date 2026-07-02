import QtQuick
import Quickshell.Hyprland
import ".."

Item {
    id: root

    property var monitor: Hyprland.focusedMonitor
    property var workspace: monitor?.activeWorkspace
    property var windows: workspace?.toplevels ?? []
    property real dimOpacity: 0.62
    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

    signal checkHover(real mouseX, real mouseY)
    signal regionSelected(real x, real y, real width, real height)

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.dimOpacity
    }

    Rectangle {
        x: root.selectionX
        y: root.selectionY
        width: root.selectionWidth
        height: root.selectionHeight
        color: "transparent"
        border.color: TuiQuickshotTheme.bright
        border.width: 2
        visible: width > 0 && height > 0

        Rectangle {
            anchors.fill: parent
            anchors.margins: 4
            color: "transparent"
            border.color: TuiQuickshotTheme.accent
            border.width: 1
        }
    }

    Repeater {
        model: root.windows

        Item {
            required property var modelData

            Connections {
                target: root

                function onCheckHover(mouseX, mouseY) {
                    const monitorX = root.monitor.lastIpcObject.x;
                    const monitorY = root.monitor.lastIpcObject.y;
                    const windowX = modelData.lastIpcObject.at[0] - monitorX;
                    const windowY = modelData.lastIpcObject.at[1] - monitorY;
                    const width = modelData.lastIpcObject.size[0];
                    const height = modelData.lastIpcObject.size[1];

                    if (mouseX >= windowX && mouseX <= windowX + width
                        && mouseY >= windowY && mouseY <= windowY + height) {
                        root.selectionX = windowX;
                        root.selectionY = windowY;
                        root.selectionWidth = width;
                        root.selectionHeight = height;
                    }
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onPositionChanged: mouse => root.checkHover(mouse.x, mouse.y)

        onReleased: mouse => {
            if (mouse.x >= root.selectionX && mouse.x <= root.selectionX + root.selectionWidth
                && mouse.y >= root.selectionY && mouse.y <= root.selectionY + root.selectionHeight) {
                root.regionSelected(
                    Math.round(root.selectionX),
                    Math.round(root.selectionY),
                    Math.round(root.selectionWidth),
                    Math.round(root.selectionHeight)
                );
            }
        }
    }
}
