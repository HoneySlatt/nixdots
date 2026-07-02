pragma Singleton

import QtQuick

QtObject {
    property bool visible: false
    property int activeTab: 0

    function toggle() { visible = !visible; }
    function close() { visible = false; activeTab = 0; }
}