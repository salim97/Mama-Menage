import 'package:mama_menage_v3/models/model_client.dart';

import 'model_product.dart';
import 'model_user.dart';

class ModelFacture {
  List<ModelProduct> products;
  ModelUser user;
  ModelClient client;
  String createdAt;
  bool valid;
  bool espece;
  bool par_cheque;
  int versement = 0;
  int crecue = 0;
  int total = 0;
  bool toSYNC= false;
  ModelFacture({this.user, this.products, this.createdAt});

  factory ModelFacture.fromJson(Map<dynamic, dynamic> json) {
    ModelFacture tmp = new ModelFacture();
    tmp.createdAt = json['createdAt'] as String;
    tmp.versement = json['versement'] as num;
    tmp.crecue = json['crecue'] as num;
    tmp.total = json['total'] as num;
    tmp.valid = json['valid'] as bool;
    tmp.espece = json['espece'] as bool;
    tmp.par_cheque = json['par_cheque'] as bool;
    tmp.client = ModelClient.fromJson(json['client']);
    tmp.user = ModelUser.fromJson(json['user']);
    tmp.products = new List<ModelProduct>();
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
      t.selectedQP = j['selectedQP'] as num;

      tmp.products.add(t);
    });

    return tmp;
  }

  Map<String, dynamic> toJson() {
    List<dynamic> array = new List<dynamic>();
    products.forEach((p) => array.add(p.toJson()));
    return {
      'createdAt': createdAt,
      'versement': versement,
      'crecue': crecue,
      'total': total,
      'valid': valid,
      'par_cheque': par_cheque,
      'espece': espece,
      'client': client.toJson(),
      'user': user.toJson(),
      'products': array,
    };
  }

  get date => DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt)).toString().split(" ").first;
  get time => DateTime.fromMillisecondsSinceEpoch(int.parse(createdAt)).toString().split(" ").last;
}
