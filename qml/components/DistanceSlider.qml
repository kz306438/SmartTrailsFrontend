import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0

ColumnLayout {
    property alias value: control.value
    spacing: 10

    // Заголовок и значение
    RowLayout {
        Layout.fillWidth: true
        Text {
            text: "Radius"
            font.pixelSize: Style.fontSizeBody
            font.bold: true
            color: Style.textPrimary
            Layout.fillWidth: true
        }
        Text {
            text: control.value.toFixed(1) + " km"
            font.pixelSize: Style.fontSizeBody
            color: Style.textPrimary
            font.bold: true
        }
    }

    Slider {
        id: control
        Layout.fillWidth: true
        from: 1.0
        to: 20.0
        value: 5.0
        stepSize: 0.5

        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 4
            width: control.availableWidth
            height: implicitHeight
            radius: 2
            color: "#E0E0E0"

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                color: Style.primary
                radius: 2
            }
        }

        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 24
            implicitHeight: 24
            radius: 12
            color: "#FFFFFF"
            border.color: "#E0E0E0"

            Rectangle {
                z: -1
                anchors.fill: parent
                anchors.margins: -2
                radius: 14
                color: "#20000000"
            }
        }
    }
}
