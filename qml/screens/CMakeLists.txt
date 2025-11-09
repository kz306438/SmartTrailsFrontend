qt_add_library(screens STATIC)

qt_add_qml_module(screens
    URI screens
    VERSION 1.0
    QML_FILES
        LoginPage.qml
    RESOURCES
        qmldir
)
