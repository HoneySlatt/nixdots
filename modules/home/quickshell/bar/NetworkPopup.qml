import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Item {
    // Wifi signal icons (weakest to strongest)
    readonly property var wifiIcons: ["\u{f092b}", "\u{f091f}", "\u{f0922}", "\u{f0925}", "\u{f0928}"]

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: NetworkPopupState.visible && monitorIsFocused

            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            property bool monitorIsFocused: (Hyprland.focusedMonitor?.id == monitor?.id)

            // Selected network for password entry
            property string selectedSsid: ""

            color: "transparent"

            WlrLayershell.namespace: "quickshell:networkpopup"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            // ── Focus grab ──

            HyprlandFocusGrab {
                id: grab
                windows: [root]
                active: false
                onCleared: () => {
                    if (!active)
                        NetworkPopupState.close();
                }
            }

            Connections {
                target: NetworkPopupState
                function onVisibleChanged() {
                    if (NetworkPopupState.visible) {
                        grabTimer.start();
                        NetworkState.scan();
                        NetworkState.refreshSavedConnections();
                        root.selectedSsid = "";
                    } else {
                        grabTimer.stop();
                        grab.active = false;
                    }
                }
            }

            Timer {
                id: grabTimer
                interval: 50
                repeat: false
                onTriggered: grab.active = NetworkPopupState.visible
            }

            // ── Click outside to close ──

            MouseArea {
                anchors.fill: parent
                onClicked: NetworkPopupState.close()
            }

            // ── Keyboard handling ──

            FocusScope {
                id: popupScope
                anchors.fill: parent
                focus: NetworkPopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        if (root.selectedSsid) {
                            root.selectedSsid = "";
                        } else {
                            NetworkPopupState.close();
                        }
                        event.accepted = true;
                    }
                }

                // ── Popup panel ──

                // Clip container — hides the radius on the bar-side edge
                Item {
                    id: popupClip
                    anchors.top: BarState.isTop ? parent.top : undefined
                    anchors.bottom: BarState.isTop ? undefined : parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 55
                    width: 250
                    height: contentCol.height + 24
                    clip: true

                    Rectangle {
                        id: popup
                        anchors.fill: parent
                        anchors.topMargin: 0
                        anchors.bottomMargin: BarState.isTop ? 0 : -radius
                        height: parent.height + radius
                        color: Theme.background
                        radius: 10
                        border.color: Theme.separator
                        border.width: 1
                    }

                    // Block clicks inside from closing
                    MouseArea { anchors.fill: parent }

                    Column {
                        id: contentCol
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 12
                        spacing: 4

                        // ── Header ──

                        RowLayout {
                            width: parent.width
                            spacing: 0

                            Text {
                                text: {
                                    if (NetworkState.connecting) return "\u{f0253}  Connecting...";
                                    if (NetworkState.netType === "wifi") return "\u{f0928}  " + NetworkState.connectionName;
                                    if (NetworkState.netType === "ethernet") return "\u{f0200}  Ethernet";
                                    return "\u{f1616}  Disconnected";
                                }
                                color: NetworkState.netType === "offline" ? Theme.caution : Theme.misc
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Font.Bold
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // Rescan button
                            Text {
                                text: "\u{f0450}"
                                color: rescanMa.containsMouse ? Theme.misc : Theme.text
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.weight: Theme.fontWeight
                                opacity: NetworkState.scanning ? 0.4 : 1.0

                                MouseArea {
                                    id: rescanMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (!NetworkState.scanning) NetworkState.scan();
                                    }
                                }
                            }
                        }

                        // Disconnect button (visible when connected to wifi)
                        Rectangle {
                            visible: NetworkState.netType === "wifi"
                            width: parent.width
                            height: visible ? 26 : 0
                            radius: 6
                            color: disconnectMa.containsMouse ? Theme.separator : "transparent"

                            Text {
                                anchors.centerIn: parent
                                text: "Disconnect"
                                color: Theme.warning
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Theme.fontWeight
                            }

                            MouseArea {
                                id: disconnectMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: NetworkState.disconnectNetwork()
                            }
                        }

                        // Separator
                        Rectangle {
                            width: parent.width
                            height: 1
                            color: Theme.separator
                        }

                        // Scanning placeholder
                        Text {
                            visible: NetworkState.scanning && NetworkState.availableNetworks.length === 0
                            text: "Scanning..."
                            color: Theme.caution
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                            font.weight: Theme.fontWeight
                        }

                        // ── Network list ──

                        Repeater {
                            model: NetworkState.availableNetworks

                            delegate: Column {
                                id: networkDelegate

                                required property var modelData
                                required property int index
                                width: contentCol.width
                                spacing: 2

                                readonly property bool isSelected: root.selectedSsid === modelData.ssid
                                readonly property bool isSecured: modelData.security !== "" && modelData.security !== "--"
                                readonly property bool isKnown: NetworkState.savedConnections.indexOf(modelData.ssid) !== -1
                                property bool savePassword: true

                                // Network row
                                Rectangle {
                                    width: parent.width
                                    height: 28
                                    radius: 6
                                    color: itemMa.containsMouse ? Theme.separator : "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8
                                        spacing: 6

                                        // Signal icon
                                        Text {
                                            text: {
                                                let idx = Math.min(Math.floor(networkDelegate.modelData.signal / 20), 4);
                                                return wifiIcons[idx];
                                            }
                                            color: networkDelegate.modelData.connected ? Theme.misc : Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Theme.fontWeight
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // SSID
                                        Text {
                                            text: networkDelegate.modelData.ssid
                                            color: networkDelegate.modelData.connected ? Theme.misc : Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 1
                                            font.weight: Theme.fontWeight
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // Lock icon
                                        Text {
                                            visible: networkDelegate.isSecured
                                            text: "\u{f0341}"
                                            color: Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 2
                                            font.weight: Theme.fontWeight
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        // Signal percentage
                                        Text {
                                            text: networkDelegate.modelData.signal + "%"
                                            color: Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 2
                                            font.weight: Theme.fontWeight
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }

                                    MouseArea {
                                        id: itemMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (networkDelegate.modelData.connected) {
                                                NetworkState.disconnectNetwork();
                                            } else if (networkDelegate.isSecured && !networkDelegate.isKnown) {
                                                root.selectedSsid = networkDelegate.modelData.ssid;
                                            } else {
                                                NetworkState.connectToNetwork(networkDelegate.modelData.ssid, "", true);
                                            }
                                        }
                                    }
                                }

                                // Save password row
                                Rectangle {
                                    visible: networkDelegate.isSelected
                                    width: parent.width
                                    height: visible ? 22 : 0
                                    color: "transparent"

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 8

                                        Text {
                                            text: "Save password"
                                            color: Theme.caution
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 2
                                            font.weight: Theme.fontWeight
                                        }

                                        Item { Layout.fillWidth: true }

                                        Rectangle {
                                            width: 14
                                            height: 14
                                            radius: 3
                                            color: networkDelegate.savePassword ? Theme.misc : "transparent"
                                            border.color: Theme.caution
                                            border.width: 1

                                            Text {
                                                visible: networkDelegate.savePassword
                                                anchors.centerIn: parent
                                                text: "\u{f012c}"
                                                color: Theme.background
                                                font.family: Theme.fontFamily
                                                font.pixelSize: 9
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: networkDelegate.savePassword = !networkDelegate.savePassword
                                            }
                                        }
                                    }
                                }

                                // Password input row (visible when network is selected)
                                Rectangle {
                                    visible: networkDelegate.isSelected
                                    width: parent.width
                                    height: visible ? 30 : 0
                                    radius: 6
                                    color: Theme.separator

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 8
                                        anchors.rightMargin: 4
                                        spacing: 4

                                        TextInput {
                                            id: passwordInput
                                            Layout.fillWidth: true
                                            Layout.alignment: Qt.AlignVCenter
                                            color: Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize - 1
                                            echoMode: TextInput.Password
                                            clip: true

                                            onVisibleChanged: {
                                                if (visible && networkDelegate.isSelected) {
                                                    text = "";
                                                    networkDelegate.savePassword = true;
                                                    forceActiveFocus();
                                                }
                                            }

                                            Keys.onReturnPressed: {
                                                NetworkState.connectToNetwork(networkDelegate.modelData.ssid, passwordInput.text, networkDelegate.savePassword);
                                                root.selectedSsid = "";
                                            }

                                            // Placeholder
                                            Text {
                                                anchors.verticalCenter: parent.verticalCenter
                                                visible: !passwordInput.text && !passwordInput.activeFocus
                                                text: "Password..."
                                                color: Theme.caution
                                                font.family: Theme.fontFamily
                                                font.pixelSize: Theme.fontSize - 1
                                            }
                                        }

                                        // Submit button
                                        Text {
                                            text: "\u{f0134}"
                                            color: connectBtnMa.containsMouse ? Theme.misc : Theme.text
                                            font.family: Theme.fontFamily
                                            font.pixelSize: Theme.fontSize
                                            font.weight: Theme.fontWeight
                                            Layout.alignment: Qt.AlignVCenter

                                            MouseArea {
                                                id: connectBtnMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    NetworkState.connectToNetwork(networkDelegate.modelData.ssid, passwordInput.text, networkDelegate.savePassword);
                                                    root.selectedSsid = "";
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
        }
    }
}
