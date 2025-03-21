import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_one/common/enum/load_status.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';

import '../../../models/order_model.dart';

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
}
