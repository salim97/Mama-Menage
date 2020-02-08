#ifndef FIREBASE_MODELS_H
#define FIREBASE_MODELS_H
#include <QCryptographicHash>
#include <QJsonArray>
#include <QJsonObject>
#include <QObject>
#include <QDateTime>
#include <QDebug>

#define PATH_USERS "users"
#define PATH_PRODUCTS "products"
#define PATH_COMMANDES "commandes"
#define PATH_CLIENTS "clients"
#define PATH_ADMIN_EMAILS "admin_emails"

class Row_User{
public:
    QString name, password, address, phone_number, email;
    bool isPriceVisible = true;
    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        addressObject.insert("name", name);
        addressObject.insert("password", password);
        addressObject.insert("address", address);
        addressObject.insert("phone_number", phone_number);
        addressObject.insert("email", email);
        addressObject.insert("isPriceVisible", isPriceVisible);

        recordObject.insert(getUniqID(), addressObject);
        return recordObject;
    }
    QString getUniqID()
    {
        return QString(QCryptographicHash::hash((QString(name+password).toUtf8()),QCryptographicHash::Sha256).toHex());
    }
    QString pathDoc()
    {
        return QString(PATH_USERS)+"/"+getUniqID() ;
    }
    bool fromJSON(QJsonObject jsonObject)
    {
        foreach(const QString& key, jsonObject.keys()) {
            QJsonValue value = jsonObject.value(key);
            if(key == "name") name = value.toString();
            if(key == "password") password = value.toString();
            if(key == "address") address = value.toString();
            if(key == "phone_number") phone_number = value.toString();
            if(key == "email") email = value.toString();
            if(key == "isPriceVisible") isPriceVisible = value.toBool();
        }
        return true ;
    }
};

class Row_Client{
public:
    QString name, address, phone;
    QString gps_long, gps_lat;

    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        addressObject.insert("name", name);
        addressObject.insert("address", address);
        addressObject.insert("phone", phone);
        addressObject.insert("gps_long", gps_long);
        addressObject.insert("gps_lat", gps_lat);
        recordObject.insert(getUniqID(), addressObject);
        return recordObject;
    }
    QString getUniqID()
    {
        return QString(QCryptographicHash::hash((QString(name).toUtf8()),QCryptographicHash::Sha256).toHex());
    }
    QString pathDoc()
    {
        return QString(PATH_CLIENTS)+"/"+getUniqID() ;
    }
    bool fromJSON(QJsonObject jsonObject)
    {
        foreach(const QString& key, jsonObject.keys()) {
            QJsonValue value = jsonObject.value(key);
            if(key == "name") name = value.toString();
            if(key == "address") address = value.toString();
            if(key == "phone") phone = value.toString();
            if(key == "gps_long") gps_long = value.toString();
            if(key == "gps_lat") gps_lat = value.toString();
        }
        return true ;
    }
};

class Image{
public:
    QString fileName  ;
    QByteArray data ;
    Image(QString fileName, QByteArray data)
    {
        this->fileName = fileName ;
        this->data = data ;
    }
    Image()
    {
        this->fileName = nullptr ;
        this->data = nullptr ;
    }
};

class Row_Product{
public:

    QString code, name, detail, createdAt, mark, category;
    QList<int> qp;
    QList<Image> image_local_path, image_remote_path;
    int quantite = 0, price = 0 ;
    Row_Product(QString code,QString name, QList<int> qp, int quantite, int price, QList<Image> image_local_path,
                QString detail = "", QString createdAt = "", QString mark= "",QString category= "")
    {
        this->name = name;
        this->detail = detail;
        this->createdAt = createdAt.isEmpty() ? QString::number(QDateTime::currentSecsSinceEpoch()) : createdAt ;
        this->quantite = quantite;
        this->price = price;
        this->mark = mark;
        this->category = category;
        this->code = code;
        this->image_local_path = image_local_path;
        this->qp = qp ;
    }

    Row_Product()
    {
    }

    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        addressObject.insert("code", code);
        addressObject.insert("name", name);
        addressObject.insert("detail", detail);
        addressObject.insert("createdAt", createdAt);
        addressObject.insert("quantite", quantite);
        addressObject.insert("price", price);
        addressObject.insert("mark", mark);
        addressObject.insert("category", category);

        QJsonArray image_local_pathArray;
        for(int i = 0 ; i < image_local_path.length() ; i++)
            image_local_pathArray.push_back(image_local_path[i].fileName);
        addressObject.insert("image_local_path", image_local_pathArray);

        QJsonArray image_remote_pathArray;
        for(int i = 0 ; i < image_local_path.length() ; i++)
            image_remote_pathArray.push_back(image_remote_path[i].fileName);
        addressObject.insert("image_remote_path", image_remote_pathArray);

        QJsonArray qp_array;
        for(int i = 0 ; i < qp.length() ; i++)
            qp_array.push_back(qp[i]);
        addressObject.insert("qp", qp_array);

        recordObject.insert(getUniqID(), addressObject);
        return recordObject;
    }
    QString getUniqID()
    {
        return QString(QCryptographicHash::hash((QString(code).toUtf8()),QCryptographicHash::Sha256).toHex());
    }

    QString pathDoc()
    {
        return QString(PATH_PRODUCTS)+"/"+getUniqID() ;
    }

    bool fromJSON(QJsonObject jsonObject)
    {
        foreach(const QString& key, jsonObject.keys()) {
            QJsonValue value = jsonObject.value(key);
            if(key == "name") name = value.toString();
            if(key == "code") code = value.toString();
            if(key == "quantite") quantite = value.toInt();
            if(key == "price") price = value.toInt();
            if(key == "detail") detail = value.toString();
            if(key == "createdAt") createdAt = value.toString();
            if(key == "mark") mark = value.toString();
            if(key == "category") category = value.toString();

            if(key == "image_local_path")
            {
                image_local_path.clear();
                QJsonArray image_local_pathArray = value.toArray();
                for(int i = 0 ; i < image_local_pathArray.count() ; i++)
                    image_local_path << Image(image_local_pathArray.at(i).toString(), nullptr);
            }
            if(key == "image_remote_path")
            {
                image_remote_path.clear();
                QJsonArray image_remote_pathArray = value.toArray();
                for(int i = 0 ; i < image_remote_pathArray.count() ; i++)
                    image_remote_path << Image(image_remote_pathArray.at(i).toString(), nullptr);
            }
            if(key == "qp")
            {
                qp.clear();
                QJsonArray qp_array = value.toArray();
                for(int i = 0 ; i < qp_array.count() ; i++)
                    qp << qp_array.at(i).toInt();
            }

        }
        return true ;
    }
};

class Commande{
public:
    QString createdAt; // uniq for each commande
    QList<Row_Product> products;
    Row_User user ;
    Row_Client client;
    bool valid;
    QJsonObject toJSON()
    {
        if(createdAt.isEmpty())
            createdAt= QString::number(QDateTime::currentMSecsSinceEpoch())  ;

        QString uniqID ;
        QJsonObject recordObject;
        QJsonObject addressObject;
        QJsonArray productsArray;
        for(int i = 0 ; i < products.length() ; i++)
        {
            productsArray.push_back(products[i].toJSON());
            //uniqID += products[i].name ;
        }
        //addressObject.insert(PATH_PRODUCTS, products[i].toJSON());
        addressObject.insert(PATH_PRODUCTS, productsArray);
        addressObject.insert(PATH_USERS, user.toJSON());
        addressObject.insert(PATH_CLIENTS, client.toJSON());
        addressObject.insert("createdAt", createdAt);
        addressObject.insert("valid", valid);
        //generate uniq key in the tree

        uniqID = createdAt;
        uniqID =  QString(QCryptographicHash::hash(uniqID.toUtf8(),QCryptographicHash::Sha256).toHex());
        recordObject.insert(uniqID, addressObject);
        //recordObject.insert(id, addressObject);
        return recordObject;
    }
    bool fromJSON(QJsonObject jsonObject)
    {
        foreach(const QString& key, jsonObject.keys()) {
            QJsonValue value = jsonObject.value(key);

            if(key == "createdAt") createdAt = value.toString();
            if(key == "valid") valid = value.toBool();
            if(key == "client")
            {
                Row_Client tmp ;
                tmp.fromJSON(value.toObject());
                client = tmp ;
            }

            if(key == "user")
            {
                Row_User tmp ;
                tmp.fromJSON(value.toObject());
                user = tmp ;
            }

            if(key == "products")
            {
                products.clear();
                QJsonArray array_products = value.toArray();
                for(int i = 0 ; i < array_products.count() ; i++)
                {
                    Row_Product row_Product ;
                    row_Product.fromJSON(array_products.at(i).toObject());
                    products.append(row_Product);
                }
            }

        }
        return true ;
    }

    QString pathDoc()
    {
        return QString(PATH_COMMANDES)+"/"+createdAt ;
    }

};

#endif // FIREBASE_MODELS_H
