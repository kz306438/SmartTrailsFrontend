qt_add_library(screens STATIC)

qt_add_qml_module(screens
    URI screens
    VERSION 1.0
    QML_FILES
        LoginScreen.qml
        RegisterScreen.qml
        HomeScreen.qml
        ProfileScreen.qml
        MapScreen.qml
        SavedRoutesScreen.qml
        SavedRouteDetailScreen.qml
        AdminHomeScreen.qml
        AdminMetricsScreen.qml
        AdminMapScreen.qml
    RESOURCES
        qmldir
)
