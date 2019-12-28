#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
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
    void on_pushButton_clicked();
    void onProgressChanged(qint64 bytesSent, qint64 bytesTotal, int percentage);
    void onDone();

private:
    Ui::MainWindow *ui;
    MyStorage *myStorage;
};

#endif // MAINWINDOW_H
