#include "myfirebasemanager.h"

#include <QFile>

MyFirebaseManager::MyFirebaseManager(QString hostName, QObject *parent) : QObject(parent)
{
    m_hostName = hostName;
    myFirebase = new MyFirebase(hostName, this);
    connect(myFirebase, SIGNAL( eventResponseReady(QByteArray,QJsonObject,QString, bool) ),
            this, SLOT( onEventResponseReady(QByteArray,QJsonObject,QString,bool) ));
    connect(myFirebase, SIGNAL(networkStateChanged(bool)), this, SLOT(onNetworkAccessibleChanged(bool)));
}

void MyFirebaseManager::onEventResponseReady(QByteArray replyData, QJsonObject replyJSON, QString url, bool isConnected)
{
    //    qDebug() << "void MyFirebaseManager::onEventResponseReady(QByteArray replyData, QJsonObject replyJSON, QString url)" ;
    //    qDebug() << "url: " << url ;
    //    qDebug() << "isConnected: "<<isConnected ;
    //    qDebug() << "data: " << replyData ;
    if(url == m_hostName)
    {
        firebaseDB(replyJSON);
        emit dataIsReady();
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


void MyFirebaseManager::update()
{
    myFirebase->setPath("");
    myFirebase->getValue();
}


void MyFirebaseManager::deleteValue(QString child)
{
    myFirebase->setPath(child);
    myFirebase->deleteValue();
    update();
}

void MyFirebaseManager::setValue(QString path, QString node, QVariant str)
{
    myFirebase->setValue(path, node, str);
}

void MyFirebaseManager::setValue(QString path, QJsonObject jsonObj)
{
    myFirebase->setValue(path, jsonObj);
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




