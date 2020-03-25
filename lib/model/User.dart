import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/ObjectBase.dart';

class User extends ObjectBase {
  final String email;
  final String role;
  final bool sentNotification;

  final DocumentReference reference;

  User.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['email'] != null),
        assert(map['role'] != null),
        assert(map['sentNotification'] != null),
        assert(map['reference'] != null),
        email = map['email'],
        role = map['role'],
        sentNotification = map['sentNotification'], super.fromMap(map);

  User.fromSnapshot(DocumentSnapshot snapshot) :
      this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "User[$uid: $email]";

}
