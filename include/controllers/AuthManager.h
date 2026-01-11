#pragma once
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

class AuthManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)
    Q_PROPERTY(QString userRole READ userRole NOTIFY userRoleChanged)
    Q_PROPERTY(QString username READ username NOTIFY userDataChanged)
    Q_PROPERTY(QString email READ email NOTIFY userDataChanged)

public:
    explicit AuthManager(QObject* parent = nullptr);

    Q_INVOKABLE void login(const QString& email, const QString& password);
    Q_INVOKABLE void registerUser(const QString& username, const QString& email, const QString& password);
    Q_INVOKABLE void logout();
    Q_INVOKABLE bool checkAutoLogin();
    Q_INVOKABLE void updateProfile(const QString& newUsername);

    bool isLoading() const { return m_isLoading; }
    QString userRole() const { return m_userRole; }
    QString username() const { return m_username; }
    QString email() const { return m_email; }

signals:
    void isLoadingChanged();
    void loginSuccess();
    void loginFailed(const QString& message);
    void registerSuccess();
    void registerFailed(const QString& message);
    void userRoleChanged();
    void userDataChanged();

private:
    QString m_userRole;
    QString m_username;
    QString m_email;
    bool m_isLoading = false;
    void setLoading(bool val);
    void fetchUserInfo(const QString& currentToken);
};
