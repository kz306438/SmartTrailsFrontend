import QtQuick
import QtQuick.Layouts
import QtQuick.Controls // Используем TabButton
import theme 1.0

Rectangle {
    id: root
    height: 80
    color: Style.cardBackground

    Rectangle {
        width: parent.width
        height: 1
        color: "#E0E0E0"
        anchors.top: parent.top
    }

    signal tabSelected(int index)
    property int activeIndex: 0

    RowLayout {
        anchors.fill: parent
        anchors.bottomMargin: 20
        spacing: 0

        Repeater {
            model: [
                { text: "Route", icon: "qrc:/qt/qml/SmartTrailsFrontend/assets/map.svg" },
                { text: "Saved", icon: "qrc:/qt/qml/SmartTrailsFrontend/assets/star.svg" },
                { text: "Profile", icon: "qrc:/qt/qml/SmartTrailsFrontend/assets/profile-user.svg" }
            ]

            delegate: TabButton {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // --- Настройка контента ---
                text: modelData.text
                // Иконка и её цвет
                icon.source: modelData.icon
                icon.width: 28
                icon.height: 28
                // Если кнопка выбрана (checked) - зеленая, нет - серая
                icon.color: checked ? Style.primary : Style.textSecondary

                // Текст под иконкой
                display: AbstractButton.TextUnderIcon
                font.pixelSize: 12
                font.bold: checked

                // Цвет текста (через palette)
                palette.buttonText: checked ? Style.primary : Style.textSecondary

                // Логика выбора
                checkable: true
                checked: root.activeIndex === index
                onClicked: root.tabSelected(index)

                // Убираем стандартный серый фон кнопки, оставляем прозрачный
                background: Item {}
            }
        }
    }
}
