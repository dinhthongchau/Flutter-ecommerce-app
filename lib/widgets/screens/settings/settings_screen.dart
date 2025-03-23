import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../main_cubit.dart';
import '../../common_widgets/bottom_navigation_bar.dart';

class SettingsScreen extends StatelessWidget {
  static const String route = "SettingsScreen";

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavigationBar(),
      appBar: AppBar(
        title: Center(
            child: Row(
          children: [
            Text("Settings Screen"),
          ],
        )),
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.deepOrangeAccent,
        ),
        padding: EdgeInsets.all(30),
        margin: EdgeInsets.all(30),
        child: Row(
          children: [
            Flexible(flex: 5, child: const Text("Light mode ")),
            BlocBuilder<MainCubit, MainState>(
              builder: (context, state) {
                var isLightTheme = state.isLightTheme;
                return Flexible(
                    flex: 5,
                    child: Switch(
                        value: isLightTheme,
                        activeColor: Colors.black,
                        onChanged: (value) {
                          isLightTheme = value;
                          context.read<MainCubit>().setTheme(isLightTheme);
                        }));
              },
            )
          ],
        ),
      ),
    );
  }
}
