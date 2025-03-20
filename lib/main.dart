import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_one/main_cubit.dart';
import 'package:project_one/repositories/log.dart';
import 'package:project_one/routes.dart';
import 'package:project_one/widgets/screens/customer/customer_cubit.dart';
import 'repositories/api.dart';
import 'repositories/api_server.dart';
import 'repositories/log_implements.dart';


import 'widgets/screens/list_products/list_products_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: "lib/assets/.env");
  Log log = LogImplement();
  Bloc.observer = MyBlocObserver(log);
  runApp(Repository());
}

class Repository extends StatelessWidget {
  final Log log = LogImplement();

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Log>.value(
      value: log,
      child: Provider(),
    );
  }
}

class Provider extends StatelessWidget {
  const Provider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<Api>(
      create: (context) => ApiServer(context.read<Log>()),
      child: BlocProvider(
        create: (context) => CustomerCubit(context.read<Api>())..loadCustomer(),
        child: App(),
      ),
    );
  }
}

class App extends StatelessWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MainCubit(),
        child: SafeArea(child: MaterialApp(
          onGenerateRoute: mainRoute,
          initialRoute: ListProductsScreen.route,
        )));
  }
}
