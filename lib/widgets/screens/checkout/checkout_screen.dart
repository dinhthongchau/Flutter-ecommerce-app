import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/order_model.dart';
import '../customer/create_customer_screen.dart';

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
      body: BlocProvider(
        create: (context) =>
            CustomerCubit(context.read<Api>())..loadCustomer(),
        child: Body(
          products: widget.products,
        ),
      ),
    );
  }
}

class Body extends StatelessWidget {
  final List<ProductModel> products;

  const Body({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _noteController = TextEditingController();
    final TextEditingController _paymentMethodController =
        TextEditingController();
    Future<void> _submitOrder() async {
      final api = context.read<Api>();
      final customer = context.read<CustomerCubit>().state.customer.first;
      final order = OrderModel(
        customerId: customer.customerId,
        orderTotal: 200,
        orderPaymentMethod: _paymentMethodController.text,
        orderStatus: "OK",
        orderNote: _noteController.text,
      );
      try {
        final response = await api.createOrder(order);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Order Created: ${response['data']['order']}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to create order")));
      }
    }

    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        final customer =
            state.customer.isNotEmpty ? state.customer.first : null;
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              CustomerContainer(customer: customer),
              ProductOrderContainer(products: products),
              NoteContainer(noteController: _noteController),
              PaymentMethodContainer(
                  paymentMethodController: _paymentMethodController),
              ElevatedButton(
                  onPressed: _submitOrder, child: const Text('Order Now'))
            ],
          ),
        );
      },
    );
  }
}

class PaymentMethodContainer extends StatelessWidget {
  const PaymentMethodContainer({
    super.key,
    required TextEditingController paymentMethodController,
  }) : _paymentMethodController = paymentMethodController;

  final TextEditingController _paymentMethodController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      width: double.infinity,
      height: 100,
      child: TextField(
        controller: _paymentMethodController,
        decoration: const InputDecoration(labelText: 'Payment Method'),
      ),
    );
  }
}

class NoteContainer extends StatelessWidget {
  const NoteContainer({
    super.key,
    required TextEditingController noteController,
  }) : _noteController = noteController;

  final TextEditingController _noteController;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      width: double.infinity,
      height: 100,
      child: TextField(
        controller: _noteController,
        decoration: const InputDecoration(labelText: 'Note'),
      ),
    );
  }
}

class ProductOrderContainer extends StatelessWidget {
  const ProductOrderContainer({
    super.key,
    required this.products,
  });

  final List<ProductModel> products;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
    );
  }
}

class CustomerContainer extends StatelessWidget {
  const CustomerContainer({
    super.key,
    required this.customer,
  });

  final CustomerModel? customer;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      height: 200,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (customer != null) ...[
            Text("Customer ID: ${customer!.customerId}"),
            Text("Name: ${customer!.customerName}"),
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
                if (result != null) {
                  context.read<CustomerCubit>().createCustomer(result);
                }
              },
              child: Text("Create Customer"),
            ),
          ]
        ],
      ),
    );
  }
}
