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
    Row_User row_User ;
    row_User.id = "01" ;
    row_User.name="salim123" ;
    row_User.password="123456" ;
    row_User.address="oran" ;
    myFirebaseManager->setValue(PATH_USERS,row_User.toJSON());

    Row_Product row_Product ;
     row_Product.id = "01" ;
    row_Product.name="salim" ;

    row_Product.quantite=1 ;
    row_Product.price=300 ;
    myFirebaseManager->setValue(PATH_PRODUCTS, row_Product.toJSON());



    Facture facture ;
     facture.id = "01" ;
    facture.products.append(row_Product);
    facture.products.append(row_Product);
    facture.products.append(row_Product);
    facture.user = row_User;
    qDebug() << row_User.toJSON() ;
    myFirebaseManager->setValue(PATH_FACTURES,facture.toJSON());



    //myFirebaseManager->setValue(PATH_USERS, ui->lineEdit_user_name->text(), ui->lineEdit_password->text());
}

void MainWindow::dataIsReady()
{

    //qDebug() << Q_FUNC_INFO ;
    QJsonObject json = myFirebaseManager->getChild(PATH_USERS);
    //qDebug() << json;
    ui->tableWidget->setRowCount(0);
     foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
       // qDebug() << "Key = " << key << ", Value = " << value.toString();
        int row = ui->tableWidget->rowCount() ;
        ui->tableWidget->setRowCount(row+1);
         ui->tableWidget->setItem(row, 0, new QTableWidgetItem(key));
         ui->tableWidget->setItem(row, 1, new QTableWidgetItem( value.toString()));
    }


}
