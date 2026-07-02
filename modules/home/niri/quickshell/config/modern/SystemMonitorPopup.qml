import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    id: systemMonitorPopup

    component GlassPanel: Rectangle {
        property color fillColor: Theme.card

        radius: 20
        color: "transparent"
        border.color: Qt.tint(Theme.separator, Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.34))
        border.width: 1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.tint(fillColor, Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.055)) }
            GradientStop { position: 0.58; color: fillColor }
            GradientStop { position: 1.0; color: Qt.tint(fillColor, Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.20)) }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.leftMargin: 22
            anchors.rightMargin: 22
            anchors.topMargin: 1
            height: 1
            radius: 1
            color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.16)
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: 1
            radius: parent.radius - 1
            color: "transparent"
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.10)
            border.width: 1
        }
    }

    component Sparkline: Canvas {
        id: sparkline

        property var values: []
        property int scaleMax: 100
        property color lineColor: Theme.accent
        property color areaColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)

        renderTarget: Canvas.FramebufferObject
        onValuesChanged: requestPaint()
        onLineColorChanged: requestPaint()
        onAreaColorChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            if (values.length < 2 || width <= 0 || height <= 0) return;

            let maxValue = Math.max(1, scaleMax);
            for (let i = 0; i < values.length; i++)
                maxValue = Math.max(maxValue, values[i]);

            function pointX(index) { return 1 + index * (width - 2) / (values.length - 1); }
            function pointY(value) { return height - 2 - Math.max(0, Math.min(1, value / maxValue)) * (height - 5); }

            ctx.beginPath();
            ctx.moveTo(pointX(0), pointY(values[0]));
            for (let i = 1; i < values.length; i++)
                ctx.lineTo(pointX(i), pointY(values[i]));
            ctx.lineTo(width - 1, height - 1);
            ctx.lineTo(1, height - 1);
            ctx.closePath();
            ctx.fillStyle = areaColor;
            ctx.fill();

            ctx.beginPath();
            ctx.moveTo(pointX(0), pointY(values[0]));
            for (let i = 1; i < values.length; i++)
                ctx.lineTo(pointX(i), pointY(values[i]));
            ctx.lineWidth = 2;
            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.strokeStyle = lineColor;
            ctx.stroke();
        }
    }

    component MetricRow: Rectangle {
        id: metricRow

        property string icon: ""
        property string label: ""
        property string value: ""
        property var history: []
        property color accentColor: Theme.accent

        height: 38
        radius: 12
        color: metricMouse.containsMouse ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.045) : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 10

            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 8
                color: Qt.rgba(metricRow.accentColor.r, metricRow.accentColor.g, metricRow.accentColor.b, 0.15)
                border.color: Qt.rgba(metricRow.accentColor.r, metricRow.accentColor.g, metricRow.accentColor.b, 0.32)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: metricRow.icon
                    color: metricRow.accentColor
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize + 1
                }
            }

            Text {
                text: metricRow.label
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: metricRow.value
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignVCenter
            }

            Sparkline {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                Layout.alignment: Qt.AlignVCenter
                values: metricRow.history
                lineColor: metricRow.accentColor
                areaColor: Qt.rgba(metricRow.accentColor.r, metricRow.accentColor.g, metricRow.accentColor.b, 0.12)
            }
        }

        MouseArea {
            id: metricMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
    }

    component ProcessRow: Rectangle {
        id: processRow

        property var processData

        height: 24
        radius: 8
        color: processMouse.containsMouse ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.045) : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 12

            Text {
                Layout.fillWidth: true
                text: processRow.processData.name
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.preferredWidth: 54
                text: processRow.processData.cpu
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.preferredWidth: 54
                text: processRow.processData.mem
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.preferredWidth: 24
                text: "\uf00d"
                color: killMouse.containsMouse ? Theme.warning : Theme.muted
                opacity: killMouse.containsMouse ? 1.0 : 0.8
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                horizontalAlignment: Text.AlignHCenter
                Layout.alignment: Qt.AlignVCenter

                MouseArea {
                    id: killMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: SystemMonitorState.killProcess(processRow.processData.pid)
                }
            }
        }

        MouseArea {
            id: processMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: SystemMonitorPopupState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.activeWorkspace !== null && Services.NiriData.activeWorkspace.output === root.screen.name
            onMonitorIsFocusedChanged: if (!monitorIsFocused) SystemMonitorPopupState.close()
            

            color: "transparent"

            WlrLayershell.namespace: "quickshell:systemmonitorpopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors { top: true; bottom: true; left: true; right: true }

            Connections {
                target: SystemMonitorPopupState
                function onVisibleChanged() {
                    if (SystemMonitorPopupState.visible) {
                        SystemMonitorState.refresh();
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: SystemMonitorPopupState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: SystemMonitorPopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        SystemMonitorPopupState.close();
                        event.accepted = true;
                    }
                }

                Item {
                    id: popupClip
                    anchors.top: BarState.isTop ? parent.top : undefined
                    anchors.bottom: BarState.isTop ? undefined : parent.bottom
                    anchors.left: parent.left
                    width: Math.min(790, parent.width)
                    height: contentRow.implicitHeight + 28
                    clip: true

                    GlassPanel {
                        anchors.fill: parent
                        anchors.topMargin: 0
                        anchors.bottomMargin: BarState.isTop ? 0 : -radius
                        height: parent.height + radius
                        radius: BarState.isTop ? 20 : 0
                        fillColor: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, Theme.popupOpacity)
                    }

                    MouseArea { anchors.fill: parent }

                    RowLayout {
                        id: contentRow
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 16
                        spacing: 18

                        Column {
                            Layout.preferredWidth: 350
                            spacing: 10

                            MetricRow {
                                width: parent.width
                                icon: "\uf013"
                                label: "CPU"
                                value: CpuState.usage + "%"
                                history: CpuState.history
                                accentColor: Theme.accent
                            }

                            MetricRow {
                                width: parent.width
                                icon: "\uf2db"
                                label: "GPU"
                                value: GpuState.tempC + "°C"
                                history: GpuState.history
                                accentColor: Theme.process
                            }

                            MetricRow {
                                width: parent.width
                                icon: "\uefc5"
                                label: "RAM"
                                value: RamState.percentage + "%"
                                history: RamState.history
                                accentColor: Theme.misc
                            }
                        }

                        Rectangle {
                            Layout.preferredWidth: 1
                            Layout.fillHeight: true
                            color: Theme.separator
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 220
                            spacing: 8

                            RowLayout {
                                width: parent.width
                                height: 22
                                spacing: 12

                                Text { Layout.fillWidth: true; text: "Process"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Bold }
                                Text { Layout.preferredWidth: 54; text: "CPU%"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Bold; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: 54; text: "MEM%"; color: Theme.accent; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Bold; horizontalAlignment: Text.AlignRight }
                                Text { Layout.preferredWidth: 24; text: "" }
                            }

                            Flickable {
                                id: processFlick

                                width: parent.width
                                height: 190
                                contentWidth: width
                                contentHeight: processList.implicitHeight
                                clip: true
                                boundsBehavior: Flickable.StopAtBounds

                                Column {
                                    id: processList

                                    width: processFlick.width
                                    spacing: 3

                                    Repeater {
                                        model: SystemMonitorState.processes
                                        delegate: ProcessRow {
                                            required property var modelData
                                            width: parent.width
                                            processData: modelData
                                        }
                                    }
                                }

                                Rectangle {
                                    visible: processFlick.contentHeight > processFlick.height
                                    anchors.right: parent.right
                                    width: 3
                                    height: Math.max(24, processFlick.height * processFlick.height / processFlick.contentHeight)
                                    y: processFlick.contentY * (processFlick.height - height) / Math.max(1, processFlick.contentHeight - processFlick.height)
                                    radius: 2
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.45)
                                }
                            }

                            Text {
                                visible: SystemMonitorState.processes.length === 0
                                text: "No process data"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                            }
                        }
                    }
                }
            }
        }
    }
}
