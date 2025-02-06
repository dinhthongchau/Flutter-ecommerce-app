import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/models/product_model.dart';
import 'package:dio/dio.dart';
import 'api.dart';
import 'log.dart';
class ApiServer implements Api{
  String? baseUrl =dotenv.env['API_BASE_URL'];
  Dio dio = Dio();
  late Log log;

  ApiServer(this.log);
  @override
  Future<List<ProductModel>> getAllProducts() async {
    try{
        final response = await dio.get('$baseUrl/products?limit=100');
        final List<dynamic> data=response.data['data']['products'];
        print("Fetching API: $baseUrl/products?limit=100");
        print("Response Data: ${response.data}");
        return data.map((json) => ProductModel.fromJson(json)).toList();

    }
    catch(e){
      print("API Fetch Error: $e");
      rethrow;
    }
  }

}