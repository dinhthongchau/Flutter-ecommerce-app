import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/order_model.dart';
import 'package:project_one/models/product_model.dart';

abstract class Api{
  Future<List<ProductModel>> getAllProducts();
  Future<dynamic> createCustomer(CustomerModel customer);
  Future<dynamic> createOrder(OrderModel order);
}