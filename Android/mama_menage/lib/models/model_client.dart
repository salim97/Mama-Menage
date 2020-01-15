class ModelClient{
  String name;
  String address;
  String phone;
  String gps_long;
  String gps_lat ;
  ModelClient({ this.name,this.address,this.phone,this.gps_long,this.gps_lat});
   
  factory ModelClient.fromJson(Map<dynamic, dynamic> json) {
    return ModelClient()
      ..name = json['name'] as String
      ..address = json['address'] as String
      ..phone = json['phone'] as String
      ..gps_long = json['gps_long'] as String
      ..gps_lat = json['gps_lat'] as String;
  }

   Map<String, dynamic> toJson() =>
    {
      'name': name,
      'address': address,
      'phone': phone,
      'gps_long': gps_long,
      'gps_lat': gps_lat,
    };
}