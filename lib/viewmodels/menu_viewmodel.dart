import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../data/models/producto.dart';

class MenuViewModel extends ChangeNotifier {
  List<Producto> _productos = [];
  List<Producto> _carrito = [];
  bool _cargando = false;

  List<Producto> get productos => _productos;
  List<Producto> get carrito => _carrito;
  bool get cargando => _cargando;

  /// 🔹 Cargar productos desde el backend
  Future<void> cargarProductos() async {
    try {
      _cargando = true;
      notifyListeners();

      final baseUrl = dotenv.env['API_URL'] ?? '';
      final url = Uri.parse('$baseUrl/productos');

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _productos = data.map((e) => Producto.fromJson(e)).toList();
      } else {
        print('❌ Error ${response.statusCode} al obtener productos');
      }
    } catch (e) {
      print('🚨 Error al cargar productos: $e');
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// 🔹 Obtener lista única de categorías (sin duplicados)
  List<String> obtenerCategorias() {
    return _productos
        .map((p) => p.categoria)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  /// 🔹 Filtrar productos por categoría
  List<Producto> filtrarPorCategoria(String categoria) =>
      _productos.where((p) => p.categoria == categoria).toList();

  /// 🔹 Agregar producto al carrito
  void agregarAlCarrito(Producto producto) {
    final index = _carrito.indexWhere((p) => p.id == producto.id);
    if (index >= 0) {
      _carrito[index].cantidad += producto.cantidad;
    } else {
      _carrito.add(producto);
    }
    notifyListeners();
  }

  // Calcular total del carrito
  double get totalCarrito =>
      _carrito.fold(0, (sum, p) => sum + (p.precio * p.cantidad));

  // Vaciar carrito
void limpiarCarrito() {
  carrito.clear();
  notifyListeners();
  }
}
