import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/ObjectBase.dart';

class Owned {
  String uid = "";
  String name = "";
  String box_art_path = "";
  bool is_liked = false;
  bool is_owned = false;
  bool is_shared = false;

  Timestamp created_when = Timestamp.now();
  String created_by = "";
  Timestamp updated_when = Timestamp.now();
  String updated_by = "";
  bool active;

  Owned({
    this.uid,
    this.name,
    this.box_art_path,
    this.is_liked,
    this.is_owned,
    this.is_shared,
    this.created_when,
    this.created_by,
    this.updated_when,
    this.updated_by,
    this.active
  });

  @override
  String toString() => "Owned[$uid: ${uid}] | box_art_path[$box_art_path] | is_liked[${is_liked}] | is_owned[${is_owned}] | is_shared[${is_shared}]";

  factory Owned.fromMap(Map data) {
    return Owned(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        box_art_path: data['box_art_path'] ?? '',
        is_liked: data['is_liked'] ?? false,
        is_owned: data['is_owned'] ?? false,
        is_shared: data['is_shared'] ?? false,
        created_when: data['created_when'] ?? Timestamp.now(),
        created_by: data['created_by'] ?? '',
        updated_when: data['updated_when'] ?? Timestamp.now(),
        updated_by: data['updated_by'] ??  '',
        active: data['active'] ?? false);
  }

}
