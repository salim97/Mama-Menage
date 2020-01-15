#include "myfirebasemanager.h"

#include <QFile>
#include <QTimer>

MyFirebaseManager::MyFirebaseManager(QString hostName, QObject *parent) : QObject(parent)
{
    m_hostName = hostName;
    myFirebase = new MyFirebase(hostName, this);
    connect(myFirebase, SIGNAL( eventResponseReady(QByteArray,QJsonObject,QString, bool,QNetworkReply*) ),
            this, SLOT( onEventResponseReady(QByteArray,QJsonObject,QString,bool,QNetworkReply*) ));
    connect(myFirebase, SIGNAL(networkStateChanged(bool)), this, SLOT(onNetworkAccessibleChanged(bool)));
     synchronous = new QEventLoop(this);
     lastReplayError = QNetworkReply::NoError ;
}

void MyFirebaseManager::onEventResponseReady(QByteArray replyData, QJsonObject replyJSON, QString url, bool isConnected, QNetworkReply *reply)
{
    //    qDebug() << "void MyFirebaseManager::onEventResponseReady(QByteArray replyData, QJsonObject replyJSON, QString url)" ;
    //    qDebug() << "url: " << url ;
    //    qDebug() << "isConnected: "<<isConnected ;
    //    qDebug() << "data: " << replyData ;
    if(url == m_hostName)
    {
        firebaseDB(replyJSON);
        lastReplayError = reply->error() ;
        synchronous->quit();
        emit dataIsReady(reply);
    }
    else
    {
        qDebug() << "void MyFirebaseManager::onEventResponseReady" ;
        qDebug() <<  "url: " << url;
        qDebug() << replyData  ;
        update();
    }
}

void MyFirebaseManager::onNetworkAccessibleChanged(bool isConnected)
{
    emit networkStateChanged(isConnected);
}


QNetworkReply::NetworkError MyFirebaseManager::update()
{
    myFirebase->setPath("");
    myFirebase->getValue();
    QTimer *timer = new QTimer(this);
    timer->setSingleShot(true);
    connect(timer, SIGNAL(timeout()), synchronous, SLOT(quit()) ); // chouf hna
    timer->start(4 * 1000);
    synchronous->exec();

    if(timer->isActive()) // chouf hna ( ida timer mazal yatmacha donc mafetch 4 second donc nkmel traitment
    {
        timer->stop();
        timer->deleteLater();
    }
    else                  // else donc fatet 4 second donc error time out
            return QNetworkReply::TimeoutError ;

    return lastReplayError ;
}


void MyFirebaseManager::deleteValue(QString child)
{
    myFirebase->setPath(child);
    myFirebase->deleteValue();
    update();
}

QNetworkReply::NetworkError MyFirebaseManager::setValue(QString path, QString node, QVariant str)
{


    myFirebase->setValue(path, node, str);

    QTimer *timer = new QTimer(this);
    timer->setSingleShot(true);
    connect(timer, SIGNAL(timeout()), synchronous, SLOT(quit()) ); // chouf hna
    timer->start(4 * 1000);
    synchronous->exec();

    if(timer->isActive()) // chouf hna ( ida timer mazal yatmacha donc mafetch 4 second donc nkmel traitment
    {
        timer->stop();
        timer->deleteLater();
    }
    else                  // else donc fatet 4 second donc error time out
            return QNetworkReply::TimeoutError ;

    return lastReplayError ;
}

QNetworkReply::NetworkError MyFirebaseManager::setValue(QString path, QJsonObject jsonObj)
{


    myFirebase->setValue(path, jsonObj);

    QTimer *timer = new QTimer(this);
    timer->setSingleShot(true);
    connect(timer, SIGNAL(timeout()), synchronous, SLOT(quit()) ); // chouf hna
    timer->start(4 * 1000);
    synchronous->exec();

    if(timer->isActive()) // chouf hna ( ida timer mazal yatmacha donc mafetch 4 second donc nkmel traitment
    {
        timer->stop();
        timer->deleteLater();
    }
    else                  // else donc fatet 4 second donc error time out
            return QNetworkReply::TimeoutError ;

    return lastReplayError ;
}

void MyFirebaseManager::setValue(QString strVal)
{
    myFirebase->setValue(strVal);
}

void MyFirebaseManager::rename(QString oldPath, QString newPath, QJsonObject jsonObj)
{
    deleteValue(oldPath);
    setValue(newPath, jsonObj);
}

QJsonObject MyFirebaseManager::getChild(QString path)
{
    QStringList childs = path.split("/");

    QJsonObject tmp = firebaseDB();
    for( int i = 0 ; i < childs.length() ; i++ )
    {
        if( tmp.value(childs.at(i)).isUndefined())
            return QJsonObject();
        tmp  = tmp.value(childs.at(i)).toObject();

    }
    return tmp ;
}




