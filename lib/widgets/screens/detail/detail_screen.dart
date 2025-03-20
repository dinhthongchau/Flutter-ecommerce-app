import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/cart/cart_screen.dart';
import 'package:project_one/widgets/screens/checkout/checkout_screen.dart';
import 'package:project_one/widgets/screens/list_products/list_products_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/bold_text.dart';
import '../../common_widgets/cart_button.dart';
import '../../common_widgets/notice_snackbar.dart';

//thêm nút điều hướng tría phải và mô ta tỉnh bay dep hon . (not now)
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
    String? baseUrl = dotenv.env['API_BASE_URL_NoApi_NoV1'];
    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        if (state.product.isEmpty ||
            state.selectedItem >= state.product.length) {
          return Center(child: Text("Không có sản phẩm nào!"));
        }
        var product = state.product[state.selectedItem];
        //print("Image detail is $baseUrl${product.product_image[2]}");
        return Scaffold(
          bottomNavigationBar: BottomNavigationBar(),
          appBar: AppBar(
            title: Row(
              children: [
                Expanded(
                    flex: 8,
                    child: Center(child: CustomBoldText(text: "List Product"))),

                Expanded(flex: 2,child: CartButton()),

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
                          child: CachedNetworkImage(
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
                      Text(product.product_name,style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                      // Text(product.product_price),

                      SizedBox(
                        height: 20,
                      ),

                      CustomBoldText(text: "Description : ",style: TextStyle(fontSize: 20),),
                      Divider(height: 2,),
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
        );
      },
    );
  }

  SizedBox _buildSizedBoxForImages(ProductModel product, String? baseUrl) {
    var numberCurrentIndex = _currentIndex + 1;
    return SizedBox(
      height: 450,
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
          child: Text("$numberCurrentIndex/${product.product_image.length}"),
        ),
      ]),
    );
  }
}

class BottomNavigationBar extends StatelessWidget {
  const BottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: AddToCartButton(),
        ),
        Expanded(
          child: BuyNowButton(),
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
              child: Text(
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
      child: BlocBuilder<CartCubit, CartState>( // Dùng instance từ main.dart
        builder: (context, state) {
          return TextButton(
            onPressed: () {
              final cartCubit = context.read<CartCubit>();
              showModalBottomSheet(
                context: context,
                builder: (context) => BlocProvider.value(
                  value: cartCubit, // Truyền instance từ main.dart
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
                  child: Text(
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

  const BottomSheetWidget({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Container(
          height: 150,
          child: Column(
            mainAxisSize: MainAxisSize.min, // Giúp column chỉ chiếm không gian cần thiết
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(

                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Quanlity"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () {
                                  cartCubit.decrementQuantityInDetailScreen();
                                },
                                icon: Icon(Icons.remove)),
                            Text("${context.read<CartCubit>().quantity}"),
                            IconButton(
                                onPressed: () {
                                  cartCubit.incrementQuantityInDetailScreen();
                                },
                                icon: Icon(Icons.add)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 400,
                    child: ElevatedButton(
                      onPressed: () {
                        Map<int, int> qualities = {
                          product.product_id: cartCubit.quantity
                        };
                        cartCubit.addToCart(context, product, qualities);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange
                      ),
                      child: Text("Add to Cart",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
