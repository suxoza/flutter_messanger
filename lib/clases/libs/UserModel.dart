import 'dart:convert';


/*
		permissions:
			1 => slots
			2 => shftReact
			3 => jobsPC
			4 => deskApp
	*/


User userFromJson(String str) {
  final jsonData = json.decode(str);
  return User.fromMap(jsonData);
}

String userToJson(User data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class User {
  int user_id;
  String firstName;
  String lastName;
  String user;
  Map<String, dynamic> permissions;


  User({
    this.user_id,
    this.firstName,
    this.lastName,
    this.user,
    this.permissions
  });

  factory User.fromMap(Map<String, dynamic> json) => new User(
    user_id: int.tryParse(json["user_id"]) as int,
    firstName: json["firstName"],
    lastName: json["lastName"],
    user: json["user"],
    permissions: json['permissions'] as Map<String, dynamic>
  );

  Map<String, dynamic> permToMap() => {
    "permissions" : json.encode(permissions)
  };

  List<int> permKeys(){
    Map<int, String> lst = {
        1: 'slots',
        2: 'shftReact',
        3: 'jobsPC',
        4: 'deskApp'
    };
    List<int> ret = [];
    lst.forEach((key, value){
        if(permissions[value] > 0){
          ret.add(key);
        }
    });
    return ret;
  }

  Map<String, dynamic> toMap() => {
    "user_id": user_id,
    "firstName": firstName,
    "lastName": lastName,
    "user": user
  };
}


Message MessageFromJson(String str) {
  final jsonData = json.decode(str);
  return Message.fromMap(jsonData);
}

class Message{
  int id;
  int perm;
  int favorited;
  int viewed;
  String insert_date;
  String title;
  String body;
  Message({this.id, this.perm, this.insert_date, this.title, this.body, this.favorited, this.viewed});

  factory Message.fromMap(Map<String, dynamic> json) => new Message(
    id: (json['id'] is int? json['id']: int.tryParse(json['id'])) as int,
    perm: (json['perm'] is int? json['perm']: int.tryParse(json['perm'])) as int,
    favorited: json['favorited'] as int,
    viewed: json['viewed'] as int,
    insert_date: json['insert_date'],
    title: json['title'],
    body: json['body']
  );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "perm": perm,
      "viewed": viewed,
      "favorited": favorited,
      "insert_date": insert_date,
      "title": title,
      "body": body
    };
  }
}