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

    // --- 2. ЛОГИКА GPS ---
        PositionSource {
            id: gpsSource
            // AllPositioningMethods позволяет использовать и GPS, и Сеть.
            // Но если нет прав на COARSE (сеть), он будет долбиться только в спутники.
            preferredPositioningMethods: PositionSource.AllPositioningMethods

            // Ставим интервал, чтобы не нагружать батарею слишком частыми опросами
            updateInterval: 1000
            active: false

            onPositionChanged: {
                var coord = gpsSource.position.coordinate
                // Проверка на isValid обязательна
                if (coord.isValid) {
                    console.log("Got coordinates:", coord.latitude, coord.longitude)

                    startPointInput.text = coord.latitude.toFixed(5) + ", " + coord.longitude.toFixed(5)

                    // Как только получили валидную точку — выключаем
                    active = false
                    gpsBusy.running = false
                }
            }
            onSourceErrorChanged: {
                if (sourceError == PositionSource.NoError) return

                console.log("GPS Error Code:", sourceError)
                gpsBusy.running = false

                // Расшифровка популярных ошибок для пользователя
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
        function onRouteGenerated(finalLength, timeMinutes) {
            console.log("Route generated! Length:", finalLength, "km")
            successText.text = ""
            errorText.text = ""
            window.pushScreen("qrc:/qt/qml/screens/MapScreen.qml", {
                "routeDistance": finalLength,
                "routeTime": timeMinutes
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

        // --- 3. ПОЛЕ ВВОДА С КНОПКОЙ GPS ---
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 50 // Высота как у AppTextInput

            AppTextInput {
                id: startPointInput
                anchors.fill: parent
                // Оставляем место справа для иконки, чтобы текст не наезжал
                rightPadding: 50
                placeholderText: "Start Point (Lat, Lon)"
            }

            // Кнопка GPS (внутри поля справа)
            Rectangle {
                width: 40
                height: 40
                radius: 20
                color: "transparent"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 5

                // Индикатор загрузки
                BusyIndicator {
                    id: gpsBusy
                    anchors.fill: parent
                    running: false
                    visible: running
                }

                // Иконка
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

        // Слайдер дистанции
        DistanceSlider {
            id: distanceSlider
            Layout.fillWidth: true
        }

        // Выбор POI
        PoiSelector {
            id: poiSelector
            Layout.fillWidth: true
        }

        // Текст успеха (можно убрать, если не используется)
        Text {
            id: successText
            visible: text !== ""
            color: Style.primary
            font.pixelSize: Style.fontSizeBody
            font.bold: true
            Layout.alignment: Qt.AlignHCenter
        }

        // Текст ошибки
        Text {
            id: errorText
            visible: text !== ""
            color: Style.error
            font.pixelSize: Style.fontSizeSmall
            Layout.alignment: Qt.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        Item { Layout.fillHeight: true }

        AppButton {
            text: "GENERATE ROUTE"
            Layout.fillWidth: true

            onClicked: {
                errorText.text = ""
                successText.text = ""

                let cleanText = startPointInput.text.trim()

                // Если поле пустое, можно подставить дефолт (для тестов) или выдать ошибку
                if (cleanText === "") {
                     // Пример для теста (Минск), если пользователь ничего не ввел
                     // cleanText = "53.90, 27.56"
                     // startPointInput.text = cleanText
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
            if (index === 2) {
                window.replaceScreen("qrc:/qt/qml/screens/ProfileScreen.qml")
            }
        }
    }
}
