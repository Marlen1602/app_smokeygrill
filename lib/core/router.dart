import 'package:flutter/material.dart';
import '../core/ui/screens/login_screen.dart';
import '../core/ui/screens/active_orders_screen.dart';
import '../core/ui/screens/pedido_screen.dart';
import 'package:provider/provider.dart';
import '../viewmodels/pedido_viewmodel.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // 🔹 Pantalla de login
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      // 🔹 Pantalla principal (pedidos activos)
      case '/pedidos':
        return MaterialPageRoute(builder: (_) => const ActiveOrdersScreen());

      // 🔹 Registrar nuevo pedido (desde el botón +)
      case '/registrarPedido':
        final args = settings.arguments as Map<String, dynamic>?;
        final tipoCuenta = args?['tipoCuenta'] ?? 'unica';
        return MaterialPageRoute(
          builder: (context) {
            final pedidoVM = Provider.of<PedidoViewModel>(context, listen: false);
            pedidoVM.cambiarTipoCuenta(tipoCuenta);
            pedidoVM.activarModoLectura(false);
            return const PedidoScreen(esNuevo: true);
          },
        );

      // 🔹 Ver detalle de pedido existente
      case '/detallePedido':
        final pedido = settings.arguments;
        return MaterialPageRoute(
          builder: (context) => PedidoScreen(
            esNuevo: false,
            pedido: pedido,
          ),
        );

      // 🔹 Ruta por defecto
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Ruta no encontrada')),
          ),
        );
    }
  }
}
