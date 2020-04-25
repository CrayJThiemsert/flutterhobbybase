import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hobbybase/model/ObjectBase.dart';


class Grade {
  String name;
  String jsonpath;
  int totalOwned;


  Grade(
      {this.name,
        this.jsonpath,
        this.totalOwned
        });

  Grade.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    jsonpath = json['grade'];
    totalOwned = json['totalOwned'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['grade'] = this.jsonpath;
    data['totalOwned'] = this.totalOwned;
    return data;
  }
}


