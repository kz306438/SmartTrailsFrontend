import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import theme 1.0

ColumnLayout {
    id: root
    spacing: 16
    property var selectedIds: []

    Text {
        text: "Points of interests"
        font.pixelSize: Style.fontSizeBody
        font.bold: true
        color: Style.textPrimary
        Layout.leftMargin: 4 // Align with scroll start
    }

    // Wrap the Row in a Flickable to enable horizontal scrolling
    Flickable {
        Layout.fillWidth: true
        height: 80 // Height enough for buttons + shadow/margins
        contentWidth: poiRow.width + 20 // Extra padding at end
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Row {
            id: poiRow
            spacing: 15
            // Add a little left margin so the first item isn't flush against the screen edge
            leftPadding: 4

            Repeater {
                model: PoiManager.poiTypes

                delegate: Button {
                    id: control
                    width: 70
                    height: 70
                    checkable: true
                    checked: false
                    property int typeId: modelData.id

                    onClicked: {
                        root.updateSelection(typeId, checked)
                    }

                    // --- Icon setup ---
                    display: AbstractButton.IconOnly

                    // Icon logic matching the design (Green when unchecked, White when checked)
                    icon.source: root.getIconSource(modelData.name)
                    icon.width: 36
                    icon.height: 36
                    icon.color: control.checked ? "white" : Style.primary

                    // --- Circular Background ---
                    background: Rectangle {
                        radius: 35 // Half of width/height (70) -> Perfect Circle

                        // Design logic:
                        // Selected = Solid Green fill
                        // Unselected = Transparent with Green Border
                        color: control.checked ? Style.primary : "transparent"

                        border.width: 2
                        border.color: Style.primary
                    }
                }
            }
        }
    }

    function updateSelection(id, add) {
        let temp = selectedIds
        if (add) {
            if (temp.indexOf(id) === -1) temp.push(id)
        } else {
            temp = temp.filter(item => item !== id)
        }
        selectedIds = temp
        console.log("Selected POI IDs:", selectedIds)
    }

    function getIconSource(apiName) {
        // Ensure path matches the resource system
        let basePath = "qrc:/qt/qml/SmartTrailsFrontend/assets/"
        switch (apiName) {
            case "fast_food": return basePath + "fast-food.svg"
            case "tourism":   return basePath + "museum.svg"
            case "restaurant":return basePath + "resturant.svg"
            case "bench":     return basePath + "bench.svg"
            case "sport":     return basePath + "sport.svg"
            default:          return basePath + "map-pin.svg"
        }
    }
}
