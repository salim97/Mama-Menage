#include "mystorage.h"

#include <QFile>
#include <QNetworkAccessManager>
#include <QDebug>
#include <QFileDialog>
#include <QNetworkReply>

MyStorage::MyStorage(QObject *parent, QString PROJECT_ID) : QObject(parent)
{
    networkAccessManager= new QNetworkAccessManager(this);
    this->PROJECT_ID = PROJECT_ID ;

}


bool MyStorage::uploadImage(QString imagePath, QString fileName)
{

    QFile file(imagePath);
    if (!file.open(QIODevice::ReadWrite))
        return false;

    QByteArray dataToSend; // byte array to be sent in POST
    dataToSend = file.readAll();
    QString url ;
    if(fileName.isEmpty())
        url = "https://firebasestorage.googleapis.com/v0/b/"+PROJECT_ID+".appspot.com/o?uploadType=media&name="+imagePath.split("/").last();
    else
        url = "https://firebasestorage.googleapis.com/v0/b/"+PROJECT_ID+".appspot.com/o?uploadType=media&name="+fileName;

    QNetworkRequest *request = new QNetworkRequest(QUrl(url));
    request->setRawHeader("Content-Type","image/png");
    request->setHeader(QNetworkRequest::ContentLengthHeader,dataToSend.size());
    //connect(networkAccessManager, SIGNAL(finished(QNetworkReply*)),this, SLOT(sendReportToServerReply(QNetworkReply*)));
    QNetworkReply *reply = networkAccessManager->post(*request,dataToSend);
    connect(reply, SIGNAL(finished()), this, SLOT(onDone()));
    connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(progressChanged(qint64, qint64)));
}

void MyStorage::progressChanged(qint64 bytesSent, qint64 bytesTotal)
{
    if(bytesTotal != 0 )
        emit progressChanged(bytesSent, bytesTotal, (bytesSent/bytesTotal)*100);
}

void MyStorage::onDone()
{
    emit done() ;
}
