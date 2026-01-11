import QtQuick
import QtQuick.Layouts
import theme 1.0

Rectangle {
    id: root
    width: 160
    height: 120
    radius: Style.radius
    color: Style.cardBackground

    property string title: "Metric"
    property string valueText: "0%"
    // Array of numbers (0.0 to 1.0) for the graph
    property var historyData: []

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 0

        // Title and Value Row
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: root.title
                font.bold: true
                font.pixelSize: Style.fontSizeSmall
                color: Style.textPrimary
                Layout.fillWidth: true
            }
            Text {
                text: root.valueText
                font.bold: true
                font.pixelSize: Style.fontSizeSmall
                color: Style.primary
            }
        }

        // The Graph
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 8

            Canvas {
                id: chartCanvas
                anchors.fill: parent
                // Redraw when data changes
                onPaint: {
                    var ctx = getContext("2d")
                    var w = width
                    var h = height
                    var data = root.historyData

                    ctx.clearRect(0, 0, w, h)

                    if (!data || data.length < 2) return

                    // Setup path
                    ctx.beginPath()
                    ctx.moveTo(0, h) // Start bottom left

                    var stepX = w / (data.length - 1)

                    for (var i = 0; i < data.length; i++) {
                        // Value 0..1, map to height. 1.0 is top (y=0), 0.0 is bottom (y=h)
                        var val = data[i]
                        // Clamp
                        if(val > 1) val = 1
                        if(val < 0) val = 0

                        var x = i * stepX
                        var y = h - (val * h)
                        ctx.lineTo(x, y)
                    }

                    ctx.lineTo(w, h) // Bottom right
                    ctx.closePath()

                    // Fill Gradient
                    var gradient = ctx.createLinearGradient(0, 0, 0, h)
                    gradient.addColorStop(0.0, Style.primary)     // Top: Green
                    gradient.addColorStop(1.0, "#204CAF50")       // Bottom: Transparent green

                    ctx.fillStyle = gradient
                    ctx.fill()

                    // Stroke Line on top
                    ctx.beginPath()
                    for (var j = 0; j < data.length; j++) {
                        var val2 = data[j]
                        if(val2 > 1) val2 = 1
                        if(val2 < 0) val2 = 0
                        var x2 = j * stepX
                        var y2 = h - (val2 * h)
                        if (j===0) ctx.moveTo(x2, y2)
                        else ctx.lineTo(x2, y2)
                    }
                    ctx.lineWidth = 2
                    ctx.strokeStyle = Style.primary
                    ctx.stroke()
                }
            }

            // Trigger repaint when data changes
            Connections {
                target: root
                function onHistoryDataChanged() { chartCanvas.requestPaint() }
            }
        }
    }
}
