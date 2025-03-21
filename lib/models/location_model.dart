// lib/models/location_model.dart
class Province {
  final String id;
  final String name;
  final List<District> districts;

  Province({required this.id, required this.name, required this.districts});

  factory Province.fromJson(Map<String, dynamic> json) {
    var districtList = json['Districts'] as List<dynamic>? ?? [];
    List<District> districts =
        districtList.map((d) => District.fromJson(d)).toList();
    return Province(
      id: json['Id'] as String? ?? 'Unknown ID', // Default value if null
      name: json['Name'] as String? ?? 'Unknown Name', // Default value if null
      districts: districts,
    );
  }
}

class District {
  final String id;
  final String name;
  final List<Ward> wards;

  District({required this.id, required this.name, required this.wards});

  factory District.fromJson(Map<String, dynamic> json) {
    var wardList = json['Wards'] as List<dynamic>? ?? [];
    List<Ward> wards = wardList.map((w) => Ward.fromJson(w)).toList();
    return District(
      id: json['Id'] as String? ?? 'Unknown ID', // Default value if null
      name: json['Name'] as String? ?? 'Unknown Name', // Default value if null
      wards: wards,
    );
  }
}

class Ward {
  final String id;
  final String name;
  final String? level;

  Ward({required this.id, required this.name, this.level});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['Id'] as String? ?? 'Unknown ID', // Default value if null
      name: json['Name'] as String? ?? 'Unknown Name', // Default value if null
      level: json['Level'] as String?, // Already nullable, no change needed
    );
  }
}
