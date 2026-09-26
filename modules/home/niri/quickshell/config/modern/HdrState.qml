pragma Singleton

import QtQuick

// niri n'a pas de gestion HDR : l'indicateur reste éteint (voir la version Hyprland pour la détection).
QtObject {
    property bool enabled: false
}
