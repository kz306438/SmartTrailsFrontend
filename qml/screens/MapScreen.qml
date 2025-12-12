import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtLocation
import QtPositioning
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    property double routeDistance: 0.0
    property int routeTime: 0

    Map {
        id: map
        anchors.fill: parent

        plugin: Plugin {
            name: "osm"
            PluginParameter {
                name: "osm.mapping.providersrepository.disabled"
                value: true
            }
        }

        activeMapType: supportedMapTypes.length > 0 ? supportedMapTypes[0] : null

        // --- УПРАВЛЕНИЕ КАРТОЙ (HANDLERS) ---
        PinchHandler {
            id: pinch
            target: null
            onActiveChanged: if (active) map.startCentroid = map.toCoordinate(pinch.centroid.position, false)
            onScaleChanged: (delta) => {
                map.zoomLevel += Math.log2(delta)
                map.alignCoordinateToPoint(map.startCentroid, pinch.centroid.position)
            }
            onRotationChanged: (delta) => map.bearing -= delta
            grabPermissions: PointerHandler.CanTakeOverFromAnything
        }

        DragHandler {
            id: drag
            target: null
            onTranslationChanged: (delta) => map.pan(-delta.x, -delta.y)
        }

        WheelHandler {
            id: wheel
            rotationScale: 1/120
            property: "zoomLevel"
        }

        property var startCentroid

        // --- ЭЛЕМЕНТЫ КАРТЫ ---

        // 1. Линия маршрута
        MapPolyline {
            id: mapPolyline
            line.width: 5
            line.color: Style.primary
            path: RouteManager.currentPath
        }

        // 2. Маркер Старта (теперь тоже в кружке)
        MapQuickItem {
            coordinate: RouteManager.currentPath.length > 0 ? RouteManager.currentPath[0] : QtPositioning.coordinate(0,0)
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height
            visible: RouteManager.currentPath.length > 0

            sourceItem: Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "white"
                border.color: Style.primary
                border.width: 2

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qt/qml/SmartTrailsFrontend/assets/map-pin.svg"
                    width: 24
                    height: 24
                    sourceSize: Qt.size(24, 24)
                    mipmap: true
                }

                layer.enabled: true
            }
        }

        // 3. POI (Точки интереса)
        MapItemView {
            model: RouteManager.currentPois
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(modelData.lat, modelData.lon)
                anchorPoint.x: sourceItem.width / 2
                anchorPoint.y: sourceItem.height / 2

                sourceItem: Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: "white"
                    border.color: Style.primary
                    border.width: 2

                    Image {
                        anchors.centerIn: parent
                        width: 24
                        height: 24
                        sourceSize: Qt.size(24, 24)

                        // Ищем имя типа по ID и подбираем иконку
                        source: getIconPath(getTypeNameById(modelData.type_id))
                    }

                    layer.enabled: true
                }
            }
        }

        Component.onCompleted: {
            if (RouteManager.currentPath.length > 0) {
                map.fitViewportToMapItems([mapPolyline])
            }
        }
    }

    // --- ИНТЕРФЕЙС ПОВЕРХ КАРТЫ ---

    // Кнопка "Назад"
    RoundButton {
        text: "‹"
        font.pixelSize: 32
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.leftMargin: 16
        anchors.topMargin: 50

        width: 48
        height: 48

        contentItem: Text {
            text: parent.text
            font: parent.font
            color: Style.textPrimary
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -2
        }

        background: Rectangle {
            radius: 24
            color: "white"
            layer.enabled: true
            border.color: "#E0E0E0"
            border.width: 1
        }
        onClicked: window.popScreen()
    }

    // Заголовок
    Text {
        text: "Your Route"
        font.pixelSize: 20
        font.bold: true
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        color: "black"
        style: Text.Outline; styleColor: "white"
    }

    // --- КНОПКИ ЗУМА (СПРАВА) ---
    Column {
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 16

        RoundButton {
            text: "+"
            font.pixelSize: 24
            width: 48
            height: 48

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: Style.textPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 24
                color: "white"
                border.color: "#E0E0E0"
                border.width: 1
                layer.enabled: true
            }
            onClicked: map.zoomLevel += 1
        }

        RoundButton {
            text: "-"
            font.pixelSize: 24
            width: 48
            height: 48

            contentItem: Text {
                text: parent.text
                font: parent.font
                color: Style.textPrimary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: 24
                color: "white"
                border.color: "#E0E0E0"
                border.width: 1
                layer.enabled: true
            }
            onClicked: map.zoomLevel -= 1
        }
    }

    // --- НИЖНЯЯ ПАНЕЛЬ ---
    Rectangle {
        id: bottomSheet
        width: parent.width
        height: 220
        anchors.bottom: parent.bottom
        color: "white"
        radius: 20
        layer.enabled: true

        Rectangle {
            width: parent.width
            height: 20
            anchors.bottom: parent.bottom
            color: "white"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Text {
                text: "Route Length: " + root.routeDistance.toFixed(2) + " km"
                font.pixelSize: 18
                font.bold: true
                color: "black"
            }

            Text {
                text: "Est. Time: ~" + root.routeTime + " min"
                font.pixelSize: 14
                color: Style.textSecondary
            }

            AppButton {
                text: "SAVE (Auto-saved)"
                Layout.fillWidth: true
                baseColor: "white"
                textColor: Style.primary
                background: Rectangle {
                    border.color: Style.primary
                    border.width: 2
                    radius: Style.radius
                    color: "white"
                }
            }

            AppButton {
                text: "GET ANOTHER"
                Layout.fillWidth: true
                onClicked: window.popScreen()
            }
        }
    }

    // Хелпер: найти имя типа по ID
    function getTypeNameById(id) {
        let types = PoiManager.poiTypes
        for(let i = 0; i < types.length; i++) {
            if (types[i].id === id) {
                return types[i].name
            }
        }
        return ""
    }

    // Хелпер: путь к иконке
    function getIconPath(apiName) {
        let basePath = "qrc:/qt/qml/SmartTrailsFrontend/assets/"
        switch (apiName) {
            case "fast_food": return basePath + "fast-food.svg"
            case "tourism":   return basePath + "museum.svg"
            case "restaurant":return basePath + "resturant.svg"
            case "bench":     return basePath + "bench.svg"
            case "sport":     return basePath + "sport.svg"
            default:          return basePath + "star.svg"
        }
    }
}
