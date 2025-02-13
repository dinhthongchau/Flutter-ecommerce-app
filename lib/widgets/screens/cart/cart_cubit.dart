import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/widgets/common_widgets/notice_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../common/enum/load_status.dart';
//cart_cubit.dart
part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(CartState.init());

  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? cartData = prefs.getStringList('cart') ?? [];
      List<ProductModel> items = [];
      Map<int, int> quantities = {};

      for (String item in cartData) {
        try {
          // Print the raw data for debugging
          //print('Raw JSON data: $item');

          Map<String, dynamic> jsonMap = jsonDecode(item);
          ProductModel product = ProductModel.fromJson(jsonMap);
          items.add(product);
          quantities[product.product_id] = jsonMap['quantity'] ?? 1;
        } catch (e) {
          print('Error parsing item: $item');
          print('Parse error: $e');
          // Skip invalid items instead of failing the whole load
          continue;
        }
      }

      emit(CartState(cartItems: items,selectedItem: [],loadStatus: LoadStatus.Done,quantities: quantities));
    } catch (e) {
      print('Error loading cart: $e');
      emit(CartState(cartItems: [],selectedItem: [],loadStatus: LoadStatus.Error,quantities: {} )); // Emit empty state on error
    }
  }
  Future<void> addToCart(BuildContext context,ProductModel product) async {
    try{
      final prefs = await SharedPreferences.getInstance();
      List<String>? cartData = prefs.getStringList('cart') ?? [];
      //cart.add(jsonEncode(product.toJson()));
      List<Map<String, dynamic>> cartItems = cartData.map((e) => jsonDecode(e) as Map<String,dynamic>).toList();

      bool productExist = false;
      for ( var item in cartItems){
        if(item['product_id'] == product.product_id){
          item['quantity']= (item['quantity'] ?? 1 ) + 1;
          productExist = true;
          break;
        }
      }
      if ( !productExist){
        Map<String, dynamic> newItem = product.toJson();
        newItem['quantity'] = 1;
        cartItems.add(newItem);
      }



      List<String> updatedCart = cartItems.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('cart', updatedCart);
      await loadCart();
      ScaffoldMessenger.of(context).showSnackBar(noticeSnackbar("Added to cart", false));

      }
    catch(e){
      print("error $e");
      ScaffoldMessenger.of(context).showSnackBar(noticeSnackbar("Error when add to cart", true));

    }

  }

  void toggleSelectItem( int productId){
    final selected = List<int>.from(state.selectedItem);
    if ( selected.contains(productId)){
      selected.remove(productId);
    }
    else {
      selected.add(productId);
    }
    emit(state.copyWith(selectedItem: selected));
  }

  void removeItem(int product_id) {
    final updatedCart = state.cartItems.where((item) => item.product_id != product_id).toList();

    // Cập nhật trạng thái với giỏ hàng đã thay đổi
    emit(state.copyWith(cartItems: updatedCart));
  }

}
