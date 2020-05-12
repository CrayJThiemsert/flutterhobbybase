import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/ObjectBase.dart';

class GunplaComment {
  String uid = "";
  String comment = "";

  Timestamp created_when = Timestamp.now();
  String created_by = "";
  Timestamp updated_when = Timestamp.now();
  String updated_by = "";
  bool active;

  GunplaComment({
    this.uid,
    this.comment,
    this.created_when,
    this.created_by,
    this.updated_when,
    this.updated_by,
    this.active
  });

  @override
  String toString() => "GunplaComment[$uid: ${uid}] | comment[$comment]";

  factory GunplaComment.fromMap(Map data) {
    return GunplaComment(
        uid: data['uid'] ?? '',
        comment: data['comment'] ?? '',
        created_when: data['created_when'] ?? Timestamp.now(),
        created_by: data['created_by'] ?? '',
        updated_when: data['updated_when'] ?? Timestamp.now(),
        updated_by: data['updated_by'] ??  '',
        active: data['active'] ?? false);
  }

}
