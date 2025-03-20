import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      int totalPayment = 0;

      for (String item in cartData) {
        try {
          // Print the raw data for debugging
          //print('Raw JSON data: $item');

          Map<String, dynamic> jsonMap = jsonDecode(item);
          ProductModel product = ProductModel.fromJson(jsonMap);
          int quantity = jsonMap['quantity'];
          items.add(product);
          quantities[product.product_id] = jsonMap['quantity'] ?? 1;
          totalPayment += product.product_price * quantity;
        } catch (e) {
          print('Error parsing item: $item');
          print('Parse error: $e');
          // Skip invalid items instead of failing the whole load
          continue;
        }
      }

      emit(CartState(
          cartItems: items,
          selectedItem: [],
          loadStatus: LoadStatus.Done,
          quantities: quantities,
          selectedProducts: [],
          selectedQuantities: {},
          totalPayment: totalPayment,
          allSelected: false));
    } catch (e) {
      print('Error loading cart: $e');
      emit(CartState(
          cartItems: [],
          selectedItem: [],
          loadStatus: LoadStatus.Error,
          quantities: {},
          selectedProducts: [],
          selectedQuantities: {},
          totalPayment: 0,
          allSelected: false)); // Emit empty state on error
    }
  }
  int quantity =1;


  void incrementQuantityInDetailScreen(){

    quantity ++;
    //Sao chép toàn bộ dữ liệu hiện có trong state.quantities
    emit(state.copyWith(quantities: {...state.quantities, -1: quantity}));

  }
  void decrementQuantityInDetailScreen(){
    if ( quantity > 1){
      quantity --;
      emit(state.copyWith(quantities: {...state.quantities, -1: quantity}));
    }


  }
  Future<void> addToCart(BuildContext context, ProductModel product,  Map<int, int> quantities) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String>? cartData = prefs.getStringList('cart') ?? [];
      //cart.add(jsonEncode(product.toJson()));
      List<Map<String, dynamic>> cartItems =
          cartData.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

      bool productExist = false;
      quantities[product.product_id] = quantity;
      for (var item in cartItems) {
        if (item['product_id'] == product.product_id) {
          item['quantity'] = (item['quantity'] ?? 1) + quantity;
          productExist = true;
          break;
        }
      }
      if (!productExist) {
        Map<String, dynamic> newItem = product.toJson();
        newItem['quantity'] = quantities[product.product_id] ?? 1;
        cartItems.add(newItem);
      }

      List<String> updatedCart = cartItems.map((e) => jsonEncode(e)).toList();
      await prefs.setStringList('cart', updatedCart);
      await loadCart();
      ScaffoldMessenger.of(context)
          .showSnackBar(noticeSnackbar("Added to cart", false));
    } catch (e) {
      print("error $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(noticeSnackbar("Error when add to cart", true));
    }
  }

  void toggleSelectItem(int productId) {
    final selected = List<int>.from(state.selectedItem);
    final selectedProducts = List<ProductModel>.from(state.selectedProducts);
    final selectedQuantities = Map<int, int>.from(state.selectedQuantities);
    int totalPayment = 0;
    if (selected.contains(productId)) {
      selected.remove(productId);
      selectedProducts.removeWhere((item) => item.product_id == productId);
      selectedQuantities.remove(productId);
    } else {
      final selectedProduct =
          state.cartItems.firstWhere((item) => item.product_id == productId);
      selectedProducts.add(selectedProduct);

      selectedQuantities[productId] = state.quantities[productId] ?? 1;
      selected.add(productId);
    }
     totalPayment = selectedProducts.fold(
        0,
        (sum, item) =>
            sum +
            (item.product_price * (selectedQuantities[item.product_id] ?? 1)));
    emit(state.copyWith(
        selectedItem: selected,
        selectedProducts: selectedProducts,
        selectedQuantities: selectedQuantities,
        totalPayment: totalPayment));
  }



  void initializeCart(
      List<ProductModel> selectedProduct, Map<int, int> selectedQuantities, totalPayment) {
    emit(state.copyWith(
        selectedProducts: selectedProduct,
        selectedQuantities: selectedQuantities,
      totalPayment: totalPayment
    ));
  }

  void toggleSelectAll() {
    bool newSelectAllState = !(state.allSelected);
    List<ProductModel> updatedItems = List.from(state.cartItems);
    Map<int, int> selectedQuantities = {};
    List<int> selectedItem =
        state.cartItems.map((item) => item.product_id).toList();
    int totalPayment = -1;
    if (newSelectAllState) {
      final selectedProducts = List<ProductModel>.from(state.cartItems) ;
      final selectedQuantities = Map<int, int>.from(state.quantities);
      totalPayment = selectedProducts.fold(0, (sum, item) {
        int quantity = selectedQuantities[item.product_id] ?? 1;
        return sum + (item.product_price * quantity);
      });
    } else {

      selectedItem = [];
      selectedQuantities = {};
      totalPayment = 0;
    }



    emit(state.copyWith(
      allSelected: newSelectAllState,
      selectedItem: selectedItem,
      totalPayment: totalPayment,
      selectedProducts: updatedItems,
      selectedQuantities: selectedQuantities,
    ));
  }

  void incrementQuantity(int productId){
    final updatedQuantities = Map<int,int>.from(state.quantities);
    updatedQuantities[productId] = (updatedQuantities[productId] ?? 1) + 1;
    int totalPayment = 0;
    for (var item in state.cartItems) {
      totalPayment += item.product_price * (updatedQuantities[item.product_id] ?? 1);
    }

    emit(state.copyWith(quantities: updatedQuantities, totalPayment: totalPayment));
    _updateCart();

  }
  Future<void> decrementQuantity(int productId) async {
    final updatedQuantities = Map<int,int>.from(state.quantities);

    if (updatedQuantities[productId]! > 1) {
      updatedQuantities[productId] = updatedQuantities[productId]! - 1;
      final totalPayment = state.cartItems.fold(0, (sum, item) =>
      sum + item.product_price * (updatedQuantities[item.product_id] ?? 1));

      emit(state.copyWith(quantities: updatedQuantities, totalPayment: totalPayment));
      await _updateCart();
    } else {
      await removeItem(productId);
    }
  }

  Future<void> removeItem(int product_id) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedCart = state.cartItems.where((item) => item.product_id != product_id).toList();
    final updatedQuantities = Map<int,int>.from(state.quantities)..remove(product_id);
    //update SharedPReferences
    List<String> updatedCartData = updatedCart.map((item) {
      Map<String, dynamic> itemJson = item.toJson();
      itemJson['quantity'] = state.quantities[item.product_id] ?? 1;
      return jsonEncode(itemJson);
    }).toList();
    await prefs.setStringList('cart', updatedCartData);

    emit(state.copyWith(cartItems: updatedCart, quantities: updatedQuantities));



  }
  Future<void> _updateCart() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> updatedCartData = state.cartItems.map((item) {
      Map<String, dynamic> itemJson = item.toJson();
      itemJson['quantity'] = state.quantities[item.product_id] ?? 1;
      return jsonEncode(itemJson);
    }).toList();
    await prefs.setStringList('cart', updatedCartData); // Lưu lại giỏ hàng
  }

  Future<void> clearProductInCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cart', []);
  }

}
