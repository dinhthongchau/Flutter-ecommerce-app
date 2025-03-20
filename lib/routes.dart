import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/checkout/checkout_cubit.dart';
import 'package:project_one/widgets/screens/list_products/list_products_cubit.dart';
import 'repositories/api.dart';
import 'widgets/screens/customer/create_customer_screen.dart';
import 'widgets/screens/customer/customer_cubit.dart';
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
      var cubitProduct = (settings.arguments
          as Map<String, dynamic>)['cubit_product'] as ListProductsCubit;
      return MaterialPageRoute(
        builder: (context) =>
            BlocProvider.value(value: cubitProduct, child: DetailScreen()),
      );
    case CartScreen.route:
      return MaterialPageRoute(builder: (context) => CartScreen());
    case CheckoutScreen.route:
      var selectedProduct = (settings.arguments
          as Map<String, dynamic>)['selectedProduct'] as List<ProductModel>;
      var selectedQuantities = (settings.arguments
          as Map<String, dynamic>)['selectedQuantities'] as Map<int, int>;
      var totalPayment =
          (settings.arguments as Map<String, dynamic>)['totalPayment'];
      return MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => CartCubit()
                      ..initializeCart(
                          selectedProduct, selectedQuantities, totalPayment),
                  ),
                  BlocProvider(
                      create: (context) => CustomerCubit(context.read<Api>())..loadCustomer()),
                  BlocProvider(
                      create: (context) => CheckoutCubit(context.read<Api>())),
                ],
                child: CheckoutScreen(),
              ));
    case CreateCustomerScreen.route:
      return MaterialPageRoute(
          builder: (context) => BlocProvider.value(
                value: context.read<CustomerCubit>(),
                child: CreateCustomerScreen(),
              ));
    default:
      return MaterialPageRoute(builder: (context) => ListProductsScreen());
  }
}
