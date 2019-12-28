#ifndef MYSTORAGE_H
#define MYSTORAGE_H

#include <QFile>
#include <QNetworkAccessManager>
#include <QObject>

class MyStorage : public QObject
{
    Q_OBJECT
public:
    explicit MyStorage(QObject *parent = nullptr, QString PROJECT_ID = "");

    bool uploadImage(QString imagePath, QString fileName= "");
signals:
    void progressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage);
    void done();

public slots:
private slots:
    void progressChanged(qint64 bytesSent, qint64 bytesTotal);
    void onDone();
private:
     QNetworkAccessManager *networkAccessManager;
     QString PROJECT_ID;
};

#endif // MYSTORAGE_H
