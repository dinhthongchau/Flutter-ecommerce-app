import 'package:flutter/material.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';
//checkout_screen.dart
class CheckoutScreen2  extends StatefulWidget {
  static const String route = "CheckoutScreen";
  final List<ProductModel> products;
  const CheckoutScreen2({super.key, required this.products});

  @override
  State<CheckoutScreen2> createState() => _CheckoutScreen2State();
}

class _CheckoutScreen2State extends State<CheckoutScreen2> {
  @override
  Widget build(BuildContext context) {
    return Page(products: widget.products);
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
    required this.products,
  });

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    CustomerModel? customer;
    return Scaffold(
      appBar: AppBar(title: const Text("Check out"),),
      body: Body(products: products),

    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
    required this.products,
  });

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [

          Container(
            color: Colors.green,
            height: 200,
            width: double.infinity,
      
            child: Text("Customer"),
          ),
          Container(
            color: Colors.grey,
            width: double.infinity,
            height: 100
            ,
            child: Text("Note: "),
          ),
          Container(
            color: Colors.green,
            width: double.infinity,
            height: 100,
            child: Text("Payment method"),
          ),
        ],
      ),
    );
  }
}
