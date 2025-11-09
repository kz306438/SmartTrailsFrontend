qt_add_library(components STATIC)

qt_add_qml_module(components
    URI components
    VERSION 1.0
    QML_FILES
    AppRoundButton.qml
    RESOURCES
        qmldir
)
