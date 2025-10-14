import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OrdersService {
  final String baseUrl = dotenv.env['API_URL'] ?? '';

  Future<List<dynamic>> getPedidosActivos() async {
    try{
      final response = await http.get(Uri.parse('$baseUrl/pedidos'));

       if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // lista de pedidos
    } else {
      throw Exception('Error al obtener pedidos: ${response.statusCode}');
    }
    } catch (e) {
      throw Exception('Error de red: $e');
    } 
  }
}
