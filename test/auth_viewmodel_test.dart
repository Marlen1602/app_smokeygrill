import 'package:flutter_test/flutter_test.dart';
import 'package:app_smokeygrill/viewmodels/auth_viewmodel.dart';
import 'package:app_smokeygrill/data/services/auth_service.dart';

/// 🔹 Servicio falso (mock) que simula el inicio de sesión real sin dotenv
class MockAuthService implements AuthService {
  // Obligatorio implementar baseUrl, aunque no se use
  @override
  String get baseUrl => 'http://mockapi.local';

  @override
  Future<Map<String, dynamic>> login(String user, String pass) async {
    await Future.delayed(const Duration(milliseconds: 100)); // Simula conexión

    if (user == 'Marlen12' && pass == 'Marlen12345?') {
      // Simula inicio de sesión exitoso
      return {
        "id": 1,
        "email": "Marlen04h@gmail.com", 
        "username": "Marlen12",
        "tipoUsuarioId": 3,
        "token": "fake-token-123"
      };
    } else {
      // Simula error en login
      throw Exception("Credenciales inválidas");
    }
  }
}

void main() {
  group(' Pruebas unitarias de AuthViewModel con MockAuthService', () {
    late AuthViewModel auth;

    setUp(() {
      // Inyectamos el servicio falso en lugar del real
      auth = AuthViewModel(authService: MockAuthService());
    });

    test('Inicio de sesión válido', () async {
      await auth.login('Marlen12', 'Marlen12345?');

      expect(auth.isLoggedIn, isTrue);
      expect(auth.username, equals('Marlen12'));
      expect(auth.email, equals('Marlen04h@gmail.com'));
    });

    test(' Inicio de sesión inválido', () async {
      expect(
        () async => await auth.login('UsuarioFalso', 'ClaveIncorrecta'),
        throwsA(isA<Exception>()),
      );
    });

    test('Cerrar sesión', () async {
      await auth.logout();

      expect(auth.isLoggedIn, isFalse);
      expect(auth.username, isNull);
    });
  });
}
