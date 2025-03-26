import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/checkout/checkout_cubit.dart';
import 'package:project_one/widgets/screens/list_products/list_products_cubit.dart';
import 'package:project_one/widgets/screens/settings/settings_screen.dart';
import 'package:project_one/widgets/screens/upload/upload_product_screen.dart';
import 'repositories/api_server.dart'; // Add this import
import 'widgets/screens/customer/create_customer_screen.dart';
import 'widgets/screens/customer/customer_cubit.dart';
import 'widgets/screens/list_products/list_products_screen.dart';

import 'widgets/screens/cart/cart_screen.dart';
import 'widgets/screens/checkout/checkout_screen.dart';
import 'widgets/screens/detail/detail_screen.dart';

Route<dynamic> mainRoute(RouteSettings settings) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) {
      switch (settings.name) {
        case ListProductsScreen.route:
          return ListProductsScreen();
        case DetailScreen.route:
          var cubitProduct = (settings.arguments
              as Map<String, dynamic>)['cubit_product'] as ListProductsCubit;
          return BlocProvider.value(
            value: cubitProduct,
            child: DetailScreen(),
          );
        case CartScreen.route:
          return CartScreen();
        case CheckoutScreen.route:
          var args = settings.arguments as Map<String, dynamic>;
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => CartCubit()
                  ..initializeCart(args['selectedProduct'],
                      args['selectedQuantities'], args['totalPayment']),
              ),
              BlocProvider(
                  create: (context) => CustomerCubit()..loadCustomer()),
              BlocProvider(
                  create: (context) =>
                      CheckoutCubit(context.read<ApiServer>())),
            ],
            child: CheckoutScreen(),
          );
        case CreateCustomerScreen.route:
          return BlocProvider.value(
            value: context.read<CustomerCubit>(),
            child: CreateCustomerScreen(),
          );
        case UploadProductScreen.route:
          return UploadProductScreen();
        case SettingsScreen.route:
          return SettingsScreen();
        default:
          return ListProductsScreen();
      }
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}
