#include "include/controllers/MapManager.h"
#include "include/network/ApiClient.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QNetworkReply>

MapManager::MapManager(QObject* parent) : QObject(parent) {}

void MapManager::setLoading(bool val) {
    if (m_isLoading != val) {
        m_isLoading = val;
        emit isLoadingChanged();
    }
}

void MapManager::fetchMapSources() {
    setLoading(true);
    QNetworkReply* reply = ApiClient::instance().sendRequest("/api/map-sources", "GET");

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        setLoading(false);
        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            m_mapSources = doc.array().toVariantList();
            emit mapSourcesChanged();
        } else {
            // 404 is handled as empty list in your controller usually, but let's be safe
            if (reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 404) {
                m_mapSources.clear();
                emit mapSourcesChanged();
            } else {
                emit errorOccurred("Failed to fetch maps: " + reply->errorString());
            }
        }
        reply->deleteLater();
    });
}

void MapManager::downloadMap(const QString& name, const QString& url) {
    setLoading(true);
    QJsonObject body;
    body["name"] = name;
    body["url"] = url;

    QNetworkReply* reply = ApiClient::instance().sendRequest("/api/map-sources", "POST", body);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        setLoading(false);
        if (reply->error() == QNetworkReply::NoError) {
            emit operationSuccess("Map download started/completed.");
            fetchMapSources();
        } else {
            emit errorOccurred("Download failed: " + reply->errorString());
        }
        reply->deleteLater();
    });
}

void MapManager::cropMap(int sourceId, const QString& path, const QString& newName,
                         double left, double bottom, double right, double top) {
    setLoading(true);
    QJsonObject body;
    body["path"] = path;
    body["name"] = newName;
    body["left"] = left;
    body["bottom"] = bottom;
    body["right"] = right;
    body["top"] = top;

    QString endpoint = QString("/api/map-sources/%1/crop").arg(sourceId);
    QNetworkReply* reply = ApiClient::instance().sendRequest(endpoint, "POST", body);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        setLoading(false);
        if (reply->error() == QNetworkReply::NoError) {
            emit operationSuccess("Map cropped successfully.");
            fetchMapSources();
        } else {
            emit errorOccurred("Crop failed: " + reply->errorString());
        }
        reply->deleteLater();
    });
}

void MapManager::setMapStatus(int id, const QString& path, bool status) {
    // Optimistic update can be done here, but we will wait for server
    setLoading(true);
    QJsonObject body;
    body["status"] = status ? "true" : "false"; // Backend expects string "true"/"false" based on controller code
    body["path"] = path;

    QString endpoint = QString("/api/map-sources/%1").arg(id);
    // Using PATCH as defined in MapSourceController
    QNetworkReply* reply = ApiClient::instance().sendRequest(endpoint, "PATCH", body);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        setLoading(false);
        if (reply->error() == QNetworkReply::NoError) {
            emit operationSuccess("Status updated.");
            fetchMapSources(); // Refresh list to ensure consistency (single active map)
        } else {
            emit errorOccurred("Status update failed: " + reply->errorString());
            fetchMapSources(); // Revert UI on error
        }
        reply->deleteLater();
    });
}

void MapManager::deleteMapSource(int id) {
    setLoading(true);
    QString endpoint = QString("/api/map-sources/%1").arg(id);
    QNetworkReply* reply = ApiClient::instance().sendRequest(endpoint, "DELETE");

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        setLoading(false);
        if (reply->error() == QNetworkReply::NoError) {
            emit operationSuccess("Map source deleted.");
            fetchMapSources(); // Refresh list
        } else {
            emit errorOccurred("Failed to delete map: " + reply->errorString());
        }
        reply->deleteLater();
    });
}
