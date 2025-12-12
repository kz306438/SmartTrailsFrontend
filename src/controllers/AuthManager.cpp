#include "include/controllers/AuthManager.h"
#include "include/network/ApiClient.h"
#include "include/utils/AppSettings.h"

#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>

AuthManager::AuthManager(QObject* parent) : QObject(parent) {}

void AuthManager::setLoading(bool val) {
    if (m_isLoading != val) {
        m_isLoading = val;
        emit isLoadingChanged();
    }
}

bool AuthManager::checkAutoLogin() {
    bool hasToken = AppSettings::instance().hasToken();
    if (hasToken) {
        // Восстанавливаем роль в память из настроек, чтобы QML ее видел
        m_userRole = AppSettings::instance().getUserRole();
        // Можно не эмитить сигнал, так как это инициализация, но для надежности:
        emit userRoleChanged();
    }
    return hasToken;
}

void AuthManager::login(const QString& email, const QString& password) {
    setLoading(true);
    QJsonObject body;
    body["email"] = email;
    body["password"] = password;

    // 1. Первый запрос: Логин для получения токена
    QNetworkReply* reply = ApiClient::instance().sendRequest("/auth/login", "POST", body, false);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        // Обрабатываем ответ логина внутри лямбды, чтобы не терять контекст
        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            auto obj = doc.object();

            QString token = obj["token"].toString();

            if (token.isEmpty()) {
                setLoading(false);
                emit loginFailed("Сервер не вернул токен");
            } else {
                AppSettings::instance().saveSession(0, token, "user");

                fetchUserInfo(token);
            }
        } else {
            setLoading(false);
            // Пытаемся достать текст ошибки из JSON ответа, если он есть
            QString errorMsg = "Ошибка входа: " + reply->errorString();
            auto doc = QJsonDocument::fromJson(reply->readAll());
            if (doc.isObject() && doc.object().contains("error")) {
                errorMsg = doc.object()["error"].toString();
            }
            emit loginFailed(errorMsg);
        }
        reply->deleteLater();
    });
}

void AuthManager::fetchUserInfo(const QString& currentToken) {
    QNetworkReply* reply = ApiClient::instance().sendRequest("/api/users/me", "GET", {}, true);

    connect(reply, &QNetworkReply::finished, this, [this, reply, currentToken]() {
        setLoading(false);

        if (reply->error() == QNetworkReply::NoError) {
            auto doc = QJsonDocument::fromJson(reply->readAll());
            auto obj = doc.object();

            if (obj.contains("id")) {
                int userId = obj["id"].toInt();

                QString role = obj.contains("role") ? obj["role"].toString() : "user";

                m_username = obj.value("username").toString();
                m_email = obj.value("email").toString();

                if (m_userRole != role) {
                    m_userRole = role;
                    emit userRoleChanged();
                }

                // Сохраняем в настройки вместе с ролью
                AppSettings::instance().saveSession(userId, currentToken, role);

                emit userDataChanged();
                emit loginSuccess();
            } else {
                AppSettings::instance().clearSession();
                emit loginFailed("Неверный ответ сервера (нет ID)");
            }
        } else {
            AppSettings::instance().clearSession();
            emit loginFailed("Ошибка профиля: " + reply->errorString());
        }
        reply->deleteLater();
    });
}
void AuthManager::registerUser(const QString& username, const QString& email, const QString& password) {
    setLoading(true);
    QJsonObject body;
    body["username"] = username;
    body["email"] = email;
    body["password"] = password;

    QNetworkReply* reply = ApiClient::instance().sendRequest("/auth/register", "POST", body, false);

    connect(reply, &QNetworkReply::finished, this, [this, reply]() {
        setLoading(false);
        if (reply->error() == QNetworkReply::NoError) {
            // Опционально: можно здесь тоже делать авто-логин, так как
            // AuthController::registerUser возвращает токен.
            // Но пока оставим просто уведомление об успехе.
            emit registerSuccess();
        } else {
            QString errorMsg = "Ошибка регистрации";
            auto doc = QJsonDocument::fromJson(reply->readAll());
            if (doc.isObject() && doc.object().contains("error")) {
                errorMsg = doc.object()["error"].toString();
            }
            emit registerFailed(errorMsg);
        }
        reply->deleteLater();
    });
}

void AuthManager::updateProfile(const QString& newUsername) {
    if (newUsername.isEmpty() || newUsername == m_username) {
        return; // Не отправляем, если имя пустое или не изменилось
    }

    setLoading(true);

    QJsonObject body;
    body["username"] = newUsername;

    // Отправляем PUT запрос на /api/users/me (требует токен = true)
    QNetworkReply* reply = ApiClient::instance().sendRequest("/api/users/me", "PUT", body, true);

    connect(reply, &QNetworkReply::finished, this, [this, reply, newUsername]() {
        setLoading(false);

        if (reply->error() == QNetworkReply::NoError) {
            // Успех: обновляем локальные данные
            m_username = newUsername;
            emit userDataChanged();
            qDebug() << "Profile updated successfully";
        } else {
            // Ошибка: можно эмитить сигнал ошибки, чтобы показать тост/уведомление
            QString err = "Failed to update profile: " + reply->errorString();
            qWarning() << err;
            // Опционально: можно вернуть старое имя в UI, если нужно
            emit userDataChanged();
        }
        reply->deleteLater();
    });
}

void AuthManager::logout() {
    AppSettings::instance().clearSession();
}
