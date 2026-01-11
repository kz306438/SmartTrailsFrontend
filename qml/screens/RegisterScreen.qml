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

        // --- Красивый вывод ошибок ---
                Rectangle {
                    Layout.fillWidth: true
                    // Высота подстраивается под текст + отступы. Если текста нет -> высота 0
                    Layout.preferredHeight: errorText.text !== "" ? errorText.implicitHeight + 24 : 0
                    visible: errorText.text !== ""

                    color: "#FFEBEE" // Светло-красный фон
                    radius: 8
                    border.color: Style.error
                    border.width: 1

                    // Анимация появления
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200 } }

                    Text {
                        id: errorText
                        anchors.centerIn: parent
                        width: parent.width - 32 // Отступы по бокам

                        text: "" // Текст устанавливается через JS при ошибке

                        color: "#D32F2F" // Темно-красный цвет текста (читабельнее, чем ярко-красный)
                        font.pixelSize: Style.fontSizeSmall
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                AppButton {
                            text: "REGISTER"
                            Layout.fillWidth: true
                            enabled: !AuthManager.isLoading

                            onClicked: {
                                errorText.text = ""

                                // Получаем значения и убираем лишние пробелы по краям
                                var user = usernameField.text.trim()
                                var email = emailField.text.trim()
                                var pass = passwordField.text // Пароль не тримим, пробелы могут быть частью пароля

                                // 1. Простая валидация на пустоту
                                if (user === "" || email === "" || pass === "") {
                                    errorText.text = "Please fill in all fields"
                                    return
                                }

                                // 2. Валидация Email через Regex
                                // Разрешает буквы, цифры, точки, дефисы до @, затем домен и зону (минимум 2 буквы)
                                var emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/
                                if (!emailRegex.test(email)) {
                                    errorText.text = "Invalid email address format"
                                    return
                                }

                                // 3. Валидация пароля
                                // А) Длина минимум 8 символов
                                if (pass.length < 8) {
                                    errorText.text = "Password must be at least 8 characters long"
                                    return
                                }

                                // Б) Наличие букв и цифр
                                var hasLetter = /[a-zA-Z]/.test(pass)
                                var hasDigit = /[0-9]/.test(pass)

                                if (!hasLetter || !hasDigit) {
                                    errorText.text = "Password must contain both letters and numbers"
                                    return
                                }

                                // Если все проверки пройдены — вызываем C++ метод
                                AuthManager.registerUser(user, email, pass)
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
