#include "dialogproducts.h"
#include "ui_dialogproducts.h"
#include "firebase_models.h"

#include <QThread>
#include <QTimer>


#define requestTIMEOUT 16000

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
    setWindowTitle("UPLOADING");
    ui->label_file_name->setText(windowTitle());
    show();
    qApp->processEvents(); // wait untill the dialog is printed to the screen

    //  QString totalFiles = QString::number( products.length());
    int totalFiles = 0 ;
    int currentFileFromTotal = 0 ;
    foreach (Row_Product p, products)
        totalFiles += p.image_local_path.length() ;

    ui->progressBar_total_uploaded->setMaximum(totalFiles);

    request_timer = new QTimer(this);
    request_timer->setSingleShot(true);
    connect(request_timer, SIGNAL(timeout()),  waitForFileToBeUploaded, SLOT(quit()) );

    for( int i = 0 ; i < products.length() ; i++)
    {
        products[i].image_remote_path.clear();
        for(int j = 0 ; j < products.at(i).image_local_path.length() ; j++)
        {
            request_timer->stop();
//            QFile currentFile(products.at(i).image_local_path.at(j))   ;
//            qDebug() << currentFile.fileName() ;
//            qDebug() << currentFile.size() ;

            //update UI
            ui->label_file_name->setText(products.at(i).image_local_path.at(j).fileName);
            ui->label_current_total_size->setText("0 Byte / "+QString::number(products.at(i).image_local_path.at(j).data.length())+" Byte");
            ui->label_current_index_total_files->setText(QString::number(currentFileFromTotal) +" / "+QString::number(totalFiles));
            ui->progressBar_current_file->setValue(0);
            ui->progressBar_total_uploaded->setValue(currentFileFromTotal);
            currentFileFromTotal++;

            qDebug() << "START UPLOADING FILE" ;
            // start uploading
//            products[i].image_remote_path  << myStorage->uploadImage(currentFile.fileName());
            products[i].image_remote_path  << Image(
                                                  myStorage->uploadImage(
                                                      products.at(i).image_local_path.at(j).fileName,
                                                      products.at(i).image_local_path.at(j).data), nullptr);

            request_timer->start(requestTIMEOUT);

            //wait until the upload is finnished
            waitForFileToBeUploaded->exec();
            qDebug() << "END UPLOADING FILE" ;

            if(request_timer->isActive())
                request_timer->stop();
            else
                    return QNetworkReply::TimeoutError ;
            if(networkError != QNetworkReply::NoError)
            {
                //there is been an error while uploading this file
                return networkError ; //exit point with error
            }
        }
        qDebug() << "START UPLOADING DATA" ;
        myFirebaseManager->setValue(PATH_PRODUCTS, products[i].toJSON());

        QTimer *timer = new QTimer(this);
        timer->setSingleShot(true);
        connect(timer, SIGNAL(timeout()),  waitForDataToBeWriten, SLOT(quit()) );
        timer->start(requestTIMEOUT);

        waitForDataToBeWriten->exec() ;
        qDebug() << "END UPLOADING DATA" ;
        QJsonObject json;
        json = myFirebaseManager->getChild(PATH_PRODUCTS);
        replayProducts.clear();
        foreach(const QString& key, json.keys()) {
            QJsonValue value = json.value(key);
            Row_Product row_Product ;
            row_Product.fromJSON(value.toObject());
            replayProducts.append(row_Product);
        }
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

        if(timer->isActive())
            timer->stop();
        else
                return QNetworkReply::TimeoutError ;

    }
    close();
    return  QNetworkReply::NoError ;
}

QNetworkReply::NetworkError DialogProducts::syncProducts(QList<Row_Product> products)
{
    setWindowTitle("Synchronisation");
    ui->label_file_name->setText(windowTitle());
    show();
    qApp->processEvents(); // wait untill the dialog is printed to the screen

    QNetworkReply::NetworkError readingFilesList = myStorage->getListOfFiles() ;
    if(readingFilesList != QNetworkReply::NoError)
    {
        close();
        return readingFilesList;
    }
    QStringList remoteFiles = myStorage->remoteFiles;

    //  QString totalFiles = QString::number( products.length());
    int totalFiles = 0 ;
    int currentFileFromTotal = 0 ;
    foreach (Row_Product p, products)
        totalFiles += p.image_local_path.length() ;

    request_timer = new QTimer(this);
    request_timer->setSingleShot(true);
    connect(request_timer, SIGNAL(timeout()),  waitForFileToBeUploaded, SLOT(quit()) );


    ui->progressBar_total_uploaded->setMaximum(totalFiles);
    for( int i = 0 ; i < products.length() ; i++)
    {
        int totalRemote = 0 ;

        for(int j = 0 ; j < products.at(i).image_local_path.length() ; j++)
        {
            request_timer->stop();
//            QFile currentFile(products.at(i).image_local_path.at(j))   ;


            //update UI
            ui->label_file_name->setText(products.at(i).image_local_path.at(j).fileName);
            ui->label_current_total_size->setText("0 Byte / "+QString::number(products.at(i).image_local_path.at(j).data.length())+" Byte");
            ui->label_current_index_total_files->setText(QString::number(currentFileFromTotal) +" / "+QString::number(totalFiles));
            ui->progressBar_current_file->setValue(0);
            ui->progressBar_total_uploaded->setValue(currentFileFromTotal);
            currentFileFromTotal++;

            if( j < products.at(i).image_remote_path.length()) ;
            if(remoteFiles.contains(products.at(i).image_remote_path.at(j).fileName))
            {
                totalRemote++;
                continue ;// don't upload,
            }

            qDebug() << "ERROOOR FILE NOT FOUND" ;
            qDebug() << products.at(i).image_local_path.at(j).fileName ;
            qDebug() << products.at(i).image_local_path.at(j).data.length() ;
            // start uploading
            products[i].image_remote_path  << Image(myStorage->uploadImage(products.at(i).image_local_path.at(j).fileName,
                                                                     products.at(i).image_local_path.at(j).data), nullptr);


            request_timer->setSingleShot(true);
            connect(request_timer, SIGNAL(timeout()),  waitForFileToBeUploaded, SLOT(quit()) );
            request_timer->start(requestTIMEOUT);

            //wait until the upload is finnished
            waitForFileToBeUploaded->exec();
            qDebug() << "END UPLOADING FILE" ;

            if(request_timer->isActive())
                request_timer->stop();
            else
                    return QNetworkReply::TimeoutError ;
            if(networkError != QNetworkReply::NoError)
            {
                //there is been an error while uploading this file
                return networkError ; //exit point with error
            }
        }

        if(totalRemote == products.at(i).image_local_path.length()) continue ;


        qDebug() << "START UPLOADING DATA" ;
        qDebug() << "ERROOOR DATA NOT FOUND" ;

        myFirebaseManager->setValue(PATH_PRODUCTS, products[i].toJSON());

        QTimer *timer = new QTimer(this);
        timer->setSingleShot(true);
        connect(timer, SIGNAL(timeout()),  waitForDataToBeWriten, SLOT(quit()) );
        timer->start(requestTIMEOUT);

        waitForDataToBeWriten->exec() ;
        qDebug() << "END UPLOADING DATA" ;
        bool dataNotFound = true ;
        QJsonObject json;
        json = myFirebaseManager->getChild(PATH_PRODUCTS);
        replayProducts.clear();
        foreach(const QString& key, json.keys()) {
            QJsonValue value = json.value(key);
            Row_Product row_Product ;
            row_Product.fromJSON(value.toObject());
            replayProducts.append(row_Product);
        }
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

        if(timer->isActive())
            timer->stop();
        else
                return QNetworkReply::TimeoutError ;

    }
    close();

    return QNetworkReply::NoError ;
}

void DialogProducts::onProgressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage)
{
    qDebug() << bytesSent << bytesTotal ;
    ui->progressBar_current_file->setValue(percentage);
    ui->label_current_total_size->setText(QString::number(bytesSent)+" Byte / "+QString::number(bytesTotal)+ " Byte");
    if(percentage != 100)
    {
        request_timer->stop();
        request_timer->start(requestTIMEOUT);
    }
}

void DialogProducts::onError(QNetworkReply::NetworkError networkError)
{
    this->networkError = networkError;
    waitForFileToBeUploaded->quit();
}

void DialogProducts::onDataIsReady()
{
    waitForDataToBeWriten->quit();
}
