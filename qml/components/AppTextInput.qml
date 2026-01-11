import QtQuick
import QtQuick.Controls
import theme 1.0

TextField {
    id: control
    placeholderText: "Type here..."
    font.pixelSize: Style.fontSizeBody
    color: Style.textPrimary

    leftPadding: 16
    rightPadding: 16
    topPadding: 14
    bottomPadding: 14

    // Используем TextMetrics, чтобы узнать ширину заглушки (placeholder)
    // Это нужно, чтобы "заплатка" была ровно по ширине текста
    TextMetrics {
        id: placeholderMetrics
        font: control.font
        text: control.placeholderText
    }

    background: Rectangle {
        id: bgRect
        implicitWidth: 200
        implicitHeight: 48
        color: Style.cardBackground
        radius: Style.radius

        border.color: control.activeFocus ? Style.primary : "#E0E0E0"
        border.width: control.activeFocus ? 2 : 1

        Rectangle {
            visible: control.activeFocus || control.length > 0

            color: Style.cardBackground

            height: parent.border.width + 4

            width: placeholderMetrics.width * 0.75 + 10 // 0.75 т.к. Material уменьшает шрифт при анимации

            anchors.top: parent.top
            anchors.topMargin: -height / 2

            x: control.leftPadding - 5

            z: 1
        }
    }
}
