import QtQuick
import QtQuick.Controls
import QtLocation
import QtPositioning
import theme 1.0

Map {
    id: map

    // Properties to allow external control
    property var routePath: [] // Coordinates list
    property var poiModel: []  // List of POI objects

    plugin: Plugin {
        name: "osm"
        PluginParameter {
            name: "osm.mapping.providersrepository.disabled"
            value: true
        }
    }

    activeMapType: supportedMapTypes.length > 0 ? supportedMapTypes[0] : null

    // HANDLERS (Zoom, Pan, Pinch)
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

    // MAP ITEMS

    // Polyline
    MapPolyline {
        id: mapPolyline
        line.width: 5
        line.color: Style.primary
        path: map.routePath
    }

    // Start Marker
    MapQuickItem {
        coordinate: map.routePath.length > 0 ? map.routePath[0] : QtPositioning.coordinate(0,0)
        anchorPoint.x: sourceItem.width / 2
        anchorPoint.y: sourceItem.height
        visible: map.routePath.length > 0

        sourceItem: Rectangle {
            width: 40; height: 40; radius: 20
            color: "white"; border.color: Style.primary; border.width: 2
            Image {
                anchors.centerIn: parent
                source: "qrc:/qt/qml/SmartTrailsFrontend/assets/map-pin.svg"
                width: 24; height: 24; sourceSize: Qt.size(24, 24)
            }
        }
    }

    // POI Markers
    MapItemView {
        model: map.poiModel
        delegate: MapQuickItem {
            coordinate: QtPositioning.coordinate(modelData.lat, modelData.lon)
            anchorPoint.x: sourceItem.width / 2
            anchorPoint.y: sourceItem.height / 2

            sourceItem: Rectangle {
                width: 32; height: 32; radius: 16
                color: "white"; border.color: Style.primary; border.width: 2

                Image {
                    anchors.centerIn: parent
                    width: 20; height: 20
                    sourceSize: Qt.size(20, 20)
                    source: map.getIconPath(map.getTypeNameById(modelData.type_id))
                }
            }
        }
    }

    // HELPER FUNCTIONS

    function fitRoute() {
        if (mapPolyline.pathLength() > 0) {
            map.fitViewportToMapItems([mapPolyline])
        }
    }

    function getTypeNameById(id) {
        let types = PoiManager.poiTypes
        for(let i = 0; i < types.length; i++) {
            if (types[i].id === id) return types[i].name
        }
        return ""
    }

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
