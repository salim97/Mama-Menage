#include "mainwindow.h"
#include <QApplication>

#define PROJECT_ID "mama-menage"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);



    MainWindow w;
    w.show();

    return a.exec();
}
