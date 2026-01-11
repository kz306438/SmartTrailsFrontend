qt_add_library(components STATIC)

qt_add_qml_module(components
    URI components
    VERSION 1.0
    QML_FILES
    AppButton.qml
    AppTextInput.qml
    AppNavBar.qml
    AppMap.qml
    DistanceSlider.qml
    PoiSelector.qml
    RouteCard.qml
    MetricCard.qml
    MapSourceCard.qml
    RESOURCES
        qmldir
)

target_link_libraries(components PRIVATE Qt6::Quick Qt6::QuickControls2)
