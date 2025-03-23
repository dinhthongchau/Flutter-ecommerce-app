import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/product_model.dart';
import '../../../common/code/calculateScreenSize.dart';
import '../../../common/enum/screen_size.dart';
import '../../common_widgets/common_styles.dart';
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
                CommonStyles.boldTextWidget(
                    "Cart(${state.selectedProducts.length})"),
                SizedBox(
                  width: 40,
                )
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
            child: const Text("Your cart is empty"),
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
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = calculateScreenSize(width);
    String? baseUrl = dotenv.env['API_BASE_URL'];
    return Container(
      margin: screenSize == ScreenSize.small
          ? EdgeInsets.symmetric(horizontal: 0)  // Điện thoại
          : screenSize == ScreenSize.medium
          ? EdgeInsets.symmetric(horizontal: 100)  // Tablet
          : EdgeInsets.symmetric(horizontal: 400),  // Desktop
      child: SizedBox(
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
      ),
    );
  }
}

class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({super.key});


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = calculateScreenSize(width);
    return Container(
      margin: screenSize == ScreenSize.small
          ? EdgeInsets.symmetric(horizontal: 0)  // Điện thoại
          : screenSize == ScreenSize.medium
          ? EdgeInsets.symmetric(horizontal: 100)  // Tablet
          : EdgeInsets.symmetric(horizontal: 400),  // Desktop
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
            Text("All")
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
            child:  Text(
              "Buy now (${context.read<CartCubit>().state.selectedProducts.length})",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cubit = context.read<CartCubit>();
        final isSelected = state.selectedItem.contains(itemsInCart.product_id);
        final quantity = state.quantities[itemsInCart.product_id] ?? 1;

        return Container(
          height: 150, // Giữ nguyên chiều cao như code gốc
          padding: const EdgeInsets.symmetric(
              vertical: 8), // Thêm padding nhẹ để căn đều
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildCheckbox(cubit, isSelected),
              _buildProductImage(),
              const SizedBox(width: 12),
              _buildProductDetails(context, quantity),
              _buildDeleteButton(cubit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(CartCubit cubit, bool isSelected) {
    return Checkbox(
      activeColor: Colors.deepOrange,
      checkColor: Colors.white,
      value: isSelected,
      onChanged: (_) => cubit.toggleSelectItem(itemsInCart.product_id),
    );
  }

  Widget _buildProductImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        image: DecorationImage(
          //image: NetworkImage("$baseUrl${itemsInCart.product_image[0]}"),
          image: NetworkImage("${itemsInCart.product_image[0]}"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, int quantity) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            itemsInCart.product_name,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Card(
            color: Colors.white54,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child:  Text(itemsInCart.product_color),
            ),
          ),
          Text(
            "đ${NumberFormat('#,###', 'vi').format(itemsInCart.product_price)}",
            style: TextStyle(color: Colors.redAccent, fontSize: 15),
          ),
          _buildQuantityControls(context, quantity),
        ],
      ),
    );
  }

  Widget _buildQuantityControls(BuildContext context, int quantity) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => context
                .read<CartCubit>()
                .decrementQuantity(itemsInCart.product_id),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.remove, size: 14),
            ),
          ),
          const SizedBox(width: 8),
          Text("$quantity", style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context
                .read<CartCubit>()
                .incrementQuantity(itemsInCart.product_id),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: Icon(Icons.add, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(CartCubit cubit) {
    return IconButton(
      onPressed: () => cubit.removeItem(itemsInCart.product_id),
      icon: const Icon(Icons.delete, color: Colors.red),
    );
  }
}
