import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import components 1.0

Rectangle {
    id: root
    width: 400
    height: 350
    color: "#f6f6f6"
    radius: 16
    border.color: "#e0e0e0"
    border.width: 1

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 16
        width: parent.width * 0.75

        // Заголовок
        Text {
            text: "Вход в аккаунт"
            font.pixelSize: 22
            font.bold: true
            color: "#222"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        // Поле для почты
        Rectangle {
            id: emailField
            Layout.fillWidth: true
            height: 40
            radius: 10
            border.color: "#2e7d32"
            border.width: 2
            color: "white"

            TextInput {
                id: emailInput
                anchors.fill: parent
                anchors.margins: 8
                font.pixelSize: 14
                color: "#222"
                //placeholderText: "Почта"
                clip: true
            }
        }

        // Поле для пароля
        Rectangle {
            id: passwordField
            Layout.fillWidth: true
            height: 40
            radius: 10
            border.color: "#2e7d32"
            border.width: 2
            color: "white"

            TextInput {
                id: passwordInput
                anchors.fill: parent
                anchors.margins: 8
                font.pixelSize: 14
                color: "#222"
                //placeholderText: "Пароль"
                echoMode: TextInput.Password
                clip: true
            }
        }

        // Кнопки
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 16

            AppRoundButton {
                id: loginButton
                text: "Войти"
                width: 130
                height: 42
                onClicked: console.log("Вход:", emailInput.text, passwordInput.text)
            }

            AppRoundButton {
                id: registerButton
                text: "Регистрация"
                width: 130
                height: 42
                borderColor: "#1b5e20"
                pressedColor: "#1b5e20"
                onClicked: console.log("Регистрация:", emailInput.text, passwordInput.text)
            }
        }
    }

    // Небольшие анимации при фокусе полей
    states: [
        State {
            name: "emailFocus"
            when: emailInput.activeFocus
            PropertyChanges { target: emailField; border.color: "#43a047" }
        },
        State {
            name: "passwordFocus"
            when: passwordInput.activeFocus
            PropertyChanges { target: passwordField; border.color: "#43a047" }
        }
    ]

    transitions: Transition {
        ColorAnimation { properties: "border.color"; duration: 150 }
    }
}
