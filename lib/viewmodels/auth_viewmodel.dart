import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String? _username;
  String? _email;
  int? _userId;
  int? _tipoUsuarioId;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  String? get username => _username;
  String? get email => _email;
  int? get userId => _userId;
  int? get tipoUsuarioId => _tipoUsuarioId;
  String? get token => _token;

Future<void> login(String user, String pass) async {
  final result = await _authService.login(user, pass);

  // Verificamos si el tipo de usuario es 3 (empleado)
  if (result["tipoUsuarioId"] != 3) {
    throw Exception("Acceso restringido: solo empleados pueden iniciar sesión");
  }

  // Guardamos datos del usuario
  _isLoggedIn = true;
  _userId = result["id"];
  _email = result["email"];
  _username = result["username"];
  _tipoUsuarioId = result["tipoUsuarioId"];
  _token = result["token"];

  notifyListeners();
}

  void logout() {
    _resetUser();
  }

  void _resetUser() {
    _isLoggedIn = false;
    _userId = null;
    _email = null;
    _username = null;
    _tipoUsuarioId = null;
    _token = null;
    notifyListeners();
  }
}
