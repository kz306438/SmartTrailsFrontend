import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    // Свойство для хранения ID маршрута, который хотим удалить
    property int routeIdToDelete: -1

    Component.onCompleted: RouteManager.fetchMyRoutes()

    // --- Диалог подтверждения удаления ---
    Dialog {
        id: deleteDialog
        title: "Delete Route"

        // Центрирование поверх всего окна
        anchors.centerIn: Overlay.overlay

        // Явно задаем ширину, чтобы избежать ошибок Binding Loop
        width: root.width * 0.8

        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle {
            color: "white"
            radius: Style.radius
        }

        contentItem: Text {
            text: "Are you sure you want to delete this route?"
            color: Style.textPrimary
            font.pixelSize: Style.fontSizeBody
            padding: 20

            // Перенос текста для фиксированной ширины
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        onAccepted: {
            if (root.routeIdToDelete !== -1) {
                RouteManager.deleteRoute(root.routeIdToDelete)
                root.routeIdToDelete = -1
            }
        }
        onRejected: {
            root.routeIdToDelete = -1
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Text {
            text: "Saved Routes"
            font.pixelSize: 24
            font.bold: true
            color: Style.textPrimary
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
        }

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 10
            bottomMargin: 100

            model: RouteManager.savedRoutes

            delegate: RouteCard {
                width: listView.width

                routeName: modelData.name || "Route #" + modelData.id

                // Вспомогательное свойство для дистанции
                property double dist: modelData.preferences ? modelData.preferences.distance_km : 0
                distanceKm: dist

                estimationTimeStr: Math.round(dist * 12) + " min"

                // Обработчики кнопок
                onViewClicked: {
                    RouteManager.loadSavedRoute(modelData.id)
                    window.pushScreen("qrc:/qt/qml/screens/SavedRouteDetailScreen.qml", {
                        "routeDistance": modelData.preferences ? modelData.preferences.distance_km : 0,
                        "routeName": modelData.name || "Route #" + modelData.id,
                        "routeId": modelData.id
                    })
               }

                onDeleteClicked: {
                    root.routeIdToDelete = modelData.id
                    deleteDialog.open()
                }
            }
        }
    }

    AppNavBar {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        activeIndex: 1
        onTabSelected: (index) => {
            if (index === 0) window.replaceScreen("qrc:/qt/qml/screens/HomeScreen.qml")
            if (index === 2) window.replaceScreen("qrc:/qt/qml/screens/ProfileScreen.qml")
        }
    }
}
