#pragma once
#include <QObject>
#include <QVariantMap>

class AdminManager : public QObject {
    Q_OBJECT
    // Current metrics
    Q_PROPERTY(double cpuUsage READ cpuUsage NOTIFY metricsChanged)
    Q_PROPERTY(double memUsage READ memUsage NOTIFY metricsChanged)
    Q_PROPERTY(int userCount READ userCount NOTIFY metricsChanged)

public:
    explicit AdminManager(QObject* parent = nullptr);

    Q_INVOKABLE void fetchSystemMetrics();

    double cpuUsage() const { return m_cpu; }
    double memUsage() const { return m_mem; }
    int userCount() const { return m_users; }

signals:
    void metricsChanged();
    void errorOccurred(const QString& msg);

private:
    double m_cpu = 0.0;
    double m_mem = 0.0;
    int m_users = 0;
};
