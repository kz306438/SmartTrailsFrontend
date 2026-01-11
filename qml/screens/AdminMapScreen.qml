import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    Component.onCompleted: MapManager.fetchMapSources()

    property int targetId: -1
    property string targetPath: ""

    Dialog {
        id: addMapDialog
        title: "Download Map Source"
        anchors.centerIn: Overlay.overlay
        width: root.width * 0.9
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle { color: "white"; radius: Style.radius }

        ColumnLayout {
            spacing: 15
            width: parent.width
            AppTextInput {
                id: newMapName
                Layout.fillWidth: true
                placeholderText: "Name (e.g. Belarus)"
            }
            AppTextInput {
                id: newMapUrl
                Layout.fillWidth: true
                placeholderText: "Region (europe/belarus) or URL"
            }
        }
        onAccepted: {
            if(newMapName.text && newMapUrl.text) {
                MapManager.downloadMap(newMapName.text, newMapUrl.text)
                newMapName.text = ""
                newMapUrl.text = ""
            }
        }
    }

    Dialog {
        id: activateDialog
        title: "Activate Map"
        anchors.centerIn: Overlay.overlay
        width: root.width * 0.9
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        background: Rectangle { color: "white"; radius: Style.radius }

        ColumnLayout {
            spacing: 10
            width: parent.width

            Text {
                text: "Confirm the filesystem path for this map to be active:"
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                color: Style.textPrimary
            }

            AppTextInput {
                id: activatePathInput
                Layout.fillWidth: true
                placeholderText: "/app/maps/..."
                text: root.targetPath // Binding
            }
        }

        onAccepted: {
            if (activatePathInput.text !== "") {
                // Отправляем запрос на активацию с указанным путем
                MapManager.setMapStatus(root.targetId, activatePathInput.text, true)
            }
        }
    }

    Dialog {
        id: cropDialog
        title: "Crop Map"
        anchors.centerIn: Overlay.overlay
        width: root.width * 0.9
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel

        background: Rectangle { color: "white"; radius: Style.radius }

        ColumnLayout {
            spacing: 12
            width: parent.width

            Text { text: "Source File Path (on server):"; font.pixelSize: 12; color: Style.textSecondary }

            // Editable Path Field
            AppTextInput {
                id: cropPathInput
                Layout.fillWidth: true
                placeholderText: "/app/maps/..."
                text: root.targetPath // Предзаполнение
            }

            Text { text: "New Map Name:"; font.pixelSize: 12; color: Style.textSecondary; Layout.topMargin: 4 }
            AppTextInput { id: cropName; Layout.fillWidth: true; placeholderText: "Name (e.g. Minsk)" }

            Text { text: "Coordinates (BBox):"; font.pixelSize: 12; color: Style.textSecondary; Layout.topMargin: 4 }
            GridLayout {
                columns: 2
                Layout.fillWidth: true
                rowSpacing: 10
                columnSpacing: 10

                AppTextInput { id: cropLeft; Layout.fillWidth: true; placeholderText: "Left (Lon)" }
                AppTextInput { id: cropBottom; Layout.fillWidth: true; placeholderText: "Bottom (Lat)" }
                AppTextInput { id: cropRight; Layout.fillWidth: true; placeholderText: "Right (Lon)" }
                AppTextInput { id: cropTop; Layout.fillWidth: true; placeholderText: "Top (Lat)" }
            }
        }

        onAccepted: {
            let l = parseFloat(cropLeft.text)
            let b = parseFloat(cropBottom.text)
            let r = parseFloat(cropRight.text)
            let t = parseFloat(cropTop.text)

            // Используем текст из поля ввода (пользователь мог его поправить)
            if (cropName.text && cropPathInput.text && !isNaN(l)) {
                MapManager.cropMap(root.targetId, cropPathInput.text, cropName.text, l, b, r, t)
            }
        }
    }

    Dialog {
        id: deleteDialog
        title: "Delete Map"
        anchors.centerIn: Overlay.overlay
        width: root.width * 0.8
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        background: Rectangle { color: "white"; radius: Style.radius }

        contentItem: Text {
            text: "Are you sure you want to delete this map source? This cannot be undone."
            wrapMode: Text.Wrap
            color: Style.textPrimary
            font.pixelSize: 16
            padding: 20
            horizontalAlignment: Text.AlignHCenter
        }
        onAccepted: MapManager.deleteMapSource(root.targetId)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 10

        // Header
        Rectangle {
            Layout.fillWidth: true
            height: 60
            color: "transparent"
            RowLayout {
                anchors.fill: parent
                Button {
                    display: AbstractButton.IconOnly
                    background: Item{}
                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/back.svg"
                    icon.color: Style.textPrimary
                    onClicked: window.popScreen()
                }
                Text {
                    text: "Manage Maps"
                    font.pixelSize: 22
                    font.bold: true
                    color: Style.textPrimary
                    Layout.fillWidth: true
                }
                Button {
                    display: AbstractButton.IconOnly
                    background: Rectangle {
                        color: Style.primary; radius: 20
                        opacity: parent.down ? 0.8 : 1.0
                    }
                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/download.svg"
                    icon.color: "white"
                    onClicked: addMapDialog.open()
                }
            }
        }

        // List
        ListView {
            id: mapList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 12
            model: MapManager.mapSources

            // Delegate
            delegate: MapSourceCard {
                width: mapList.width

                mapName: modelData.name
                mapPath: modelData.path
                isActive: modelData.is_active
                createdAt: modelData.created_at || ""

                onActivationRequested: {
                    root.targetId = modelData.id
                    root.targetPath = modelData.path
                    activateDialog.open()
                }

                onCropClicked: {
                    root.targetId = modelData.id
                    root.targetPath = modelData.path
                    cropName.text = modelData.name + "_cropped"
                    cropDialog.open()
                }

                onDeleteClicked: {
                    root.targetId = modelData.id
                    deleteDialog.open()
                }
            }
        }
    }

    // Loading Overlay
    Rectangle {
        anchors.fill: parent
        color: "#50000000"
        visible: MapManager.isLoading
        z: 99
        BusyIndicator { anchors.centerIn: parent }
    }
}
