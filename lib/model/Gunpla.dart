import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/ObjectBase.dart';


class Gunpla {
  String name;
  String grade;
  String box_art_path;
  String price_yen;
  String price_thb;
  String series;
  String desc;
  String scale;
  String isPBandai;
  String releasedWhen;
  String createdWhen;
  String updatedWhen;
  String janCode;

  Gunpla(
      {this.name,
        this.grade,
        this.box_art_path,
        this.price_yen,
        this.price_thb,
        this.series,
        this.desc,
        this.scale,
        this.isPBandai,
        this.releasedWhen,
        this.createdWhen,
        this.updatedWhen,
        this.janCode});

  Gunpla.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    grade = json['grade'];
    box_art_path = json['box_art_path'];
    price_yen = json['price_yen'];
    price_thb = json['price_thb'];
    series = json['series'];
    desc = json['desc'];
    scale = json['scale'];
    isPBandai = json['is_p_bandai'];
    releasedWhen = json['released_when'];
    createdWhen = json['created_when'];
    updatedWhen = json['updated_when'];
    janCode = json['jan_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['grade'] = this.grade;
    data['box_art_path'] = this.box_art_path;
    data['price_yen'] = this.price_yen;
    data['price_thb'] = this.price_thb;
    data['series'] = this.series;
    data['desc'] = this.desc;
    data['scale'] = this.scale;
    data['is_p_bandai'] = this.isPBandai;
    data['released_when'] = this.releasedWhen;
    data['created_when'] = this.createdWhen;
    data['updated_when'] = this.updatedWhen;
    data['jan_code'] = this.janCode;
    return data;
  }
}


//class Gunpla extends ObjectBase {
//  final String grade;
//  final String box_art_path;
//  final String price_yen;
//  final String price_thb;
//  final String series;
//  final String desc;
//  final String scale;
//  final String jan_code;
//
//  final bool is_p_bandai;
//  final Timestamp released_when;
//
//  Gunpla(
//      {this.grade,
//      this.box_art_path,
//      this.price_yen,
//      this.price_thb,
//      this.series,
//      this.desc,
//      this.scale,
//      this.jan_code,
//      this.is_p_bandai,
//      this.released_when})
//      : super.fromMap(null);
//
//  Gunpla.fromMap(Map<String, dynamic> map, {this.reference})
//      : assert(map['email'] != null),
//        assert(map['role'] != null),
//        assert(map['sentNotification'] != null),
//        assert(map['reference'] != null),
//        grade = map['email'],
//        box_art_path = map['role'],
//        is_p_bandai = map['sentNotification'],
//        super.fromMap(map);
//
//  Gunpla.fromSnapshot(DocumentSnapshot snapshot)
//      : this.fromMap(snapshot.data, reference: snapshot.reference);
//
//  @override
//  String toString() => "User[$uid: $grade]";
//}
