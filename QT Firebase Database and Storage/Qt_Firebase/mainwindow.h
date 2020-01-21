#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include "firebase_models.h"

#include <QMainWindow>
#include <myfirebasemanager.h>
#include <mystorage.h>

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();


    void readAllFromFirebase();
    void writeAllFromFirebase();
private slots:
    void on_pushButton_upload_clicked();
    void onProgressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage);
    void onDone();


    void on_pushButton_add_clicked();

    void dataIsReady(QNetworkReply *reply);
    void on_pushButton_check_clicked();

private:
    Ui::MainWindow *ui;
    MyStorage *myStorage;
    MyFirebaseManager *myFirebaseManager;
    QList<Row_User> users ;
    QList<Row_Product> products ;
    QList<Commande> commandes ;

};

#endif // MAINWINDOW_H
