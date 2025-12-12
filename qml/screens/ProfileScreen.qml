import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import components 1.0
import theme 1.0
import Qt5Compat.GraphicalEffects // Remove if not using DropShadow, otherwise see note below*

Page {
    id: root
    background: Rectangle { color: Style.background }

    Component.onCompleted: {
        RouteManager.fetchMyRoutes()
    }

    property int savedRoutesCount: RouteManager.savedRoutes.length
    property double totalDistance: {
        let dist = 0.0
        for(let i = 0; i < RouteManager.savedRoutes.length; i++) {
            let route = RouteManager.savedRoutes[i]
            if (route.preferences && route.preferences.distance_km) {
                dist += route.preferences.distance_km
            }
        }
        return dist
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        anchors.bottomMargin: 90
        spacing: 24

        // --- 1. Avatar Section ---
        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            width: 140
            height: 140

            // Green Circle Border
            Rectangle {
                anchors.fill: parent
                radius: 70
                color: "transparent"
                border.color: Style.primary
                border.width: 4

                // FIX: Use Button instead of Image+Shader to colorize the icon
                Button {
                    anchors.centerIn: parent
                    width: 80
                    height: 80
                    display: AbstractButton.IconOnly
                    background: null // Remove button background

                    // Icon settings
                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/profile-user.svg"
                    icon.width: 80
                    icon.height: 80
                    icon.color: Style.primary // Native Qt6 colorizing

                    // Make it look active even if not clickable
                    enabled: false
                    opacity: 1.0
                    contentItem.opacity: 1.0
                }
            }
        }

        // --- 2. Input Fields ---

        // USERNAME
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 8
            color: "white"
            border.color: Style.primary
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Pencil Icon
                Button {
                    display: AbstractButton.IconOnly
                    background: null
                    enabled: false
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/pencil.svg"
                    icon.width: 24
                    icon.height: 24
                    icon.color: Style.primaryDark // Dark Green

                    opacity: 1.0
                    contentItem.opacity: 1.0
                }

                // Text Column
                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "User Name"
                        color: Style.primary
                        font.pixelSize: 12
                        font.bold: true
                    }

                    TextInput {
                        id: nameInput
                        text: AuthManager.username
                        width: parent.width
                        font.pixelSize: 16
                        color: "black"
                        selectByMouse: true
                        clip: true
                        onEditingFinished: {
                            focus = false
                            AuthManager.updateProfile(text)
                        }
                    }
                }
            }
        }

        // EMAIL
        Rectangle {
            Layout.fillWidth: true
            height: 60
            radius: 8
            color: "#F0F0F0"
            border.color: "#BDBDBD"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Mail Icon
                Button {
                    display: AbstractButton.IconOnly
                    background: null
                    enabled: false
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/mail.svg"
                    icon.width: 24
                    icon.height: 24
                    icon.color: "#757575" // Grey

                    opacity: 1.0
                    contentItem.opacity: 1.0
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter

                    Text {
                        text: "Email"
                        color: "#757575"
                        font.pixelSize: 12
                    }

                    Text {
                        text: AuthManager.email
                        width: parent.width
                        font.pixelSize: 16
                        color: "#616161"
                        elide: Text.ElideRight
                    }
                }
            }
        }

        // --- 3. Statistics ---
        Text {
            text: "Statistics"
            font.bold: true
            font.pixelSize: 18
            color: "black"
            Layout.topMargin: 10
        }

        // Stats Rows
        ColumnLayout {
            spacing: 12

            // Distance
            RowLayout {
                spacing: 15
                Button {
                    display: AbstractButton.IconOnly
                    background: null
                    enabled: false
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    padding: 0

                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/run.svg"
                    icon.width: 24
                    icon.height: 24
                    icon.color: Style.primary

                    opacity: 1.0
                    contentItem.opacity: 1.0
                }
                Text {
                    text: "Total Distance: " + root.totalDistance.toFixed(1) + " km"
                    font.pixelSize: 16
                    color: Style.textPrimary
                }
            }

            // Saved Routes
            RowLayout {
                spacing: 15
                Button {
                    display: AbstractButton.IconOnly
                    background: null
                    enabled: false
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    padding: 0

                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/star.svg"
                    icon.width: 24
                    icon.height: 24
                    icon.color: Style.primary

                    opacity: 1.0
                    contentItem.opacity: 1.0
                }
                Text {
                    text: "Saved Routes: " + root.savedRoutesCount
                    font.pixelSize: 16
                    color: Style.textPrimary
                }
            }
        }

        Item { Layout.fillHeight: true }

        // --- 4. Log Out ---
        Button {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            background: Rectangle {
                radius: 25
                color: "white"
                border.color: "#D32F2F"
                border.width: 2
            }

            contentItem: Text {
                text: "LOG OUT"
                color: "#D32F2F"
                font.bold: true
                font.pixelSize: 16
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                AuthManager.logout()
                window.replaceScreen(Qt.resolvedUrl("LoginScreen.qml"))
            }
        }
    }

    AppNavBar {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        activeIndex: 2
        onTabSelected: (index) => {
            if (index === 0) window.replaceScreen(Qt.resolvedUrl("HomeScreen.qml"))
        }
    }
}
