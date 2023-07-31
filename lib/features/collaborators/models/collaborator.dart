import 'package:hive/hive.dart';

part 'collaborator.g.dart';

@HiveType(typeId: 0)
class Collaborator {
  @HiveField(0)
  String id;
  @HiveField(1)
  String name;
  @HiveField(2)
  int personalId;
  @HiveField(3)
  List<double> biometric;
  @HiveField(4)
  List<int> pic;
  @HiveField(5)
  String createdAt;
  @HiveField(6)
  bool faker;

  Collaborator(
      {required this.id,
      required this.name,
      required this.personalId,
      required this.biometric,
      required this.pic,
      required this.createdAt,
      required this.faker});


  factory Collaborator.fromJson(Map<String, dynamic> json) {
    return Collaborator(
      id: json['id'],
      name: json['name'],
      personalId: json['personalId'],
      biometric: List<double>.from(json['biometric'][0]),
      pic: List<int>.from(json['pic']['data']),
      createdAt: json['createdAt'],
      faker: json['faker'],
    );
  }
}
