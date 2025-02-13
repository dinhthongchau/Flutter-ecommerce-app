import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/common/enum/load_status.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/screens/cart/create_customer_cubit.dart';
import 'package:project_one/widgets/screens/checkout/checkout_screen.dart';

import '../../../common/code/random.dart';
import '../../../models/customer_model.dart';

class CreateCustomerScreen extends StatefulWidget {
  static const String route = "CreateCustomerScreen";

  const CreateCustomerScreen({super.key});

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {

  @override
  Widget build(BuildContext context) {
    return Page();
  }
}

class Page extends StatelessWidget {
  const Page({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Create Customer Screen"),),
        body: BlocProvider(
          create: (context) => CreateCustomerCubit(context.read<Api>()),
          child: Body(),
        )
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _phoneController = TextEditingController();
    final TextEditingController _addressController = TextEditingController();
    late LoadStatus loadStatus;


    return BlocBuilder<CreateCustomerCubit, CreateCustomerState>(
      builder: (context, state) {
        return Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            ElevatedButton(

                onPressed: () async {

                  int randomId = generateRandomId();
                  print(randomId);
                  final customer = CustomerModel(
                    customerId: randomId,
                    customerName: _nameController.text,
                    customerEmail: _emailController.text,
                    customerPhone: _phoneController.text,
                    customerAddress: _addressController.text,


                  );


                  await context.read<CreateCustomerCubit>().createCustomer(customer);
                  Navigator.pop(context, customer);
                }, child: Text("Create Customer")),
            if (state.loadStatus == LoadStatus.Done) ...[

              Text("Customer ID: ${state.idCustomer}"),
              for (var customer in state.customer) ...[
                Text("Name: ${customer.customerName}"),
                Text("Email: ${customer.customerEmail}"),
                Text("Phone: ${customer.customerPhone}"),
                Text("Address: ${customer.customerAddress}"),
              ]

            ],


          ],

        );

      },
    );
  }
}
