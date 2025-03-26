import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meta/meta.dart';
import 'package:project_one/common/enum/load_status.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';
import '../cart/cart_cubit.dart';

part 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._api) : super(CheckoutState.init());
  final Api _api;

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
      // Chuẩn bị nội dung chi tiết sản phẩm cho email
      final orderDetails = selectedProducts
          .map((product) =>
              "${product.product_name} (Màu: ${product.product_color}) - SL: ${selectedQuantities[product.product_id] ?? 1} - ${product.product_price} đ")
          .join('<br>');

      final orderNote =
          '${selectedProducts.map((product) => "${product.product_name} (${product.product_color}) x ${selectedQuantities[product.product_id] ?? 1}").join('\n')}\nGhi chú: $note';

      // 1. Gửi email cho khách hàng
      await _api.sendOrderEmail(
        to: customer.customerEmail,
        subject: 'Xác nhận đơn hàng từ cửa hàng',
        text:
            'Cảm ơn bạn đã đặt hàng!\nTổng tiền: $totalPayment đ\nChi tiết:\n$orderNote',
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

      // 2. Gửi email cho admin
      final adminEmail =
          dotenv.env['EMAIL_ADMIN_RECEIVE_ORDER'] ?? 'admin@example.com';
      await _api.sendOrderEmail(
        to: adminEmail,
        subject: 'Đơn hàng mới từ ${customer.customerName}',
        text: 'Tổng tiền: $totalPayment đ\nChi tiết:\n$orderNote',
        html: '''
        <h2>Đơn hàng mới từ ${customer.customerName}</h2>
        <p><strong>Tổng tiền:</strong> $totalPayment đ</p>
        <p><strong>Khách hàng:</strong> ${customer.customerName}</p>
        <p><strong>Email:</strong> ${customer.customerEmail}</p>
        <p><strong>SĐT:</strong> ${customer.customerPhone}</p>
        <p><strong>Địa chỉ:</strong> ${customer.customerAddress}</p>
        <p><strong>Chi tiết đơn hàng:</strong><br>$orderDetails</p>
        ''',
      );
      print("Email sent to admin: $adminEmail");

      // 3. Xóa giỏ hàng sau khi gửi email thành công
      if (!context.mounted) return;
      await context.read<CartCubit>().clearProductInCart();
      emit(state.copyWith(loadStatus: LoadStatus.Done));
    } catch (e) {
      print('Error sending order email: $e');
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedMethod: method));
  }
}
