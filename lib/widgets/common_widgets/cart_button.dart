// cart_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import '../screens/cart/cart_screen.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.route);
            },
            icon: Badge.count(
              backgroundColor: Colors.white,
              textColor: Colors.deepOrange,
              count: state.quantities.length,
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
            ));
      },
    );
  }
}