import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/widgets/screens/list_products/list_products_cubit.dart';
import 'widgets/screens/list_products/list_products_screen.dart';

import 'widgets/screens/cart/cart_screen.dart';
import 'widgets/screens/checkout/checkout_screen.dart';
import 'widgets/screens/detail/detail_screen.dart';
//routes.dart

Route<dynamic> mainRoute(RouteSettings settings) {
  switch (settings.name) {
    case ListProductsScreen.route:
      return MaterialPageRoute(builder: (context) => ListProductsScreen());
    case DetailScreen.route:
      var cubit_product = (settings.arguments as Map<String,
          dynamic>)['cubit_product'] as ListProductsCubit;
      return MaterialPageRoute(builder: (context) =>
          BlocProvider.value(
            value: cubit_product,
            child:  DetailScreen()
            ),
      );
    case CartScreen.route:
      return MaterialPageRoute(builder: (context) => CartScreen());
    case CheckoutScreen.route:
      return MaterialPageRoute(builder: (context) => CheckoutScreen());
      ;
    default:
      return MaterialPageRoute(builder: (context) => ListProductsScreen());
  }
}