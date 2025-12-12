import QtQuick
import QtQuick.Controls
import theme 1.0

TextField {
    id: control
    placeholderText: "Type here..."
    font.pixelSize: Style.fontSizeBody
    color: Style.textPrimary
    // Стиль фона
    background: Rectangle {
        enabled: false
        implicitWidth: 200
        implicitHeight: 48
        color: Style.cardBackground
        radius: Style.radius
        border.color: control.activeFocus ? Style.primary : "#E0E0E0"
        border.width: control.activeFocus ? 2 : 1
    }
}
