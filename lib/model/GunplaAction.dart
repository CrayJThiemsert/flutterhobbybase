import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/Gunpla.dart';
import 'package:hobbybase/model/ObjectBase.dart';

class GunplaAction {
//  final String key;
  Gunpla gunpla = Gunpla();
  bool is_liked = false;
  bool is_owned = false;
  bool is_shared = false;

  GunplaAction( { this.gunpla, this.is_liked, this.is_owned, this.is_shared } );

  @override
  String toString() => "GunplaAction[${this.gunpla.box_art_path}.: liked[${this.is_liked}] | owned[${this.is_owned}] | shared[${this.is_shared}]]";

  factory GunplaAction.fromMap(Map data) {
    return GunplaAction(
        gunpla: data['gunpla'] ?? Gunpla(),
        is_liked: data['is_liked'] ?? false,
        is_owned: data['is_owned'] ?? false,
        is_shared: data['is_shared'] ?? false
    );
  }
}
