import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import theme 1.0

Item {
    id: root

    // Data properties
    property string mapName: "Unknown"
    property string mapPath: "/path/to/file"
    property string createdAt: ""
    property bool isActive: false

    // Signals
    signal cropClicked()
    signal deleteClicked()
    signal activationRequested()

    implicitHeight: mainLayout.implicitHeight + 20
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
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // TOP ROW: Icon, Name, Switch
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // Name & Info
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: root.mapName
                        font.pixelSize: 18
                        font.bold: true
                        color: Style.textPrimary
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.createdAt
                        font.pixelSize: 10
                        color: "#9E9E9E"
                        Layout.fillWidth: true
                    }
                }

                // Status Switch
                // Если карта активна (isActive == true) -> Switch ON, Disabled (нельзя выключить, только включить другую).
                // Если карта не активна -> Switch OFF, Enabled. При клике вызываем диалог.
                Switch {
                    checked: root.isActive
                    enabled: !root.isActive

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!parent.checked && parent.enabled) {
                                root.activationRequested()
                            }
                        }
                    }

                    // Custom colors
                    palette.mid: "#E0E0E0"
                    palette.highlight: Style.primary
                }
            }

            // MIDDLE: Path
            // Фон для пути, чтобы визуально отделить его
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                color: "#F5F5F5"
                radius: 6

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: parent.width - 16
                    text: root.mapPath
                    font.pixelSize: 11
                    color: Style.textSecondary
                    elide: Text.ElideMiddle // Сокращаем середину пути (/app/.../file.pbf)
                    horizontalAlignment: Text.AlignLeft
                }
            }

            // --- BOTTOM ROW: Actions ---
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                // CROP Button
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36

                    contentItem: Text {
                        text: "CROP MAP"
                        color: Style.primary
                        font.bold: true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#E8F5E9" : "transparent"
                        border.color: Style.primary
                        border.width: 1
                        radius: 6
                    }
                    onClicked: root.cropClicked()
                }

                // DELETE Button
                Button {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 36

                    contentItem: Text {
                        text: "DELETE"
                        color: Style.error
                        font.bold: true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        color: parent.down ? "#FFEBEE" : "transparent"
                        border.color: Style.error
                        border.width: 1
                        radius: 6
                    }
                    onClicked: root.deleteClicked()
                }
            }
        }
    }
}
