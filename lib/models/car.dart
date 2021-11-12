import 'package:hive/hive.dart';
part "car.g.dart";

@HiveType(typeId: 0)
class Car {
  Car({
    required this.model,
    required this.description,
    required this.year,
    required this.images,
  });
  @HiveField(0)
  final String model;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final int year;
  @HiveField(3)
  final List<String> images;

  @override
  String toString() {
    return '$model : $year' + super.toString();
  }
}
