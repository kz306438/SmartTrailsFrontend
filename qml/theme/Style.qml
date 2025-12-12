pragma Singleton
import QtQuick

QtObject {
    // Цвета из твоего дизайна
    property color primary: "#4CAF50"       // Основной зеленый
    property color primaryDark: "#388E3C"   // Темно-зеленый (для нажатий)
    property color background: "#F5F5F5"    // Светло-серый фон
    property color cardBackground: "#FFFFFF"// Белый для карточек
    property color textPrimary: "#212121"   // Почти черный текст
    property color textSecondary: "#757575" // Серый текст
    property color error: "#E53935"         // Красный для ошибок

    // Размеры (можно адаптировать под DPI, но пока фиксировано)
    property int margin: 16
    property int radius: 12
    property int fontSizeHeading: 24
    property int fontSizeBody: 16
    property int fontSizeSmall: 14
}
