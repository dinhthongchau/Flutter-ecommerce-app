import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/customer_model.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/checkout/checkout_cubit.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
import 'package:project_one/widgets/screens/list_products/list_products_screen.dart';
import '../../../common/code/calculateScreenSize.dart';
import '../../../common/enum/load_status.dart';
import '../../../common/enum/screen_size.dart';
import '../../common_widgets/bold_text.dart';
import '../../common_widgets/notice_snackbar.dart';
import '../customer/create_customer_screen.dart';
import '../settings/main_cubit.dart';

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
    super.initState();
    context.read<MainCubit>().setTheme(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
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
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = calculateScreenSize(width);
    final TextEditingController _noteController = TextEditingController();

    return BlocListener<CheckoutCubit, CheckoutState>(
      listener: (context, state) {
        if (state.loadStatus == LoadStatus.Done) {
          _showSuccessOrderDialog(context);
        } else if (state.loadStatus == LoadStatus.Error) {
          ScaffoldMessenger.of(context).showSnackBar(
              noticeSnackbar("Order failed ! Please try again", true));
        }
      },
      child: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state.loadStatus == LoadStatus.Loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final customer =
              state.customer.isNotEmpty ? state.customer.first : null;
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              return Container(
                margin: screenSize == ScreenSize.small
                    ? EdgeInsets.symmetric(horizontal: 0) //Phone
                    : screenSize == ScreenSize.medium
                        ? EdgeInsets.symmetric(horizontal: 100) // Tablet
                        : EdgeInsets.symmetric(horizontal: 400),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      CustomerContainer(),
                      ProductOrderContainer(),
                      NoteContainer(noteController: _noteController),
                      PaymentMethodContainer(),
                      DetailPaymentContainer(),
                      // Thay toàn bộ ElevatedButton trong build của Body
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          if (customer == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                noticeSnackbar(
                                    "Please tạo khách hàng trước! ", true));
                            return;
                          }
                          context.read<CheckoutCubit>().placeOrder(
                                context: context,
                                customer: customer,
                                selectedProducts: cartState.selectedProducts,
                                selectedQuantities:
                                    cartState.selectedQuantities,
                                totalPayment: cartState.totalPayment.toDouble(),
                                paymentMethod: context
                                    .read<CheckoutCubit>()
                                    .state
                                    .selectedMethod,
                                note: _noteController.text,
                              );
                        },
                        child: BlocBuilder<CheckoutCubit, CheckoutState>(
                          builder: (context, checkoutState) {
                            return checkoutState.loadStatus ==
                                    LoadStatus.Loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text(
                                    'Order Now',
                                    style: TextStyle(color: Colors.white),
                                  );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _showSuccessOrderDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 48),
          const SizedBox(height: 8),
          Text(
            "Order Successful! ",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        "A confirmation email has been sent to your email and the admin's email. . ",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.black54),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                ListProductsScreen.route,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    ),
  );
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
                  title: Text("Cash on Delivery"),
                  value: "Cash on Delivery",
                  groupValue: state.selectedMethod,
                  onChanged: (String? value) {
                    if (value != null) {
                      context.read<CheckoutCubit>().selectPaymentMethod(value);
                    }
                  },
                ),
                RadioListTile<String>(
                  title: Text("Banking"),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomBoldText(
                  text: "List products: ",
                  // Matching PaymentMethodContainer1's header
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: state.selectedProducts.length,
                  itemBuilder: (context, index) {
                    final product = state.selectedProducts[index];
                    final quantity =
                        state.selectedQuantities[product.product_id] ?? 1;
                    return SizedBox(
                      height: 150,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1),
                              // Viền màu xám, dày 2px
                              borderRadius:
                                  BorderRadius.circular(8), // Bo góc nhẹ
                            ),
                            child: Image.network(
                              //"$baseUrl${product.product_image[0]}",
                              "${product.product_image[0]}",
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
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.product_name,
                                  maxLines: 3,
                                  softWrap: true,
                                ),
                                Text(
                                  product.product_color,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                            ),
                          )
                        ],
                      ),
                    );
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
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  ),
                                  Text(
                                    " (+84) ${customer.customerPhone}",
                                    style: TextStyle(
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
                              backgroundColor: Colors.red),
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
                            if (!context.mounted) return;
                            await context
                                .read<CustomerCubit>()
                                .createCustomer(result);
                            if (!context.mounted) return;

                            await context.read<CustomerCubit>().loadCustomer();
                          }
                        },
                        child: const Text("Tạo thông tin khách hàng ",
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
                  children: [
                    Text("Total price: "),
                    Spacer(),
                    Text(state.totalPayment.toString())
                  ],
                ),
                Row(
                  children: [Text("Ship cost: "), Spacer(), Text("0")],
                ),
                Row(
                  children: [
                    CustomBoldText(text: "Total payment: "),
                    Spacer(),
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
