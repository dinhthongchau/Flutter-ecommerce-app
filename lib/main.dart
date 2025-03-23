import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/main_cubit.dart';
import 'package:project_one/repositories/log.dart';
import 'package:project_one/routes.dart';
import 'package:project_one/widgets/screens/cart/cart_cubit.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
import 'repositories/api.dart';
import 'repositories/api_server.dart';
import 'repositories/log_implements.dart';

import 'widgets/screens/list_products/list_products_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "assets/dotenv");
  final log = LogImplement(); // Khởi tạo log như gốc
  Bloc.observer = MyBlocObserver(log);
  runApp(Repository(log: log)); // Truyền log vào Repository
}

class Repository extends StatelessWidget {
  final Log log;

  const Repository({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Log>.value(
      value: log,
      child: const Provider(),
    );
  }
}

class Provider extends StatelessWidget {
  const Provider({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Api>(
      create: (context) => ApiServer(context.read<Log>()),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                CustomerCubit(context.read<Api>())..loadCustomer(),
          ),
          BlocProvider(
            create: (context) => CartCubit()..loadCart(),
          ),
        ],
        child: const App(),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MainCubit(),
      child: SafeArea(
        child: BlocBuilder<MainCubit, MainState>(
          builder: (context, state) {
            return MaterialApp(
              darkTheme: ThemeData.dark(),
              theme: ThemeData.light(),
              themeMode: state.isLightTheme ? ThemeMode.light : ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              onGenerateRoute: mainRoute,
              initialRoute: ListProductsScreen.route,
            );
          },
        ),
      ),
    );
  }
}
