#include "include/network/ApiClient.h"
#include "include/utils/AppSettings.h"

ApiClient& ApiClient::instance() {
    static ApiClient _instance;
    return _instance;
}

ApiClient::ApiClient(QObject* parent) : QObject(parent) {
    m_manager = new QNetworkAccessManager(this);
}

QNetworkReply* ApiClient::sendRequest(const QString& endpoint, const QString& method, const QJsonObject& body, bool requireAuth) {
    QUrl url(m_baseUrl + endpoint);
    QNetworkRequest request(url);

    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");

    // Автоматически добавляем токен, если он нужен
    if (requireAuth) {
        QString token = AppSettings::instance().getToken();
        if (!token.isEmpty()) {
            request.setRawHeader("Authorization", "Bearer " + token.toUtf8());
        }
    }

    QByteArray data;
    if (!body.isEmpty()) {
        data = QJsonDocument(body).toJson();
    }

    if (method == "GET") return m_manager->get(request);
    if (method == "POST") return m_manager->post(request, data);
    if (method == "PUT") return m_manager->put(request, data);
    if (method == "DELETE") return m_manager->deleteResource(request);
    if (method == "PATCH") return m_manager->sendCustomRequest(request, "PATCH", data);

    return nullptr;
}
