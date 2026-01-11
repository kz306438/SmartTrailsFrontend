import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 24

        // Header
        Text {
            text: "Admin Dashboard"
            font.pixelSize: 24
            font.bold: true
            color: Style.textPrimary
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
        }

        // Grid of Actions
        GridLayout {
            columns: 2
            Layout.fillWidth: true
            columnSpacing: 16
            rowSpacing: 16

            // 1. Server Status
            ActionCard {
                iconSource: "qrc:/qt/qml/SmartTrailsFrontend/assets/metrics.svg" // Placeholder icon
                title: "Server Metrics"
                description: "CPU, RAM, Users"
                onClicked: window.pushScreen("qrc:/qt/qml/screens/AdminMetricsScreen.qml")
            }

            // 2. Maps Manager (Placeholder for future tasks)
            ActionCard {
                iconSource: "qrc:/qt/qml/SmartTrailsFrontend/assets/map.svg"
                title: "Manage Maps"
                description: "Upload, Crop, Select"
                onClicked: window.pushScreen("qrc:/qt/qml/screens/AdminMapScreen.qml")
            }
        }

        Item { Layout.fillHeight: true } // Spacer

        // Logout
        AppButton {
            text: "LOGOUT"
            Layout.fillWidth: true
            baseColor: Style.error
            textColor: "white"
            onClicked: {
                AuthManager.logout()
                window.replaceScreen("qrc:/qt/qml/screens/LoginScreen.qml")
            }
        }
    }

    // Helper component for this screen
    component ActionCard : Rectangle {
        property string title
        property string description
        property string iconSource
        signal clicked()

        Layout.fillWidth: true
        Layout.preferredHeight: 140
        radius: Style.radius
        color: Style.cardBackground

        MouseArea { anchors.fill: parent; onClicked: parent.clicked() }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 48; height: 48; radius: 24
                color: "#E8F5E9"
                Image {
                    anchors.centerIn: parent
                    source: iconSource
                    width: 24; height: 24
                    sourceSize: Qt.size(24,24)
                }
            }

            Text {
                text: title
                font.bold: true
                color: Style.textPrimary
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: description
                font.pixelSize: 12
                color: Style.textSecondary
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
