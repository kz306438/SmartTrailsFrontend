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

    // Основной метод отправки запросов
    QNetworkReply* sendRequest(const QString& endpoint,
                               const QString& method = "GET",
                               const QJsonObject& body = QJsonObject(),
                               bool requireAuth = true);

private:
    explicit ApiClient(QObject* parent = nullptr);
    QNetworkAccessManager* m_manager;
    // URL твоего бекенда (для локального теста на Android эмуляторе используй 10.0.2.2 вместо localhost)
    const QString m_baseUrl = "http://127.0.0.1:8080";
};
