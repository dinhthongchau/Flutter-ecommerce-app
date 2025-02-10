import 'package:flutter/material.dart';
import 'package:project_one/models/product_model.dart';
//checkout_screen.dart
class CheckoutScreen  extends StatelessWidget {
  static const String route = "CheckoutScreen";
  final List<ProductModel> products;
  const CheckoutScreen({super.key, required this.products});


  @override
  Widget build(BuildContext context) {
    return Page(products: products);
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
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: products.length,
            itemBuilder: (context,index){
              final product = products[index];
              return ListTile(
                title: Text(product.product_name),
              );
            },


          ),
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
