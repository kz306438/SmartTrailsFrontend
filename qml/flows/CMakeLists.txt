qt_add_library(flows STATIC)

qt_add_qml_module(flows
    URI flows
    VERSION 1.0
    QML_FILES
        AppFlow.qml
        AuthFlow.qml
    RESOURCES
        qmldir
)
