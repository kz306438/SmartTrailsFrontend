 import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import theme 1.0
import components 1.0

Page {
    id: root
    background: Rectangle { color: Style.background }

    // Arrays to store history for charts
    property var cpuHistory: [0.1, 0.2, 0.15, 0.3, 0.25, 0.4, 0.35, 0.2, 0.1, 0.2] // Mock start
    property var memHistory: [0.4, 0.41, 0.42, 0.41, 0.43, 0.44, 0.45, 0.44, 0.43, 0.44]

    // Timer to fetch data every 2 seconds
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: AdminManager.fetchSystemMetrics()
    }

    Connections {
        target: AdminManager
        function onMetricsChanged() {
            // Update CPU History
            let cpuVal = AdminManager.cpuUsage / 100.0
            let newCpu = cpuHistory
            newCpu.shift() // Remove first
            newCpu.push(cpuVal) // Add new
            cpuHistory = newCpu // Reassign to trigger update

            // Update Mem History
            let memVal = AdminManager.memUsage / 100.0
            let newMem = memHistory
            newMem.shift()
            newMem.push(memVal)
            memHistory = newMem
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Header with Back Button
        Rectangle {
            Layout.fillWidth: true
            height: 80
            color: Style.cardBackground

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                Button {
                    display: AbstractButton.IconOnly
                    background: Item{}
                    icon.source: "qrc:/qt/qml/SmartTrailsFrontend/assets/back.svg"
                    icon.color: Style.textPrimary
                    onClicked: window.popScreen()
                }

                Text {
                    text: "Server Status"
                    font.pixelSize: 20
                    font.bold: true
                    color: Style.textPrimary
                }
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: parent.width // Prevent horizontal scroll

            ColumnLayout {
                width: parent.width
                spacing: 20
                anchors.margins: 20

                // 1. Charts Row
                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    spacing: 16

                    MetricCard {
                        Layout.fillWidth: true
                        title: "CPU Usage"
                        valueText: AdminManager.cpuUsage.toFixed(1) + "%"
                        historyData: root.cpuHistory
                    }

                    MetricCard {
                        Layout.fillWidth: true
                        title: "Memory Usage"
                        valueText: AdminManager.memUsage.toFixed(1) + "%"
                        historyData: root.memHistory
                    }
                }

                // 2. Detailed Info Card
                Rectangle {
                    Layout.fillWidth: true
                    Layout.margins: 16
                    height: 160
                    radius: Style.radius
                    color: Style.cardBackground

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 12

                        Text {
                            text: "Server Metrics"
                            font.bold: true
                            font.pixelSize: 16
                            color: Style.textPrimary
                        }

                        // Status Line
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Server Status:"; color: Style.textSecondary }
                            Item { Layout.fillWidth: true }
                            Text { text: "Online"; color: Style.primary; font.bold: true }
                        }

                        // Users Line
                        RowLayout {
                            Layout.fillWidth: true
                            Text { text: "Registered Users:"; color: Style.textSecondary }
                            Item { Layout.fillWidth: true }
                            Text { text: String(AdminManager.userCount); color: Style.textPrimary; font.bold: true }
                        }
                    }
                }
            }
        }
    }
}
