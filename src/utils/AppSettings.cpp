#include "include/utils/AppSettings.h"

AppSettings& AppSettings::instance() {
    static AppSettings _instance;
    return _instance;
}

AppSettings::AppSettings(QObject* parent) : QObject(parent), m_settings("MyCompany", "SmartTrails") {}

void AppSettings::saveSession(int userId, const QString& token, const QString& role) {
    // ИСПРАВЛЕНО: auth/user_id -> auth/userId
    m_settings.setValue("auth/userId", userId);
    m_settings.setValue("auth/token", token);
    m_settings.setValue("auth/role", role);
}

QString AppSettings::getUserRole() const {
    return m_settings.value("auth/role", "user").toString();
}

void AppSettings::clearSession() {
    m_settings.remove("auth/userId");
    m_settings.remove("auth/token");
    m_settings.remove("auth/role");
}

int AppSettings::getUserId() const {
    return m_settings.value("auth/userId", -1).toInt();
}

QString AppSettings::getToken() const {
    return m_settings.value("auth/token", "").toString();
}

bool AppSettings::hasToken() const {
    return !getToken().isEmpty();
}
