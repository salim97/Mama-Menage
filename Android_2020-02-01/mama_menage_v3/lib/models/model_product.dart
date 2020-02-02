import 'package:flutter/material.dart';

class ModelProduct {
  // remote
  List<String> imagePath;
  String code;
  String name;
  String mark;
  String category;
  num cost;
  int quantity;
  String detail;
  String createdAt;

  //local
  int selectedQuantity = 1;
  bool checked;
  bool selectedProduct = false ;
  get total => quantity * cost;

  ModelProduct({
    this.name,
    this.cost = 0,
    this.imagePath,
    this.checked = false,
    this.quantity = 1,
  });

  factory ModelProduct.fromJson(Map<dynamic, dynamic> json) {
    ModelProduct tmp = new ModelProduct();
    tmp.code = json['code'] as String;
    tmp.name = json['name'] as String;
    tmp.mark = json['mark'] as String;
    tmp.category = json['category'] as String;
    tmp.detail = json['detail'] as String;
    tmp.createdAt = json['createdAt'] as String;
    tmp.quantity = json['quantite'] as num;
    tmp.cost = json['price'] as num;
    List<dynamic> a = json['image_remote_path'];
    if( a == null ) return null ;
    tmp.imagePath = new List<String>();
    a.forEach((e) {
      tmp.imagePath.add(e);
    });
    return tmp;
    // return ModelProduct()
    //   ..name = json['name'] as String
    //   ..quantity = json['quantite'] as num
    //   ..cost = json['price'] as num
    //   ..imagePath = json['image_remote_path'] as List<dynamic>;
  }

   Map<String, dynamic> toJson() =>
    {
      'code': code,
      'name': name,
      'mark': mark,
      'category': category,
      'detail': detail,
      'createdAt': createdAt,
      'quantite': selectedQuantity,
      'price': cost,
      'total': total
    };
}
