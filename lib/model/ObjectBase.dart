import 'package:cloud_firestore/cloud_firestore.dart';

class ObjectBase {
  final String uid;
  final String name;
  final Timestamp created_when;
  final String created_by;
  final Timestamp updated_when;
  final String updated_by;
  final bool active;
  final DocumentReference reference;

  ObjectBase.fromMap(Map<String, dynamic> map, {this.reference}) :
        assert(map['uid'] != null),
        assert(map['name'] != null),
        assert(map['createdWhen'] != null),
        assert(map['createdBy'] != null),
        assert(map['updatedWhen'] != null),
        assert(map['updatedWhen'] != null),
        assert(map['active'] != null),
        assert(map['reference'] != null),
        uid = map['uid'],
        name = map['name'],
        created_when = map['createdWhen'],
        created_by = map['createdBy'],
        updated_when = map['updatedWhen'],
        updated_by = map['updatedBy'],
        active = map['active'];

  ObjectBase.fromSnapshot(DocumentSnapshot snapshot) :
      this.fromMap(snapshot.data, reference: snapshot.reference);

}
