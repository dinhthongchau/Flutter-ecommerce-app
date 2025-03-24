import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/widgets/screens/detail/detail_screen.dart';
import '../../../common/code/calculateScreenSize.dart';
import '../../../common/enum/load_status.dart';
import '../../../common/enum/screen_size.dart';
import '../../../repositories/api_server.dart';
import '../../common_widgets/bottom_navigation_bar.dart';
import '../../common_widgets/cart_button.dart';
import '../../common_widgets/notice_snackbar.dart';
import '../settings/settings_screen.dart';
import 'list_products_cubit.dart';
import 'package:intl/intl.dart';

class ListProductsScreen extends StatelessWidget {
  static const String route = "ListProductsScreen";

  const ListProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListProductsCubit(context.read<ApiServer>())..loadData(),
      child: Page(),
    );
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  String searchQuery = ''; // Lưu từ khóa tìm kiếm
  bool isSearching = false; // Theo dõi trạng thái tìm kiếm
  late TextEditingController _searchController; // Controller cho TextField

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.deepOrange,
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              isSearching = value.isNotEmpty;
            });
          },
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            hintStyle: TextStyle(color: Colors.white70),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.yellow,
                    width: 2
                )
            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.white,
                    width: 2
                )
            ),
            suffixIcon: isSearching
                ? IconButton(
              icon: Icon(Icons.clear, color: Colors.white),
              onPressed: () {
                setState(() {
                  searchQuery = '';
                  isSearching = false;
                  _searchController.clear();
                });
              },
            )
                : Icon(Icons.search, color: Colors.white),
          ),
        ),
        actions: [
          CartButton(),
        ],
      ),
      body: BlocConsumer<ListProductsCubit, ListProductsState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.Error) {
            ScaffoldMessenger.of(context)
                .showSnackBar(noticeSnackbar("error page1", true));
          }
        },
        builder: (context, state) {
          return Body(searchQuery: searchQuery, isSearching: isSearching);
        },
      ),
    );
  }
}


class Body extends StatelessWidget {
  final String searchQuery;
  final bool isSearching;

  const Body({super.key, required this.searchQuery, required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        if (state.loadStatus == LoadStatus.Loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListProductPage(searchQuery: searchQuery, isSearching: isSearching);
      },
    );
  }
}

class ListProductPage extends StatefulWidget {
  final String searchQuery;
  final bool isSearching;

  const ListProductPage({super.key, required this.searchQuery, required this.isSearching});

  @override
  State<ListProductPage> createState() => _ListProductPageState();
}

class _ListProductPageState extends State<ListProductPage> {
  String? selectedCategory; // null đại diện cho "See All"

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        var cubitProduct = context.read<ListProductsCubit>();
        List<ProductModel> sortedProducts = List.from(state.product)
          ..sort((a, b) => b.product_id.compareTo(a.product_id));

        // Lọc sản phẩm dựa trên từ khóa tìm kiếm hoặc danh mục được chọn
        List<ProductModel> filteredProducts;
        if (widget.isSearching && widget.searchQuery.isNotEmpty) {
          String queryLower = widget.searchQuery.toLowerCase();
          filteredProducts = sortedProducts.where((product) {
            return product.product_name.toLowerCase().contains(queryLower);
          }).toList();
        } else if (selectedCategory != null) {
          String categoryLower = selectedCategory!.toLowerCase();
          filteredProducts = sortedProducts.where((product) {
            return product.product_name.toLowerCase().contains(categoryLower);
          }).toList();
        } else {
          filteredProducts = sortedProducts;
        }

        return Column(
          children: [
            if (!widget.isSearching)
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                //color: Colors.grey[200],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton("All", null),
                    _buildCategoryButton("Iphone ", "Iphone"),
                    _buildCategoryButton("Samsung", "Samsung"),
                    _buildCategoryButton("Macbook", "Macbook"),
                  ],
                ),
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenSize = calculateScreenSize(constraints.maxWidth);
                  final crossAxisCount = switch (screenSize) {
                    ScreenSize.small => 2,
                    ScreenSize.medium => 3,
                    ScreenSize.large => 4,
                  };

                  return Center(
                    child: Container(
                      constraints: BoxConstraints(maxWidth: 1200),
                      margin: switch (screenSize) {
                        ScreenSize.small => EdgeInsets.symmetric(horizontal: 20),
                        ScreenSize.medium => EdgeInsets.symmetric(horizontal: 50),
                        ScreenSize.large => EdgeInsets.symmetric(horizontal: 100),
                      },
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          childAspectRatio: switch (screenSize) {
                            ScreenSize.small => 0.75,
                            ScreenSize.medium => 0.75,
                            ScreenSize.large => 1.2,
                          },
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return GestureDetector(
                            onTap: () {
                              // Tìm index của sản phẩm trong danh sách gốc
                              int originalIndex = state.product.indexOf(product);
                              cubitProduct.setSelectedIndex(originalIndex);
                              Navigator.of(context).pushNamed(DetailScreen.route,
                                  arguments: {'cubit_product': cubitProduct});
                            },
                            child: Card(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      "${product.product_image[0]}",
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
                                    Container(
                                      padding: EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Text(
                                            "${product.product_name} ",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            "${NumberFormat('#,###', 'vi').format(product.product_price)} đ",
                                            style: TextStyle(color: Colors.orange),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        );
      },
    );
  }

  // Hàm tạo nút danh mục
  Widget _buildCategoryButton(String label, String? category) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedCategory = category;
          // Không cần reset searchQuery/isSearching ở đây vì đã xử lý ở Page
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == category ? Colors.green : Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      child: Text(label),
    );
  }
}