#pragma once
#include <QObject>
#include <QVariantList>

class PoiManager : public QObject {
    Q_OBJECT
    // Свойство для QML: список типов POI (каждый элемент — объект {id, name})
    Q_PROPERTY(QVariantList poiTypes READ poiTypes NOTIFY poiTypesChanged)

public:
    explicit PoiManager(QObject* parent = nullptr);

    // Метод для загрузки типов с бэкенда
    Q_INVOKABLE void fetchPoiTypes();

    QVariantList poiTypes() const { return m_poiTypes; }

signals:
    void poiTypesChanged();
    void errorOccurred(const QString& msg);

private:
    QVariantList m_poiTypes;
};
