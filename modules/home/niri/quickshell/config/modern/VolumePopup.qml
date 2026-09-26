import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    component GlassPanel: Rectangle {
        property color fillColor: Theme.card

        radius: 18
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
            anchors.leftMargin: 18
            anchors.rightMargin: 18
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

    component GlassSlider: Slider {
        id: slider
        property bool muted: false
        property int targetValue: 0
        signal valueSelected(int percent)

        from: 0
        to: 100
        live: true
        height: 18

        onTargetValueChanged: {
            if (!slider.pressed) slider.value = targetValue;
        }

        onMoved: slider.valueSelected(Math.round(slider.value))

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4
            width: slider.availableWidth
            height: implicitHeight
            radius: 3
            color: Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.10)

            Rectangle {
                width: parent.width * (slider.value / slider.to)
                height: parent.height
                radius: parent.radius
                color: slider.muted ? Theme.muted : Theme.accent
            }
        }

        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: 11
            height: 11
            radius: 6
            color: Theme.text
        }
    }

    component SectionButton: Rectangle {
        id: sectionButton

        property string icon: ""
        property string title: ""
        property bool expanded: false
        signal clicked()

        height: 32
        radius: 9
        color: sectionMouse.containsMouse || expanded
            ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.055)
            : "transparent"

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 8

            Text {
                text: sectionButton.icon
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 2
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                text: sectionButton.title
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.Bold
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: sectionButton.expanded ? "\uf077" : "\uf054"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                Layout.alignment: Qt.AlignVCenter
            }
        }

        MouseArea {
            id: sectionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: sectionButton.clicked()
        }
    }

    component ActionButton: Rectangle {
        id: actionButton

        property string icon: ""
        property string title: ""
        property bool active: false
        signal clicked()

        radius: 12
        color: actionMouse.containsMouse || active
            ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)
            : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.35)
        border.color: active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.36)
            : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.36)
        border.width: 1

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: actionButton.icon
                color: active ? Theme.accent : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 5
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: actionButton.title
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                font.weight: Font.Bold
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        MouseArea {
            id: actionMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: actionButton.clicked()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: VolumePopupState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.activeWorkspace !== null && Services.NiriData.activeWorkspace.output === root.screen.name
            onMonitorIsFocusedChanged: if (!monitorIsFocused) VolumePopupState.close()
            
            property bool showDevices: false
            property bool showApps: false

            color: "transparent"

            WlrLayershell.namespace: "quickshell:volumepopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            Connections {
                target: VolumePopupState
                function onVisibleChanged() {
                    if (VolumePopupState.visible) {
                        VolumeState.popupVisible = true;
                        VolumeState.refreshSinks();
                        VolumeState.refreshAppStreams();
                    } else {
                        VolumeState.popupVisible = false;
                        root.showDevices = false;
                        root.showApps = false;
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: VolumePopupState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: VolumePopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        VolumePopupState.close();
                        event.accepted = true;
                    }
                }

                Item {
                    id: popupClip
                    anchors.top: BarState.isTop ? parent.top : undefined
                    anchors.bottom: BarState.isTop ? undefined : parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 86
                    width: 280
                    height: contentCol.implicitHeight + 20
                    clip: true

                    GlassPanel {
                        anchors.fill: parent
                        anchors.topMargin: 0
                        anchors.bottomMargin: BarState.isTop ? 0 : -radius
                        height: parent.height + radius
                        radius: BarState.isTop ? 18 : 0
                        fillColor: Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, Theme.popupOpacity)
                    }

                    MouseArea { anchors.fill: parent }

                    Column {
                        id: contentCol
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 10
                        spacing: 5

                        RowLayout {
                            width: parent.width
                            height: 24
                            spacing: 8

                            Text {
                                text: VolumeState.muted ? "\uf026" : VolumeState.volume <= 30 ? "\uf027" : "\uf028"
                                color: VolumeState.muted ? Theme.muted : Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 5
                                Layout.alignment: Qt.AlignVCenter

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: VolumeState.toggleMute()
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Audio"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 1
                                font.weight: Font.Bold
                                Layout.alignment: Qt.AlignVCenter
                            }

                            Text {
                                text: VolumeState.volume + "%"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Theme.fontWeight
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }

                        GlassSlider {
                            width: parent.width
                            targetValue: VolumeState.volume
                            muted: VolumeState.muted
                            onValueSelected: percent => VolumeState.setVolume(percent)
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.separator }

                        SectionButton {
                            width: parent.width
                            icon: "\uf025"
                            title: "Output Device"
                            expanded: root.showDevices
                            onClicked: {
                                root.showDevices = !root.showDevices;
                                if (root.showDevices) VolumeState.refreshSinks();
                            }
                        }

                        Column {
                            visible: root.showDevices
                            width: parent.width
                            spacing: 4

                            Repeater {
                                model: VolumeState.sinks
                                delegate: Rectangle {
                                    required property var modelData
                                    width: parent.width
                                    height: 30
                                    radius: 8
                                    color: modelData.active ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.13)
                                        : sinkMouse.containsMouse ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.045) : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 7

                                        Text { text: modelData.active ? "\uf192" : "\uf10c"; color: modelData.active ? Theme.accent : Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; Layout.alignment: Qt.AlignVCenter }
                                        Text { text: "\uf025"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 1; Layout.alignment: Qt.AlignVCenter }
                                        Text { Layout.fillWidth: true; text: modelData.label; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; font.weight: Theme.fontWeight; elide: Text.ElideRight; Layout.alignment: Qt.AlignVCenter }
                                        Text { visible: modelData.active; text: "\uf00c"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; Layout.alignment: Qt.AlignVCenter }
                                    }

                                    MouseArea {
                                        id: sinkMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: VolumeState.setDefaultSink(modelData.sinkId)
                                    }
                                }
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.separator }

                        SectionButton {
                            width: parent.width
                            icon: "\uf1de"
                            title: "App Volumes"
                            expanded: root.showApps
                            onClicked: {
                                root.showApps = !root.showApps;
                                if (root.showApps) VolumeState.refreshAppStreams();
                            }
                        }

                        Column {
                            visible: root.showApps
                            width: parent.width
                            spacing: 5

                            Text {
                                visible: VolumeState.appStreams.length === 0
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "No app streams"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Theme.fontWeight
                            }

                            Repeater {
                                model: VolumeState.appStreams
                                delegate: RowLayout {
                                    required property var modelData
                                    width: parent.width
                                    height: 28
                                    spacing: 7

                                    Text { text: "\uf1b2"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 2; Layout.preferredWidth: 18; Layout.alignment: Qt.AlignVCenter }
                                    Text { text: modelData.label; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 1; font.weight: Theme.fontWeight; elide: Text.ElideRight; Layout.preferredWidth: 70; Layout.alignment: Qt.AlignVCenter }

                                    GlassSlider {
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                        targetValue: modelData.volume
                                        muted: modelData.muted
                                        onValueSelected: percent => VolumeState.setAppVolume(modelData.streamId, percent)
                                    }

                                    Text { text: modelData.volume + "%"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize - 2; Layout.preferredWidth: 30; horizontalAlignment: Text.AlignRight; Layout.alignment: Qt.AlignVCenter }
                                    Text {
                                        text: modelData.muted ? "\uf026" : "\uf028"
                                        color: modelData.muted ? Theme.muted : Theme.text
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize
                                        Layout.preferredWidth: 16
                                        Layout.alignment: Qt.AlignVCenter
                                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: VolumeState.toggleAppMute(modelData.streamId) }
                                    }
                                }
                            }
                        }

                    }
                }
            }
        }
    }
}
