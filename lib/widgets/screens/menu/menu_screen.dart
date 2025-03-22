import 'package:flutter/material.dart';

import 'package:project_one/widgets/screens/settings/settings_screen.dart';
import '../../common_widgets/bold_text.dart';

class MenuScreen extends StatelessWidget {
  static const String route = "MenuScreen";

  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ListTile(
            title: Center(child: CustomBoldText(text: "Menu")),
          ),
          ListTile(
            tileColor: Colors.deepOrangeAccent,
            title: Row(
              children: [Text("Settings"), Icon(Icons.settings)],
            ),
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.route);
            },
          )
        ],
      ),
    );
  }
}
