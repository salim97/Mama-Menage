#ifndef MYSTORAGE_H
#define MYSTORAGE_H

#include <QEventLoop>
#include <QFile>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkReply>
#include <QObject>

class MyStorage : public QObject
{
    Q_OBJECT
public:
    explicit MyStorage(QObject *parent = nullptr, QString PROJECT_ID = "");

    QString uploadImage(QString imagePath, QString fileName= "");
    QNetworkReply::NetworkError getListOfFiles();
      QStringList remoteFiles ;
signals:
    void progressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage);
    void done();
    void error(QNetworkReply::NetworkError);

public slots:
private slots:
    void progressChanged(qint64 bytesSent, qint64 bytesTotal);
    void onDone();
    void onError(QNetworkReply::NetworkError networkError);
private:
     QNetworkAccessManager *networkAccessManager;
     QString PROJECT_ID;
     QEventLoop *synchronous ;
};

#endif // MYSTORAGE_H
