#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "include/controllers/AuthManager.h"
#include "include/controllers/RouteManager.h"
#include "include/controllers/PoiManager.h"
#include "include/controllers/AdminManager.h"
#include "include/controllers/MapManager.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    AuthManager* authManager = new AuthManager(&app);
    MapManager* mapManager = new MapManager(&app);
    AdminManager* adminManager = new AdminManager(&app);
    RouteManager* routeManager = new RouteManager(&app);
    PoiManager* poiManager = new PoiManager(&app);

    engine.rootContext()->setContextProperty("AdminManager", adminManager);
    engine.rootContext()->setContextProperty("AuthManager", authManager);
    engine.rootContext()->setContextProperty("RouteManager", routeManager);
    engine.rootContext()->setContextProperty("MapManager", mapManager);
    engine.rootContext()->setContextProperty("PoiManager", poiManager);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("SmartTrailsFrontend", "Main");

    return app.exec();
}
