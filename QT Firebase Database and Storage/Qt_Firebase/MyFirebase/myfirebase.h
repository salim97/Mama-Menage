#ifndef FIREBASE_H
#define FIREBASE_H

#include <QObject>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkRequest>
#include <QUrl>
#include <QUrlQuery>
#include <QDebug>
#include <QtGlobal>
#include <datasnapshot.h>
#include <QJsonObject>

class MyFirebase : public QObject
{
    Q_OBJECT
public:
    explicit MyFirebase(QString hostName, QObject *parent = nullptr);
    MyFirebase(QString hostName,QString child);
//    MyFirebase(QString hostName);

public slots:
    void init();

    void setValue(QString path, QString node, QVariant str);
    void setValue(QString path, QJsonObject jsonObj);
    void setValue(QString strVal);
    void getValue();
    void deleteValue();

    void setToken(QString);
    void listenEvents();
    MyFirebase* child(QString childName);
    void setPath(QString path) ;
    QString getPath();
signals:
    void eventResponseReady(QByteArray replyData, QJsonObject replyJSON, QString url, bool isConnected);
    void eventDataChanged(DataSnapshot*);
    void networkStateChanged(bool isConnectedToInternet);

private slots:
    void replyFinished(QNetworkReply*);
    void onReadyRead(QNetworkReply*);
    void eventFinished();
    void eventReadyRead();
    void onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility nam);

private:
    QString host;
    QString firebaseToken="";
    QNetworkAccessManager *manager;
    QString currentNode;
    QString latestNode;
    QString buildPath(int);
    QString createJson(QString);
    QString createJson(QString node, QVariant value);
    void open(const QUrl &url);
    QByteArray trimValue(const QByteArray &line) const;

    /*----- local system temp var ----*/
    QString m_hostname ;
};

#endif // FIREBASE_H
