class ModelUser{
  String name;
  String password;
  String address;
  String phone_number;
  String email;

  ModelUser({ this.name,  this.password,this.address,this.phone_number,this.email});
   
  factory ModelUser.fromJson(Map<dynamic, dynamic> json) {
    return ModelUser()
      ..name = json['name'] as String
      ..password = json['password'] as String
      ..address = json['address'] as String
      ..phone_number = json['phone_number'] as String
      ..email = json['email'] as String;
      
  }
}