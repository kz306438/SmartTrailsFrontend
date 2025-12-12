import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components 1.0
import theme 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.85
        spacing: 20

        Text {
            text: "Create Account"
            font.pixelSize: 28
            font.bold: true
            color: Style.textPrimary
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "Sign up to start your journey"
            font.pixelSize: Style.fontSizeBody
            color: Style.textSecondary
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
        }

        // --- Поля ввода ---

        AppTextInput {
            id: usernameField
            Layout.fillWidth: true
            placeholderText: "Username"
        }

        AppTextInput {
            id: emailField
            Layout.fillWidth: true
            placeholderText: "Email"
            inputMethodHints: Qt.ImhEmailCharactersOnly
        }

        AppTextInput {
            id: passwordField
            Layout.fillWidth: true
            placeholderText: "Password"
            echoMode: TextInput.Password
        }

        // --- Вывод ошибок ---
        Text {
            id: errorText
            visible: text !== ""
            color: Style.error
            font.pixelSize: Style.fontSizeSmall
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: parent.width
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }

        // --- Кнопка регистрации ---
        AppButton {
            text: "REGISTER"
            Layout.fillWidth: true
            enabled: !AuthManager.isLoading

            onClicked: {
                errorText.text = ""

                // Простая валидация на пустоту
                if (usernameField.text === "" || emailField.text === "" || passwordField.text === "") {
                    errorText.text = "Please fill in all fields"
                    return
                }

                // Вызов C++ метода
                AuthManager.registerUser(usernameField.text, emailField.text, passwordField.text)
            }

            // Индикатор загрузки
            BusyIndicator {
                anchors.centerIn: parent
                running: AuthManager.isLoading
                visible: running
                height: parent.height * 0.8
            }
        }

        // Ссылка на логин
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 5

            Text {
                text: "Already have an account?"
                color: Style.textSecondary
                font.pixelSize: Style.fontSizeBody
            }

            Text {
                text: "Login"
                color: Style.primary
                font.bold: true
                font.pixelSize: Style.fontSizeBody

                MouseArea {
                    anchors.fill: parent
                    onClicked: window.popScreen()
                }
            }
        }
    }

    // Обработка сигналов от C++
    Connections {
        target: AuthManager

        function onRegisterSuccess() {
            console.log("Registration successful")
            // Возвращаемся на экран логина, можно передать сообщение об успехе
            window.popScreen()
            // Опционально: можно автоматически подставить email в поле логина через свойства
        }

        function onRegisterFailed(message) {
            console.log("Registration failed: " + message)
            errorText.text = message
        }
    }
}
