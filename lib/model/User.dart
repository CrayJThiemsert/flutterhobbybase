import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/ObjectBase.dart';

class User {
//  final String key;
  String email = "";
  String role = "";
  bool sent_notification = true;

  String uid = "";
  String name = "";
  String rank = "";
  String area = "";

  Timestamp created_when = Timestamp.now();
  String created_by = "";
  Timestamp updated_when = Timestamp.now();
  String updated_by = "";
  bool active;

//  User(
////      this.key,
//      this.email,
//      this.role,
//      this.sent_notification,
//      this.uid,
//      this.name,
//      this.created_when,
//      this.created_by,
//      this.updated_when,
//      this.updated_by,
//      this.active);


  User( { this.email, this.name, this.active, this.uid, this.area, this.rank } ); //  User.fromSnapshot(
//      DataSnapshot snapshot) :
//      this.key = snapshot.key,
//      this.email = snapshot.email,
//      this.role = snapshot.role,
//      this.sent_notification = snapshot.sent_notification,
//      this.uid = snapshot.uid,
//      this.name = snapshot.name,
//      this.created_when = snapshot.created_when,
//      this.created_by = snapshot.created_by,
//      this.updated_when = snapshot.updated_when,
//      this.updated_by = snapshot.updated_by,
//      this.active = snapshot.value["active"];

//  User(this.email, this.role, this.sentNotification);

//  User.fromMap(Map<String, dynamic> map, {this.reference}) :
//        assert(map['email'] != null),
//        assert(map['role'] != null),
//        assert(map['sentNotification'] != null),
//        assert(map['reference'] != null),
//        email = map['email'],
//        role = map['role'],
//        sentNotification = map['sentNotification']);
//
//  User.fromSnapshot(DocumentSnapshot snapshot) :
//      this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "User[uid:${this.uid} email:${this.email} name:${this.name} rank:${this.rank} area:${this.area}]";

  factory User.fromMap(Map data) {
    return User(
        email: data['email'] ?? '',
//        String role = "";
//        bool sent_notification = true;

        uid: data['uid'] ?? '',
        name: data['username'] ?? '',
        area: data['area'] ?? '',
        rank: data['rank'] ?? '',
//    Timestamp created_when = Timestamp.now();
//    String created_by = "";
//    Timestamp updated_when = Timestamp.now();
//    String updated_by = "";
      active: data['active'] ?? false
    );
  }

  static Future<User> getUserDB(String uid) async {
    try {
//      String username = email.substring(0, email.indexOf('@'));
//      User user = new User(
//        email: email,
//        name: username,
//      );
      var db = Firestore.instance;

      var snap = await db.collection("users")
          .document(uid)
          .get();
      final User user = User.fromMap(snap.data);

      return user;
    } on Exception catch(err) {
      print('Get user error: $err');
      return User();
    } finally {

      print('End of getUserDB()');
    }
  }
}
