

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';

import 'package:project_one/widgets/screens/checkout/checkout_screen.dart';
import 'package:project_one/widgets/screens/list_products/list_products_cubit.dart';


import '../../../common/code/calculateScreenSize.dart';
import '../../../common/enum/screen_size.dart';
import '../../common_widgets/bold_text.dart';
import '../../common_widgets/cart_button.dart';

//detail_screen.dart
class DetailScreen extends StatefulWidget {
  static const String route = "DetailScreen";

  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

final PageController _pageController = PageController();

class _DetailScreenState extends State<DetailScreen> {
  // Điều khiển PageView, giúp cuộn qua ảnh sản phẩm.
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = calculateScreenSize(width);
    String? baseUrl = dotenv.env['API_BASE_URL_NoApi_NoV1'];

    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        if (state.product.isEmpty ||
            state.selectedItem >= state.product.length) {
          return Center(child: const Text("Không có sản phẩm nào!"));
        }
        var product = state.product[state.selectedItem];
        //print("Image detail is $baseUrl${product.product_image[2]}");
        return Scaffold(

          bottomNavigationBar: BottomNavigationBar(),
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.deepOrange,
            title: Row(
              children: [
                Spacer(),
                const Text("Detail Screen"),
                Spacer(),
                CartButton(),
              ],
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Container(

              margin: screenSize == ScreenSize.small
                  ? EdgeInsets.symmetric(horizontal: 0)  // Điện thoại
                  : screenSize == ScreenSize.medium
                  ? EdgeInsets.symmetric(horizontal: 100)  // Tablet
                  : EdgeInsets.symmetric(horizontal: 400),  // Desktop
              child: Column(
                children: [
                  _buildSizedBoxForImages(product, baseUrl),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.product_image.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(index,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut); //hieu ung click
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _currentIndex == index
                                    ? Colors.deepOrange
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: kIsWeb
                            //check if is web
                                ? Image.network(
                              "$baseUrl${product.product_image[index]}",
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                print("Error loading $baseUrl${product.product_image[index]}: $error");
                                return Icon(Icons.error);
                              },
                            )
                                : CachedNetworkImage(
                              imageUrl: "$baseUrl${product.product_image[index]}",
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) {
                                print("Error loading $url: $error");
                                return Icon(Icons.error);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomLeft,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "đ${NumberFormat('#,###', 'vi').format(product.product_price)} ",
                          style: TextStyle(color: Colors.redAccent, fontSize: 25),
                        ),
                        Text(
                          product.product_name,
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        // Text(product.product_price),

                        SizedBox(
                          height: 20,
                        ),

                        CustomBoldText(
                          text: "Description : ",
                          style: TextStyle(fontSize: 20),
                        ),
                        Divider(
                          height: 2,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(product.product_description),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SizedBox _buildSizedBoxForImages(ProductModel product, String? baseUrl) {
    var numberCurrentIndex = _currentIndex + 1;
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = calculateScreenSize(width);

    double imageHeight = screenSize == ScreenSize.small ? 300
        : screenSize == ScreenSize.medium ? 400
        : 500; // Desktop
    return SizedBox(
      height: imageHeight,
      child: Stack(children: [
        PageView.builder(
          controller: _pageController,
          itemCount: product.product_image.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage(
                          "$baseUrl${product.product_image[index]}"),
                      fit: BoxFit.contain)),
            );
          },
        ),
        Positioned(
          bottom: 20,
          right: 10,
          child:  Text("$numberCurrentIndex/${product.product_image.length}"),
        ),
      ]),
    );
  }
}

class BottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    ScreenSize screenSize = calculateScreenSize(width);

    double buttonHeight = screenSize == ScreenSize.small ? 50
        : screenSize == ScreenSize.medium ? 60
        : 70; // Desktop

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: AddToCartButton(),
          ),
        ),
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: BuyNowButton(),
          ),
        ),
      ],
    );
  }
}


class BuyNowButton extends StatelessWidget {
  const BuyNowButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.deepOrange,
      child: BlocBuilder<ListProductsCubit, ListProductsState>(
        builder: (context, state) {
          final selectedProduct = context
              .read<ListProductsCubit>()
              .state
              .product[context.read<ListProductsCubit>().state.selectedItem];
          return TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(CheckoutScreen.route, arguments: {
                  'selectedProduct': [selectedProduct],
                  'selectedQuantities': {selectedProduct.product_id: 1},
                  'totalPayment': selectedProduct.product_price,
                });
              },
              child: const Text(
                "Buy Now",
                style: TextStyle(color: Colors.white),
              ));
        },
      ),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final product = context
        .read<ListProductsCubit>()
        .state
        .product[context.read<ListProductsCubit>().state.selectedItem];

    return Container(
      height: 50,
      color: Colors.green,
      child: BlocBuilder<CartCubit, CartState>(
        // Dùng instance từ main.dart
        builder: (context, state) {
          return TextButton(
            onPressed: () {
              final cartCubit = context.read<CartCubit>();
              showModalBottomSheet(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: cartCubit,
                  child: BottomSheetWidget(product: product),
                ),
              );
            },
            child: Column(
              children: [
                Expanded(
                  child: Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: const Text(
                    "Add to Cart",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class BottomSheetWidget extends StatelessWidget {
  final ProductModel product;

  const BottomSheetWidget({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartCubit = context.read<CartCubit>();
        return Container(
          height: 150,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildQuantitySelector(context, cartCubit),
              const SizedBox(height: 10),
              _buildAddToCartButton(context, cartCubit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuantitySelector(BuildContext context, CartCubit cartCubit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Quantity"),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: cartCubit.decrementQuantityInDetailScreen,
            ),
            Text("${cartCubit.quantity}"),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: cartCubit.incrementQuantityInDetailScreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(BuildContext context, CartCubit cartCubit) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          final quantities = {product.product_id: cartCubit.quantity};
          cartCubit.addToCart(context, product, quantities);
          _showSuccessDialog(context);
        },
        icon: const Icon(Icons.add_shopping_cart_sharp, color: Colors.white),
        label: Text("Add to Cart", style: TextStyle(color: Colors.white)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
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
              "Product added successfully!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          "The item has been added to your cart.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close bottom sheet
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("OK",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
