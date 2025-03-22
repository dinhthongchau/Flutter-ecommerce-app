import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';
import 'package:project_one/common/enum/load_status.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';

import '../../../models/customer_model.dart';
import '../../../models/order_model.dart';
import '../cart/cart_cubit.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._api) : super(CheckoutState.init());
  final Api _api;

  Future<void> submitOrder(OrderModel order) async {

    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      final response = await _api.createOrder(order);
      print("API Response: $response");
      emit(state.copyWith(loadStatus: LoadStatus.Done));
      print("OK");
    } catch (e) {
      print("Error $e ");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  String generateOrderNote(List<ProductModel> selectedItems,
      Map<int, int> selectedQuantities, String customerNote) {
    return "${selectedItems.asMap().entries.map((entry) {
      final index = entry.key + 1; // Đánh số SP từ 1
      final item = entry.value;
      final quantity =
          selectedQuantities[item.product_id] ?? 1; // Lấy số lượng từ Map

      return "SP$index: ${item.product_name} (Màu sắc: ${item.product_color}) SL: $quantity";
    }).join(',\n')}\nGhi chú của khách: $customerNote";
  }
  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedMethod: method));
  }

  Future<void> placeOrder({
    required BuildContext context,
    required CustomerModel customer,
    required List<ProductModel> selectedProducts,
    required Map<int, int> selectedQuantities,
    required double totalPayment,
    required String paymentMethod,
    required String note,
  }) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      // 1. Xác định ID khách hàng (nếu mới thì tạo)
      int customerId = customer.customerId;
      if (customerId == 0) {
        final customerResponse = await _api.createCustomer(customer);
        customerId = customerResponse['data']['customer']['customer_id'];
      }

      // 2. Tạo order
      final orderNote = selectedProducts
          .map((product) =>
      "${product.product_name} (${product.product_color}) x ${selectedQuantities[product.product_id] ?? 1}")
          .join('\n') +
          '\nGhi chú: $note';

      final order = OrderModel(
        customerId: customerId,
        orderTotal: totalPayment,
        orderPaymentMethod: paymentMethod,
        orderStatus: 'Ordered',
        orderNote: orderNote,
      );

      final orderResponse = await _api.createOrder(order);
      print("Order created: $orderResponse");

      // 3. Nội dung email
      final orderDetails = selectedProducts
          .map((product) =>
      "${product.product_name} (Màu: ${product.product_color}) - SL: ${selectedQuantities[product.product_id] ?? 1} - ${product.product_price} đ")
          .join('<br>');

      // 4. Gửi email cho khách hàng
      await _api.sendOrderEmail(
        to: customer.customerEmail,
        subject: 'Xác nhận đơn hàng từ cửa hàng',
        text: 'Cảm ơn bạn đã đặt hàng!\nTổng tiền: $totalPayment đ\nChi tiết:\n$orderNote',
        html: '''
        <h2>Xác nhận đơn hàng</h2>
        <p>Cảm ơn ${customer.customerName} đã đặt hàng tại cửa hàng chúng tôi!</p>
        <p><strong>Tổng tiền:</strong> $totalPayment đ</p>
        <p><strong>Phương thức thanh toán:</strong> $paymentMethod</p>
        <p><strong>Chi tiết đơn hàng:</strong><br>$orderDetails</p>
        <p>Chúng tôi sẽ xử lý đơn hàng của bạn sớm nhất.</p>
        <p>Liên hệ zalo/sdt 0888888888 nếu có thắc mắc hoặc yêu cầu thêm.</p>
      ''',
      );
      print("Email sent to customer: ${customer.customerEmail}");

      // 5. Gửi email cho admin
      final adminEmail = dotenv.env['EMAIL_ADMIN_RECEIVE_ORDER'] ?? 'admin@example.com';
      await _api.sendOrderEmail(
        to: adminEmail,
        subject: 'Đơn hàng mới từ ${customer.customerName}',
        text: 'Tổng tiền: $totalPayment đ\nChi tiết:\n$orderNote',
        html: '''
        <h2>Đơn hàng mới từ ${customer.customerName}</h2>
        <p><strong>ID Khách hàng:</strong> $customerId</p>
        <p><strong>Tổng tiền:</strong> $totalPayment đ</p>
        <p><strong>Khách hàng:</strong> ${customer.customerName}</p>
        <p><strong>Email:</strong> ${customer.customerEmail}</p>
        <p><strong>SĐT:</strong> ${customer.customerPhone}</p>
        <p><strong>Địa chỉ:</strong> ${customer.customerAddress}</p>
        <p><strong>Chi tiết đơn hàng:</strong><br>$orderDetails</p>
      ''',
      );
      print("Email sent to admin: $adminEmail");

      // 6. Xóa giỏ hàng sau khi đặt hàng thành công
      if (!context.mounted) return;
      await context.read<CartCubit>().clearProductInCart();
      emit(state.copyWith(loadStatus: LoadStatus.Done));

    } catch (e) {
      print('Error placing order: $e');
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

}