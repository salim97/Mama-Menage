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
    myFirebaseManager->update();
    connect(myFirebaseManager, SIGNAL(dataIsReady()), this, SLOT(dataIsReady()));


    ui->tableWidget->setColumnCount(2);
    ui->tableWidget->setHorizontalHeaderLabels(QStringList() << "User Name"<<"Password");
    ui->tableWidget->horizontalHeader()->setStretchLastSection(true);


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

void MainWindow::on_pushButton_add_clicked()
{

    QString basePath = "d://Archive//GITHUB//SUDO-DEV//Mama-Menage//Android//mama_menage//assets//images//";

    QList<Row_Product> row_Product ;
    row_Product.append(Row_Product("shoes6", 10, 300, basePath+"shoes6.jpeg"));
    row_Product.append(Row_Product("clothes1", 15, 900, basePath+"clothes1.jpg"));
    row_Product.append(Row_Product("furniture1", 5, 800, basePath+"furniture1.jpg"));
    row_Product.append(Row_Product("shoes1", 25, 1200, basePath+"shoes1.jpg"));
    qDebug() << "Start uploading..." ;
    DialogProducts dialogProducts(PROJECT_ID) ;
    QNetworkReply::NetworkError replay = dialogProducts.uploadProducts(row_Product);
    if(replay == QNetworkReply::NoError)
    {
        qDebug() << "done" ;
    }
    else
    {
        qDebug() << replay ;
    }

    return ;
    //    Row_User row_User ;
    //    row_User.name="dfgdf" ;
    //    row_User.password="123456" ;
    //    row_User.address="oran" ;
    //    myFirebaseManager->setValue(PATH_USERS,row_User.toJSON());

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

void MainWindow::dataIsReady()
{

    QJsonObject json;
    json = myFirebaseManager->getChild(PATH_USERS);
    users.clear();
    foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
        Row_User row_User ;
        row_User.fromJSON(value.toObject());
        users.append(row_User);
    }

    json = myFirebaseManager->getChild(PATH_PRODUCTS);
    products.clear();
    foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
        Row_Product row_Product ;
        row_Product.fromJSON(value.toObject());
        products.append(row_Product);
    }

    qDebug() << Q_FUNC_INFO;
    qDebug() << "users.length() =" << users.length() ;
    qDebug() << "products.length() =" << products.length() ;


}
