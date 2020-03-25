import 'package:cloud_firestore/cloud_firestore.dart';

class ObjectBase {
  final String uid;
  final String name;
  final Timestamp createdWhen;
  final String createdBy;
  final Timestamp updatedWhen;
  final String updatedBy;
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
        createdWhen = map['createdWhen'],
        createdBy = map['createdBy'],
        updatedWhen = map['updatedWhen'],
        updatedBy = map['updatedBy'],
        active = map['active'];

  ObjectBase.fromSnapshot(DocumentSnapshot snapshot) :
      this.fromMap(snapshot.data, reference: snapshot.reference);

}
