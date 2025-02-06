import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_one/widgets/screens/list_products/list_products_cubit.dart';

class DetailScreen extends StatelessWidget {
  static const String route = "DetailScreen";

  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ListProductsCubit, ListProductsState>(
      builder: (context, state) {
        return Container(
            child: Column(
              children: [
                Text("Name product: ${state.product[state.selectedItem].product_price}")
              ],
            ),
        );
      },
    );
  }
}
