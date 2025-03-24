import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:project_one/common/enum/load_status.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/services/storage_service.dart';
import 'package:project_one/common/code/random.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final StorageService _storage = StorageService();

  CustomerCubit() : super(const CustomerState.init()) {
    loadCustomer(); // Tự động load dữ liệu khi khởi tạo
  }

  /// Load thông tin khách hàng từ SharedPreferences
  Future<void> loadCustomer() async {
    try {
      final customerJson = await _storage.getString('customer');
      if (customerJson != null) {
        final customerMap = jsonDecode(customerJson);
        final customer = CustomerModel.fromJson(customerMap);
        emit(state.copyWith(
          loadStatus: LoadStatus.Done,
          idCustomer: customer.customerId,
          customer: [customer],
        ));
      } else {
        emit(state.copyWith(loadStatus: LoadStatus.Init));
      }
    } catch (e) {
      print("Error loading customer: $e");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  /// Tạo khách hàng mới và lưu vào SharedPreferences
  Future<void> createCustomer(CustomerModel customer) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      final customerId = generateRandomId(); // Sinh ID ngẫu nhiên
      final newCustomer = CustomerModel(
        customerId: customerId,
        customerName: customer.customerName,
        customerEmail: customer.customerEmail,
        customerPhone: customer.customerPhone,
        customerAddress: customer.customerAddress,
      );

      final customerJson = jsonEncode(newCustomer.toJson());
      await _storage.saveString('customer', customerJson);

      emit(state.copyWith(
        loadStatus: LoadStatus.Done,
        idCustomer: customerId,
        customer: [newCustomer],
      ));
    } catch (e) {
      print("Error creating customer: $e");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  /// Cập nhật thông tin khách hàng và lưu lại vào SharedPreferences
  Future<void> updateCustomer(CustomerModel updatedCustomer) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try {
      final customerJson = jsonEncode(updatedCustomer.toJson());
      await _storage.saveString('customer', customerJson);

      emit(state.copyWith(
        loadStatus: LoadStatus.Done,
        customer: [updatedCustomer],
      ));
    } catch (e) {
      print("Error updating customer: $e");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  /// Xóa thông tin khách hàng khỏi SharedPreferences
  Future<void> removeCustomer() async {
    await _storage.remove('customer');
    emit(state.copyWith(
      customer: [],
      idCustomer: 0,
      loadStatus: LoadStatus.Init,
    ));
  }
}