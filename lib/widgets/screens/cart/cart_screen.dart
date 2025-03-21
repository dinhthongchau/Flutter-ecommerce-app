import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/product_model.dart';
import '../../common_widgets/bold_text.dart';
import '../checkout/checkout_screen.dart';
import 'cart_cubit.dart';

//cart_screen.dart
class CartScreen extends StatelessWidget {
  static const String route = "CartScreen";

  const CartScreen({super.key});

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
    context.read<CartCubit>().loadCart();
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepOrange,
        title: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomBoldText(
                    text: "Cart(${state.selectedProducts.length})"),
                SizedBox(width: 40,)
              ],

            );
          },
        ),
      ),
      body: Body(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (state.cartItems.isEmpty) {
          return Center(
            child: Text("Your cart is empty"),
          );
        }
        return ListItemsInCart(
          state: state,
        );
      },
    );
  }
}

class ListItemsInCart extends StatelessWidget {
  final CartState state;

  const ListItemsInCart({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    String? baseUrl = dotenv.env['API_BASE_URL_NoApi_NoV1'];
    return SizedBox(
      child: ListView.builder(
        itemCount: state.cartItems.length,
        itemBuilder: (context, index) {
          ProductModel itemsInCart = state.cartItems[index];
          return Column(
            children: [
              CartItemListTile(baseUrl: baseUrl, itemsInCart: itemsInCart),
              Divider()
            ],
          );
        },
      ),
    );
  }
}

class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Divider(),
          Expanded(
            flex: 2,
            child: SelectAll(),
          ),
          Expanded(
            flex: 4,
            child: TotalCalculator(),
          ),
          Expanded(
            flex: 4,
            child: CheckOutButton(),
          ),
        ],
      ),
    );
  }
}

class TotalCalculator extends StatelessWidget {
  const TotalCalculator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final formatCurrency = NumberFormat.decimalPattern('vi_VN');
        String formattedTotal = formatCurrency.format(state.totalPayment);

        return Row(
          children: [
            Text(
              "Total Payment: ",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            Text(
              "đ$formattedTotal",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange),
            )
          ],
        );
      },
    );
  }
}

class SelectAll extends StatelessWidget {
  const SelectAll({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        bool allSelected = state.cartItems.every((item) => state.selectedItem
            .contains(item.product_id)); // Check if all items are selected
        return Row(
          children: [
            Checkbox(
              activeColor: Colors.deepOrange,
              checkColor: Colors.white,
              value: allSelected,
              onChanged: (value) {
                context.read<CartCubit>().toggleSelectAll();
              },
            ),
            const Text("All")
          ],
        );
      },
    );
  }
}

class CheckOutButton extends StatelessWidget {
  const CheckOutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final selectedProduct = state.cartItems
            .where((item) => state.selectedItem.contains(item.product_id))
            .toList();
        final selectedQuantities = selectedProduct.asMap().map(
            (index, product) => MapEntry(
                product.product_id, state.quantities[product.product_id] ?? 1));
        final totalPayment = state.totalPayment;

        return ElevatedButton(
            onPressed: () {
              if (state.selectedProducts.isEmpty) {
                return;
              }
              Navigator.of(context).pushNamed(CheckoutScreen.route, arguments: {
                'selectedProduct': selectedProduct,
                'selectedQuantities': selectedQuantities,
                'totalPayment': totalPayment
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text(
              "Buy now (${context.read<CartCubit>().state.selectedProducts.length})",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ));
      },
    );
  }
}

class CartItemListTile extends StatelessWidget {
  const CartItemListTile({
    super.key,
    required this.baseUrl,
    required this.itemsInCart,
  });

  final String? baseUrl;
  final ProductModel itemsInCart;

  @override
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        var cubit_cart = context.read<CartCubit>();
        bool isSelected = state.selectedItem.contains(itemsInCart.product_id);

        return Container(
          height: 150,
          //padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            children: [
              // Checkbox ở bên trái
              Checkbox(
                activeColor: Colors.deepOrange,
                checkColor: Colors.white,
                value: isSelected,
                onChanged: (value) {
                  cubit_cart.toggleSelectItem(itemsInCart.product_id);
                },
              ),

              // Ảnh sản phẩm
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        NetworkImage("$baseUrl${itemsInCart.product_image[0]}"),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: 12),

              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text(itemsInCart.product_name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Card(
                        color: Colors.white54,
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(itemsInCart.product_color),
                        )),
                    Text(
                      "đ${NumberFormat('#,###', 'vi').format(itemsInCart.product_price)}",
                      style: TextStyle(color: Colors.redAccent, fontSize: 15),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      // Giảm padding sát nhất
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<CartCubit>()
                                  .decrementQuantity(itemsInCart.product_id);
                            },
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  Center(child: Icon(Icons.remove, size: 14)),
                            ),
                          ),
                          SizedBox(
                              width: 1,
                              height: 14,
                              child: ColoredBox(color: Colors.grey)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "${state.quantities[itemsInCart.product_id] ?? 1}",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          SizedBox(
                              width: 1,
                              height: 14,
                              child: ColoredBox(color: Colors.grey)),
                          GestureDetector(
                            onTap: () {
                              context
                                  .read<CartCubit>()
                                  .incrementQuantity(itemsInCart.product_id);
                            },
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: Center(child: Icon(Icons.add, size: 14)),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // Nút xóa
              IconButton(
                onPressed: () {
                  cubit_cart.removeItem(itemsInCart.product_id);
                },
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }
}
