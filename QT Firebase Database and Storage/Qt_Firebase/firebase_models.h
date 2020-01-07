#ifndef FIREBASE_MODELS_H
#define FIREBASE_MODELS_H
#include <QJsonArray>
#include <QJsonObject>
#include <QObject>

#define PATH_USERS "users"
#define PATH_PRODUCTS "products"
#define PATH_FACTURES "factures"

class Row_User{
public:
    QString id, name, password, address, phone_number, email;
    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        addressObject.insert("name", name);
        addressObject.insert("password", password);
        addressObject.insert("address", address);
        addressObject.insert("phone_number", phone_number);
        addressObject.insert("email", email);
        recordObject.insert(id, addressObject);
        return recordObject;
    }
};

class Row_Product{
public:
    QString id, name, image_path;
    int quantite, price ;
    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        addressObject.insert("name", name);
        addressObject.insert("quantite", quantite);
        addressObject.insert("price", price);
        addressObject.insert("image_path", image_path);
        recordObject.insert(id, addressObject);
        return recordObject;
    }
};

class Facture{
public:
    QList<Row_Product> products;
    Row_User user ;
    QString id;
    QJsonObject toJSON()
    {
        QJsonObject recordObject;
        QJsonObject addressObject;
        QJsonArray productsArray;
        for(int i = 0 ; i < products.length() ; i++)
            productsArray.push_back(products[i].toJSON());
            //addressObject.insert(PATH_PRODUCTS, products[i].toJSON());
        addressObject.insert(PATH_PRODUCTS, productsArray);
        addressObject.insert(PATH_USERS, user.toJSON());

        recordObject.insert(id, addressObject);
        return recordObject;
    }


};

#endif // FIREBASE_MODELS_H
