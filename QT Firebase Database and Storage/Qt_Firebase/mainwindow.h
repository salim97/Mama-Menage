#ifndef MAINWINDOW_H
#define MAINWINDOW_H

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


private slots:
    void on_pushButton_upload_clicked();
    void onProgressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage);
    void onDone();


    void on_pushButton_add_clicked();

    void dataIsReady();
private:
    Ui::MainWindow *ui;
    MyStorage *myStorage;
    MyFirebaseManager *myFirebaseManager;
};

#endif // MAINWINDOW_H
