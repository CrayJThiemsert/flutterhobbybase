import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/ObjectBase.dart';


class Grade {
  String name;
  String jsonpath;


  Grade(
      {this.name,
        this.jsonpath,
        });

  Grade.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    jsonpath = json['grade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['grade'] = this.jsonpath;
    return data;
  }
}


