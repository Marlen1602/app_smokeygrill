import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/router.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/orders_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Cargar variables de entorno (.env)
  await dotenv.load(fileName: "assets/config/.env");
  print("🌍 API_URL = ${dotenv.env['API_URL']}");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => OrdersViewModel()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smoke & Grill',
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
