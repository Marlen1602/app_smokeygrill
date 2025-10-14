import 'package:flutter/material.dart';
import './ui/screens/login_screen.dart';
import './ui/screens/active_orders_screen.dart';
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/pedidos':
        return MaterialPageRoute(builder: (_) => const ActiveOrdersScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
