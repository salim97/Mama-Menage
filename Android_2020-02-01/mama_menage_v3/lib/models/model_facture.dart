import 'package:mama_menage_v3/models/model_client.dart';

import 'model_product.dart';
import 'model_user.dart';

class ModelFacture {
  List<ModelProduct> products ;
  ModelUser user;
  ModelClient client;
  String createdAt;
  bool valid;
  ModelFacture({this.user, this.products, this.createdAt});

  factory ModelFacture.fromJson(Map<dynamic, dynamic> json) {
    ModelFacture tmp = new ModelFacture();
    tmp.createdAt = json['createdAt'] as String;
    tmp.valid = json['valid'] as bool;
    tmp.client = ModelClient.fromJson(json['client']);
    tmp.user = ModelUser.fromJson(json['user']);
tmp.products= new List<ModelProduct>();
    List<dynamic> mapResponse = json['products'];
    mapResponse?.forEach((key) async {
        Map<dynamic, dynamic> j = key;
        ModelProduct t = new ModelProduct();
        t.code = j['code'] as String;
        t.name = j['name'] as String;
        t.mark = j['mark'] as String;
        t.category = j['category'] as String;
        t.detail = j['detail'] as String;
        t.createdAt = j['createdAt'] as String;
        t.quantity = j['quantite'] as num;
        t.cost = j['price'] as num;

        tmp.products.add(t);
    });

    return tmp;
  }
}
