#ifndef DIALOGPRODUCTS_H
#define DIALOGPRODUCTS_H

#include "firebase_models.h"
#include <QDialog>
#include <QEventLoop>
#include <QNetworkReply>
#include <myfirebasemanager.h>
#include <mystorage.h>

namespace Ui {
class DialogProducts;
}

class DialogProducts : public QDialog
{
    Q_OBJECT

public:
    explicit DialogProducts( QString PROJECT_ID, QWidget *parent = nullptr);
    ~DialogProducts();

    QNetworkReply::NetworkError uploadProducts(QList<Row_Product> products);
    QNetworkReply::NetworkError syncProducts(QList<Row_Product> products);
private slots:
    void onProgressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage);
    void onError(QNetworkReply::NetworkError networkError);
    void onDataIsReady();
private:
    Ui::DialogProducts *ui;
    MyStorage *myStorage;
    MyFirebaseManager *myFirebaseManager;
    QEventLoop *waitForFileToBeUploaded, *waitForDataToBeWriten;
    QNetworkReply::NetworkError networkError = QNetworkReply::NoError;
    QList<Row_Product> replayProducts ;
     QTimer *request_timer;
};

#endif // DIALOGPRODUCTS_H
