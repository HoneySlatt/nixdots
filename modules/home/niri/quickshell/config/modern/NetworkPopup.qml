import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    id: networkPopup

    readonly property var wifiIcons: ["\u{f092b}", "\u{f091f}", "\u{f0922}", "\u{f0925}", "\u{f0928}"]

    function signalIcon(signal) {
        return wifiIcons[Math.max(0, Math.min(4, Math.floor(signal / 20)))];
    }

    component GlassPanel: Rectangle {
        property color fillColor: Theme.card

        radius: 22
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

    component ToggleSwitch: Rectangle {
        id: toggleSwitch

        property bool checked: false
        signal clicked()

        width: 50
        height: 28
        radius: 14
        color: checked ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.72)
            : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.12)
        border.color: checked ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.55)
            : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.55)
        border.width: 1

        Rectangle {
            x: toggleSwitch.checked ? parent.width - width - 4 : 4
            anchors.verticalCenter: parent.verticalCenter
            width: 20
            height: 20
            radius: 10
            color: Theme.text
            Behavior on x { NumberAnimation { duration: 120 } }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggleSwitch.clicked()
        }
    }

    component NetworkRow: Rectangle {
        id: networkRow

        property var networkData
        property bool selected: false
        signal clicked()

        readonly property bool secured: networkData.security !== "" && networkData.security !== "--"

        width: parent ? parent.width : 0
        height: 48
        radius: 12
        color: selected || networkMouse.containsMouse
            ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.055)
            : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.28)
        border.color: networkData.connected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35) : "transparent"
        border.width: networkData.connected ? 1 : 0

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 10

            Text {
                text: networkRow.networkData.connected ? "\uf192" : "\uf10c"
                color: networkRow.networkData.connected ? Theme.accent : Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: networkPopup.signalIcon(networkRow.networkData.signal)
                color: networkRow.networkData.connected ? Theme.accent : Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 4
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                Layout.fillWidth: true
                text: networkRow.networkData.ssid
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Font.Bold
                elide: Text.ElideRight
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                visible: networkRow.networkData.connected
                text: "connected"
                color: Theme.accent
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                font.weight: Theme.fontWeight
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                visible: networkRow.secured
                text: "\uf023"
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                Layout.alignment: Qt.AlignVCenter
            }

            Text {
                text: "\uf012"
                color: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                Layout.alignment: Qt.AlignVCenter
            }
        }

        MouseArea {
            id: networkMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: networkRow.clicked()
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: NetworkPopupState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.activeWorkspace !== null && Services.NiriData.activeWorkspace.output === root.screen.name
            onMonitorIsFocusedChanged: if (!monitorIsFocused) NetworkPopupState.close()
            

            property string selectedSsid: ""
            property bool selectedIsSecured: false
            property bool savePassword: true
            property bool showPassword: false

            color: "transparent"

            WlrLayershell.namespace: "quickshell:networkpopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            anchors { top: true; bottom: true; left: true; right: true }

            function chooseNetwork(network) {
                const secured = network.security !== "" && network.security !== "--";
                const known = NetworkState.savedConnections.indexOf(network.ssid) !== -1;
                if (network.connected) return;
                if (secured && !known) {
                    selectedSsid = network.ssid;
                    selectedIsSecured = true;
                    savePassword = true;
                    showPassword = false;
                    passwordFocusTimer.start();
                } else {
                    NetworkState.connectToNetwork(network.ssid, "", true);
                }
            }

            Connections {
                target: NetworkPopupState
                function onVisibleChanged() {
                    if (NetworkPopupState.visible) {
                        root.selectedSsid = "";
                        NetworkState.scan();
                        NetworkState.refreshSavedConnections();
                    }
                }
            }

            Timer {
                id: passwordFocusTimer
                interval: 80
                repeat: false
                onTriggered: passwordInput.forceActiveFocus()
            }

            MouseArea {
                anchors.fill: parent
                onClicked: NetworkPopupState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: NetworkPopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        if (root.selectedSsid.length > 0) root.selectedSsid = "";
                        else NetworkPopupState.close();
                        event.accepted = true;
                    }
                }

                Item {
                    id: popupClip
                    anchors.top: BarState.isTop ? parent.top : undefined
                    anchors.bottom: BarState.isTop ? undefined : parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 55
                    width: 320
                    height: contentCol.implicitHeight + 28
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

                    Column {
                        id: contentCol
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 16
                        spacing: 12

                        RowLayout {
                            width: parent.width
                            height: 56
                            spacing: 12

                            Rectangle {
                                Layout.preferredWidth: 44
                                Layout.preferredHeight: 44
                                radius: 22
                                color: NetworkState.wifiEnabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.28)
                                    : Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.055)
                                border.color: NetworkState.wifiEnabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.60)
                                    : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.55)
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: "\uf1eb"
                                    color: NetworkState.wifiEnabled ? Theme.accent : Theme.muted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize + 12
                                }
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Wi-Fi"
                                color: Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize + 4
                                font.weight: Font.Bold
                                Layout.alignment: Qt.AlignVCenter
                            }

                            ToggleSwitch {
                                checked: NetworkState.wifiEnabled
                                Layout.alignment: Qt.AlignVCenter
                                onClicked: NetworkState.toggleWifi()
                            }
                        }

                        Rectangle { width: parent.width; height: 1; color: Theme.separator }

                        Loader {
                            width: parent.width
                            sourceComponent: NetworkState.connecting ? connectingView
                                : root.selectedSsid.length > 0 ? passwordView
                                : networkListView
                        }
                    }
                }
            }

            Component {
                id: networkListView

                Column {
                    width: parent.width
                    spacing: 10

                    Text {
                        text: NetworkState.wifiEnabled ? "Available networks" : "Wi-Fi is off"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.weight: Theme.fontWeight
                    }

                    Text {
                        visible: NetworkState.scanning && NetworkState.availableNetworks.length === 0 && NetworkState.wifiEnabled
                        text: "Scanning..."
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    Repeater {
                        model: NetworkState.wifiEnabled ? NetworkState.availableNetworks : []
                        delegate: NetworkRow {
                            required property var modelData
                            networkData: modelData
                            selected: root.selectedSsid === modelData.ssid
                            onClicked: root.chooseNetwork(modelData)
                        }
                    }
                }
            }

            Component {
                id: passwordView

                Column {
                    width: parent.width
                    spacing: 14

                    RowLayout {
                        width: parent.width
                        height: 36
                        spacing: 10

                        Text {
                            text: "\uf053"
                            color: backMouse.containsMouse ? Theme.text : Theme.muted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 4
                            Layout.alignment: Qt.AlignVCenter
                            MouseArea { id: backMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedSsid = "" }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: root.selectedSsid
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize + 1
                            font.weight: Font.Bold
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Text { text: "\uf023"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 1; Layout.alignment: Qt.AlignVCenter }
                    }

                    Text {
                        text: "Password"
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        font.weight: Font.Bold
                    }

                    Rectangle {
                        width: parent.width
                        height: 46
                        radius: 12
                        color: Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.34)
                        border.color: passwordInput.activeFocus ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.55) : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.48)
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 8

                            TextInput {
                                id: passwordInput
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                                color: Theme.text
                                selectionColor: Theme.accent
                                selectedTextColor: Theme.background
                                clip: true
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Theme.fontWeight
                                Keys.onReturnPressed: {
                                    NetworkState.connectToNetwork(root.selectedSsid, text, root.savePassword);
                                    root.selectedSsid = "";
                                }

                                Text {
                                    anchors.fill: parent
                                    verticalAlignment: Text.AlignVCenter
                                    visible: passwordInput.text.length === 0
                                    text: "Enter password"
                                    color: Theme.muted
                                    font.family: passwordInput.font.family
                                    font.pixelSize: passwordInput.font.pixelSize
                                    font.weight: passwordInput.font.weight
                                }
                            }

                            Text {
                                text: root.showPassword ? "\uf070" : "\uf06e"
                                color: eyeMouse.containsMouse ? Theme.text : Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                MouseArea { id: eyeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.showPassword = !root.showPassword }
                            }
                        }
                    }

                    RowLayout {
                        width: parent.width
                        height: 36
                        spacing: 10

                        ToggleSwitch {
                            checked: root.savePassword
                            Layout.alignment: Qt.AlignVCenter
                            onClicked: root.savePassword = !root.savePassword
                        }

                        Text {
                            Layout.fillWidth: true
                            text: "Save password"
                            color: Theme.text
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Theme.fontWeight
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }

                    RowLayout {
                        width: parent.width
                        height: 48
                        spacing: 12

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: cancelMouse.containsMouse ? Qt.rgba(Theme.text.r, Theme.text.g, Theme.text.b, 0.055) : Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.34)
                            border.color: Qt.rgba(Theme.separator.r, Theme.separator.g, Theme.separator.b, 0.45)
                            border.width: 1
                            Text { anchors.centerIn: parent; text: "Cancel"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Bold }
                            MouseArea { id: cancelMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.selectedSsid = "" }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: 12
                            color: connectMouse.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.78) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.62)
                            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.55)
                            border.width: 1
                            Text { anchors.centerIn: parent; text: "Connect"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize; font.weight: Font.Bold }
                            MouseArea {
                                id: connectMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    NetworkState.connectToNetwork(root.selectedSsid, passwordInput.text, root.savePassword);
                                    root.selectedSsid = "";
                                }
                            }
                        }
                    }
                }
            }

            Component {
                id: connectingView

                Column {
                    width: parent.width
                    spacing: 16

                    RowLayout {
                        width: parent.width
                        height: 36
                        spacing: 10
                        Text { text: "\uf053"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 4; Layout.alignment: Qt.AlignVCenter }
                        Text { Layout.fillWidth: true; text: NetworkState.connectionName || "Connecting"; color: Theme.text; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 1; font.weight: Font.Bold; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; Layout.alignment: Qt.AlignVCenter }
                        Text { text: "\uf023"; color: Theme.muted; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize + 1; Layout.alignment: Qt.AlignVCenter }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "\uf110"
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 20
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Connecting..."
                        color: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 1
                        font.weight: Font.Bold
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: "Please wait"
                        color: Theme.muted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }
                }
            }
        }
    }
}
