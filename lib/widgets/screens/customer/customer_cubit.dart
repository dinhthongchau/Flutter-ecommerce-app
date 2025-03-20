import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/enum/load_status.dart';
import '../../../repositories/api.dart';

part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final Api _api;
  CustomerCubit(this._api) : super(CustomerState.init());
  Future<void> loadCustomer() async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try{
      // Lưu customer vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        String? customerData = prefs.getString('customer');
        //print("Customer Data from SharedPreferences: $customerData");

        if (customerData !=null ){
          Map<String,dynamic> jsonMap = jsonDecode(customerData);
          final CustomerModel customer = CustomerModel.fromJson(jsonMap);
          emit(state.copyWith(
            idCustomer: customer.customerId,
            loadStatus: LoadStatus.Done,
            customer: [customer]
          ));

        }
        else {
          emit(state.copyWith(loadStatus: LoadStatus.Init));
        }
    }
    catch(E){
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }
  Future<void> createCustomer(CustomerModel customer) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    // Cập nhật trạng thái thành Done với dữ liệu cục bộ
    emit(state.copyWith(
      loadStatus: LoadStatus.Done,
      idCustomer: customer.customerId,
      customer: [customer],
    ));
    try {
      final response = await _api.createCustomer(customer);
      //print("API Response1: $response");
      if (response != null &&
          response['data'] != null &&
          response['data']['customer'] != null) {
        final int customerId = int.tryParse(response['data']['customer']['customer_id'].toString()) ?? 0;

        //print("customerId: $customerId");

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
            newCustomer
          ], // Cập nhật danh sách khách hàng
        ));
        // Lưu customer vào SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String customerJson = jsonEncode(newCustomer.toJson());
        await prefs.setString('customer', customerJson);
      } else {
        throw Exception("Invalid API Response");
      }
    }

    catch (e, stackTrace) {
      print("Error in CustomerCubit: $e");
      print("StackTrace: $stackTrace");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  Future<void> updateCustomer(CustomerModel updatedCustomer) async {
    emit(state.copyWith(loadStatus: LoadStatus.Loading));
    try{
     final response =  await _api.createCustomer(updatedCustomer);
     if ( response != null){
       emit(state.copyWith(loadStatus: LoadStatus.Done));
     }
     else{
       emit(state.copyWith(loadStatus: LoadStatus.Error));
     }


    }
    catch(e){
      print("Error updating customer: $e");
      emit(state.copyWith(loadStatus: LoadStatus.Error));
    }
  }

  void clearOrder(){
    try{
      emit(state.copyWith(loadStatus: LoadStatus.Init));
    }
    catch(e){
      print(e);
    }

  }
  Future<void> removeCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('customer');
    emit(state.copyWith(customer: [], idCustomer: 0, loadStatus: LoadStatus.Init));
  }


}
