import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import theme 1.0

Rectangle {
    id: root
    height: 80
    color: Style.cardBackground

    Rectangle {
        width: parent.width
        height: 1
        color: "#E0E0E0"
        anchors.top: parent.top
    }

    signal tabSelected(int index)
    property int activeIndex: 0

    RowLayout {
        anchors.fill: parent
        anchors.bottomMargin: 20
        spacing: 0

        Repeater {
            model: [
                { text: "Route", icon: "qrc:/qt/qml/SmartTrailsFrontend/assets/map.svg" },
                { text: "Saved", icon: "qrc:/qt/qml/SmartTrailsFrontend/assets/star.svg" },
                { text: "Profile", icon: "qrc:/qt/qml/SmartTrailsFrontend/assets/profile-user.svg" }
            ]

            delegate: TabButton {
                Layout.fillWidth: true
                Layout.fillHeight: true

                text: modelData.text

                icon.source: modelData.icon
                icon.width: 28
                icon.height: 28

                icon.color: checked ? Style.primary : Style.textSecondary

                display: AbstractButton.TextUnderIcon
                font.pixelSize: 12
                font.bold: checked

                palette.buttonText: checked ? Style.primary : Style.textSecondary

                checkable: true
                checked: root.activeIndex === index
                onClicked: root.tabSelected(index)

                background: Item {}
            }
        }
    }
}
