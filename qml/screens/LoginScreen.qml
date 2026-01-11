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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: errorText.text !== "" ? errorText.implicitHeight + 24 : 0
                    visible: errorText.text !== ""

                    color: "#FFEBEE"
                    radius: 8
                    border.color: Style.error
                    border.width: 1

                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200 } }

                    Text {
                        id: errorText
                        anchors.centerIn: parent
                        width: parent.width - 32

                        text: ""

                        color: "#D32F2F"
                        font.pixelSize: Style.fontSizeSmall
                        wrapMode: Text.WordWrap
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

        AppButton {
            text: "LOGIN"
            Layout.fillWidth: true
            enabled: !AuthManager.isLoading

            onClicked: {
                errorText.text = ""
                AuthManager.login(emailField.text, passwordField.text)
            }

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


    Connections {
            target: AuthManager

            function onLoginSuccess() {
                console.log("Login successful! Role:", AuthManager.userRole)

                if (AuthManager.userRole === "admin") {
                    window.replaceScreen(Qt.resolvedUrl("AdminHomeScreen.qml"))
                } else {
                    window.replaceScreen(Qt.resolvedUrl("HomeScreen.qml"))
                }
            }

            function onLoginFailed(message) {
                console.log("Login failed: " + message)
                errorText.text = message
            }
        }
}
