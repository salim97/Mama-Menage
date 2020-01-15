#ifndef MYFIREBASEMANAGER_H
#define MYFIREBASEMANAGER_H

#include <QEventLoop>
#include <QObject>
#include "myfirebase.h"
#include "mypropertyhelper.h"

class MyFirebaseManager : public QObject
{
    Q_OBJECT
public:
    explicit MyFirebaseManager(QString hostName, QObject *parent = nullptr);



signals:
    void dataIsReady(QNetworkReply *reply);
    void networkStateChanged(bool isConnected);
//    void eventResponseReady(QByteArray replyData, QJsonObject replyJSON, QString url, bool isConnected);

public slots:

       QNetworkReply::NetworkError update();

    void deleteValue(QString child);
    QNetworkReply::NetworkError setValue(QString path, QString node, QVariant str);
    QNetworkReply::NetworkError setValue(QString path, QJsonObject jsonObj);
    void setValue(QString strVal);
    void rename(QString oldPath, QString newPath, QJsonObject jsonObj);
    QJsonObject getChild(QString path);

private slots:
    void onEventResponseReady(QByteArray replyData, QJsonObject replyJSON, QString url, bool isConnected, QNetworkReply *reply);
    void onNetworkAccessibleChanged(bool isConnected);

private:
    MyFirebase *myFirebase;
    QString m_hostName;

    QNetworkAccessManager networkAM;
    QEventLoop *synchronous ;
    QNetworkReply::NetworkError lastReplayError ;
    AUTO_PROPERTY(QJsonObject, firebaseDB)


};

#endif // MYFIREBASEMANAGER_H
