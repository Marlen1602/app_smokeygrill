import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;
  //  Constructor con inyección opcional del servicio
    AuthViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();

  bool _isLoggedIn = false;
  String? _username;
  String? _email;
  int? _userId;
  int? _tipoUsuarioId;
  String? _token;

  String get nombreUsuario => _username ?? "Usuario";

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

  Future<void> logout() async {
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
