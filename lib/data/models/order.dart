class Order {
  final int id;
  final String estado;
  final double total;
  final String fecha;
  final String cliente;
  final String telefono;
  final String mesa;
  final String tipoCuenta;
  final List<DetallePedido> detalles;
  final List<CuentaSeparada> cuentas;

  Order({
    required this.id,
    required this.estado,
    required this.total,
    required this.fecha,
    required this.cliente,
    required this.telefono,
    required this.mesa,
    required this.tipoCuenta,
    required this.detalles,
    required this.cuentas,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<dynamic> detallesJson = [];
    if (json['detalle_pedido'] != null && json['detalle_pedido'] is List) {
      detallesJson = json['detalle_pedido'];
    }

    List<dynamic> cuentasJson = [];
    if (json['cuentas'] != null && json['cuentas'] is List) {
      cuentasJson = json['cuentas'];
      for (var cuenta in cuentasJson) {
        if (cuenta['productos'] != null && cuenta['productos'] is List) {
          detallesJson.addAll(cuenta['productos']);
        }
      }
    }

    return Order(
      id: json['id'] ?? 0,
      estado: json['estado'] ?? 'En preparación',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      fecha: json['fecha'] ?? '',
      cliente: json['clienteNombre'] ?? 'Desconocido',
      telefono: json['clienteTelefono'] ?? '',
      mesa: json['direccionEnvio'] ?? 'Sin mesa',
      tipoCuenta: json['tipoCuenta'] ?? 'unica',
      detalles: detallesJson.map((d) => DetallePedido.fromJson(d)).toList(),
      cuentas: cuentasJson.map((c) => CuentaSeparada.fromJson(c)).toList(),
    );
  }
}

class DetallePedido {
  final int id; // 👈 agregado
  final String nombre;
  final int cantidad;
  final String imagen;
  final double precio;
  final String? nota;

  DetallePedido({
    required this.id,
    required this.nombre,
    required this.cantidad,
    required this.imagen,
    required this.precio,
    this.nota,
  });

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    final producto = json['productos'] ?? json;
    return DetallePedido(
      id: producto['ID_Producto'] ?? 0, // 👈 agregado para compatibilidad
      nombre: producto['Nombre'] ?? producto['nombre'] ?? 'Producto sin nombre',
      cantidad: json['cantidad'] ?? 0,
      imagen: producto['Imagen'] ?? producto['imagen'] ?? '',
      precio: double.tryParse(producto['Precio']?.toString() ?? '0') ?? 0.0,
      nota: json['nota'],
    );
  }
}

class CuentaSeparada {
  final int id;
  final int numeroCuenta;
  final List<DetallePedido> productos;

  CuentaSeparada({
    required this.id,
    required this.numeroCuenta,
    required this.productos,
  });

  factory CuentaSeparada.fromJson(Map<String, dynamic> json) {
    return CuentaSeparada(
      id: json['id'] ?? 0,
      numeroCuenta: json['numeroCuenta'] ?? 1,
      productos: (json['productos'] as List<dynamic>? ?? [])
          .map((p) => DetallePedido.fromJson(p))
          .toList(),
    );
  }
}
