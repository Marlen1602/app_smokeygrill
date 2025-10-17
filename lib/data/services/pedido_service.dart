import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PedidoService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  /// Crear nuevo pedido (una cuenta o separadas)
  Future<void> enviarPedido(Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl/pedidos');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        print('✅ Pedido creado exitosamente');
      } else {
        print('❌ Error al crear pedido: ${response.body}');
        throw Exception('Error al crear pedido');
      }
    } catch (e) {
      print('🚨 Error de red al enviar pedido: $e');
      rethrow;
    }
  }

  /// Cambiar estado del pedido
  Future<void> actualizarEstadoPedido(int pedidoId, String nuevoEstado) async {
    try {
      final url = Uri.parse('$baseUrl/pedidos/$pedidoId/estado');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'nuevoEstado': nuevoEstado}), // 👈 igual que en backend
      );

      if (response.statusCode == 200) {
        print('✅ Estado actualizado a $nuevoEstado');
      } else {
        print('❌ Error al actualizar estado: ${response.body}');
        throw Exception('Error al actualizar estado');
      }
    } catch (e) {
      print('🚨 Error al cambiar estado: $e');
      rethrow;
    }
  }
}
