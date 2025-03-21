// lib/widgets/screens/customer/create_customer_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/location_model.dart';
import 'package:project_one/services/location_service.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
import '../../../common/code/random.dart';

class CreateCustomerScreen extends StatefulWidget {
  static const String route = "CreateCustomerScreen";

  const CreateCustomerScreen({super.key});

  @override
  State<CreateCustomerScreen> createState() => _CreateCustomerScreenState();
}

class _CreateCustomerScreenState extends State<CreateCustomerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
          title: Text("Create Customer Screen")),
      body: Body(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _detailAddressController;

  List<Province> provinces = [];
  Province? selectedProvince;
  District? selectedDistrict;
  Ward? selectedWard;

  final LocationService _locationService = LocationService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    final state = context.read<CustomerCubit>().state;
    final customer = state.customer.isNotEmpty ? state.customer.first : null;

    _nameController = TextEditingController(text: customer?.customerName ?? '');
    _emailController =
        TextEditingController(text: customer?.customerEmail ?? '');
    _phoneController =
        TextEditingController(text: customer?.customerPhone ?? '');
    _detailAddressController = TextEditingController();

    _loadProvinces();
  }

  Future<void> _loadProvinces() async {
    try {
      provinces = await _locationService.fetchProvinces();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading provinces: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                const SizedBox(height: 16),
                // Dropdown Tỉnh/Thành
                DropdownButtonFormField<Province>(
                  decoration:
                      const InputDecoration(labelText: 'Chọn tỉnh thành'),
                  value: selectedProvince,
                  items: provinces.map((province) {
                    return DropdownMenuItem<Province>(
                      value: province,
                      child:  Text(province.name),
                    );
                  }).toList(),
                  onChanged: (Province? value) {
                    setState(() {
                      selectedProvince = value;
                      selectedDistrict = null;
                      selectedWard = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown Quận/Huyện
                DropdownButtonFormField<District>(
                  decoration:
                      const InputDecoration(labelText: 'Chọn quận huyện'),
                  value: selectedDistrict,
                  items: selectedProvince?.districts.map((district) {
                        return DropdownMenuItem<District>(
                          value: district,
                          child:  Text(district.name),
                        );
                      }).toList() ??
                      [],
                  onChanged: (District? value) {
                    setState(() {
                      selectedDistrict = value;
                      selectedWard = null;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Dropdown Phường/Xã
                DropdownButtonFormField<Ward>(
                  decoration:
                      const InputDecoration(labelText: 'Chọn phường xã'),
                  value: selectedWard,
                  items: selectedDistrict?.wards.map((ward) {
                        return DropdownMenuItem<Ward>(
                          value: ward,
                          child:  Text(ward.name),
                        );
                      }).toList() ??
                      [],
                  onChanged: (Ward? value) {
                    setState(() {
                      selectedWard = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Ô nhập địa chỉ chi tiết
                TextField(
                  controller: _detailAddressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ chi tiết (số nhà, tên đường)',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white),
                  onPressed: () async {
                    int randomId = generateRandomId();
                    String address = [
                      _detailAddressController.text,
                      // Địa chỉ chi tiết nhập vào
                      selectedWard?.name,
                      selectedDistrict?.name,
                      selectedProvince?.name
                    ].where((e) => e != null && e.isNotEmpty).join(', ');

                    final customer = CustomerModel(
                      customerId: randomId,
                      customerName: _nameController.text,
                      customerEmail: _emailController.text,
                      customerPhone: _phoneController.text,
                      customerAddress: address,
                    );

                    await context
                        .read<CustomerCubit>()
                        .createCustomer(customer);
                    Navigator.pop(context, customer);
                  },
                  child: const Text("Create Customer"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _detailAddressController.dispose(); // Giải phóng bộ nhớ cho controller
    super.dispose();
  }
}
