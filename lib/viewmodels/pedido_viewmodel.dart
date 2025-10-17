import 'package:flutter/material.dart';
import '../data/models/order.dart';

class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final bool disponible;
  final String imagen; 
  int cantidad;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.disponible,
    required this.imagen, 
    this.cantidad = 1,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['ID_Producto'],
      nombre: json['Nombre'] ?? '',
      descripcion: json['Descripcion'] ?? '',
      precio: double.tryParse(json['Precio'].toString()) ?? 0.0,
      disponible: json['Disponible'] ?? true,
      imagen: json['Imagen'] ?? '', 
    );
  }

  Map<String, dynamic> toPedidoJson() => {"id": id, "cantidad": cantidad};
}

class PedidoViewModel extends ChangeNotifier {
  String tipoCuenta = "unica";
  int cuentaSeleccionada = 0;
  String? mesa;
  int? idActual;
  String estadoActual = "En preparación";
  bool modoLectura = false;

  List<Map<String, dynamic>> cuentas = [
    {
      "numeroCuenta": 1,
      "nombre": "Cuenta 1",
      "productos": <Producto>[],
      "total": 0.0
    },
  ];

  void cambiarTipoCuenta(String nuevoTipo) {
    tipoCuenta = nuevoTipo;
    if (nuevoTipo == "separada" && cuentas.length == 1) {
      cuentas = [
        {
          "numeroCuenta": 1,
          "nombre": "Cuenta 1",
          "productos": <Producto>[],
          "total": 0.0
        },
        {
          "numeroCuenta": 2,
          "nombre": "Cuenta 2",
          "productos": <Producto>[],
          "total": 0.0
        },
      ];
    } else if (nuevoTipo == "unica") {
      cuentas = [
        {
          "numeroCuenta": 1,
          "nombre": "Cuenta 1",
          "productos": <Producto>[],
          "total": 0.0
        },
      ];
    }
    notifyListeners();
  }

  void agregarProducto(int cuentaIndex, Producto producto) {
    if (modoLectura) return;
    final productos = cuentas[cuentaIndex]["productos"] as List<Producto>;
    productos.add(producto);
    calcularTotal(cuentaIndex);
    notifyListeners();
  }

  void cambiarCantidad(int cuentaIndex, Producto producto, int delta) {
    if (modoLectura) return;
    final productos = cuentas[cuentaIndex]["productos"] as List<Producto>;
    final index = productos.indexOf(producto);
    if (index != -1) {
      productos[index].cantidad += delta;
      if (productos[index].cantidad <= 0) productos.removeAt(index);
      calcularTotal(cuentaIndex);
      notifyListeners();
    }
  }

  void calcularTotal(int cuentaIndex) {
    final productos = cuentas[cuentaIndex]["productos"] as List<Producto>;
    final total =
        productos.fold<double>(0.0, (sum, p) => sum + (p.precio * p.cantidad));
    cuentas[cuentaIndex]["total"] = total;
  }

  double get totalGeneral =>
      cuentas.fold(0.0, (sum, c) => sum + (c["total"] as double));

  void activarModoLectura(bool valor) {
    modoLectura = valor;
    notifyListeners();
  }

  /// --- Cargar pedido existente ---
  void cargarDesdePedidoExistente(dynamic pedido) {
    if (pedido is Order) {
      idActual = pedido.id;
      estadoActual = pedido.estado;
      tipoCuenta = pedido.tipoCuenta;
      mesa = pedido.mesa;

      if (tipoCuenta == "separada" && pedido.cuentas.isNotEmpty) {
        cuentas = pedido.cuentas.map((c) {
          return {
            "numeroCuenta": c.numeroCuenta,
            "nombre": "Cuenta ${c.numeroCuenta}",
            "productos": c.productos.map((p) {
              return Producto(
                id: p.id,
                nombre: p.nombre,
                descripcion: p.nota ?? '',
                precio: p.precio,
                disponible: true,
                imagen: p.imagen ?? '', 
                cantidad: p.cantidad,
              );
            }).toList(),
            "total": c.productos.fold<double>(
              0.0,
              (sum, p) => sum + (p.precio * p.cantidad),
            ),
          };
        }).toList();
      } else {
        cuentas = [
          {
            "numeroCuenta": 1,
            "nombre": "Cuenta 1",
            "productos": pedido.detalles.map((d) {
              return Producto(
                id: d.id,
                nombre: d.nombre,
                descripcion: d.nota ?? '',
                precio: d.precio,
                disponible: true,
                imagen: d.imagen ??  '', 
                cantidad: d.cantidad,
              );
            }).toList(),
            "total": pedido.total,
          },
        ];
      }

      notifyListeners();
      return;
    }

    // ✅ Si viene como Map (por compatibilidad)
    if (pedido is Map<String, dynamic>) {
      idActual = pedido['id'];
      estadoActual = pedido['estado'] ?? "En preparación";
      tipoCuenta = pedido['tipoCuenta'] ?? "unica";
      mesa = pedido['direccionEnvio'];
      cuentas = [];

      if (tipoCuenta == "separada" && pedido['cuentas'] != null) {
        for (var c in pedido['cuentas']) {
          cuentas.add({
            "numeroCuenta": c['numeroCuenta'],
            "nombre": "Cuenta ${c['numeroCuenta']}",
            "productos": (c['productos'] as List)
                .map((p) => Producto(
                      id: p['productoId'],
                      nombre: p['productos']['Nombre'],
                      descripcion: p['nota'] ?? '',
                      precio: double.tryParse(
                              p['productos']['Precio'].toString()) ??
                          0,
                      disponible: true,
                      imagen: p['productos']['Imagen'] ?? '',
                      cantidad: p['cantidad'],
                    ))
                .toList(),
            "total": c['productos'].fold<double>(
              0.0,
              (sum, p) =>
                  sum +
                  ((double.tryParse(p['productos']['Precio'].toString()) ?? 0) *
                      (p['cantidad'] ?? 1)),
            ),
          });
        }
      } else {
        cuentas = [
          {
            "numeroCuenta": 1,
            "nombre": "Cuenta 1",
            "productos": (pedido['detalle_pedido'] as List)
                .map((d) => Producto(
                      id: d['productos']['ID_Producto'],
                      nombre: d['productos']['Nombre'],
                      descripcion: d['nota'] ?? '',
                      precio: double.tryParse(
                              d['productos']['Precio'].toString()) ??
                          0,
                      disponible: true,
                      imagen: d['productos']['Imagen'] ?? '',
                      cantidad: d['cantidad'],
                    ))
                .toList(),
            "total": pedido['total'] ?? 0.0,
          },
        ];
      }
      notifyListeners();
    }
  }

  void actualizarEstado(String nuevoEstado) {
    estadoActual = nuevoEstado;
    notifyListeners();
  }
}
