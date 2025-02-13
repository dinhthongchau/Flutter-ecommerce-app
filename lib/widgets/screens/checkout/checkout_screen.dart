import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';

import '../../../models/order_model.dart';
import '../cart/create_customer_screen.dart';
//checkout_screen.dart
class CheckoutScreen extends StatefulWidget {
  static const String route = "CheckoutScreen";
  final List<ProductModel> products;

  const CheckoutScreen({super.key, required this.products});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CustomerModel? customer; // Lưu khách hàng đã tạo

  void updateCustomer(CustomerModel newCustomer) {
    setState(() {
      customer = newCustomer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check out")),
      body: Body(products: widget.products, customer: customer, updateCustomer: updateCustomer),
    );
  }
}

class Body extends StatelessWidget {
  final List<ProductModel> products;
  final CustomerModel? customer;
  final Function(CustomerModel) updateCustomer;

  const Body({super.key, required this.products, required this.customer, required this.updateCustomer});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _noteController = TextEditingController();
    final TextEditingController _paymentMethodController = TextEditingController();
    Future<void> _submitOrder() async {
      final api = context.read<Api>();
      final order = OrderModel(
        customerId: customer!.customerId,
        orderTotal: 200,
        orderPaymentMethod: _paymentMethodController.text,
        orderStatus: "OK",
        orderNote: _noteController.text,
      );
      try{
        final response = await api.createOrder(order);

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Order Created: ${response['data']['order']}')),
        );

      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create order"))
        );
      }

    }
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [

          Container(
            color: Colors.green,
            height: 200,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (customer != null) ...[
                  Text("Customer ID: ${customer!.customerName}"),
                  Text("Email: ${customer!.customerEmail}"),
                  Text("Phone: ${customer!.customerPhone}"),
                  Text("Address: ${customer!.customerAddress}"),
                ] else ...[
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push<CustomerModel>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateCustomerScreen(),
                        ),
                      );

                      if(result !=null){
                        updateCustomer(result);
                      }
                    },
                    child: Text("Create Customer"),
                  ),
                ]
              ],
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ListTile(
                  title: Text(product.product_name),
                );
              },
            ),
          ),
          Container(
            color: Colors.green,
            width: double.infinity,
            height: 100,
            child: TextField(controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),),
          ),
          Container(
            color: Colors.grey,
            width: double.infinity,
            height: 100,
            child: TextField(controller: _paymentMethodController,
              decoration: const InputDecoration(labelText: 'Payment Method'),),
          ),
          ElevatedButton(onPressed: _submitOrder, child: const Text('Order Now'))


        ],
      ),
    );
  }
}
