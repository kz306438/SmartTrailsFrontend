qt_add_library(theme STATIC)

qt_add_qml_module(theme
    URI theme
    VERSION 1.0
    QML_FILES
        Style.qml
    RESOURCES
        qmldir
)
