#include "include/controllers/PoiManager.h"
#include <QJsonArray>
#include <QJsonObject>
#include <QNetworkReply>
#include "include/network/ApiClient.h"

PoiManager::PoiManager(QObject* parent) : QObject(parent) {}

void PoiManager::fetchPoiTypes() {
    // GET запрос на /api/poi-type
    QNetworkReply* reply = ApiClient::instance().sendRequest("/api/poi-type", "GET");

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            if (doc.isArray()) {
                m_poiTypes = doc.array().toVariantList();
                emit poiTypesChanged();
            }
        } else {
            emit errorOccurred("Failed to load POI types: " + reply->errorString());
        }
        reply->deleteLater();
    });
}
