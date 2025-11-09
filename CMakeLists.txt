cmake_minimum_required(VERSION 3.16)
project(SmartTrailsFrontend VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml)
qt_standard_project_setup(REQUIRES 6.5)

set(SOURCES
    src/main.cpp
)

set(HEADERS
)

qt_add_executable(appSmartTrailsFrontend
    ${SOURCES}
    ${HEADERS}
)

add_subdirectory(qml/components)
add_subdirectory(qml/flows)
add_subdirectory(qml/screens)
add_subdirectory(qml/theme)

qt_add_qml_module(appSmartTrailsFrontend
    URI SmartTrailsFrontend
    VERSION 1.0
    QML_FILES qml/Main.qml
)

target_include_directories(appSmartTrailsFrontend PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src )
target_include_directories(appSmartTrailsFrontend PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

target_link_libraries(appSmartTrailsFrontend
    PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml
    componentsplugin
    flowsplugin
    screensplugin
    themeplugin
)

