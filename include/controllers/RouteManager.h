#pragma once
#include <QObject>
#include <QVariantList>
#include <QGeoCoordinate>
#include "include/network/ApiClient.h"
#include "include/utils/AppSettings.h"

class RouteManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList currentPath READ currentPath NOTIFY currentPathChanged)
    Q_PROPERTY(QVariantList currentPois READ currentPois NOTIFY currentPoisChanged)
    Q_PROPERTY(QVariantList savedRoutes READ savedRoutes NOTIFY savedRoutesChanged)

public:
    explicit RouteManager(QObject* parent = nullptr);

    Q_INVOKABLE void generateRoute(double lengthKm, const QList<int>& poiTypes, double startLat, double startLon);
    Q_INVOKABLE void fetchMyRoutes();
    Q_INVOKABLE void deleteRoute(int routeId);
    Q_INVOKABLE void loadSavedRoute(int routeId); // Fetches details for viewing
    Q_INVOKABLE void renameRoute(int routeId, const QString& newName);

    QVariantList currentPath() const { return m_currentPath; }
    QVariantList currentPois() const { return m_currentPois; } // Геттер
    QVariantList savedRoutes() const { return m_savedRoutes; }

signals:
    void currentPathChanged();
    void currentPoisChanged(); // Сигнал
    void savedRoutesChanged();
    void routeGenerated(double finalLength, int timeMinutes);
    void errorOccurred(const QString& msg);

private:
    QVariantList m_currentPath;
    QVariantList m_currentPois; // Данные
    QVariantList m_savedRoutes;

    void parseRouteResponse(const QJsonObject& jsonResponse);
};
