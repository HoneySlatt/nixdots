import QtQuick
import Quickshell
import Quickshell.Wayland
import "services" as Services

Item {
    id: popupScope

    function signalBar(s) {
        if (s >= 80) return "████";
        if (s >= 60) return "███░";
        if (s >= 40) return "██░░";
        if (s >= 20) return "█░░░";
        return "░░░░";
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: root

            required property var modelData
            screen: modelData
            visible: TuiNetworkPopupState.visible && monitorIsFocused

            readonly property bool monitorIsFocused: Services.NiriData.focusedOutput === root.screen.name

            property string selectedSsid: ""
            property bool selectedIsSecured: false
            property bool savePassword: true
            property bool showPassword: false

            color: "transparent"

            WlrLayershell.namespace: "quickshell:tui:network"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            anchors { top: true; bottom: true; left: true; right: true }

            function chooseNetwork(network) {
                let secured = network.security !== "" && network.security !== "--";
                let known = TuiNetworkState.savedConnections.indexOf(network.ssid) !== -1;
                if (network.connected) return;
                if (secured && !known) {
                    root.selectedSsid = network.ssid;
                    root.selectedIsSecured = true;
                    root.savePassword = true;
                    root.showPassword = false;
                    passwordFocusTimer.start();
                } else {
                    TuiNetworkState.connectToNetwork(network.ssid, "", true);
                }
            }

            Connections {
                target: TuiNetworkPopupState
                function onVisibleChanged() {
                    if (TuiNetworkPopupState.visible) {
                        root.selectedSsid = "";
                        TuiNetworkState.scan();
                        TuiNetworkState.refreshSavedConnections();
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
                onClicked: TuiNetworkPopupState.close()
            }

            FocusScope {
                anchors.fill: parent
                focus: TuiNetworkPopupState.visible

                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Escape) {
                        if (root.selectedSsid.length > 0) root.selectedSsid = "";
                        else TuiNetworkPopupState.close();
                        event.accepted = true;
                    }
                }

                Item {
                    id: popupClip
                    anchors.top: TuiState.isTop ? parent.top : undefined
                    anchors.bottom: TuiState.isTop ? undefined : parent.bottom
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    width: 320
                    height: popupContent.implicitHeight + 24
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: TuiTheme.bg
                        border.color: TuiTheme.accent
                        border.width: 2

                        Column {
                            id: popupContent
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 6

                            Row {
                                spacing: 0
                                width: parent.width

                                Text {
                                    text: " network"
                                    color: TuiTheme.accent
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: " "
                                    color: TuiTheme.dim
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: TuiNetworkState.wifiEnabled ? "on" : "off"
                                    color: TuiNetworkState.wifiEnabled ? TuiTheme.accent : TuiTheme.warn
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: TuiNetworkState.toggleWifi()
                                    }
                                }
                                Text {
                                    text: " "
                                    color: TuiTheme.dim
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: "["
                                    color: TuiTheme.dim
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                Text {
                                    text: TuiNetworkState.wifiEnabled ? "toggle" : "enable"
                                    color: wifiToggleMouse.containsMouse ? TuiTheme.bright : TuiTheme.fg
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter

                                    MouseArea {
                                        id: wifiToggleMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: TuiNetworkState.toggleWifi()
                                    }
                                }
                                Text {
                                    text: "]"
                                    color: TuiTheme.dim
                                    font.family: TuiTheme.fontFamily
                                    font.pixelSize: TuiTheme.fontSize
                                    font.weight: TuiTheme.fontWeight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }

                            Text {
                                text: " \u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500\u2500"
                                color: TuiTheme.dim
                                font.family: TuiTheme.fontFamily
                                font.pixelSize: TuiTheme.fontSize
                                font.weight: TuiTheme.fontWeight
                            }

                            Loader {
                                width: parent.width
                                sourceComponent: TuiNetworkState.connecting ? connectingView
                                    : root.selectedSsid.length > 0 ? passwordView
                                    : networkListView
                            }
                        }
                    }
                }
            }

            Component {
                id: networkListView

                Column {
                    width: parent ? parent.width : 0
                    spacing: 0

                    Text {
                                        text: !TuiNetworkState.wifiEnabled ? "  wifi is off"
                        : TuiNetworkState.scanning && TuiNetworkState.availableNetworks.length === 0 ? "  scanning..."
                        : "  available networks"
                                        color: TuiTheme.dim
                                        font.family: TuiTheme.fontFamily
                                        font.pixelSize: TuiTheme.fontSize
                                        font.weight: TuiTheme.fontWeight
                                    }

                    Repeater {
                        model: TuiNetworkState.wifiEnabled ? TuiNetworkState.availableNetworks : []

                        delegate: Text {
                            required property var modelData
                            text: (modelData.connected ? "  \u25CF " : "  \u25CB ")
                                + modelData.ssid
                                + " "
                                + popupScope.signalBar(modelData.signal)
                                + (modelData.connected ? " \u25C8" : "")
                                + (modelData.security !== "" && modelData.security !== "--" ? " \u2523" : "")
                            color: modelData.connected ? TuiTheme.accent : TuiTheme.fg
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            elide: Text.ElideRight
                            width: parent ? parent.width : 0

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onClicked: root.chooseNetwork(modelData)
                            }
                        }
                    }
                }
            }

            Component {
                id: passwordView

                Column {
                    width: parent ? parent.width : 0
                    spacing: 6

                    Row {
                        spacing: 0

                        Text {
                            text: " <"
                            color: backMouse.containsMouse ? TuiTheme.bright : TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: backMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedSsid = ""
                            }
                        }
                        Text {
                            text: " " + root.selectedSsid + " "
                            color: TuiTheme.fg
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            width: 220
                        }
                        Text {
                            text: "\u2523"
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Row {
                        spacing: 0

                        Text {
                            text: " password:"
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Rectangle {
                        width: parent ? parent.width : 0
                        height: 24
                        color: TuiTheme.bg
                        border.color: passwordInput.activeFocus ? TuiTheme.accent : TuiTheme.dim
                        border.width: 1

                        TextInput {
                            id: passwordInput
                            anchors.fill: parent
                            anchors.margins: 4
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                            color: TuiTheme.fg
                            selectionColor: TuiTheme.accent
                            selectedTextColor: TuiTheme.bg
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            clip: true
                            Keys.onReturnPressed: {
                                TuiNetworkState.connectToNetwork(root.selectedSsid, text, root.savePassword);
                                root.selectedSsid = "";
                            }

                            Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                visible: passwordInput.text.length === 0
                                text: "enter password..."
                                color: TuiTheme.dim
                                font.family: passwordInput.font.family
                                font.pixelSize: passwordInput.font.pixelSize
                                font.weight: passwordInput.font.weight
                            }
                        }
                    }

                    Row {
                        spacing: 0

                        Text {
                            text: " ["
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text {
                            text: root.showPassword ? "hide" : "show"
                            color: showPwMouse.containsMouse ? TuiTheme.bright : TuiTheme.fg
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: showPwMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.showPassword = !root.showPassword
                            }
                        }
                        Text {
                            text: "] "
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text {
                            text: "["
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text {
                            text: root.savePassword ? "saved" : "temp"
                            color: savePwMouse.containsMouse ? TuiTheme.bright : TuiTheme.fg
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: savePwMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.savePassword = !root.savePassword
                            }
                        }
                        Text {
                            text: "]"
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Row {
                        spacing: 0

                        Text {
                            text: " ["
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text {
                            text: "cancel"
                            color: cancelMouse.containsMouse ? TuiTheme.bright : TuiTheme.fg
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: cancelMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedSsid = ""
                            }
                        }
                        Text {
                            text: "]  ["
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                        Text {
                            text: "connect"
                            color: connectMouse.containsMouse ? TuiTheme.bg : TuiTheme.accent
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter

                            MouseArea {
                                id: connectMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    TuiNetworkState.connectToNetwork(root.selectedSsid, passwordInput.text, root.savePassword);
                                    root.selectedSsid = "";
                                }
                            }
                        }
                        Text {
                            text: "]"
                            color: TuiTheme.dim
                            font.family: TuiTheme.fontFamily
                            font.pixelSize: TuiTheme.fontSize
                            font.weight: TuiTheme.fontWeight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            Component {
                id: connectingView

                Column {
                    width: parent ? parent.width : 0
                    spacing: 6

                    Text {
                        text: "  connecting..."
                        color: TuiTheme.fg
                        font.family: TuiTheme.fontFamily
                        font.pixelSize: TuiTheme.fontSize
                        font.weight: TuiTheme.fontWeight
                    }
                    Text {
                        text: "  please wait"
                        color: TuiTheme.dim
                        font.family: TuiTheme.fontFamily
                        font.pixelSize: TuiTheme.fontSize
                        font.weight: TuiTheme.fontWeight
                    }
                }
            }
        }
    }
}
