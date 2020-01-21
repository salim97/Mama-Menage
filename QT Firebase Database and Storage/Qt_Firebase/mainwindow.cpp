#include "dialogproducts.h"
#include "firebase_models.h"
#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QFile>
#include <QNetworkAccessManager>
#include <QDebug>
#include <QFileDialog>
#include <mystorage.h>
#include <myfirebasemanager.h>

#define PROJECT_ID "mama-menage"


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    myStorage = new MyStorage(this, PROJECT_ID);
    connect(myStorage, SIGNAL(progressChanged(qint64,qint64,int)), this, SLOT(onProgressChanged(qint64,qint64,int)));
    connect(myStorage, SIGNAL(done()), this, SLOT(onDone()));

    myFirebaseManager = new MyFirebaseManager("https://" PROJECT_ID ".firebaseio.com/");

    //    connect(myFirebaseManager, SIGNAL(dataIsReady(QNetworkReply*)), this, SLOT(dataIsReady(QNetworkReply*)));

    ui->tableWidget->setColumnCount(2);
    ui->tableWidget->setHorizontalHeaderLabels(QStringList() << "User Name"<<"Password");
    ui->tableWidget->horizontalHeader()->setStretchLastSection(true);

    readAllFromFirebase();
}

MainWindow::~MainWindow()
{
    delete ui;
}

//--------------------------Storage

void MainWindow::on_pushButton_upload_clicked()
{
    QFileDialog dialog(this);
    dialog.setNameFilter(tr("Images (*.png)"));
    dialog.setViewMode(QFileDialog::Detail);
    QString filePath= QFileDialog::getOpenFileName(this, tr("Open File"),
                                                   "C:/Users/unix/Downloads",
                                                   tr("Images (*.png)"));
    qDebug() << filePath ;
    myStorage->uploadImage(filePath);
}

void MainWindow::onProgressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage)
{
    ui->progressBar->setValue(percentage);
}

void MainWindow::onDone()
{
    ui->progressBar->setValue(100);
}


//--------------------------Database

void MainWindow::readAllFromFirebase()
{
    QNetworkReply::NetworkError error;
    error= myFirebaseManager->update();
    if(error != QNetworkReply::NoError)
    {
        qDebug() << Q_FUNC_INFO << error ;
        return;
    }


    QJsonObject json;

    //read all users
    json = myFirebaseManager->getChild(PATH_USERS);
    users.clear();
    foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
        Row_User row_User ;
        row_User.fromJSON(value.toObject());
        users.append(row_User);
    }

    //read all products
    json = myFirebaseManager->getChild(PATH_PRODUCTS);
    products.clear();
    foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
        Row_Product row_Product ;
        row_Product.fromJSON(value.toObject());
        products.append(row_Product);

    }

    //read all factures
    json = myFirebaseManager->getChild(PATH_FACTURES);
    factures.clear();
    foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
        Facture facture ;
        facture.fromJSON(value.toObject());
        factures.append(facture);

    }


    qDebug() << Q_FUNC_INFO;
    qDebug() << "users.length() =" << users.length() ;
    qDebug() << "products.length() =" << products.length() ;
    qDebug() << "factures.length() =" << factures.length() ;
//    foreach ( Facture f, factures) {
//        qDebug() << "------------------------";
//        qDebug() << f.createdAt;
//        qDebug() << f.user.toJSON();
//        qDebug() << f.client.toJSON();
//        qDebug() << f.products.length();
//        qDebug() << f.toJSON();
//    }
}

void MainWindow::writeAllFromFirebase()
{
    QNetworkReply::NetworkError error;
    Row_User row_User ;
    row_User.name="salim" ;
    row_User.password="123456" ;
    row_User.isPriceVisible=true ;

    error =  myFirebaseManager->setValue(PATH_USERS,row_User.toJSON());
    if(error != QNetworkReply::NoError)
    {
        qDebug() << Q_FUNC_INFO << error ;
        return;
    }



    Row_Client row_Client;
    row_Client.name = "client03" ;
    row_Client.phone = "06668569";
    row_Client.address = "Oran, belgaid";
    error = myFirebaseManager->setValue(PATH_CLIENTS,row_Client.toJSON());
    if(error != QNetworkReply::NoError)
    {
        qDebug() << Q_FUNC_INFO << error ;
        return;
    }
    QJsonArray arrayEmails ;
    arrayEmails.push_back("email01@mail.com");
    arrayEmails.push_back("email02@mail.com");
    arrayEmails.push_back("email03@mail.com");
    arrayEmails.push_back("email04@mail.com");
    QJsonObject recordObject;
    recordObject.insert(PATH_ADMIN_EMAILS, arrayEmails);
    error = myFirebaseManager->setValue("",recordObject);
    if(error != QNetworkReply::NoError)
    {
        qDebug() << Q_FUNC_INFO << error ;
        return;
    }

    return ;

    QByteArray image01DATA, image02DATA ;
    QList<Row_Product> row_Product ;
    row_Product.append(Row_Product("01", "furniture1", 5, 800, QList<Image>() << Image("image.png", image01DATA) << Image("image02.png", image02DATA),
                                       "detail detail detail"));
//    QString basePath = "d://Archive//GITHUB//SUDO-DEV//Mama-Menage//Android//mama_menage//assets//images//";

//    QList<Row_Product> row_Product ;
//    row_Product.append(Row_Product("furniture1", 5, 800, QStringList() << basePath+"furniture1.jpg",
//                                   "detail detail detail"));
//    row_Product.append(Row_Product("shoes1-3", 10, 300, QStringList() << basePath+"shoes1.jpg" << basePath+"shoes2.jpg" << basePath+"shoes3.jpg",
//                                   "detail detail detail"));
//    row_Product.append(Row_Product("clothes1-2", 15, 900, QStringList() << basePath+"clothes1.jpg"<< basePath+"clothes2.jpg",
//                                   "detail detail detail"));
//    row_Product.append(Row_Product("shoes4-7", 25, 1200,
//                                   QStringList() << basePath+"shoes4.jpg"<< basePath+"shoes5.jpg"<< basePath+"shoes8.jpg"<< basePath+"shoes7.jpg",
//                                   "detail detail detail"));
//    qDebug() << "Start uploading..." ;
//    DialogProducts dialogProducts(PROJECT_ID) ;
//    error = dialogProducts.uploadProducts(row_Product);
//    if(error != QNetworkReply::NoError)
//    {
//        qDebug() << Q_FUNC_INFO << error ;
//        return;
//    }


//    return ;

    //    {
    //        Row_Product row_Product ;
    //        row_Product.name="clothes1" ;
    //        row_Product.quantite=8 ;
    //        row_Product.price=300 ;
    //        myFirebaseManager->setValue(PATH_PRODUCTS, row_Product.toJSON());
    //    }

    //    {
    //        Row_Product row_Product ;
    //        row_Product.name="clothes1" ;
    //        row_Product.quantite=8 ;
    //        row_Product.price=300 ;
    //        row_Product.price=300 ;

    //        myFirebaseManager->setValue(PATH_PRODUCTS, row_Product.toJSON());
    //    }


    //        Row_Product row_Product ;
    //        row_Product.name="clothes1" ;
    //        row_Product.quantite=8 ;
    //        row_Product.price=300 ;
    //        myFirebaseManager->setValue(PATH_PRODUCTS, row_Product.toJSON());


    //    Facture facture ;
    //    facture.products.append(row_Product);
    //    facture.products.append(row_Product);
    //    facture.products.append(row_Product);
    //    facture.user = row_User;

    //    myFirebaseManager->setValue(PATH_FACTURES,facture.toJSON());



    //myFirebaseManager->setValue(PATH_USERS, ui->lineEdit_user_name->text(), ui->lineEdit_password->text());
}

void MainWindow::on_pushButton_add_clicked()
{

    writeAllFromFirebase();

}



//void MainWindow::dataIsReady(QNetworkReply *reply)
//{
//    QJsonObject json;
//    json = myFirebaseManager->getChild(PATH_USERS);
//    users.clear();
//    foreach(const QString& key, json.keys()) {
//        QJsonValue value = json.value(key);
//        Row_User row_User ;
//        row_User.fromJSON(value.toObject());
//        users.append(row_User);
//    }

//    json = myFirebaseManager->getChild(PATH_PRODUCTS);
//    products.clear();
//    foreach(const QString& key, json.keys()) {
//        QJsonValue value = json.value(key);
//        Row_Product row_Product ;
//        row_Product.fromJSON(value.toObject());
//        products.append(row_Product);

//    }
//    qDebug() << Q_FUNC_INFO;
//    qDebug() << "users.length() =" << users.length() ;
//    qDebug() << "products.length() =" << products.length() ;
//}

void MainWindow::on_pushButton_check_clicked()
{
    if(products.length() == 0 ) return ;
    DialogProducts dialogProducts(PROJECT_ID) ;
    QNetworkReply::NetworkError replay = dialogProducts.syncProducts(products);
    if(replay == QNetworkReply::NoError)
    {
        qDebug() << "done" ;
    }
    else
    {
        qDebug() << "ERRRRRROOOOOOOOOOOOR" ;
        qDebug() << replay ;
    }
}
