#include "myfirebase.h"
#include <string.h>
#include <QIODevice>
#include <QBuffer>
#include <QJsonDocument>
#include <datasnapshot.h>

MyFirebase::MyFirebase(QString hostName, QObject *parent) :
    QObject(parent)
{
    m_hostname = hostName ;
    host=hostName;
    currentNode="";
    init();
}

void MyFirebase::init()
{
    manager=new QNetworkAccessManager(this);
    connect(manager,SIGNAL(finished(QNetworkReply*)),this,SLOT(replyFinished(QNetworkReply*)));
    connect(manager, SIGNAL(networkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)),
            this, SLOT(onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)));
}

void MyFirebase::onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility nam)
{
//    qDebug() << "void MyFirebase::onNetworkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility nam) ";
    if(nam == QNetworkAccessManager::UnknownAccessibility)
        emit networkStateChanged(false);
    if(nam == QNetworkAccessManager::NotAccessible)
        emit networkStateChanged(false);
    if(nam == QNetworkAccessManager::Accessible)
        emit networkStateChanged(true);
}

void MyFirebase::setToken(QString token)
{
    firebaseToken=token;
}

MyFirebase::MyFirebase(QString hostName,QString child)
{
    m_hostname = hostName ;
    host=hostName
            .append(child).append("/");
    latestNode=child;
    init();
}

MyFirebase* MyFirebase::child(QString childName)
{
    MyFirebase *childNode=new MyFirebase(host,childName);
    childNode->setToken(firebaseToken);
    return childNode;
}

void MyFirebase::setPath(QString path)
{
    host=m_hostname + path.trimmed()  ;
    latestNode=path;
}

QString MyFirebase::getPath()
{
    return host;
}

void MyFirebase::open(const QUrl &url)
{
    QNetworkRequest request(url);
    request.setRawHeader("Accept",
                         "text/event-stream");
    QNetworkReply *_reply = manager->get(request);
    connect(_reply, &QNetworkReply::readyRead, this, &MyFirebase::eventReadyRead);
    connect(_reply, &QNetworkReply::finished, this, &MyFirebase::eventFinished);
}
void MyFirebase::eventFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if (reply)
    {
        QUrl redirectUrl = reply->attribute(QNetworkRequest::RedirectionTargetAttribute).toUrl();
        if (!redirectUrl.isEmpty())
        {
            reply->deleteLater();
            open(redirectUrl);
            return;
        }
        reply->deleteLater();
    }
}
void MyFirebase::eventReadyRead()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply*>(sender());
    if(reply)
    {
        QByteArray line=reply->readLine();
        if(!line.isEmpty())
        {
            QByteArray eventName=trimValue(line);
            line=reply->readAll();
            if(eventName=="put")
            {
                DataSnapshot *dataSnapshot=new DataSnapshot(line);
                emit eventDataChanged(dataSnapshot);
            }
        }
    }
    reply->readAll();
}
void MyFirebase::onReadyRead(QNetworkReply *reply)
{
    /*qDebug()<<"incoming data";
    qDebug()<<reply->readAll();*/
}
void MyFirebase::replyFinished(QNetworkReply *reply)
{
    //qDebug()<<reply->readAll();
    QByteArray readAll = reply->readAll();
    QJsonDocument itemDoc = QJsonDocument::fromJson(readAll);
    QJsonObject rootObject = itemDoc.object();QJsonObject json;

    bool isConnectedToInternet = false ;
//    if(manager->networkAccessible() == QNetworkAccessManager::Accessible)
//        isConnectedToInternet = true ; NoError
    if (reply->error() == QNetworkReply::NoError)
        isConnectedToInternet = true;
    emit eventResponseReady(readAll, rootObject, reply->request().url().toString().replace(".json", ""), isConnectedToInternet, reply);


//    QString data=QString(reply->readAll());
//    emit eventResponseReady(data);
}
void MyFirebase::setValue(QString strVal)
{
    //Json data creation
    QNetworkRequest request(buildPath(1));
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");
    QBuffer *buffer=new QBuffer();
    buffer->open((QBuffer::ReadWrite));
    buffer->write(createJson(strVal).toUtf8());
    buffer->seek(0);
    /*
     * To be able to send "PATCH" request sendCustomRequest method is used.
     * sendCustomRequest requires a QIOdevice so QBuffer is used.
     * I had to seek 0 because it starts reading where it paused.
     */
    manager->sendCustomRequest(request,"PATCH",buffer);
    buffer->close();
}

void MyFirebase::setValue(QString path, QString node, QVariant strVal)
{
    //Json data creation
    QNetworkRequest request(m_hostname+path+".json");
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");
    QBuffer *buffer=new QBuffer();
    buffer->open((QBuffer::ReadWrite));
    buffer->write(createJson(node, strVal).toUtf8());
    buffer->seek(0);
    /*
     * To be able to send "PATCH" request sendCustomRequest method is used.
     * sendCustomRequest requires a QIOdevice so QBuffer is used.
     * I had to seek 0 because it starts reading where it paused.
     */
    manager->sendCustomRequest(request,"PATCH",buffer);
    buffer->close();
}

void MyFirebase::setValue(QString path, QJsonObject jsonObj)
{
    QJsonDocument jsonDoc(jsonObj);
    QByteArray jsonBA = jsonDoc.toJson(QJsonDocument::Compact);
    //Json data creation
    QNetworkRequest request(m_hostname+path+".json");
    request.setHeader(QNetworkRequest::ContentTypeHeader,
                      "application/x-www-form-urlencoded");
    QBuffer *buffer=new QBuffer();
    buffer->open((QBuffer::ReadWrite));
    buffer->write(jsonBA);
    buffer->seek(0);
    /*
     * To be able to send "PATCH" request sendCustomRequest method is used.
     * sendCustomRequest requires a QIOdevice so QBuffer is used.
     * I had to seek 0 because it starts reading where it paused.
     */
    manager->sendCustomRequest(request,"PATCH",buffer);
    buffer->close();
}

void MyFirebase::getValue()
{
    QNetworkRequest request(buildPath(0));
    manager->get(request);
}
void MyFirebase::listenEvents()
{
    open(buildPath(0));
}
void MyFirebase::deleteValue()
{
    QNetworkRequest request(buildPath(0));
    manager->deleteResource(request);
}
QString MyFirebase::createJson(QString str)
{
    QString data=QString(QString("{").append("\"").append(latestNode).append("\"").append(":").append("\"").append(str).append("\"").append(QString("}")));
    return data;
}
QString MyFirebase::createJson(QString node, QVariant value)
{
    QString data;
    if(QString(value.typeName()) == "bool")
    {
        QString tmp;

        if(value.toBool() == true)
            tmp = "true" ;
        else
            tmp = "false";

        data=QString(QString("{").append("\"").append(node).append("\"").append(":").append(tmp).append(QString("}")));
    }
    if(QString(value.typeName()) == "QString")
        data=QString(QString("{").append("\"").append(node).append("\"").append(":").append("\"").append(value.toString()).append("\"").append(QString("}")));

    return data;
}
QString MyFirebase::buildPath(int mode)
{
    QString destination="";
    if(mode)
    {
        host.replace(QString("/").append(latestNode).append("/"),"");
        destination
                .append(host)
                .append("/.json");
    }
    else
    {
        destination
                .append(host)
                .append(currentNode)
                .append(".json");

    }
    if(!firebaseToken.isEmpty())
        destination.append("?auth=").append(firebaseToken);
    return destination;

}
QByteArray MyFirebase::trimValue(const QByteArray &line) const
{
    QByteArray value;
    int index = line.indexOf(':');
    if (index > 0)
        value = line.right(line.size() - index  - 1);
    return value.trimmed();
}
