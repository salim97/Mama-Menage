#include "actionhandler.h"
#include <QUrl>
#include <myfirebase.h>
ActionHandler::ActionHandler()
{
    MyFirebase *firebase=new MyFirebase("https://test-ccd18.firebaseio.com/", this);
    firebase->listenEvents();
    connect(firebase,SIGNAL(eventResponseReady(QString)),this,SLOT(onResponseReady(QString)));
    connect(firebase,SIGNAL(eventDataChanged(DataSnapshot*)),this,SLOT(onDataChanged(DataSnapshot*)));
    //firebase->getValue();
    firebase->getValue();
    firebase->getValue();
}
void ActionHandler::onResponseReady(QString data)
{
    qDebug()<<"void ActionHandler::onResponseReady(QString data)";
    qDebug()<<data;
}
void ActionHandler::onDataChanged(DataSnapshot *data)
{
    qDebug()<<"void ActionHandler::onDataChanged(DataSnapshot *data)";
    qDebug()<<data->getDataMap();
}
