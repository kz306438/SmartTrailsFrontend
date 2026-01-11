#include "include/controllers/AdminManager.h"
#include "include/network/ApiClient.h"
#include <QJsonObject>
#include <QJsonDocument>
#include <QNetworkReply>

AdminManager::AdminManager(QObject* parent) : QObject(parent) {}

void AdminManager::fetchSystemMetrics() {
    QNetworkReply* reply = ApiClient::instance().sendRequest("/api/admin/metrics", "GET");

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        if (reply->error() == QNetworkReply::NoError) {
            auto json = QJsonDocument::fromJson(reply->readAll()).object();

            m_cpu = json["cpu"].toDouble();
            m_mem = json["memory"].toDouble();
            m_users = json["users"].toInt();

            emit metricsChanged();
        } else {
            emit errorOccurred("Failed to fetch metrics: " + reply->errorString());
        }
        reply->deleteLater();
    });
}
