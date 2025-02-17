import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../checkout/checkout_screen.dart';
import 'cart_cubit.dart';

//cart_screen.dart
class CartScreen extends StatelessWidget {
  static const String route = "CartScreen";

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CartCubit(),
      child: Page(),
    );
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    context.read<CartCubit>().loadCart();
    return Scaffold(
      bottomNavigationBar: bottomNavigatonBar(),
      appBar: AppBar(
        title: Text("Cart Screen"),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.cartItems.isEmpty) {
          return Center(
            child: Text("Your cart is empty"),
          );
        }
        return ListItemsInCart(
          state: state,
        );
      },
    );
  }
}

class ListItemsInCart extends StatelessWidget {
  final CartState state;

  const ListItemsInCart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String? baseUrl = dotenv.env['API_BASE_URL_NoApi_NoV1'];
    return SizedBox(
      child: ListView.builder(
        itemCount: state.cartItems.length,
        itemBuilder: (context, index) {
          ProductModel itemsInCart = state.cartItems[index];
          return Column(
            children: [
              CartItemListTile(baseUrl: baseUrl, itemsInCart: itemsInCart),
              Divider()
            ],
          );
        },
      ),
    );
  }
}

class bottomNavigatonBar extends StatelessWidget {
  const bottomNavigatonBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: SelectAll(),
        ),

        Expanded(
          flex: 3,
          child: TotalCalculator(),
        ),
        Expanded(
          flex: 3,
          child: CheckOutButton(),
        ),
      ],
    );
  }
}

class TotalCalculator extends StatelessWidget {
  const TotalCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Text(
          "Total Payment: đ${state.totalPayment}",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        );
      },
    );
  }
}

class SelectAll extends StatelessWidget {
  const SelectAll({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        bool allSelected = state.cartItems.every((item) => state.selectedItem.contains(item.product_id)); // Check if all items are selected
        return Row(
          children: [
            Checkbox(

              value: allSelected,
              onChanged: (value) {
                context.read<CartCubit>().toggleSelectAll();
              },
            ),
            const Text("Select all")
          ],
        );
      },
    );
  }
}

class CheckOutButton extends StatelessWidget {
  const CheckOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(

      builder: (context, state) {
        final selectedProduct = state.cartItems.where((item) =>
            state.selectedItem.contains(item.product_id)).toList();
        final selectedQuantities = selectedProduct.asMap().map((index,
            product) =>
            MapEntry(
                product.product_id, state.quantities[product.product_id] ?? 1));
        final totalPayment = state.totalPayment;

        return TextButton(
            onPressed: () {
              if (  state.selectedProducts.isEmpty){
                return;
              }
              Navigator.of(context).pushNamed(CheckoutScreen.route, arguments: {
                'selectedProduct': selectedProduct,
                'selectedQuantities': selectedQuantities,
                'totalPayment': totalPayment
              });
            },
            child: Text("CheckoutPage"));
      },
    );
  }
}

class CartItemListTile extends StatelessWidget {
  const CartItemListTile({
    super.key,
    required this.baseUrl,
    required this.itemsInCart,
  });

  final String? baseUrl;
  final ProductModel itemsInCart;

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(

      builder: (context, state) {
        var cubit_cart = context.read<CartCubit>();
        bool isSelected = state.selectedItem.contains(itemsInCart.product_id);

        return Container(
          height: 100,
          //padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              // Checkbox ở bên trái
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  cubit_cart.toggleSelectItem(itemsInCart.product_id);
                },
              ),

              // Ảnh sản phẩm
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                    NetworkImage("$baseUrl${itemsInCart.product_image[0]}"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 16),

              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(itemsInCart.product_name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(itemsInCart.product_color),
                    Text(
                      "đ${NumberFormat('#,###', 'vi').format(
                          itemsInCart.product_price)}",
                      style: TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                    Text(
                        "Quantity: ${state.quantities[itemsInCart.product_id] ??
                            1}")
                  ],
                ),
              ),

              // Nút xóa
              IconButton(
                onPressed: () {
                  cubit_cart.removeItem(itemsInCart.product_id);
                },
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }
}
