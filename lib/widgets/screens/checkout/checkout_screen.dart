import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/checkout/checkout_cubit.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
import 'package:project_one/widgets/screens/list_products/list_products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/enum/load_status.dart';
import '../../../models/order_model.dart';
import '../../common_widgets/bold_text.dart';
import '../customer/create_customer_screen.dart';

//checkout_screen.dart
class CheckoutScreen extends StatefulWidget {
  static const String route = "CheckoutScreen";

  const CheckoutScreen({super.key});

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
      appBar: AppBar(title: Center(child: const CustomBoldText(text: "Check out"))),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _noteController = TextEditingController();

    return BlocBuilder<CheckoutCubit, CheckoutState>(
  builder: (contextCheckout, stateCheckout) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.Loading) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading spinner while submitting
        } else if (stateCheckout.loadStatus == LoadStatus.Done) {
          context.read<CustomerCubit>().clearOrder();
          context.read<CartCubit>().clearProductInCart();
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Order successfully submitted!"),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(ListProductsScreen.route);
                },
                child: const Text("Place New Order"),
              ),
            ],
          );
        }
        else if (stateCheckout.loadStatus == LoadStatus.Error) {
          return const Center( child: Text("An error occurred while submitting the order."));
        }
        else  {
          final customer =
          state.customer.isNotEmpty ? state.customer.first : null;
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    CustomerContainer(),
                    ProductOrderContainer(),
                    NoteContainer(noteController: _noteController),
                    PaymentMethodContainer(),
                    DetailPaymentContainer(),
                    ElevatedButton(
                        onPressed: () {
                          final orderNote = context.read<CheckoutCubit>().generateOrderNote(
                              state.selectedProducts,  // Danh sách sản phẩm đã chọn
                              state.selectedQuantities, // Số lượng tương ứng
                              _noteController.text
                          );
                          final order = OrderModel(
                            customerId: customer?.customerId ?? 0,
                            orderTotal: double.parse(state.totalPayment.toString()),
                            orderPaymentMethod:context.read<CheckoutCubit>().state.selectedMethod,
                            orderStatus: "OK2",
                            orderNote: orderNote,
                          );
                          context.read<CheckoutCubit>().submitOrder(order);
                        },
                        child: const Text('Order Now'))
                  ],
                ),
              );
            },
          );
        }

      },
    );
  },
);
  }
}

class PaymentMethodContainer extends StatelessWidget {
  const PaymentMethodContainer({
    super.key,
  }) ;



  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
  builder: (context, state) {
    return Container(
      color: Colors.grey,
      width: double.infinity,
      height: 150,
     child: Column(
       children: [
         const Text("Select Payment Method"),
         RadioListTile<String>(
              title: const Text("Cash on Delivery"),
             value: "Cash on Delivery",
             groupValue: state.selectedMethod,
             onChanged: (String? value){
                if(value != null){
                  context.read<CheckoutCubit>().selectPaymentMethod(value);
                }
             }
             ),
         RadioListTile<String>(
             title: const Text("Banking"),
             value: "Banking",
             groupValue: state.selectedMethod,
             onChanged: (String? value){
               if(value != null){
                 context.read<CheckoutCubit>().selectPaymentMethod(value);
               }
             }
         ),

       ],
     )
    );
  },
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
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        String? baseUrl = dotenv.env['API_BASE_URL_NoApi_NoV1'];
        //print(state.selectedProducts);
        return SizedBox(
          height: 300,
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: state.selectedProducts.length,
            itemBuilder: (context, index) {
              final product = state.selectedProducts[index];
              final quantity = state.selectedQuantities[product.product_id] ?? 1;
              // return ListTile(
              //   title: Text(product.product_name),
              //   subtitle: Text("Quantity : $quantity"),
              //   trailing: Text(product.product_color),
              // );
              return Row(
                children: [

                  Image.network(
                    "$baseUrl${product.product_image[0]}",
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 80, color: Colors.red); // Xử lý khi ảnh lỗi
                    },
                  ),
                  const SizedBox(width: 10,),
                  Column(

                    children: [
                      Text(product.product_name),
                      Text(product.product_color),
                      Row(
                        mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                        children: [
                          Text("${product.product_price}"),
                          SizedBox(
                            width: 20,
                          ),
                          Text("$quantity"),

                        ],
                      )
                    ],
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class CustomerContainer extends StatelessWidget {
  const CustomerContainer({
    super.key,
  });
  

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
  builder: (context, state) {
    final customer = state.customer.isNotEmpty ? state.customer.first : null;
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
            ElevatedButton(
              onPressed: ()  {context.read<CustomerCubit>().removeCustomer();
              },
              child: Text("Remove Customer"),
            ),
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
                  await context.read<CustomerCubit>().createCustomer(result);
                  await context.read<CustomerCubit>().loadCustomer();
                }
              },
              child: Text("Create Customer"),
            ),
          ]
        ],
      ),
    );
  },
);
  }
}

class DetailPaymentContainer extends StatelessWidget {
  const DetailPaymentContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tong tien hang"),
                SizedBox(
                  width: 20,
                ),
                Text(state.totalPayment.toString())
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tong tien phi van chuyen"),
                SizedBox(
                  width: 20,
                ),
                Text("0")
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Tong thanh toan"),
                SizedBox(
                  width: 50,
                ),
                Text(state.totalPayment.toString())
              ],
            ),
          ],
        );
      },
    );
  }
}
