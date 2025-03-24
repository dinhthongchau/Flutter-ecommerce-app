import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/models/product_model.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Colors.deepOrange, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
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
                hintText: 'Find products...',
                hintStyle: TextStyle(color: Colors.white70),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orangeAccent, // Đồng bộ với màu cam
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orangeAccent, // Đồng bộ với màu cam
                    width: 2,
                  ),
                ),
                suffixIcon: isSearching
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.white, size: 28), // Tăng kích thước biểu tượng
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      isSearching = false;
                      _searchController.clear();
                    });
                  },
                )
                    : Icon(Icons.search, color: Colors.white, size: 28), // Tăng kích thước biểu tượng
              ),
            ),
            actions: [
              CartButton(),
            ],
          ),
        ),
      ),
      body: BlocConsumer<ListProductsCubit, ListProductsState>(
        listener: (context, state) {
          if (state.loadStatus == LoadStatus.Error) {
            ScaffoldMessenger.of(context)
                .showSnackBar(noticeSnackbar("error from API, can not loading. Contact admin to fix", true));
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

        return SingleChildScrollView(
          child: Column(
            children: [
              // Phần danh mục (category buttons)
              if (!widget.isSearching)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
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
              // Phần Image.network

              !(selectedCategory == "Macbook" || selectedCategory == "Iphone" || selectedCategory == "Samsung")
                  ? Container(

                margin: EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(

                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    "https://theme.hstatic.net/200000571041/1001034712/14/right_banner_2.jpg?v=599",
                    fit: BoxFit.cover,
                    height: 200,
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
                ),
              ):Container(),
              SizedBox(height: 20,),
              // Phần GridView cho danh sách sản phẩm
              Container(
                //height: MediaQuery.of(context).size.height, // Chiều cao cố định cho GridView
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
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(), // Hỗ trợ cuộn trong SingleChildScrollView
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: switch (screenSize) {
                              ScreenSize.small => 0.65,
                              ScreenSize.medium => 0.75,
                              ScreenSize.large => 0.75,
                            },
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = filteredProducts[index];
                            return GestureDetector(
                              onTap: () {
                                int originalIndex = state.product.indexOf(product);
                                cubitProduct.setSelectedIndex(originalIndex);
                                Navigator.of(context).pushNamed(DetailScreen.route,
                                    arguments: {'cubit_product': cubitProduct});
                              },
                              child: SingleChildScrollView(
                                child: Container(

                                  child: CardOfProducts(product: product),
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
          ),
        );
      },
    );
  }

  // Hàm tạo nút danh mục
  Widget _buildCategoryButton(String label, String? category) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedCategory = category;
            // Không cần reset searchQuery/isSearching ở đây vì đã xử lý ở Page
          });
        },
        style: ElevatedButton.styleFrom(
          shape:RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ) ,
          elevation: 5,
          backgroundColor: selectedCategory == category ? Colors.deepOrange : Colors.orange,
          foregroundColor: selectedCategory ==category ? Colors.white : Colors.white,
        ),
        child: Text(label),
      ),
    );
  }
}

class CardOfProducts extends StatelessWidget {
  const CardOfProducts({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),

      child: Stack(
        children: [
          Column(

            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
                child: Image.network(
                  "${product.product_image[0]}",
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print("Image Load Error: $error");
                    return Icon(Icons.error, color: Colors.red);
                  },
                ),
              ),
              Container(
                padding: EdgeInsets.all(20),
                height: 130,
                child: Column(
                  children: [
                    Text(
                      "${product.product_name} ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 3, // Giới hạn 2 dòng
                      overflow: TextOverflow.ellipsis, // Cắt bớt nếu quá dài
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),

                  ],
                ),
              ),
            ],
          ),

          Positioned(
            right: 30,
            bottom: 15,
            left: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange, Colors.orange], // Gradient từ đỏ đến đỏ nhạt
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(5), // Bo góc
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2), // Đổ bóng nhẹ
                    ),
                  ],
                ),
                child: Text(
                  "${NumberFormat('#,###', 'vi').format(product.product_price)} đ",
                  style: TextStyle(color: Colors.white
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 5,
            child: Opacity(
              opacity: 0.7,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.greenAccent], // Gradient từ đỏ đến đỏ nhạt
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(5), // Bo góc
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2), // Đổ bóng nhẹ
                    ),
                  ],
                ),
                child: Text(
                  "2nd",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              return Positioned(
            bottom: 5, // Cách bottom 10px
            right: 5,  // Cách right 10px
            child: FloatingActionButton(
              mini: true, // Kích thước nhỏ hơn nếu muốn
              onPressed: () {
                // Xử lý sự kiện thêm vào giỏ hàng tại đây
                context.read<CartCubit>().addToCart(context, product, {product.product_id: 1});
                ScaffoldMessenger.of(context)
                    .showSnackBar(noticeSnackbar("Added to cart", false));
              },
              backgroundColor: Colors.deepOrange,
              child: Icon(Icons.add, color: Colors.white,), // Màu nền của nút
            ),
          );
      },
    ),

        ],
      ),
    );
  }
}