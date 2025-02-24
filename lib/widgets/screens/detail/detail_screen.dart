import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/cart/cart_screen.dart';
import 'package:project_one/widgets/screens/list_products/list_products_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          bottomNavigationBar: bottomNavigatonBar(),
          appBar: AppBar(
            title: Row(
              children: [
                Text("Detail Screen"),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.route);
                    },
                    child: Text("Cart"))
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
              child: Column(
                children: [
                  _buildSizedBoxForImages(product, baseUrl),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(index,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut); //hieu ung click
                            },
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: _currentIndex == index
                                          ? Colors.deepOrange
                                          : Colors.transparent,
                                      width: 2),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          "$baseUrl${product.product_image[index]}"),
                                      fit: BoxFit.cover)),
                            ));
                      },
                      itemCount: product.product_image.length,
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
                          style:
                              TextStyle(color: Colors.redAccent, fontSize: 25),
                        ),
                        Text(product.product_name),
                        // Text(product.product_price),

                        SizedBox(
                          height: 20,
                        ),
                        Text("Description : "),
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
                      child: Text(
                          "$_currentIndex/${product.product_image.length}"),
                      bottom: 20,
                      right: 10,
                    ),
                  ]),
                );
  }
}

class bottomNavigatonBar extends StatelessWidget {
  const bottomNavigatonBar({super.key});

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
      child: TextButton(
          onPressed: () {},
          child: Text(
            "Buy Now",
            style: TextStyle(color: Colors.white),
          )),
    );
  }
}

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final product = context
        .read<ListProductsCubit>()
        .state
        .product[context.read<ListProductsCubit>().state.selectedItem];
    //print("Hello $product");
    return Container(
      height: 50,
      color: Colors.green,
      child: BlocProvider(
  create: (context) => CartCubit()..loadCart(),
  child: BlocBuilder<CartCubit, CartState>(
  builder: (context, state) {
    return TextButton(
        onPressed: () {
          context.read<CartCubit>().addToCart(context, product);
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
            ))
          ],
        ),
      );
  },
),
),
    );
  }
}
