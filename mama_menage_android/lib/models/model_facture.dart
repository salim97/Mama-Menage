import 'model_product.dart';
import 'model_user.dart';

class ModelFacture{
  
  List<ModelProduct> products = new List<ModelProduct>();
  ModelUser user;
  DateTime dateTime;

  ModelFacture({ this.user,  this.products,this.dateTime});
   
  factory ModelFacture.fromJson(Map<dynamic, dynamic> json) {
    // ModelFacture()
    // return ModelFacture()
    //   ..name = json['name'] as String
    //   ..password = json['password'] as String
    //   ..address = json['address'] as String
    //   ..phone_number = json['phone_number'] as String
    //   ..email = json['email'] as String;
      
  }
}