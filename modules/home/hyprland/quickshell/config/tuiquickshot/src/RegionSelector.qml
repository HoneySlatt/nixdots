import QtQuick
import ".."

Item {
    id: root

    signal regionSelected(real x, real y, real width, real height)

    property real dimOpacity: 0.62
    property point startPos
    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

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

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.CrossCursor

        onPressed: mouse => {
            root.startPos = Qt.point(mouse.x, mouse.y);
            root.selectionX = mouse.x;
            root.selectionY = mouse.y;
            root.selectionWidth = 0;
            root.selectionHeight = 0;
        }

        onPositionChanged: mouse => {
            if (!pressed) return;
            root.selectionX = Math.min(root.startPos.x, mouse.x);
            root.selectionY = Math.min(root.startPos.y, mouse.y);
            root.selectionWidth = Math.abs(mouse.x - root.startPos.x);
            root.selectionHeight = Math.abs(mouse.y - root.startPos.y);
        }

        onReleased: {
            if (root.selectionWidth < 4 || root.selectionHeight < 4) return;
            root.regionSelected(
                Math.round(root.selectionX),
                Math.round(root.selectionY),
                Math.round(root.selectionWidth),
                Math.round(root.selectionHeight)
            );
        }
    }
}
