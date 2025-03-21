// lib/services/location_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/location_model.dart';

class LocationService {
  static const String url =
      "https://raw.githubusercontent.com/kenzouno1/DiaGioiHanhChinhVN/master/data.json";
  final Dio _dio = Dio();

  Future<List<Province>> fetchProvinces() async {
    try {
      final response = await _dio.get(url,
          options: Options(
              responseType: ResponseType.plain)); // Use plain to ensure String
      print("Response status code: ${response.statusCode}");
      print("Raw response data type: ${response.data.runtimeType}");
      print(
          "Raw response data content: ${response.data.substring(0, 500)}..."); // Limit log size

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw Exception("Response data is null");
        }
        final data = response.data;
        List<dynamic> jsonData;

        if (data is String) {
          jsonData = jsonDecode(data);
        } else {
          throw Exception("Unexpected data type: ${data.runtimeType}");
        }

        return jsonData.map((json) {
          if (json['Id'] == null || json['Name'] == null) {
            print("Warning: Null value found in JSON: $json");
          }
          return Province.fromJson(json);
        }).toList();
      } else {
        throw Exception("Failed to load provinces: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching provinces: $e");
      rethrow;
    }
  }
}
