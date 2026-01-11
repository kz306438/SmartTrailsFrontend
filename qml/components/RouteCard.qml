import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import theme 1.0

Item {
    id: root

    property string routeName: "Route Name"
    property double distanceKm: 0.0
    property string estimationTimeStr: ""

    signal viewClicked()
    signal deleteClicked()

    height: 140
    width: parent ? parent.width : 300

    Rectangle {
        id: cardBg
        anchors.fill: parent
        anchors.margins: 4
        anchors.leftMargin: 2
        anchors.rightMargin: 2

        color: Style.cardBackground
        radius: 12

        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 2
            radius: 8
            samples: 16
            color: "#15000000"
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // ВЕРХНЯЯ ЧАСТЬ
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                // Иконка слева
                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    radius: 24
                    color: "#E8F5E9"

                    Image {
                        anchors.centerIn: parent
                        source: "qrc:/qt/qml/SmartTrailsFrontend/assets/map.svg"
                        width: 24
                        height: 24
                        sourceSize: Qt.size(24, 24)
                        opacity: 0.6
                    }
                }

                // Текст
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4

                    Text {
                        text: root.routeName
                        font.pixelSize: 16
                        font.bold: true
                        color: Style.textPrimary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.distanceKm.toFixed(1) + " km • " + root.estimationTimeStr
                        font.pixelSize: 14
                        color: Style.textSecondary
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            // --- НИЖНЯЯ ЧАСТЬ (КНОПКИ) ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Button {
                    id: viewBtn
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    padding: 0

                    background: Rectangle {
                    color: viewBtn.down ? Style.primary : "transparent"
                    border.color: Style.primary
                    border.width: 1
                    radius: 6
                }

                contentItem: Item {
                    anchors.fill: parent

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        // Иконка
                        Image {
                            source: "qrc:/qt/qml/SmartTrailsFrontend/assets/map.svg"
                            sourceSize: Qt.size(16, 16)
                            width: 16
                            height: 16
                            anchors.verticalCenter: parent.verticalCenter
                            layer.enabled: true
                            layer.effect: ColorOverlay {
                            color: viewBtn.down ? "white" : Style.primary
                        }
                }

                // Текст
                Text {
                text: "VIEW ON MAP"
                color: viewBtn.down ? "white" : Style.primary
                font.bold: true
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
                }
                }
            }

            onClicked: root.viewClicked()
                            }

                            Button {
                                id: deleteBtn
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 36
                                padding: 0

                                background: Rectangle {
                                    color: deleteBtn.down ? Style.error : "transparent"
                                    border.color: Style.error
                                    border.width: 1
                                    radius: 6
                                }

                                contentItem: Item {
                                    anchors.fill: parent

                                    Row {
                                        anchors.centerIn: parent
                                        spacing: 8

                                        Text {
                                            text: "DELETE"
                                            color: deleteBtn.down ? "white" : Style.error
                                            font.bold: true
                                            font.pixelSize: 12
                                            anchors.verticalCenter: parent.verticalCenter
                                        }

                                        Image {
                                            source: "qrc:/qt/qml/SmartTrailsFrontend/assets/trash.svg"
                                            sourceSize: Qt.size(16, 16)
                                            width: 16
                                            height: 16
                                            anchors.verticalCenter: parent.verticalCenter
                                            layer.enabled: true
                                            layer.effect: ColorOverlay {
                                                color: deleteBtn.down ? "white" : Style.error
                                            }
                                        }
                                    }
                                }

                                onClicked: root.deleteClicked()
                            }
                        }
        }
    }
}
