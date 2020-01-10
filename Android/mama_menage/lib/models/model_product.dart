import 'package:flutter/material.dart';

class ModelProduct{
  String imagePath;
  String name;
  num cost;
  int quantity;
  int selectedQuantity = 1 ;
  bool checked  ;
  get total => quantity * cost ;
 
  ModelProduct({ this.name,  this.cost = 0 ,  this.imagePath, this.checked = false, this.quantity = 1,});
   
  factory ModelProduct.fromJson(Map<dynamic, dynamic> json) {
    return ModelProduct()
      ..name = json['name'] as String
      ..quantity = json['quantite'] as num
      ..cost = json['price'] as num
      ..imagePath = json['image_remote_path'] as String;
      
  }
}