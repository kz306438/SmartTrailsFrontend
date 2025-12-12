#include "include/controllers/RouteManager.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>

RouteManager::RouteManager(QObject* parent) : QObject(parent) {}

void RouteManager::generateRoute(double lengthKm, const QList<int>& poiTypes, double startLat, double startLon) {
    int userId = AppSettings::instance().getUserId();
    QString url = QString("/api/users/%1/routes").arg(userId);

    qDebug() << "user id: " << userId;

    QJsonObject body;
    body["name"] = "Generated Route";
    body["distance"] = lengthKm;


    // ВАЖНО: Бэкенд теперь ожидает "lon, lat".
    // startLat и startLon приходят из QML (где пользователь ввел их как Lat, Lon или кликнул по карте).
    // Мы форматируем их как "Longitude, Latitude".
    body["start_point"] = QString("%1, %2").arg(startLon).arg(startLat);

    QJsonArray pois;
    for(int id : poiTypes) {
        pois.append(id);
    }
    body["poi_types"] = pois;

    QNetworkReply* reply = ApiClient::instance().sendRequest(url, "POST", body);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            auto jsonResponse = doc.object();

            // 1. Парсим линию маршрута (как было раньше)
            m_currentPath.clear();
            if (jsonResponse.contains("route_line")) {
                QJsonObject routeLine = jsonResponse["route_line"].toObject();
                if (routeLine.contains("coordinates")) {
                    QJsonArray coordsArr = routeLine["coordinates"].toArray();
                    for(const auto& val : coordsArr) {
                        QJsonArray point = val.toArray();
                        if (point.size() >= 2) {
                            double lon = point[0].toDouble();
                            double lat = point[1].toDouble();
                            m_currentPath.append(QVariant::fromValue(QGeoCoordinate(lat, lon)));
                        }
                    }
                }
            }
            emit currentPathChanged();

            // 2. НОВОЕ: Парсим POI для отображения маркеров
            m_currentPois.clear();
            if (jsonResponse.contains("pois")) { // Предполагаем, что бекенд возвращает массив "pois"
                QJsonArray poisArr = jsonResponse["pois"].toArray();
                for(const auto& val : poisArr) {
                    QJsonObject p = val.toObject();

                    // Извлекаем координаты из GeoJSON POI, если они там есть
                    double pLat = 0, pLon = 0;
                    if(p.contains("location") && p["location"].isObject()) {
                        QJsonArray c = p["location"].toObject()["coordinates"].toArray();
                        if(c.size() >= 2) {
                            pLon = c[0].toDouble();
                            pLat = c[1].toDouble();
                        }
                    }

                    QVariantMap poiMap;
                    poiMap["id"] = p["id"].toInt();
                    poiMap["name"] = p["name"].toString();
                    poiMap["type_id"] = p["type_id"].toInt();
                    poiMap["lat"] = pLat;
                    poiMap["lon"] = pLon;

                    m_currentPois.append(poiMap);
                }
            }
            emit currentPoisChanged();

            // 3. Метаданные
            double dist = jsonResponse["distance_km"].toDouble();
            int timeMinutes = static_cast<int>((dist / 5.0) * 60);

            emit routeGenerated(dist, timeMinutes);

        } else {
            qWarning() << "Generate route error:" << reply->readAll();
            emit errorOccurred("Network error: " + reply->errorString());
        }
        reply->deleteLater();
    });
}

void RouteManager::fetchMyRoutes() {
    int userId = AppSettings::instance().getUserId();
    QString url = QString("/api/users/%1/routes").arg(userId);

    QNetworkReply* reply = ApiClient::instance().sendRequest(url, "GET");

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            m_savedRoutes = doc.array().toVariantList();
            emit savedRoutesChanged();
        } else {
            emit errorOccurred("Failed to fetch routes");
        }
        reply->deleteLater();
    });
}
