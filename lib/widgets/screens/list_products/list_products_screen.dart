
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/repositories/api.dart';
import 'package:project_one/widgets/common_widgets/bold_text.dart';
import 'package:project_one/widgets/screens/detail/detail_screen.dart';
import 'package:project_one/widgets/screens/menu/menu_screen.dart';
import '../../../common/code/calculateScreenSize.dart';
import '../../../common/enum/load_status.dart';
import '../../../common/enum/screen_size.dart';
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
      create: (context) => ListProductsCubit(context.read<Api>())..loadData(),
      child: Page(),
    );
  }
}

class Page extends StatelessWidget {
  const Page({super.key});

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
                child: Center(child: CustomBoldText(text: "List Products"))),
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
  const Body({super.key});

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
class ListProductPage extends StatefulWidget {
  const ListProductPage({super.key});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  String? baseUrl = dotenv.env['API_BASE_URL'];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        var cubitProduct = context.read<ListProductsCubit>();
        List<ProductModel> sortedProducts = List.from(state.product)
          ..sort((a, b) => b.product_id.compareTo(a.product_id)); // Sắp xếp giảm dần theo product_id

        return LayoutBuilder(
          builder: (context, constraints) {
            // Tính toán kích thước màn hình
            final screenSize = calculateScreenSize(constraints.maxWidth);

            // Điều chỉnh số lượng cột dựa trên kích thước màn hình
            final crossAxisCount = switch (screenSize) {
              ScreenSize.small => 2,  // 2 cột cho màn hình nhỏ
              ScreenSize.medium => 3, // 3 cột cho màn hình trung bình
              ScreenSize.large => 4,  // 4 cột cho màn hình lớn
            };

            return Center(
              child: Container(
                // Giới hạn chiều rộng tối đa
                constraints: BoxConstraints(maxWidth: 1200), // Có thể điều chỉnh giá trị này
                margin: switch (screenSize) {
                  ScreenSize.small => EdgeInsets.symmetric(horizontal: 20), // 20px cho màn hình nhỏ
                  ScreenSize.medium => EdgeInsets.symmetric(horizontal: 50), // 50px cho màn hình trung bình
                  ScreenSize.large => EdgeInsets.symmetric(horizontal: 100), // 100px cho màn hình lớn
                },// Khoảng trống hai bên
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: state.product.length,
                  itemBuilder: (context, index) {
                    final product = sortedProducts[index];
                    return GestureDetector(
                      onTap: () {
                        cubitProduct.setSelectedIndex(index);
                        Navigator.of(context).pushNamed(DetailScreen.route,
                            arguments: {'cubit_product': cubitProduct});
                      },
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // if (kIsWeb)
                            // // Hiển thị trên web
                          Image.network(
                          //"https://storage.googleapis.com/project1-flutter-454507.appspot.com/uploads/1742707776299-552752944-images.png",
                            //  "$baseUrl${state.product[index].product_image[0]}",
                            "${state.product[index].product_image[0]}",
                          fit: BoxFit.contain,
                            height: 150,
                            width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print("Image Load Error: $error");
                            return Icon(Icons.error, color: Colors.red);
                          },
                        ),




                          // Expanded(
                            //   child: Image.network(
                            //     // "$baseUrl${state.product[index].product_image[0]}",
                            //     "https://storage.googleapis.com/project1-flutter-454507.appspot.com/uploads/1742707776299-552752944-images.png",
                            //     height: 150,
                            //     width: double.infinity,
                            //     fit: BoxFit.contain,
                            //     loadingBuilder: (context, child, loadingProgress) {
                            //       if (loadingProgress == null) return child;
                            //       return Center(child: CircularProgressIndicator());
                            //     },
                            //     errorBuilder: (context, error, stackTrace) {
                            //       print("Image Load Error: $error");
                            //       print("Stack Trace: $stackTrace");
                            //       return Icon(Icons.error,color: Colors.red,);
                            //     },
                            //   ),
                            // ),
                            // else
                            // Hiển thị trên Android
                            //   Expanded(
                            //     child:
                            //
                            //     CachedNetworkImage(
                            //       imageUrl:
                            //       "$baseUrl${state.product[index].product_image[0]}",
                            //       height: 150,
                            //       width: double.infinity,
                            //       fit: BoxFit.contain,
                            //       placeholder: (context, url) =>
                            //       new CircularProgressIndicator(),
                            //       errorWidget: (context, url, error) =>
                            //           Icon(Icons.error),
                            //     ),
                            //   ),
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
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}