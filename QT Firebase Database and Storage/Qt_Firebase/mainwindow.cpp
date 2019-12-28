#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QFile>
#include <QNetworkAccessManager>
#include <QDebug>
#include <QFileDialog>
#include <mystorage.h>

#define PROJECT_ID "mama-menage"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    myStorage = new MyStorage(this, PROJECT_ID);
    connect(myStorage, SIGNAL(progressChanged(qint64,qint64,int)), this, SLOT(onProgressChanged(qint64,qint64,int)));
    connect(myStorage, SIGNAL(done()), this, SLOT(onDone()));

}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_pushButton_clicked()
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


