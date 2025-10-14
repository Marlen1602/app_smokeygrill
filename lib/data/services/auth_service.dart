import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final String baseUrl = dotenv.env['API_URL']!;

  Future<Map<String, dynamic>> login(String user, String pass) async {
    final url = Uri.parse("$baseUrl/login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "identificador": user,   
        "password": pass,         
      }),
    );

   
    if (response.statusCode == 200) {
      // Si la respuesta es correcta, regresamos el JSON
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Si el estado es 401 (Unauthorized), es porque las credenciales son incorrectas
      throw Exception("Credenciales inválidas");
    } else if (response.statusCode == 400) {
      // Si hay un error de solicitud, mostramos que algo está mal con los datos
      throw Exception("Solicitud incorrecta: ${response.body}");
    } else {
      // Para otros errores, mostramos el cuerpo de la respuesta
      throw Exception("Error en login: ${response.body}");
    }
  }
}
