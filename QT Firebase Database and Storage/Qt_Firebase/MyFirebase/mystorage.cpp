#include "mystorage.h"

#include <QFile>
#include <QNetworkAccessManager>
#include <QDebug>
#include <QFileDialog>
#include <QNetworkReply>
#include <QTimer>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>

MyStorage::MyStorage(QObject *parent, QString PROJECT_ID) : QObject(parent)
{
    networkAccessManager= new QNetworkAccessManager(this);
    this->PROJECT_ID = PROJECT_ID ;
     synchronous = new QEventLoop(this); // chouf hna

}


QString MyStorage::uploadImage(QString imagePath, QString fileName)
{

    QFile file(imagePath);
    if (!file.open(QIODevice::ReadWrite))
        return false;

    QByteArray dataToSend; // byte array to be sent in POST
    dataToSend = file.readAll();
    QString url ;
    if(fileName.isEmpty())
        fileName = imagePath.split("/").last() ;

    url = "https://firebasestorage.googleapis.com/v0/b/"+PROJECT_ID+".appspot.com/o?uploadType=media&name="+fileName;

    QNetworkRequest *request = new QNetworkRequest(QUrl(url));
    request->setRawHeader("Content-Type","image/png");
    request->setHeader(QNetworkRequest::ContentLengthHeader,dataToSend.size());
    //connect(networkAccessManager, SIGNAL(finished(QNetworkReply*)),this, SLOT(sendReportToServerReply(QNetworkReply*)));
    QNetworkReply *reply = networkAccessManager->post(*request,dataToSend);
    connect(reply, SIGNAL(finished()), this, SLOT(onDone()));
    connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(progressChanged(qint64, qint64)));
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), SLOT(onError(QNetworkReply::NetworkError)));

    return fileName ;
}


QNetworkReply::NetworkError MyStorage::getListOfFiles()
{
    remoteFiles.clear();
    QString url = "https://firebasestorage.googleapis.com/v0/b/"+PROJECT_ID+".appspot.com/o";



    QTimer *timer = new QTimer(this);
    timer->setSingleShot(true);

    QNetworkRequest *request = new QNetworkRequest(QUrl(url));
    QNetworkReply *reply = networkAccessManager->get(*request); // chouf hna , rselt HTTP request
    connect(reply, SIGNAL(finished()),                          synchronous, SLOT(quit())); // chouf hna
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)),  synchronous,SLOT(quit())); // chouf hna
    connect(timer, SIGNAL(timeout()),                           synchronous, SLOT(quit()) ); // chouf hna
    timer->start(4 * 1000);

    synchronous->exec(); // chouf hna, programme yhabess hna jusqua wahda men les slot foga tat executa w y3ayto
                         // : synchronous->quit() , bech ykhrej men exec

    if(timer->isActive()) // chouf hna ( ida timer mazal yatmacha donc mafetch 4 second donc nkmel traitment
    {
        timer->stop();
    }
    else                  // else donc fatet 4 second donc error time out
            return QNetworkReply::TimeoutError ;

    if(reply->error() != QNetworkReply::NoError) // ida response type ta3ha !=200 donc return error
        return reply->error() ;

    QString replyJSON = reply->readAll() ;  // ida wselt l hada le point c bn everything okey 9ra response

    QJsonDocument doc = QJsonDocument::fromJson(replyJSON.toUtf8());
    // check validity of the document
    if(!doc.isNull())
    {
        if(doc.isObject())
        {
            QJsonArray array = doc.object().value("items").toArray();
            foreach(const  QJsonValue &obj, array) {
                //QJsonValue value = obj.value(key);
//                qDebug() <<  obj.toObject().value("name");
                remoteFiles << obj.toObject().value("name").toString() ;
            }
            //files
        }
        else
        {
            qDebug() << "Document is not an object" << endl;
            return QNetworkReply::ContentConflictError;
        }
    }
    else
    {
        qDebug() << "Invalid JSON...\n" << replyJSON << endl;
        return QNetworkReply::ContentConflictError;
    }





    return QNetworkReply::NoError ;


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

void MyStorage::onError(QNetworkReply::NetworkError networkError)
{
    emit error(networkError) ;
}
