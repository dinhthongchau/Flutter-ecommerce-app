import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/models/order_model.dart';
import 'package:project_one/repositories/api.dart';

class SubmitOrderScreen extends StatefulWidget {
  static const route = '/submit_order';

  @override
  _SubmitOrderScreenState createState() => _SubmitOrderScreenState();
}

class _SubmitOrderScreenState extends State<SubmitOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController customerIdController = TextEditingController();
  final TextEditingController orderTotalController = TextEditingController();
  final TextEditingController paymentMethodController = TextEditingController();
  final TextEditingController orderStatusController = TextEditingController();
  final TextEditingController orderNoteController = TextEditingController();

  void _submitOrder() async {
    if (_formKey.currentState!.validate()) {
      final api = context.read<Api>();
      final order = OrderModel(
        customerId: int.parse(customerIdController.text),
        orderTotal: double.parse(orderTotalController.text),
        orderPaymentMethod: paymentMethodController.text,
        orderStatus: orderStatusController.text,
        orderNote: orderNoteController.text,
      );

      try {
        final response = await api.createOrder(order);
        print(response);
        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Order Created: ${response['data']['order']}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create order')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Order')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: customerIdController,
                decoration: InputDecoration(labelText: 'Customer ID'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter Customer ID' : null,
              ),
              TextFormField(
                controller: orderTotalController,
                decoration: InputDecoration(labelText: 'Order Total'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter Order Total' : null,
              ),
              TextFormField(
                controller: paymentMethodController,
                decoration: InputDecoration(labelText: 'Payment Method'),
                validator: (value) => value!.isEmpty ? 'Enter Payment Method' : null,
              ),
              TextFormField(
                controller: orderStatusController,
                decoration: InputDecoration(labelText: 'Order Status'),
                validator: (value) => value!.isEmpty ? 'Enter Order Status' : null,
              ),
              TextFormField(
                controller: orderNoteController,
                decoration: InputDecoration(labelText: 'Order Note'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitOrder,
                child: Text('Submit Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
