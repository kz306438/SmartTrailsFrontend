import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtPositioning // <--- 1. ДОБАВЛЕН ИМПОРТ
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    Component.onCompleted: {
        PoiManager.fetchPoiTypes()
    }

        PositionSource {
            id: gpsSource
            preferredPositioningMethods: PositionSource.AllPositioningMethods

            updateInterval: 1000
            active: false

            onPositionChanged: {
                var coord = gpsSource.position.coordinate
                if (coord.isValid) {
                    console.log("Got coordinates:", coord.latitude, coord.longitude)

                    startPointInput.text = coord.latitude.toFixed(5) + ", " + coord.longitude.toFixed(5)

                    active = false
                    gpsBusy.running = false
                }
            }
            onSourceErrorChanged: {
                if (sourceError == PositionSource.NoError) return

                console.log("GPS Error Code:", sourceError)
                gpsBusy.running = false

                if (sourceError == PositionSource.AccessError) {
                    errorText.text = "GPS Access Denied. Allow permission in settings."
                } else if (sourceError == PositionSource.ClosedError) {
                    errorText.text = "GPS Backend Closed."
                } else {
                    errorText.text = "GPS Error: Check location settings"
                }
            }
        }
        Connections {
                target: RouteManager
                enabled: root.visible

                function onRouteGenerated(finalLength, timeMinutes) {
                    console.log("Route generated! Length:", finalLength, "km")
                    successText.text = ""
                    errorText.text = ""

                    window.pushScreen("qrc:/qt/qml/screens/MapScreen.qml", {
                        "routeDistance": finalLength,
                        "routeTime": timeMinutes,
                        // Новые параметры для повторной генерации:
                        "startLat": parseFloat(startPointInput.text.split(",")[0].trim()),
                        "startLon": parseFloat(startPointInput.text.split(",")[1].trim()),
                        "requestDistance": distanceSlider.value,
                        "requestPoiTypes": poiSelector.selectedIds
                    })
                }
            }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Style.margin
        anchors.bottomMargin: 80
        spacing: 24

        Text {
            text: "Find Your Route"
            font.pixelSize: 28
            font.bold: true
            color: Style.textPrimary
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 40
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 50

            AppTextInput {
                id: startPointInput
                anchors.fill: parent
                rightPadding: 50
                placeholderText: "Start Point (Lat, Lon)"
            }

            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "transparent"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5

                BusyIndicator {
                    id: gpsBusy
                    anchors.fill: parent
                    running: false
                    visible: running
                }

                Image {
                    anchors.centerIn: parent
                    source: "qrc:/qt/qml/SmartTrailsFrontend/assets/map-pin.svg"
                    width: 24
                    height: 24
                    sourceSize: Qt.size(24, 24)
                    visible: !gpsBusy.running
                    opacity: 0.7
                }

                MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            errorText.text = ""
                            gpsBusy.running = true

                            if (gpsSource.position.coordinate.isValid) {
                                 var coord = gpsSource.position.coordinate
                                 startPointInput.text = coord.latitude.toFixed(5) + ", " + coord.longitude.toFixed(5)
                                 gpsBusy.running = false
                                 return
                            }

                            gpsSource.active = true
                        }
                    }
            }
        }

        DistanceSlider {
            id: distanceSlider
            Layout.fillWidth: true
        }

        PoiSelector {
            id: poiSelector
            Layout.fillWidth: true
        }

        Text {
            id: successText
            visible: text !== ""
            color: Style.primary
            font.pixelSize: Style.fontSizeBody
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
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
        Item { Layout.fillHeight: true }

        AppButton {
            text: "GENERATE ROUTE"
            Layout.fillWidth: true

            onClicked: {
                errorText.text = ""
                successText.text = ""

                let cleanText = startPointInput.text.trim()

                if (cleanText === "") {
                     errorText.text = "Please enter start point or use GPS"
                     return
                }

                let coords = cleanText.split(",")

                if (coords.length < 2) {
                    errorText.text = "Invalid format. Use: Lat, Lon"
                    return
                }

                let lat = parseFloat(coords[0].trim())
                let lon = parseFloat(coords[1].trim())

                if (isNaN(lat) || isNaN(lon)) {
                    errorText.text = "Coordinates must be numbers"
                    return
                }

                if (poiSelector.selectedIds.length === 0) {
                    errorText.text = "Please select at least one POI type"
                    return
                }

                console.log("Sending request: Lat=" + lat + ", Lon=" + lon + ", Dist=" + distanceSlider.value)
                RouteManager.generateRoute(distanceSlider.value, poiSelector.selectedIds, lat, lon)
            }
        }
    }

    AppNavBar {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        activeIndex: 0

        onTabSelected: (index) => {
            if (index === 1) window.replaceScreen("qrc:/qt/qml/screens/SavedRoutesScreen.qml")
            if (index === 2) window.replaceScreen("qrc:/qt/qml/screens/ProfileScreen.qml")
        }
    }
}
