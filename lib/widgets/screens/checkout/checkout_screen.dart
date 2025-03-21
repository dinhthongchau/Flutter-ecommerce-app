import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/checkout/checkout_cubit.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
import 'package:project_one/widgets/screens/list_products/list_products_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/enum/load_status.dart';
import '../../../main_cubit.dart';
import '../../../models/order_model.dart';
import '../../common_widgets/bold_text.dart';
import '../../common_widgets/notice_snackbar.dart';
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
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<MainCubit>().setTheme(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepOrange,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomBoldText(text: "Check out"),
            SizedBox(
              width: 30,
            ),
          ],
        ),
      ),
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
              return const Center(child: CircularProgressIndicator());
            } else if (stateCheckout.loadStatus == LoadStatus.Done) {
              context.read<CustomerCubit>().clearOrder();
              context.read<CartCubit>().clearProductInCart();
              return Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 80),
                        SizedBox(height: 10),
                        Text(
                          "Order Successfully Submitted!",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Thank you for your purchase. Your order will be processed soon.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed(ListProductsScreen.route);
                          },
                          child: Text("Back to Home",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              if (stateCheckout.loadStatus == LoadStatus.Error) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    noticeSnackbar(
                        "Error when ordering. Please enter all required fields.",
                        true),
                  );
                });

                // Trả về một widget rỗng để giữ nguyên trang
              }
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              final orderNote = context
                                  .read<CheckoutCubit>()
                                  .generateOrderNote(
                                      state.selectedProducts,
                                      // Danh sách sản phẩm đã chọn
                                      state.selectedQuantities,
                                      // Số lượng tương ứng
                                      _noteController.text);
                              final order = OrderModel(
                                customerId: customer?.customerId ?? 0,
                                orderTotal:
                                    double.parse(state.totalPayment.toString()),
                                orderPaymentMethod: context
                                    .read<CheckoutCubit>()
                                    .state
                                    .selectedMethod,
                                orderStatus: "Orded",
                                orderNote: orderNote,
                              );
                              context.read<CheckoutCubit>().submitOrder(order);
                            },
                            child: const Text(
                              'Order Now',
                              style: TextStyle(color: Colors.white),
                            ))
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
  const PaymentMethodContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return Card(
          color: Colors.white, // Matching PaymentMethodContainer1's white Card
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Matching padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomBoldText(
                  text: "Payment method",
                  // Matching PaymentMethodContainer1's header
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                RadioListTile<String>(
                  title: const Text("Cash on Delivery"),
                  value: "Cash on Delivery",
                  groupValue: state.selectedMethod,
                  onChanged: (String? value) {
                    if (value != null) {
                      context.read<CheckoutCubit>().selectPaymentMethod(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: const Text("Banking"),
                  value: "Banking",
                  groupValue: state.selectedMethod,
                  onChanged: (String? value) {
                    if (value != null) {
                      context.read<CheckoutCubit>().selectPaymentMethod(value);
                    }
                  },
                ),
              ],
            ),
          ),
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
    return Card(
      color: Colors.white,
      child: TextField(
        controller: _noteController,
        decoration: const InputDecoration(
            hintText: 'Note for shop',
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.only(left: 20)),
        textAlign: TextAlign.start,
        maxLines: null,
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
        return Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: state.selectedProducts.length,
              itemBuilder: (context, index) {
                final product = state.selectedProducts[index];
                final quantity =
                    state.selectedQuantities[product.product_id] ?? 1;
                // return ListTile(
                //   title: Text(product.product_name),
                //   subtitle: Text("Quantity : $quantity"),
                //   trailing: Text(product.product_color),
                // );
                return SizedBox(
                  height: 150,
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 1),
                          // Viền màu xám, dày 2px
                          borderRadius: BorderRadius.circular(8), // Bo góc nhẹ
                        ),
                        child: Image.network(
                          "$baseUrl${product.product_image[0]}",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error,
                                size: 80,
                                color: Colors.red); // Xử lý khi ảnh lỗi
                          },
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.product_name),
                          Text(
                            product.product_color,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomBoldText(
                                text:
                                    "đ${NumberFormat('#,###', 'vi').format(product.product_price)}",
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Text(
                                "x$quantity",
                                style: TextStyle(fontSize: 10),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class CustomerContainer extends StatelessWidget {
  const CustomerContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerCubit, CustomerState>(
      builder: (context, state) {
        final customer =
            state.customer.isNotEmpty ? state.customer.first : null;

        return SizedBox(
          width: 500,
          child: Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(13.0),
              child: customer != null
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.add_location,
                            color: Colors.deepOrange),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    customer.customerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    " (+84) ${customer.customerPhone}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                              Text("Email: ${customer.customerEmail}"),
                              Text(customer.customerAddress.split(', ').first),
                              Text(customer.customerAddress
                                  .split(', ')
                                  .skip(1)
                                  .join(', ')),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CustomerCubit>().removeCustomer();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange),
                          child: const Text("Remove",
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  : Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                        onPressed: () async {
                          final result = await Navigator.push<CustomerModel>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateCustomerScreen(),
                            ),
                          );
                          if (result != null) {
                            await context
                                .read<CustomerCubit>()
                                .createCustomer(result);
                            await context.read<CustomerCubit>().loadCustomer();
                          }
                        },
                        child: const Text("Create Customer",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
            ),
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
        return Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomBoldText(
                  text: "Details payment",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total price: "),
                    SizedBox(
                      width: 20,
                    ),
                    Text(state.totalPayment.toString())
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Ship cost: "),
                    SizedBox(
                      width: 20,
                    ),
                    Text("0")
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomBoldText(text: "Total payment: "),
                    SizedBox(
                      width: 50,
                    ),
                    CustomBoldText(text: state.totalPayment.toString())
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
