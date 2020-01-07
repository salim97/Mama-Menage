#ifndef FIREBASE_MODELS_H
#define FIREBASE_MODELS_H
#include <QCryptographicHash>
#include <QJsonArray>
#include <QJsonObject>
#include <QObject>

#define PATH_USERS "users"
#define PATH_PRODUCTS "products"
#define PATH_FACTURES "factures"

class Row_User{
public:
    QString name, password, address, phone_number, email;
    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        addressObject.insert("name", name);
        addressObject.insert("password", password);
        addressObject.insert("address", address);
        addressObject.insert("phone_number", phone_number);
        addressObject.insert("email", email);

        recordObject.insert(getUniqID(), addressObject);
        return recordObject;
    }
    QString getUniqID()
    {
        return QString(QCryptographicHash::hash((QString(name+password).toUtf8()),QCryptographicHash::Sha256).toHex());
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
        }
        return true ;
    }
};

class Row_Product{
public:
    QString name, image_path;
    int quantite, price ;
    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        addressObject.insert("name", name);
        addressObject.insert("quantite", quantite);
        addressObject.insert("price", price);
        addressObject.insert("image_path", image_path);
        recordObject.insert(getUniqID(), addressObject);
        return recordObject;
    }
    QString getUniqID()
    {
        return QString(QCryptographicHash::hash((QString(name).toUtf8()),QCryptographicHash::Sha256).toHex());
    }

    bool fromJSON(QJsonObject jsonObject)
    {
        foreach(const QString& key, jsonObject.keys()) {
             QJsonValue value = jsonObject.value(key);
            if(key == "name") name = value.toString();
            if(key == "quantite") quantite = value.toInt();
            if(key == "price") price = value.toInt();
            if(key == "image_path") image_path = value.toString();
        }
        return true ;
    }
};

class Facture{
public:
    QList<Row_Product> products;
    Row_User user ;
    QJsonObject toJSON()
    {
        QString uniqID ;
        QJsonObject recordObject;
        QJsonObject addressObject;
        QJsonArray productsArray;
        for(int i = 0 ; i < products.length() ; i++)
        {
            productsArray.push_back(products[i].toJSON());
            uniqID += products[i].name ;
        }
        //addressObject.insert(PATH_PRODUCTS, products[i].toJSON());
        addressObject.insert(PATH_PRODUCTS, productsArray);
        addressObject.insert(PATH_USERS, user.toJSON());
        //generate uniq key in the tree

        uniqID += user.name+user.password;
        uniqID =  QString(QCryptographicHash::hash((uniqID.toUtf8()),QCryptographicHash::Sha256).toHex());
        recordObject.insert(uniqID, addressObject);
        //recordObject.insert(id, addressObject);
        return recordObject;
    }


};

#endif // FIREBASE_MODELS_H
