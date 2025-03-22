import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:project_one/common/enum/load_status.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/services/storage_service.dart';
import 'package:project_one/widgets/common_widgets/notice_snackbar.dart';

part 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final StorageService _storage = StorageService();
  int quantity = 1;

  CartCubit() : super(CartState.init());

  /// Loads cart data from storage
  Future<void> loadCart() async {
    try {
      final cartData = await _storage.getList('cart') ?? [];
      final items = <ProductModel>[];
      final quantities = <int, int>{};
      var totalPayment = 0;

      for (final item in cartData) {
        try {
          final jsonMap = jsonDecode(item);
          final product = ProductModel.fromJson(jsonMap);
          final qty = (jsonMap['quantity'] as num?)?.toInt() ?? 1;
          items.add(product);
          quantities[product.product_id] = qty;
          totalPayment += product.product_price * qty;
        } catch (e) {
          print('Parse error: $e');
          continue;
        }
      }

      emit(CartState(
        cartItems: items,
        quantities: quantities,
        totalPayment: totalPayment,
        selectedItem: [],
        selectedProducts: [],
        selectedQuantities: {},
        loadStatus: LoadStatus.Done,
        allSelected: false,
      ));
    } catch (e) {
      print('Load cart error: $e');
      emit(CartState.init(loadStatus: LoadStatus.Error));
    }
  }

  /// Increases quantity in detail screen
  void incrementQuantityInDetailScreen() {
    quantity++;
    emit(state.copyWith(quantities: {...state.quantities, -1: quantity}));
  }

  /// Decreases quantity in detail screen
  void decrementQuantityInDetailScreen() {
    if (quantity > 1) {
      quantity--;
      emit(state.copyWith(quantities: {...state.quantities, -1: quantity}));
    }
  }

  /// Adds product to cart
  Future<void> addToCart(BuildContext context, ProductModel product,
      Map<int, int> quantities) async {
    try {
      final cartData = await _storage.getList('cart') ?? [];
      final cartItems =
          cartData.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      var productExist = false;

      quantities[product.product_id] = quantity;
      for (final item in cartItems) {
        if (item['product_id'] == product.product_id) {
          item['quantity'] = (item['quantity'] ?? 1) + quantity;
          productExist = true;
          break;
        }
      }

      if (!productExist) {
        final newItem = product.toJson()
          ..['quantity'] = quantities[product.product_id] ?? 1;
        cartItems.add(newItem);
      }

      await _storage.saveList(
          'cart', cartItems.map((e) => jsonEncode(e)).toList());
      await loadCart();

    } catch (e) {
      print('Add to cart error: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(noticeSnackbar("Error adding to cart", true));
    }
  }

  /// Toggles item selection
  void toggleSelectItem(int productId) {
    final selected = List<int>.from(state.selectedItem);
    final selectedProducts = List<ProductModel>.from(state.selectedProducts);
    final selectedQuantities = Map<int, int>.from(state.selectedQuantities);

    if (selected.contains(productId)) {
      selected.remove(productId);
      selectedProducts.removeWhere((item) => item.product_id == productId);
      selectedQuantities.remove(productId);
    } else {
      final product =
          state.cartItems.firstWhere((item) => item.product_id == productId);
      selectedProducts.add(product);
      selectedQuantities[productId] = state.quantities[productId] ?? 1;
      selected.add(productId);
    }

    final totalPayment = selectedProducts.fold(
      0,
      (sum, item) =>
          sum +
          (item.product_price * (selectedQuantities[item.product_id] ?? 1)),
    );

    emit(state.copyWith(
      selectedItem: selected,
      selectedProducts: selectedProducts,
      selectedQuantities: selectedQuantities,
      totalPayment: totalPayment,
    ));
  }

  /// Initializes cart with selected items
  void initializeCart(List<ProductModel> selectedProducts,
      Map<int, int> selectedQuantities, int totalPayment) {
    emit(state.copyWith(
      selectedProducts: selectedProducts,
      selectedQuantities: selectedQuantities,
      totalPayment: totalPayment,
    ));
  }

  /// Toggles select all items
  void toggleSelectAll() {
    final newSelectAllState = !state.allSelected;
    final selectedItem = newSelectAllState
        ? state.cartItems.map((item) => item.product_id).toList()
        : <int>[];
    final selectedQuantities =
        newSelectAllState ? Map<int, int>.from(state.quantities) : <int, int>{};
    final selectedProducts = newSelectAllState
        ? List<ProductModel>.from(state.cartItems)
        : state.cartItems;

    final totalPayment = newSelectAllState
        ? state.cartItems.fold(
            0,
            (sum, item) =>
                sum +
                (item.product_price * (state.quantities[item.product_id] ?? 1)))
        : 0;

    emit(state.copyWith(
      allSelected: newSelectAllState,
      selectedItem: selectedItem,
      selectedProducts: selectedProducts,
      selectedQuantities: selectedQuantities,
      totalPayment: totalPayment,
    ));
  }

  /// Increases item quantity
  void incrementQuantity(int productId) {
    final updatedQuantities = Map<int, int>.from(state.quantities);
    updatedQuantities[productId] = (updatedQuantities[productId] ?? 1) + 1;
    final totalPayment = state.cartItems.fold(
        0,
        (sum, item) =>
            sum +
            (item.product_price * (updatedQuantities[item.product_id] ?? 1)));

    emit(state.copyWith(
        quantities: updatedQuantities, totalPayment: totalPayment));
    _updateCart();
  }

  /// Decreases item quantity
  Future<void> decrementQuantity(int productId) async {
    final updatedQuantities = Map<int, int>.from(state.quantities);
    if (updatedQuantities[productId]! > 1) {
      updatedQuantities[productId] = updatedQuantities[productId]! - 1;
      final totalPayment = state.cartItems.fold(
          0,
          (sum, item) =>
              sum +
              (item.product_price * (updatedQuantities[item.product_id] ?? 1)));

      emit(state.copyWith(
          quantities: updatedQuantities, totalPayment: totalPayment));
      await _updateCart();
    } else {
      await removeItem(productId);
    }
  }

  /// Removes item from cart
  Future<void> removeItem(int productId) async {
    final updatedCart =
        state.cartItems.where((item) => item.product_id != productId).toList();
    final updatedQuantities = Map<int, int>.from(state.quantities)
      ..remove(productId);
    await _updateCart(updatedCart);
    emit(state.copyWith(cartItems: updatedCart, quantities: updatedQuantities));
  }

  /// Updates cart in storage
  Future<void> _updateCart([List<ProductModel>? cartItems]) async {
    final items = cartItems ?? state.cartItems;
    final updatedCartData = items.map((item) {
      final itemJson = item.toJson()
        ..['quantity'] = state.quantities[item.product_id] ?? 1;
      return jsonEncode(itemJson);
    }).toList();
    await _storage.saveList('cart', updatedCartData);
  }

  /// Clears all items in cart
  Future<void> clearProductInCart() async {
    await _storage.saveList('cart', []);
    emit(CartState.init());
  }
}
