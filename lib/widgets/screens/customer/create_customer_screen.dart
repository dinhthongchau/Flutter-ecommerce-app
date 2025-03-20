import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/common/enum/load_status.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
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
        body: Body()
    );
  }
}

class Body extends StatefulWidget {
  const Body({
    super.key,
  });

  @override
  State<Body> createState() => _BodyState();

}

class _BodyState extends State<Body> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  @override
  void initState() {
    super.initState();
    final state = context.read<CustomerCubit>().state;

    // Kiểm tra nếu danh sách khách hàng có dữ liệu
    final customer = state.customer.isNotEmpty ? state.customer.first : null;

    // Khởi tạo TextEditingController với dữ liệu của khách hàng
    _nameController = TextEditingController(text: customer?.customerName ?? '');
    _emailController = TextEditingController(text: customer?.customerEmail ?? '');
    _phoneController = TextEditingController(text: customer?.customerPhone ?? '');
    _addressController = TextEditingController(text: customer?.customerAddress ?? '');
  }
  @override
  Widget build(BuildContext context) {





    return BlocBuilder<CustomerCubit, CustomerState>(
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
                  //print(randomId);
                  final customer = CustomerModel(
                    customerId: randomId,
                    customerName: _nameController.text,
                    customerEmail: _emailController.text,
                    customerPhone: _phoneController.text,
                    customerAddress: _addressController.text,


                  );


                  await context.read<CustomerCubit>().createCustomer(customer);
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
