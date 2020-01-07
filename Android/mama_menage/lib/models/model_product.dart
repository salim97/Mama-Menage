import 'package:flutter/material.dart';

class ModelProduct{
  String imagePath;
  String name;
  double cost;
  int quantity;
  bool checked  ;
  get total => quantity * cost ;
  ModelProduct({@required this.name,  this.cost = 0.0 , @required this.imagePath, this.checked = false, this.quantity = 1,});
}