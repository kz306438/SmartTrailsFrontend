import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import components 1.0
import theme 1.0

Page {
    background: Rectangle { color: Style.background }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 20

        // // Логотип или заголовок
        // Image {
        //     source: "../../assets/logo.png" // Если есть, иначе заглушка
        //     Layout.alignment: Qt.AlignHCenter
        //     Layout.preferredHeight: 100
        //     Layout.preferredWidth: 100
        //     fillMode: Image.PreserveAspectFit
        //     // Временная заглушка, если нет картинки
        //     visible: status === Image.Ready
        // }

        Text {
            text: "Route Finder"
            font.pixelSize: 28
            font.bold: true
            color: Style.textPrimary
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Welcome Back!"
            font.pixelSize: Style.fontSizeBody
            color: Style.textSecondary
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
        }

        // Поля ввода
        AppTextInput {
            id: emailField
            Layout.fillWidth: true
            placeholderText: "Email"
        }

        AppTextInput {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Password"
            echoMode: TextInput.Password
        }

        // Сообщение об ошибке (управляется из C++)
        Text {
            id: errorText
            visible: text !== ""
            color: Style.error
            font.pixelSize: Style.fontSizeSmall
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
        }

        // Кнопка входа
        AppButton {
            text: "LOGIN"
            Layout.fillWidth: true
            enabled: !AuthManager.isLoading // Блокируем, пока грузится

            onClicked: {
                errorText.text = ""
                // Вызов C++ метода
                AuthManager.login(emailField.text, passwordField.text)
            }

            // Индикатор загрузки внутри кнопки (опционально)
            BusyIndicator {
                anchors.centerIn: parent
                running: AuthManager.isLoading
                visible: running
                height: parent.height * 0.81
            }
        }

        AppButton {
            text: "REGISTER"
            Layout.fillWidth: true
            baseColor: Style.cardBackground
            textColor: Style.primary
            onClicked: window.pushScreen(Qt.resolvedUrl("RegisterScreen.qml"))
        }
    }


    // Подключаемся к сигналам от AuthManager (C++)
    Connections {
            target: AuthManager

            function onLoginSuccess() {
                console.log("Login successful! Role:", AuthManager.userRole)

                // ЛОГИКА МАРШРУТИЗАЦИИ
                if (AuthManager.userRole === "admin") {
                    // Если админ - идем в админку (создашь этот файл позже)
                    window.replaceScreen(Qt.resolvedUrl("HomeScreen.qml"))
                } else {
                    // Если обычный юзер - идем на главный экран
                    window.replaceScreen(Qt.resolvedUrl("HomeScreen.qml"))
                }
            }

            function onLoginFailed(message) {
                console.log("Login failed: " + message)
                errorText.text = message
            }
        }
}
