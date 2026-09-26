import QtQuick
import Quickshell
import Quickshell.Wayland
import "services" as Services

// Closes popups when clicking another output (niri has no HyprlandFocusGrab).
Scope {
    id: root

    readonly property var popupStates: [TuiLauncherState, TuiAppLauncherState, TuiVolumePopupState, TuiNetworkPopupState, TuiSystemMonitorPopupState, TuiCalendarPopupState, TuiThemeLauncherState, TuiWallpaperLauncherState, TuiGameLauncherState, TuiMusicLauncherState, TuiPowerLauncherState, TuiVpnLauncherState]
    readonly property bool anyOpen: popupStates.some(s => s.visible)

    function closeAll() {
        popupStates.forEach(s => s.close());
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            required property var modelData
            screen: modelData
            visible: root.anyOpen && Services.NiriData.focusedOutput !== modelData.name

            color: "transparent"
            exclusionMode: ExclusionMode.Ignore

            WlrLayershell.namespace: "quickshell:click-outside"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            anchors { top: true; bottom: true; left: true; right: true }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.AllButtons
                onPressed: root.closeAll()
            }
        }
    }
}
