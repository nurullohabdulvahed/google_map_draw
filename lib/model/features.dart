import 'dart:convert';

Features featuresFromJson(String str) => Features.fromJson(json.decode(str));

String featuresToJson(Features data) => json.encode(data.toJson());

class Features {
  List<Feature>? features;
  String? type;

  Features({
    this.features,
    this.type,
  });

  factory Features.fromJson(Map<String, dynamic> json) => Features(
    features: json["features"] == null ? [] : List<Feature>.from(json["features"]!.map((x) => Feature.fromJson(x))),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "features": features == null ? [] : List<dynamic>.from(features!.map((x) => x.toJson())),
    "type": type,
  };
}

class Feature {
  String? type;
  Properties? properties;
  Geometry? geometry;
  String? id;

  Feature({
    this.type,
    this.properties,
    this.geometry,
    this.id,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    type: json["type"],
    properties: json["properties"] == null ? null : Properties.fromJson(json["properties"]),
    geometry: json["geometry"] == null ? null : Geometry.fromJson(json["geometry"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "properties": properties?.toJson(),
    "geometry": geometry?.toJson(),
    "id": id,
  };
}

class Geometry {
  List<List<List<double>>>? coordinates;
  String? type;

  Geometry({
    this.coordinates,
    this.type,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => Geometry(
    coordinates: json["coordinates"] == null ? [] : List<List<List<double>>>.from(json["coordinates"]!.map((x) => List<List<double>>.from(x.map((x) => List<double>.from(x.map((x) => x?.toDouble())))))),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "coordinates": coordinates == null ? [] : List<dynamic>.from(coordinates!.map((x) => List<dynamic>.from(x.map((x) => List<dynamic>.from(x.map((x) => x)))))),
    "type": type,
  };
}

class Properties {
  int? level;
  String? name;
  int? height;
  int? baseHeight;
  String? color;

  Properties({
    this.level,
    this.name,
    this.height,
    this.baseHeight,
    this.color,
  });

  factory Properties.fromJson(Map<String, dynamic> json) => Properties(
    level: json["level"],
    name: json["name"],
    height: json["height"],
    baseHeight: json["base_height"],
    color: json["color"],
  );

  Map<String, dynamic> toJson() => {
    "level": level,
    "name": name,
    "height": height,
    "base_height": baseHeight,
    "color": color,
  };
}
