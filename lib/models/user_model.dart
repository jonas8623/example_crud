

class UserModel {

  int? id;
  String? name;
  String? email;
  int? age;

  UserModel({this.id, this.name, this.email, this.age});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    age = json['age'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'name': name,
      'email': email,
      'age': age
    };
  }

}