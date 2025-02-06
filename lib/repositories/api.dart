import 'package:project_one/models/product_model.dart';

abstract class Api{
  Future<List<ProductModel>> getAllProducts();
}