#include "dialogproducts.h"
#include "ui_dialogproducts.h"
#include "firebase_models.h"

#include <QThread>



DialogProducts::DialogProducts(QString PROJECT_ID, QWidget *parent) :
    QDialog(parent),
    ui(new Ui::DialogProducts)
{
    ui->setupUi(this);
    waitForFileToBeUploaded = new QEventLoop(this);
    myStorage = new MyStorage(this, PROJECT_ID);
    connect(myStorage, SIGNAL(progressChanged(qint64,qint64,int)), this, SLOT(onProgressChanged(qint64,qint64,int)));
    connect(myStorage, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(onError(QNetworkReply::NetworkError)));
    connect(myStorage, SIGNAL(done()), waitForFileToBeUploaded, SLOT(quit()));

    waitForDataToBeWriten = new QEventLoop(this);
    myFirebaseManager = new MyFirebaseManager("https://"+ PROJECT_ID+ ".firebaseio.com/");
    connect(myFirebaseManager, SIGNAL(dataIsReady()), this, SLOT(onDataIsReady()));
}

DialogProducts::~DialogProducts()
{
    delete ui;
}

QNetworkReply::NetworkError DialogProducts::uploadProducts(QList<Row_Product> products)
{
    show();
    qApp->processEvents(); // wait untill the dialog is printed to the screen
    ui->label_file_name->setText("UPLOADING");
    QString totalFiles = QString::number( products.length());

    ui->progressBar_total_uploaded->setMaximum(products.length());
    for( int i = 0 ; i < products.length() ; i++)
    {
        QFile currentFile(products.at(i).image_local_path)   ;
        qDebug() << currentFile.fileName() ;
        qDebug() << currentFile.size() ;

        //update UI
        ui->label_file_name->setText(currentFile.fileName());
        ui->label_current_total_size->setText("0 Byte / "+QString::number(currentFile.size())+" Byte");
        ui->label_current_index_total_files->setText(QString::number(i) +" / "+totalFiles);
        ui->progressBar_current_file->setValue(0);
        ui->progressBar_total_uploaded->setValue(i);
        qDebug() << "START UPLOADING FILE" ;
        // start uploading
        products[i].image_remote_path  = myStorage->uploadImage(currentFile.fileName());

        //        QTimer timer;
        //        timer.setSingleShot(true);
        //        connect( &timer, &QTimer::timeout, &loop, &QEventLoop::quit );
        //        timer.start(msTimeout);

        //wait until the upload is finnished
        waitForFileToBeUploaded->exec();
        qDebug() << "END UPLOADING FILE" ;
        if(networkError != QNetworkReply::NoError)
        {
            //there is been an error while uploading this file

            return networkError ; //exit point with error
        }
qDebug() << "START UPLOADING DATA" ;
        myFirebaseManager->setValue(PATH_PRODUCTS, products[i].toJSON());

        waitForDataToBeWriten->exec() ;
qDebug() << "END UPLOADING DATA" ;
        bool dataNotFound = true ;
        foreach (Row_Product p, replayProducts) {
            if(products[i].getUniqID() == p.getUniqID())
            {
                dataNotFound = false ;
                break ;
            }
        }
        if(dataNotFound)
        {
            return  QNetworkReply::ContentGoneError ;//exit point with error
        }
        //        if(timer.isActive())
        //            qDebug("encrypted");
        //        else
        //            qDebug("timeout");
    }
    close();
    return  QNetworkReply::NoError ;
}

QNetworkReply::NetworkError DialogProducts::syncProducts(QList<Row_Product> products)
{
    Q_UNUSED(products);
    return QNetworkReply::NoError ;
}

void DialogProducts::onProgressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage)
{
    qDebug() << bytesSent << bytesTotal ;
    ui->progressBar_current_file->setValue(percentage);
    ui->label_current_total_size->setText(QString::number(bytesSent)+" Byte / "+QString::number(bytesTotal)+ " Byte");

}

void DialogProducts::onError(QNetworkReply::NetworkError networkError)
{
    this->networkError = networkError;
    waitForFileToBeUploaded->quit();
}

void DialogProducts::onDataIsReady()
{

    QJsonObject json;

    json = myFirebaseManager->getChild(PATH_PRODUCTS);
    replayProducts.clear();
    foreach(const QString& key, json.keys()) {
        QJsonValue value = json.value(key);
        Row_Product row_Product ;
        row_Product.fromJSON(value.toObject());
        replayProducts.append(row_Product);
    }
    waitForDataToBeWriten->quit();
}
