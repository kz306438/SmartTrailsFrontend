import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    property double routeDistance: 0.0
    property int routeTime: 0

    property double startLat: 0.0
    property double startLon: 0.0
    property double requestDistance: 5.0
    property var requestPoiTypes: []

    Connections {
        target: RouteManager
        function onRouteGenerated(finalLength, timeMinutes) {
            root.routeDistance = finalLength
            root.routeTime = timeMinutes
        }
    }

    AppMap {
        id: map
        anchors.fill: parent
        routePath: RouteManager.currentPath
        poiModel: RouteManager.currentPois

        Component.onCompleted: fitRoute()
        onRoutePathChanged: fitRoute()
    }

    RoundButton {
        display: AbstractButton.IconOnly
        icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/back.svg"
        icon.width: 24
        icon.height: 24
        icon.color: Style.primary

        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.topMargin: 50
        width: 48
        height: 48

        background: Rectangle {
            radius: 24
            color: "white"
            border.color: "#E0E0E0"
        }
        onClicked: window.popScreen()
    }

    Rectangle {
        id: bottomSheet
        width: parent.width
        height: 220
        anchors.bottom: parent.bottom
        color: "white"
        radius: 20

        // Заглушка снизу, чтобы скругление было только сверху (визуальный трюк)
        Rectangle { width: parent.width; height: 20; anchors.bottom: parent.bottom; color: "white" }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            // Инфо о маршруте
            Text {
                text: "Route Length: " + root.routeDistance.toFixed(2) + " km"
                font.pixelSize: 18
                font.bold: true; color: "black"
            }
            Text {
                text: "Est. Time: ~" + root.routeTime + " min"
                font.pixelSize: 14
                color: Style.textSecondary
            }

            // Кнопка 1: Got it (вместо SAVE)
            AppButton {
                text: "GOT IT"
                Layout.fillWidth: true
                baseColor: "white"
                textColor: Style.primary

                background: Rectangle {
                    border.color: Style.primary
                    border.width: 2
                    radius: Style.radius
                    color: "white"
                }

                // Просто возвращает пользователя на HomeScreen
                onClicked: window.popScreen()
            }

            AppButton {
                text: "GET ANOTHER"
                Layout.fillWidth: true

                onClicked: {
                    RouteManager.generateRoute(
                        root.requestDistance,
                        root.requestPoiTypes,
                        root.startLat,
                        root.startLon
                    )
                }
            }
        }
    }
}
