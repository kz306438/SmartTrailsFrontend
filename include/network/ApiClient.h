#pragma once
#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonObject>
#include <QJsonDocument>

class ApiClient : public QObject {
    Q_OBJECT
public:
    static ApiClient& instance();

    QNetworkReply* sendRequest(const QString& endpoint,
                               const QString& method = "GET",
                               const QJsonObject& body = QJsonObject(),
                               bool requireAuth = true);

private:
    explicit ApiClient(QObject* parent = nullptr);
    QNetworkAccessManager* m_manager;
    const QString m_baseUrl = "http://127.0.0.1:8080";
};
