cmake_minimum_required(VERSION 3.16)
project(SmartTrailsFrontend VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 1. ДОБАВЛЯЕМ QuickControls2 (здесь живет IconImage)
find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml Svg Positioning Location QuickControls2)
qt_standard_project_setup(REQUIRES 6.5)

set(SOURCES
    src/main.cpp
    src/network/ApiClient.cpp
    src/controllers/AuthManager.cpp
    src/controllers/RouteManager.cpp
    src/controllers/PoiManager.cpp
    src/controllers/AdminManager.cpp
    src/controllers/MapManager.cpp
    src/utils/AppSettings.cpp
)

set(HEADERS
    include/network/ApiClient.h
    include/controllers/AuthManager.h
    include/controllers/RouteManager.h
    include/controllers/PoiManager.h
    include/controllers/AdminManager.h
    include/controllers/MapManager.h
    include/utils/AppSettings.h
)

qt_add_executable(appSmartTrailsFrontend
    ${SOURCES}
    ${HEADERS}
)

add_subdirectory(qml/components)
add_subdirectory(qml/screens)
add_subdirectory(qml/theme)

qt_add_qml_module(appSmartTrailsFrontend
    URI SmartTrailsFrontend
    VERSION 1.0
    QML_FILES qml/Main.qml
    RESOURCES
        assets/bench.svg
        assets/fast-food.svg
        assets/mail.svg
        assets/map-pin.svg
        assets/map.svg
        assets/museum.svg
        assets/pencil.svg
        assets/profile-user.svg
        assets/profile.svg
        assets/resturant.svg
        assets/run.svg
        assets/sport.svg
        assets/star.svg
        assets/trash.svg
        assets/back.svg
        assets/bookmark.svg
        assets/metrics.svg
        assets/download.svg
)

target_include_directories(appSmartTrailsFrontend PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/src )
target_include_directories(appSmartTrailsFrontend PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)

target_link_libraries(appSmartTrailsFrontend
    PRIVATE
    Qt6::Core Qt6::Gui Qt6::Quick Qt6::Qml Qt6::Positioning Qt6::Location
    Qt6::Svg Qt6::QuickControls2
    componentsplugin
    screensplugin
    themeplugin
)

if(ANDROID)
    set_property(TARGET appSmartTrailsFrontend PROPERTY
        QT_ANDROID_PACKAGE_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android"
    )

    set(ANDROID_OPENSSL_LIBS_DIR "${CMAKE_CURRENT_SOURCE_DIR}/android/libs/${ANDROID_ABI}")
    if(EXISTS "${ANDROID_OPENSSL_LIBS_DIR}/libcrypto_3.so" AND EXISTS "${ANDROID_OPENSSL_LIBS_DIR}/libssl_3.so")
        set_property(TARGET appSmartTrailsFrontend APPEND PROPERTY
            QT_ANDROID_EXTRA_LIBS
            "${ANDROID_OPENSSL_LIBS_DIR}/libcrypto_3.so"
            "${ANDROID_OPENSSL_LIBS_DIR}/libssl_3.so"
        )
        message(STATUS "Android OpenSSL found: libcrypto_3.so & libssl_3.so included.")
    else()
        message(WARNING "Real OpenSSL binaries (lib..._3.so) NOT found in ${ANDROID_OPENSSL_LIBS_DIR}")
    endif()
endif()
