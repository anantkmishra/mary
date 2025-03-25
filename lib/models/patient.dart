import 'package:intl/intl.dart';

class Patient {
  final String id;
  final String name;
  final DateTime dob;

  Patient({required this.id, required this.name, required this.dob});

  factory Patient.fromJSON(Map<String, dynamic> json) {
    return Patient(
      id: json.containsKey('id') ? json["id"] : "",
      name: json.containsKey('name') ? json["name"] : "",
      dob:
          json.containsKey('birth_date')
              ? DateFormat("yyyy-MM-dd").parse(json["birth_date"])
              : DateTime.now(),
    );
  }
}
