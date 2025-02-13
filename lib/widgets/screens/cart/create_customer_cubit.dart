import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/enum/load_status.dart';
import '../../../repositories/api.dart';

part 'create_customer_state.dart';

class CreateCustomerCubit extends Cubit<CreateCustomerState> {
  final Api _api;
  CreateCustomerCubit(this._api) : super(CreateCustomerState.init());
  Future<void> loadCustomer() async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try{
        final prefs = await SharedPreferences.getInstance();
        List<String> customerData = prefs.getStringList('customer');
    }
    catch(E){
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }
  Future<void> createCustomer(CustomerModel customer) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));

    try {
      final response = await _api.createCustomer(customer);
      print("API Response1: $response");
      if (response != null &&
          response['data'] != null &&
          response['data']['customer'] != null) {
        final int customerId = int.tryParse(response['data']['customer']['customer_id'].toString()) ?? 0;

        print("customerId: $customerId");

        final newCustomer = CustomerModel(
          customerId: customerId  ?? 0,
          customerName: response['data']['customer']['customer_name'],
          customerEmail: response['data']['customer']['customer_email'],
          customerPhone: response['data']['customer']['customer_phone'],
          customerAddress: response['data']['customer']['customer_address'],
        );

        emit(state.copyWith(
          loadStatus: LoadStatus.Done,
          idCustomer: customerId ?? 0,
          customer: [
            ...state.customer,
            newCustomer
          ], // Cập nhật danh sách khách hàng
        ));
      } else {
        throw Exception("Invalid API Response");
      }
    }

    catch (e, stackTrace) {
      print("Error: $e");
      print("StackTrace: $stackTrace");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }
}
