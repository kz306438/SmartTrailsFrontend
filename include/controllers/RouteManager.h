#pragma once
#include <QObject>
#include <QVariantList>
#include <QGeoCoordinate>
#include "include/network/ApiClient.h"
#include "include/utils/AppSettings.h"

class RouteManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList currentPath READ currentPath NOTIFY currentPathChanged)
    // Добавляем свойство для списка POI на карте
    Q_PROPERTY(QVariantList currentPois READ currentPois NOTIFY currentPoisChanged)
    Q_PROPERTY(QVariantList savedRoutes READ savedRoutes NOTIFY savedRoutesChanged)

public:
    explicit RouteManager(QObject* parent = nullptr);

    Q_INVOKABLE void generateRoute(double lengthKm, const QList<int>& poiTypes, double startLat, double startLon);
    Q_INVOKABLE void fetchMyRoutes();

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
};
