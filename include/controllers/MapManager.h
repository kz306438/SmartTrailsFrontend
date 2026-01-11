#pragma once
#include <QObject>
#include <QVariantList>

class MapManager : public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList mapSources READ mapSources NOTIFY mapSourcesChanged)
    Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

public:
    explicit MapManager(QObject* parent = nullptr);

    Q_INVOKABLE void fetchMapSources();
    Q_INVOKABLE void downloadMap(const QString& name, const QString& url);
    Q_INVOKABLE void cropMap(int sourceId, const QString& path, const QString& newName,
                             double left, double bottom, double right, double top);
    Q_INVOKABLE void setMapStatus(int id, const QString& path, bool status);
    Q_INVOKABLE void deleteMapSource(int id);

    QVariantList mapSources() const { return m_mapSources; }
    bool isLoading() const { return m_isLoading; }

signals:
    void mapSourcesChanged();
    void isLoadingChanged();
    void operationSuccess(const QString& msg);
    void errorOccurred(const QString& msg);

private:
    QVariantList m_mapSources;
    bool m_isLoading = false;
    void setLoading(bool val);
};
