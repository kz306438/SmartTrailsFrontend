#pragma once
#include <QObject>
#include <QSettings>

class AppSettings : public QObject {
    Q_OBJECT
public:
    static AppSettings& instance();

    void saveSession(int userId, const QString& token, const QString& role);
    void clearSession();

    int getUserId() const;
    QString getUserRole() const;
    QString getToken() const;
    bool hasToken() const;

private:
    explicit AppSettings(QObject* parent = nullptr);
    QSettings m_settings;
};
