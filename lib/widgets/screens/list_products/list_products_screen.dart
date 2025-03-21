import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/common_widgets/bold_text.dart';
import 'package:project_one/widgets/screens/cart/cart_screen.dart';
import 'package:project_one/widgets/screens/detail/detail_screen.dart';
import 'package:project_one/widgets/screens/menu/menu_screen.dart';
import '../../../common/enum/load_status.dart';
import '../../common_widgets/cart_button.dart';
import '../../common_widgets/notice_snackbar.dart';
import 'list_products_cubit.dart';
import 'package:intl/intl.dart';


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
        child: MenuScreen(),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepOrange,

        title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 8,
                child: Center(child: CustomBoldText(text: "List Products"))
            ),


            Expanded(
                flex: 2,
                child: CartButton(),
            ),
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
                return GestureDetector(
                  onTap: () {
                    cubit_product.setSelectedIndex(index);
                    Navigator.of(context).pushNamed(DetailScreen.route,
                        arguments: {'cubit_product': cubit_product});
                  },
                  child: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        CachedNetworkImage(

                          imageUrl:
                              "$baseUrl${state.product[index].product_image[0]}",

                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
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

              }),
        );
      },
    );
  }
}
