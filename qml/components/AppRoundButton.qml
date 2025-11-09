import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
        // API
        property alias text: label.text
        property color borderColor: "green"
        property color pressedColor: "green"
        property color normalColor: "white"
        property color disabledColor: "#eeeeee"
        property bool enabled: true
        signal clicked()

        width: 160
        height: 40
        radius: 10
        color: enabled ? normalColor : disabledColor
        border.color: enabled ? borderColor : "#cccccc"
        border.width: 2
        antialiasing: true

        // Visual overlay for pressed state
        Rectangle {
            id: pressOverlay
            anchors.fill: parent
            radius: parent.radius
            color: pressed ? pressedColor : "transparent"
            z: 1
            visible: pressed || hovered
            opacity: pressed ? 1.0 : (hovered ? 0.04 : 0.0)
        }

        // Content
        Text {
            id: label
            text: "Button"
            anchors.centerIn: parent
            font.pixelSize: 14
            z: 2
            color: pressed ? "white" : (enabled ? "black" : "#9a9a9a")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            clip: true
        }

        // ripple / focus ring (subtle)
        Rectangle {
            id: focusRing
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            //border.width: hasFocus ? 2 : 0
            //border.color: (hasFocus && enabled) ? Qt.lighter(borderColor, 1.2) : "transparent"
            z: 3
        }

        // interaction state
        property bool hovered: false
        property bool pressed: false

        Keys.onPressed: {
            if (!enabled) return;
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                pressed = true
                event.accepted = true
            }
        }
        Keys.onReleased: {
            if (!enabled) return;
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
                // activate on key release
                pressed = false
                root.clicked()
                event.accepted = true
            }
        }

        MouseArea {
            id: marea
            anchors.fill: parent
            hoverEnabled: true
            enabled: root.enabled
            onEntered: { root.hovered = true }
            onExited: { root.hovered = false; root.pressed = false }
            onPressed: { root.pressed = true; }
            onReleased: {
                if (root.pressed) { // was pressed inside
                    root.clicked()
                }
                root.pressed = false
            }
            onCanceled: { root.pressed = false }
            // allow keyboard focus
            focus: true
            onPressedChanged: { /* no-op, just keep focus behavior */ }
        }

        // small transition for smoothness
        Behavior on color { NumberAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
}
