import 'package:flutter/material.dart';
import '../data/models/order.dart';
import '../data/services/orders_service.dart';

class OrdersViewModel extends ChangeNotifier {
  final OrdersService _service = OrdersService();

  bool _isLoading = false;
  List<Order> _orders = [];

  bool get isLoading => _isLoading;
  List<Order> get orders => _orders;

  Future<void> loadPedidos() async {
    _isLoading = true;
    notifyListeners();

    try {
     final data = await _service.getPedidosActivos();
     final allOrders = data.map((p) => Order.fromJson(p)).toList();

      // Filtrar solo los pedidos del día actual
       final today = DateTime.now();
    _orders = allOrders.where((order) {
      final orderDate = DateTime.parse(order.fecha);
      return orderDate.year == today.year &&
             orderDate.month == today.month &&
             orderDate.day == today.day;
    }).toList();

    } catch (e) {
      debugPrint("❌ Error cargando pedidos: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  List<Order> getPedidosPorEstado(String estado) {
    return _orders.where((o) => o.estado.toLowerCase().contains(estado.toLowerCase())).toList();
  }
}
