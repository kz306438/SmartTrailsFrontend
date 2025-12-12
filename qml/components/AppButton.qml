import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0

Button {
    id: control
    text: "Button"

    // Свойства для кастомизации
    property color baseColor: Style.primary
    property color textColor: "#FFFFFF"

    contentItem: Text {
        text: control.text
        font.pixelSize: Style.fontSizeBody
        font.bold: true
        opacity: enabled ? 1.0 : 0.3
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 48
        opacity: enabled ? 1 : 0.3
        color: control.down ? Qt.darker(control.baseColor, 1.1) : control.baseColor
        radius: Style.radius
    }
}
