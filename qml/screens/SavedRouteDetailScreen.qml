import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    property double routeDistance: 0.0
    property string routeName: "Saved Route"
    property int routeId: 0

    // --- Диалог переименования ---
    Dialog {
        id: renameDialog
        title: "Rename Route"
        anchors.centerIn: Overlay.overlay
        width: root.width * 0.8
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: "white"
            radius: Style.radius
        }

        ColumnLayout {
            spacing: 10
            width: parent.width

            AppTextInput {
                id: nameInput
                placeholderText: "Enter new name"
                Layout.fillWidth: true
                text: root.routeName
                focus: true
                color: Style.textPrimary
            }
        }

        onOpened: nameInput.forceActiveFocus()

        onAccepted: {
            if (nameInput.text.trim() !== "") {
                RouteManager.renameRoute(root.routeId, nameInput.text)
                root.routeName = nameInput.text
            }
        }
    }

    // Карта
    AppMap {
        id: map
        anchors.fill: parent
        routePath: RouteManager.currentPath
        poiModel: RouteManager.currentPois

        onRoutePathChanged: fitRoute()
    }

    // Верхняя панель
    Rectangle {
        id: topBar
        width: parent.width
        height: 80
        color: "white"
        layer.enabled: true

        RowLayout {
            anchors.fill: parent
            anchors.topMargin: 20
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            // [ИЗМЕНЕНО] Кнопка Назад
            Button { // Используем Button вместо RoundButton для предсказуемых размеров
                display: AbstractButton.IconOnly
                flat: true // Убираем тень и фон

                // 1. Увеличиваем область нажатия до комфортных 48x48
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48

                // 2. Сбрасываем отступы, чтобы иконка не сжималась
                padding: 0
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0

                // 3. Задаем большой размер иконки
                icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/back.svg"
                icon.width: 32  // Было 24
                icon.height: 32 // Было 24
                icon.color: Style.primary

                background: Item {} // Прозрачный фон
                onClicked: window.popScreen()
            }

            // Заголовок маршрута
            Text {
                text: root.routeName
                font.pixelSize: 18
                font.bold: true
                color: Style.textPrimary
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            // [ИЗМЕНЕНО] Кнопка редактирования
            Button {
                display: AbstractButton.IconOnly
                flat: true

                // 1. Размер кнопки
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48

                // 2. Сброс отступов
                padding: 0

                background: Item {}

                // 3. Размер иконки
                icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/pencil.svg"
                icon.width: 28  // Было 20
                icon.height: 28 // Было 20
                icon.color: Style.primary

                onClicked: renameDialog.open()
            }
        }
    }

    // Нижняя панель с информацией
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
        width: parent.width * 0.9
        height: 60
        radius: 30
        color: "white"
        border.color: "#E0E0E0"
        border.width: 1

        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            Text {
                text: root.routeDistance.toFixed(2) + " km"
                font.bold: true
                color: Style.primary
                font.pixelSize: 16
            }
            Rectangle { width: 1; height: 20; color: "#E0E0E0" }
            Text {
                text: Math.round((root.routeDistance/5)*60) + " min"
                font.bold: true
                color: Style.textSecondary
                font.pixelSize: 16
            }
        }
    }
}
