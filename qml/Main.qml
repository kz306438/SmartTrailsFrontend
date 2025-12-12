import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtQuick.Controls.Material
import screens 1.0
import theme 1.0

Window {
    id: window
    //width: 375 // Ширина iPhone (для теста на десктопе)
    //height: 812
    visible: true
    title: "Smart Trails"
    color: Style.background

    Material.theme: Material.Light
    Material.primary: Style.primary
    Material.accent: Style.primary

    StackView {
        id: stackView
        anchors.fill: parent

        // Начальный экран - пустой, решение примем в onCompleted
        initialItem: Item {}
    }


    Component.onCompleted: {
            // Проверяем автологин
            if (AuthManager.checkAutoLogin()) {
                // Если токен есть, смотрим на сохраненную роль
                if (AuthManager.userRole === "admin") {
                     stackView.replace("qrc:/qt/qml/screens/HomeScreen.qml")
                } else {
                     stackView.replace("qrc:/qt/qml/screens/HomeScreen.qml")
                }
            } else {
                // Если токена нет - показываем логин
                stackView.replace("qrc:/qt/qml/screens/LoginScreen.qml")
            }
        }

    // Глобальная функция для смены экранов (можно вызывать из любого экрана)
    function pushScreen(url, props = {}) {
        stackView.push(url, props)
    }

    function replaceScreen(url, props = {}) {
        stackView.replace(url, props)
    }

    function popScreen() {
        stackView.pop()
    }
}
