import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';
import 'package:dio/dio.dart';
import '../models/order_model.dart';
import 'api.dart';
import 'log.dart';

class ApiServer implements Api {
  String? baseUrl = dotenv.env['API_BASE_URL_API_V1'];
  String? baseUrlForSendEmail = dotenv.env['API_BASE_URL'];
  Dio dio = Dio();
  late Log log;

  ApiServer(this.log);
  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final response = await dio.get('$baseUrl/products?limit=100');
      final List<dynamic> data = response.data['data']['products'];
      //print("Fetching API: $baseUrl/products?limit=100");
      //print("Response Data: ${response.data}");
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      print("API Fetch Prod Error: $e");
      rethrow;
    }
  }

  @override
  Future<dynamic> createCustomer(CustomerModel customer) async {
    try {
      final String url = '$baseUrl/customers';
      FormData formData = FormData.fromMap({
        'customer_id': customer.customerId,
        'customer_name': customer.customerName,
        'customer_email': customer.customerEmail,
        'customer_phone': customer.customerPhone,
        'customer_address': customer.customerAddress,
      });
      Response response = await dio.post(url,
          data: formData,
          options: Options(headers: {
            'accept': 'application/json',
            'Content-Type': 'multipart/form-data'
          }));
      return response.data;
    } catch (e) {
      print("API Create Cus Error: $e");
      rethrow;
    }
  }

  @override
  Future<dynamic> createOrder(OrderModel order) async {
    try {
      final String url = '$baseUrl/orders';
      FormData formData = FormData.fromMap({
        "customer_id": order.customerId,
        "order_total": order.orderTotal,
        "order_payment_method": order.orderPaymentMethod,
        "order_status": order.orderStatus,
        "order_note": order.orderNote
      });
      Response response = await dio.post(url,
          data: formData,
          options: Options(headers: {
            'accept': 'application/json',
            'Content-Type': 'multipart/form-data'
          }));
      return response.data;
    } catch (e) {
      print("API Create Order Error: ${e.toString()}");
      rethrow;
    }
  }
  @override
  Future<dynamic> sendOrderEmail({
    required String to,
    required String subject,
    required String text,
    required String html,
  }) async {
    try {
      final String url = '$baseUrlForSendEmail/send-email';
      print("📤 Sending email to: $to");
      print("📧 Subject: $subject");
      print("📜 Text: $text");
      print("📜 HTML: $html");

      final data = {
        'to': to,
        'subject': subject,
        'text': text,
        'html': html,
      };

      Response response = await dio.post(
        url,
        data: data,
        options: Options(headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        }),
      );

      print("✅ Email sent successfully: ${response.data}");
      return response.data;
    } catch (e) {
      print("❌ API Send Email Error: $e");
      rethrow;
    }
  }

}
