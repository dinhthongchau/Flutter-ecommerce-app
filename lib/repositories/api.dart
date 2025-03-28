import 'package:file_picker/file_picker.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';

abstract class Api {
  Future<List<ProductModel>> getAllProducts();
  Future<dynamic> createCustomer(CustomerModel customer);
  Future<dynamic> sendOrderEmail({
    required String to,
    required String subject,
    required String text,
    required String html,
  });
  Future<dynamic> createProduct(ProductModel product,
      List<PlatformFile> imageFiles); // Đảm bảo sử dụng List<PlatformFile>
}
