#include "include/controllers/RouteManager.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QJsonDocument>
#include <QDebug>

RouteManager::RouteManager(QObject* parent) : QObject(parent) {}

// --- Helper to parse Route Response ---
void RouteManager::parseRouteResponse(const QJsonObject& jsonResponse) {
    // 1. Parse Route Line
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

    // 2. Parse POIs
    m_currentPois.clear();
    if (jsonResponse.contains("pois")) { // "pois" array from backend
        QJsonArray poisArr = jsonResponse["pois"].toArray();
        for(const auto& val : poisArr) {
            QJsonObject p = val.toObject();
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
}

void RouteManager::generateRoute(double lengthKm, const QList<int>& poiTypes, double startLat, double startLon) {
    int userId = AppSettings::instance().getUserId();
    QString url = QString("/api/users/%1/routes").arg(userId);

    QJsonObject body;
    body["name"] = "Generated Route " + QDateTime::currentDateTime().toString("dd.MM HH:mm"); // Default name
    body["distance"] = lengthKm;
    body["start_point"] = QString("%1, %2").arg(startLon).arg(startLat);

    QJsonArray pois;
    for(int id : poiTypes) pois.append(id);
    body["poi_types"] = pois;

    QNetworkReply* reply = ApiClient::instance().sendRequest(url, "POST", body);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            auto jsonResponse = doc.object();

            parseRouteResponse(jsonResponse); // Reused parser

            double dist = jsonResponse["distance_km"].toDouble();
            int timeMinutes = static_cast<int>((dist / 5.0) * 60);
            emit routeGenerated(dist, timeMinutes);

            // Refresh saved list immediately as it is auto-saved
            fetchMyRoutes();
        } else {
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

void RouteManager::deleteRoute(int routeId) {
    int userId = AppSettings::instance().getUserId();
    // DELETE /api/users/{user_id}/routes/{route_id}
    QString url = QString("/api/users/%1/routes/%2").arg(userId).arg(routeId);

    QNetworkReply* reply = ApiClient::instance().sendRequest(url, "DELETE");

    connect(reply, &QNetworkReply::finished, this, [this, reply, routeId]() {
        if (reply->error() == QNetworkReply::NoError) {
            // Remove locally to update UI instantly without re-fetching everything
            QVariantList tempList = m_savedRoutes;
            for(int i=0; i<tempList.size(); ++i) {
                if(tempList[i].toMap()["id"].toInt() == routeId) {
                    tempList.removeAt(i);
                    break;
                }
            }
            m_savedRoutes = tempList;
            emit savedRoutesChanged();
        } else {
            emit errorOccurred("Failed to delete route");
        }
        reply->deleteLater();
    });
}

void RouteManager::loadSavedRoute(int routeId) {
    int userId = AppSettings::instance().getUserId();
    // GET /api/users/{user_id}/routes/{route_id}
    QString url = QString("/api/users/%1/routes/%2").arg(userId).arg(routeId);

    QNetworkReply* reply = ApiClient::instance().sendRequest(url, "GET");

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            parseRouteResponse(doc.object()); // Parse geometry and POIs

            // Signal that data is ready to view
            double dist = doc.object()["distance_km"].toDouble();
            int timeMinutes = static_cast<int>((dist / 5.0) * 60);
            emit routeGenerated(dist, timeMinutes);
        } else {
            emit errorOccurred("Failed to load route details");
        }
        reply->deleteLater();
    });
}

void RouteManager::renameRoute(int routeId, const QString& newName) {
    int userId = AppSettings::instance().getUserId();
    // Формируем URL согласно API RouteController::updateOne
    QString url = QString("/api/users/%1/routes/%2").arg(userId).arg(routeId);

    QJsonObject body;
    body["name"] = newName;

    QNetworkReply* reply = ApiClient::instance().sendRequest(url, "PATCH", body);

    connect(reply, &QNetworkReply::finished, this, [this, reply, routeId, newName]() {
        if (reply->error() == QNetworkReply::NoError) {
            // Обновляем локальный список сохраненных маршрутов, чтобы изменения сразу отразились в UI
            QVariantList tempList = m_savedRoutes;
            for(int i = 0; i < tempList.size(); ++i) {
                QVariantMap map = tempList[i].toMap();
                if(map["id"].toInt() == routeId) {
                    map["name"] = newName;
                    tempList[i] = map; // Записываем обновленный объект обратно
                    break;
                }
            }
            m_savedRoutes = tempList;
            emit savedRoutesChanged(); // Уведомляем QML об обновлении списка
        } else {
            emit errorOccurred("Failed to rename route: " + reply->errorString());
        }
        reply->deleteLater();
    });
}


