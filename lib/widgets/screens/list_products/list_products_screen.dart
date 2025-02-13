import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/screens/cart/cart_screen.dart';
import 'package:project_one/widgets/screens/detail/detail_screen.dart';

import '../../../common/enum/load_status.dart';
import '../../common_widgets/notice_snackbar.dart';
import 'list_products_cubit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListProductsScreen extends StatelessWidget {
  static const String route = "ListProductsScreen";

  const ListProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // read API
      create: (context) => ListProductsCubit(context.read<Api>())..loadData(),
      child: Page(),
    );
  }
}

class Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Text("Drawer"),
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(flex: 2, child: Text("List Products")),
            Expanded(
                flex: 1,
                child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(CartScreen.route);
                    },
                    icon: Icon(Icons.shopping_cart))),
            Expanded(
                flex: 1,
                child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Login",
                      style: TextStyle(backgroundColor: Colors.orangeAccent),
                    )))
          ],
        ),
      ),
      body: BlocConsumer<ListProductsCubit, ListProductsState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.Error) {
            ScaffoldMessenger.of(context)
                .showSnackBar(noticeSnackbar("error page1", true));
          }
        },
        builder: (context, state) {
          return Body();
        },
      ),
    );
  }
}

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.Loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListProductPage();
      },
    );
  }
}

class ListProductPage extends StatelessWidget {
  String? baseUrl = dotenv.env['API_BASE_URL_NoApi_NoV1'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        var cubit_product = context.read<ListProductsCubit>();

        return Container(
          child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: state.product.length,
              itemBuilder: (context, index) {
                print(
                    "Image URL: $baseUrl${state.product[index].product_image[0]}");
                print("Image URL: ${state.product[index].product_image[0]}");
                return GestureDetector(
                  onTap: () {
                    cubit_product.setSelectedIndex(index);
                    Navigator.of(context).pushNamed(DetailScreen.route,
                        arguments: {'cubit_product': cubit_product});
                  },
                  child: Card(
                    child: Column(
                      children: [
                        Image.network(
                          "$baseUrl${state.product[index].product_image[0]}",
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Text(
                                "${state.product[index].product_name} ",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 4,
                              ),
                              Text(
                                "${NumberFormat('#,###', 'vi').format(state.product[index].product_price)} đ",
                                style: TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                ;
              }),
        );
      },
    );
  }
}
