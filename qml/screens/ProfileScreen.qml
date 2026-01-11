import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import components 1.0
import theme 1.0

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

    Dialog {
        id: renameDialog
        title: "Change User Name"
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
                text: AuthManager.username
                focus: true
            }
        }

        onOpened: nameInput.forceActiveFocus()

        onAccepted: {
            if (nameInput.text.trim() !== "") {
                AuthManager.updateProfile(nameInput.text)
            }
        }
        onRejected: {
            nameInput.text = AuthManager.username
        }
    }

    Dialog {
            id: logoutDialog
            title: "Log Out"
            anchors.centerIn: Overlay.overlay
            width: root.width * 0.8
            modal: true
            standardButtons: Dialog.Ok | Dialog.Cancel

            background: Rectangle {
                color: "white"
                radius: Style.radius
            }

            contentItem: Text {
                text: "Are you sure you want to log out?"
                color: Style.textPrimary
                font.pixelSize: Style.fontSizeBody
                padding: 20
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            onAccepted: {
                AuthManager.logout()
                window.replaceScreen(Qt.resolvedUrl("LoginScreen.qml"))
            }
        }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        anchors.bottomMargin: 90
        spacing: 20

        Item {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 40
            Layout.bottomMargin: 10
            width: 120
            height: 120

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Style.primary
                border.color: "white"
                border.width: 4

                Image {
                    id: profileIcon
                    anchors.centerIn: parent
                    width: parent.width * 0.9
                    height: parent.height * 0.9

                    source: "qrc:/qt/qml/SmartTrailsFrontend/assets/profile-user.svg"
                    sourceSize: Qt.size(width, height)
                    smooth: true
                    visible: false
                }

                ColorOverlay {
                    anchors.fill: profileIcon
                    source: profileIcon
                    color: "white" // Красим иконку в белый
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: 12
            color: "white"
            border.color: Style.primary
            border.width: 2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 16

                // Карандаш
                Item {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    Image {
                        id: pencilImg
                        anchors.fill: parent
                        source: "qrc:/qt/qml/SmartTrailsFrontend/assets/pencil.svg"
                        sourceSize: Qt.size(24, 24)
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: pencilImg
                        source: pencilImg
                        color: Style.primary
                    }

                    MouseArea {
                        anchors.fill: parent
                        onPressed: parent.opacity = 0.5
                        onReleased: parent.opacity = 1.0
                        onClicked: renameDialog.open()
                    }
                }

                // Текст
                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        text: "User Name"
                        color: Style.primary
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Text {
                        text: AuthManager.username === "" ? "..." : AuthManager.username
                        font.pixelSize: 16
                        color: Style.textPrimary
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 64
            radius: 12
            color: "#F5F5F5"
            border.color: "#E0E0E0"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 16

                // Иконка почты
                Item {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    Image {
                        id: mailImg
                        anchors.fill: parent
                        source: "qrc:/qt/qml/SmartTrailsFrontend/assets/mail.svg"
                        sourceSize: Qt.size(24, 24)
                        visible: false
                    }

                    ColorOverlay {
                        anchors.fill: mailImg
                        source: mailImg
                        color: "#757575"
                    }
                }

                Column {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 2

                    Text {
                        text: "Email"
                        color: "#757575"
                        font.pixelSize: 12
                    }

                    Text {
                        text: AuthManager.email
                        font.pixelSize: 16
                        color: "#616161"
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
            }
        }

        Text {
            text: "Statistics"
            font.bold: true
            font.pixelSize: 18
            color: "black"
            Layout.topMargin: 20
        }

        ColumnLayout {
            spacing: 16

            // Distance
            RowLayout {
                spacing: 15
                Item {
                    Layout.preferredWidth: 28; Layout.preferredHeight: 28
                    Image {
                        id: runImg
                        anchors.fill: parent
                        source: "qrc:/qt/qml/SmartTrailsFrontend/assets/run.svg"
                        sourceSize: Qt.size(28, 28)
                        visible: false
                    }
                    ColorOverlay { anchors.fill: runImg; source: runImg; color: Style.primary }
                }
                Text {
                    text: "Total Distance: " + root.totalDistance.toFixed(1) + " km"
                    font.pixelSize: 16
                    color: Style.textPrimary
                }
            }

            // Saved Routes (bookmark.svg)
            RowLayout {
                spacing: 15
                Item {
                    Layout.preferredWidth: 28; Layout.preferredHeight: 28
                    Image {
                        id: bookmarkImg
                        anchors.fill: parent
                        source: "qrc:/qt/qml/SmartTrailsFrontend/assets/bookmark.svg"
                        sourceSize: Qt.size(28, 28)
                        visible: false
                    }
                    ColorOverlay { anchors.fill: bookmarkImg; source: bookmarkImg; color: Style.primary }
                }
                Text {
                    text: "Saved Routes: " + root.savedRoutesCount
                    font.pixelSize: 16
                    color: Style.textPrimary
                }
            }
        }

        Item { Layout.fillHeight: true }

                Button {
                    id: logoutBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    Layout.bottomMargin: 10

                    background: Rectangle {
                        radius: 12
                        color: logoutBtn.down ? "#D32F2F" : "white"
                        border.color: "#D32F2F"
                        border.width: 2
                    }

                    contentItem: Text {
                        text: "LOG OUT"
                        color: logoutBtn.down ? "white" : "#D32F2F"
                        font.bold: true
                        font.pixelSize: 16
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        logoutDialog.open()
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
            if (index === 1) window.replaceScreen(Qt.resolvedUrl("SavedRoutesScreen.qml"))
        }
    }
}
