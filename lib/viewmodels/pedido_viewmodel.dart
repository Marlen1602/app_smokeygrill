import 'package:flutter/material.dart';
import '../data/models/order.dart';
import '../data/models/producto.dart'; 

class PedidoViewModel extends ChangeNotifier {
  String tipoCuenta = "unica";
  int cuentaSeleccionada = 0;
  String? mesa;
  int? idActual;
  String estadoActual = "En preparación";
  bool modoLectura = false;
  bool modoAgregar = false;

  List<Map<String, dynamic>> cuentas = [
    {
      "numeroCuenta": 1,
      "nombre": "Cuenta 1",
      "productos": <Producto>[],
      "total": 0.0,
    },
  ];


  // Cambiar tipo de cuenta
void cambiarTipoCuenta(String nuevoTipo) {
  // Si ya hay productos NO vaciar cuentas
  final tieneProductos = cuentas.any(
    (c) => (c["productos"] as List).isNotEmpty,
  );

  if (tieneProductos) {
    tipoCuenta = nuevoTipo;
    notifyListeners();
    return;
  }

  // Si NO hay productos, sí podemos regenerar cuentas
  tipoCuenta = nuevoTipo;

  if (nuevoTipo == "separada") {
    cuentas = [
      {"numeroCuenta": 1, "nombre": "Cuenta 1", "productos": <Producto>[], "total": 0.0},
      {"numeroCuenta": 2, "nombre": "Cuenta 2", "productos": <Producto>[], "total": 0.0},
    ];
  } else {
    cuentas = [
      {"numeroCuenta": 1, "nombre": "Cuenta 1", "productos": <Producto>[], "total": 0.0},
    ];
  }

  notifyListeners();
}


  // Crear varias cuentas separadas dinámicamente
void configurarCuentasSeparadas(int cantidad) {
  tipoCuenta = "separada";
  cuentas = List.generate(
    cantidad,
    (i) => {
      "numeroCuenta": i + 1,
      "nombre": "Cuenta ${i + 1}",
      "productos": <Producto>[],
      "total": 0.0,
    },
  );
  notifyListeners();
}


 void agregarProducto(int cuentaIndex, Producto producto) {
  if (modoLectura) return;

  // Si por alguna razon cuentas esta vacio, crear una cuenta unica
  if (cuentas.isEmpty) {
    cuentas = [
      {
        "numeroCuenta": 1,
        "nombre": "Cuenta 1",
        "productos": <Producto>[],
        "total": 0.0,
      },
    ];
  }

  // Ajustar indice si se sale del rango
  if (cuentaIndex < 0 || cuentaIndex >= cuentas.length) {
    cuentaIndex = 0;
  }

  final productos = cuentas[cuentaIndex]["productos"] as List<Producto>;

  final index = productos.indexWhere((p) => p.id == producto.id);

  if (index != -1) {
    productos[index].cantidad += producto.cantidad;
  } else {
    productos.add(Producto(
      id: producto.id,
      nombre: producto.nombre,
      descripcion: producto.descripcion,
      precio: producto.precio,
      disponible: producto.disponible,
      imagen: producto.imagen,
      categoria: producto.categoria,
      cantidad: producto.cantidad,
      nota: producto.nota,
    ));
  }

  calcularTotal(cuentaIndex);
  notifyListeners();
}


  // Cambiar cantidad
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


  // Calcular total de cuenta

  void calcularTotal(int cuentaIndex) {
    final productos = cuentas[cuentaIndex]["productos"] as List<Producto>;
    final total =
        productos.fold<double>(0.0, (sum, p) => sum + (p.precio * p.cantidad));
    cuentas[cuentaIndex]["total"] = total;
  }


  // Total general
  double get totalGeneral =>
      cuentas.fold(0.0, (sum, c) => sum + (c["total"] as double));


  // Activar modo lectura

  void activarModoLectura(bool valor) {
  if (modoLectura != valor) {
    modoLectura = valor;
    notifyListeners();
  }
}

/// Cargar solo datos principales del pedido (ID, mesa, estado)
/// SIN cargar productos ni cuentas
void cargarSoloCabeceraPedido(Order pedido) {
  idActual = pedido.id;
  estadoActual = pedido.estado;
  tipoCuenta = pedido.tipoCuenta;

  mesa = (pedido.mesa.isNotEmpty && pedido.mesa.toLowerCase() != "sin mesa")
      ? pedido.mesa
      : "No asignada";

  // No tocar cuentas ni productos
  // vm.cuentas queda como estaba (carrito temporal)

  notifyListeners();
}

  // Cargar pedido existente
void cargarDesdePedidoExistente(dynamic pedido) {
  if (pedido == null) return;

  // Limpieza inicial
  idActual = null;
  mesa = "No asignada";
  tipoCuenta = "unica";
  estadoActual = "En preparación";
  cuentas = [];

  // 🟢 Caso 1: Pedido como objeto Order
  if (pedido is Order) {
    idActual = pedido.id;
    estadoActual = pedido.estado;
    tipoCuenta = pedido.tipoCuenta;
    mesa = (pedido.mesa.isNotEmpty) ? pedido.mesa : "No asignada";

    // Si es cuenta separada
    if (tipoCuenta == "separada" && pedido.cuentas.isNotEmpty) {
      cuentas = pedido.cuentas.map((c) {
        final productosList = c.productos.map((p) {
  return Producto(
    id: p.id,
    nombre: p.nombre,
    descripcion: p.nota ?? "",
    precio: p.precio,
    disponible: true,
    imagen: p.imagen,
    categoria: "Sin categoría",
    cantidad: p.cantidad,
  );
}).toList();

// AGRUPAR POR ID
Map<int, Producto> agrupados = {};
for (var p in productosList) {
  if (agrupados.containsKey(p.id)) {
    agrupados[p.id]!.cantidad += p.cantidad;
  } else {
    agrupados[p.id] = p;
  }
}

final productos = agrupados.values.toList();

       return {
  "id": c.id,
  "numeroCuenta": c.numeroCuenta,
  "nombre": "Cuenta ${c.numeroCuenta}",
  "productos": productos,
  "total": productos.fold<double>(
    0.0,
    (sum, p) => sum + (p.precio * p.cantidad),
  ),
};

      }).toList();
    }

    // Si es cuenta única
    else if (pedido.detalles.isNotEmpty) {
      var productos = pedido.detalles.map((d) {
        return Producto(
          id: d.id,
          nombre: d.nombre,
          descripcion: d.nota ?? "",
          precio: d.precio,
          disponible: true,
          imagen: d.imagen,
          categoria: "Sin categoría",
          cantidad: d.cantidad,
        );
      }).toList();

      // Agrupar productos con el mismo ID
      Map<int, Producto> agrupados = {};
      for (var p in productos) {
        if (agrupados.containsKey(p.id)) {
          agrupados[p.id]!.cantidad += p.cantidad;
        } else {
          agrupados[p.id] = p;
        }
      }
      productos = agrupados.values.toList();

      cuentas = [
        {
          "numeroCuenta": 1,
          "nombre": "Cuenta 1",
          "productos": productos,
          "total": productos.fold<double>(
            0.0,
            (sum, p) => sum + (p.precio * p.cantidad),
          ),
        }
      ];
    }
  }

  // 🟢 Caso 2: Pedido como Map (desde backend)
  else if (pedido is Map<String, dynamic>) {
    idActual = pedido["id"] ?? pedido["ID_Pedido"];
    estadoActual = pedido["estado"] ?? "En preparación";
    tipoCuenta = pedido["tipoCuenta"] ?? "unica";

    // ✅ Obtener mesa desde direccionEnvio o mesa
    final direccion = pedido["direccionEnvio"] ?? pedido["mesa"];
    if (direccion != null && direccion.toString().trim().isNotEmpty) {
      mesa = direccion.toString();
    } else {
      mesa = "No asignada";
    }

    if (tipoCuenta == "separada" && pedido["cuentas"] != null) {
      for (var c in pedido["cuentas"]) {
       final productosList = (c["productos"] as List).map((p) {
  final producto = p["productos"] ?? p;
  return Producto(
    id: producto["ID_Producto"] ?? producto["id"] ?? 0,
    nombre: producto["Nombre"] ?? producto["nombre"] ?? "Producto",
    descripcion: p["nota"] ?? "",
    precio: double.tryParse(producto["Precio"].toString()) ?? 0,
    disponible: true,
    imagen: producto["Imagen"] ?? "",
    categoria: "Sin categoría",
    cantidad: p["cantidad"] ?? 1,
  );
}).toList();

Map<int, Producto> agrupados = {};
for (var p in productosList) {
  if (agrupados.containsKey(p.id)) {
    agrupados[p.id]!.cantidad += p.cantidad;
  } else {
    agrupados[p.id] = p;
  }
}

final productos = agrupados.values.toList();


        cuentas.add({
          "id": c["id"],
          "numeroCuenta": c["numeroCuenta"],
          "nombre": c["nombre"] ?? "Cuenta ${c["numeroCuenta"]}",
          "productos": productos,
          "total": productos.fold<double>(
            0.0,
            (sum, p) => sum + (p.precio * p.cantidad),
          ),
        });
      }
    } else if (pedido["detalle_pedido"] != null) {
      var productos = (pedido["detalle_pedido"] as List).map((d) {
        final prod = d["productos"];
        return Producto(
          id: prod["ID_Producto"],
          nombre: prod["Nombre"],
          descripcion: d["nota"] ?? "",
          precio: double.tryParse(prod["Precio"].toString()) ?? 0,
          disponible: true,
          imagen: prod["Imagen"] ?? "",
          categoria: "Sin categoría",
          cantidad: d["cantidad"],
        );
      }).toList();

      // Agrupar productos
      Map<int, Producto> agrupados = {};
      for (var p in productos) {
        if (agrupados.containsKey(p.id)) {
          agrupados[p.id]!.cantidad += p.cantidad;
        } else {
          agrupados[p.id] = p;
        }
      }
      productos = agrupados.values.toList();

      cuentas = [
        {
          "numeroCuenta": 1,
          "nombre": "Cuenta 1",
          "productos": productos,
          "total": productos.fold<double>(
            0.0,
            (sum, p) => sum + (p.precio * p.cantidad),
          ),
        }
      ];
    }
  }

  // Recalcular totales
  for (var i = 0; i < cuentas.length; i++) {
    final productos = cuentas[i]["productos"] as List<Producto>;
    final totalCuenta = productos.fold<double>(
      0.0,
      (sum, p) => sum + (p.precio * p.cantidad),
    );
    cuentas[i]["total"] = totalCuenta;
  }
    // 🔥 FIX: si después de cargar datos no hay cuentas, crear una por default
  if (cuentas.isEmpty) {
    cuentas = [
      {
        "numeroCuenta": 1,
        "nombre": "Cuenta 1",
        "productos": <Producto>[],
        "total": 0.0,
      },
    ];
  }

  notifyListeners();
}

  // Actualizar estado
  void actualizarEstado(String nuevoEstado) {
    estadoActual = nuevoEstado;
    notifyListeners();
  }
   // Limpiar pedido
void limpiarPedido() {
  tipoCuenta = "unica";
  cuentaSeleccionada = 0;
  mesa = "No asignada";
  idActual = null;
  estadoActual = "En preparación";
  modoLectura = false;
  modoAgregar = false;
  cuentas = [
    {
      "numeroCuenta": 1,
      "nombre": "Cuenta 1",
      "productos": <Producto>[],
      "total": 0.0,
    },
  ];
  notifyListeners();
}


void limpiarSoloCarrito() {
  for (var cuenta in cuentas) {
    cuenta["productos"] = <Producto>[];
    cuenta["total"] = 0.0;
  }
  notifyListeners();
}

 int get totalProductos {
  int total = 0;
  for (var cuenta in cuentas) {
    final productos = cuenta["productos"] as List<Producto>;
    total += productos.fold(0, (sum, p) => sum + p.cantidad);
  }
  return total;
}



void activarModoAgregar(bool valor) {
  modoAgregar = valor;
  notifyListeners();
}

void recalcularTotal() {
  for (var i = 0; i < cuentas.length; i++) {
    calcularTotal(i);
  }
  notifyListeners();
}



}
