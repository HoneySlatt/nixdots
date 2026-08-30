//@ pragma UseQApplication
//@ pragma IconTheme Papirus-Dark
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

ShellRoot {
    Loader {
        active: TuiLauncherState.visible
        source: "TuiLauncher.qml"
    }

    Loader {
        active: TuiVolumePopupState.visible
        source: "TuiVolumePopup.qml"
    }

    Loader {
        active: TuiNetworkPopupState.visible
        source: "TuiNetworkPopup.qml"
    }

    Loader {
        active: TuiSystemMonitorPopupState.visible
        source: "TuiSystemMonitorPopup.qml"
    }

    Loader {
        active: TuiCalendarPopupState.visible
        source: "TuiCalendarPopup.qml"
    }

    Loader {
        active: TuiAppLauncherState.visible
        source: "TuiAppLauncher.qml"
    }

    Loader {
        active: TuiThemeLauncherState.visible
        source: "TuiThemeLauncher.qml"
    }

    Loader {
        active: TuiWallpaperLauncherState.visible
        source: "TuiWallpaperLauncher.qml"
    }

    Loader {
        active: TuiGameLauncherState.visible
        source: "TuiGameLauncher.qml"
    }

    Loader {
        active: TuiMusicLauncherState.visible
        source: "TuiMusicLauncher.qml"
    }

    Loader {
        active: TuiOverviewState.visible
        source: "TuiOverview.qml"
    }

    Loader {
        active: TuiPowerLauncherState.visible
        source: "TuiPowerLauncher.qml"
    }

    Loader {
        active: TuiVpnLauncherState.visible
        source: "TuiVpnLauncher.qml"
    }

    Variants {
        id: shellVariants
        model: Quickshell.screens

        TuiBar {
            required property var modelData
            screen: modelData
        }
    }

    IpcHandler {
        target: "tuiToggleLauncher"
        function call() { TuiLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiTogglePower"
        function call() { TuiPowerLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiTogglePowerLauncher"
        function call() { TuiPowerLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiToggleSystemMonitor"
        function call() { TuiSystemMonitorPopupState.toggle(); }
    }

    IpcHandler {
        target: "tuiToggleAppLauncher"
        function call() { TuiAppLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiToggleThemeLauncher"
        function call() { TuiThemeLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiToggleWallpaperLauncher"
        function call() { TuiWallpaperLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiToggleGameLauncher"
        function call() { TuiGameLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiToggleMusicLauncher"
        function call() { TuiMusicLauncherState.toggle(); }
    }

    IpcHandler {
        target: "tuiToggleVpnLauncher"
        function call() { TuiVpnLauncherState.toggle(); }
    }

    IpcHandler {
        target: "overview"
        function toggle() { TuiOverviewState.toggle(); }
        function close() { TuiOverviewState.close(); }
        function open() { TuiOverviewState.open(); }
    }

    IpcHandler {
        target: "tuiTogglePosition"
        function call() { TuiState.togglePosition(); }
    }

    IpcHandler {
        target: "tuiToggleVisibility"
        function call() {
            for (let i = 0; i < shellVariants.instances.length; i++) {
                let bar = shellVariants.instances[i];
                if (Hyprland.monitorFor(bar.screen)?.id === Hyprland.focusedMonitor?.id)
                    bar.manuallyVisible = !bar.manuallyVisible;
            }
        }
    }

}
