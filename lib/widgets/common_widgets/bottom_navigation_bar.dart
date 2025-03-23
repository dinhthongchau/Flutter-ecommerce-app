import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/widgets/screens/upload/upload_product_screen.dart';
import 'package:project_one/widgets/screens/list_products/list_products_screen.dart';
import 'package:project_one/widgets/screens/settings/settings_screen.dart';

import '../../common/code/calculateScreenSize.dart';
import '../../common/enum/screen_size.dart';
import 'bottom_navigation_cubit.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  final List<String> _routes = const [
    ListProductsScreen.route,
    UploadProductScreen.route,
    SettingsScreen.route,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottomNavigationCubit, int>(
      builder: (context, currentPageIndex) {
        // Tạo controller cho AnimatedNotchBottomBar, đồng bộ với Cubit
        final NotchBottomBarController controller = NotchBottomBarController(index: currentPageIndex);
        // Sửa: Sử dụng calculateScreenSize để xác định kích thước màn hình
        final double screenWidth = MediaQuery.of(context).size.width;
        final ScreenSize screenSize = calculateScreenSize(screenWidth);
        // Điều chỉnh bottomBarWidth dựa trên screenSize
        final double adjustedWidth = switch (screenSize) {
          ScreenSize.small => screenWidth, // Full width cho mobile
          ScreenSize.medium => screenWidth, // Full width cho medium
          ScreenSize.large => screenWidth, // Giới hạn 500px cho web
        };
        return AnimatedNotchBottomBar(

          notchBottomBarController: controller,
          color: Colors.deepOrange,
          showLabel: true,
          textOverflow: TextOverflow.visible,
          maxLine: 1,
          shadowElevation: 5,
          kBottomRadius: 28.0,
          notchColor: Colors.green,
          removeMargins: false,
          bottomBarWidth: adjustedWidth,
          showShadow: false,
          durationInMilliSeconds: 300,
          itemLabelStyle: const TextStyle(fontSize: 10),
          elevation: 1,


          bottomBarItems: const [
            BottomBarItem(
              inActiveItem: Icon(Icons.home_outlined, color: Colors.white),
              activeItem: Icon(Icons.home, color: Colors.white), // Màu khi được chọn

            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.upload_outlined, color: Colors.white),
              activeItem: Icon(Icons.upload, color: Colors.white), // Màu khi được chọn
              itemLabelWidget: Text(
                'Upload',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color:Colors.white, // Màu khi chọn: vàng, không chọn: trắng
                ),
              ),

            ),
            BottomBarItem(
              inActiveItem: Icon(Icons.settings_outlined, color: Colors.white),
              activeItem: Icon(Icons.settings, color: Colors.white), // Màu khi được chọn
            ),
          ],
          onTap: (int index) {
            // Cập nhật Cubit và điều hướng
            context.read<BottomNavigationCubit>().setPageIndex(index);
            Navigator.pushReplacementNamed(context, _routes[index]);
          },
          kIconSize: 24.0,
        );
      },
    );
  }
}