import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/pedido_viewmodel.dart';
import '../../../data/services/pedido_service.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../data/models/producto.dart';

class PedidoScreen extends StatefulWidget {
  final bool esNuevo;
  final dynamic pedido;

  const PedidoScreen({super.key, this.esNuevo = true, this.pedido});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  late PedidoViewModel vm;
  final TextEditingController _mesaController = TextEditingController();
  int _cuentaSeleccionada = 0;

@override
void initState() {
  super.initState();
  vm = Provider.of<PedidoViewModel>(context, listen: false);

  WidgetsBinding.instance.addPostFrameCallback((_) {

    // 🌟 CASO 1: NUEVO PEDIDO — LIMPIAR TODO
    if (widget.esNuevo) {
      vm.activarModoLectura(false);
      vm.modoAgregar = false;
      vm.mesa = "No asignada";
      return;
    }

    // 🌟 CASO 2: AGREGAR MÁS A UN PEDIDO EXISTENTE
    if (vm.modoAgregar) {
      vm.cargarSoloCabeceraPedido(widget.pedido);
      vm.activarModoLectura(false);
      return;
    }

    // 🌟 CASO 3: VER DETALLE DE PEDIDO
    if (widget.pedido != null) {
      vm.cargarDesdePedidoExistente(widget.pedido);
      vm.activarModoLectura(true);
      return;
    }
  });
}



  @override
  void dispose() {
    _mesaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    vm = Provider.of<PedidoViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildProductos(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: _buildBotonAccion(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(85),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B00), // Naranja
              Color(0xFF1A1A1A), // Negro/gris oscuro
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 Botón de regreso
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),

                // 🔹 Título y fecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.esNuevo
                            ? "Nuevo Pedido"
                            : "Pedido ORD-${vm.idActual ?? ''}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!widget.esNuevo)
                        Text(
                          DateTime.now()
                              .toString()
                              .substring(5, 16)
                              .replaceAll('-', '/'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                ),

                // 🔹 Estado del pedido (chip de color)
                if (!widget.esNuevo)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: vm.estadoActual == "En preparación"
                          ? const Color(0xFFFFC107)
                          : vm.estadoActual == "Listo para entrega"
                              ? Colors.green
                              : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          vm.estadoActual == "En preparación"
                              ? Icons.access_time
                              : vm.estadoActual == "Listo para entrega"
                                  ? Icons.delivery_dining
                                  : Icons.check_circle_outline,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          vm.estadoActual,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
   final totalProductos = vm.cuentas.fold<int>(
  0,
  (acc, c) {
    final productos = c["productos"] as List;
    return acc + productos.fold<int>(0, (sum, p) => sum + (p.cantidad as int));
  },
);


    return Card(
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: const Color.fromARGB(255, 171, 179, 171),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  "#",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "Información del Pedido",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniInfo("Pedido", widget.esNuevo ? "NUEVO" : "ORD-${vm.idActual}"),
                _miniInfo("Productos", "$totalProductos productos"),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniInfo(
                  "Total",
                  "\$${vm.totalGeneral.toStringAsFixed(2)}",
                  color: const Color(0xFF4CAF50),
                  isBold: true,
                ),
    _miniInfo(
      "Mesa",
      (() {
        // Siempre mostrar lo que hay en el ViewModel
        if (vm.mesa != null &&
            vm.mesa!.trim().isNotEmpty &&
            vm.mesa!.toLowerCase() != "sin mesa" &&
            vm.mesa!.toLowerCase() != "no asignada") {
          return vm.mesa!;
        }

        return "No asignada";
      })(),
    ),


             ],
            ),
            if (widget.esNuevo) ...[
              const SizedBox(height: 16),
              const Text(
                "Número de Mesa",
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mesaController,
                onChanged: (value) {
                  vm.mesa = value.trim().isEmpty ? "No asignada" : "Mesa ${value.trim()}";
                  setState(() {});
                },
                decoration: InputDecoration(
                  hintText: "Ej: 5",
                  hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 255, 254, 254),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _miniInfo(String title, String value,
      {Color color = const Color(0xFF333333), bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF757575),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildProductos() {
     // 🟠 MODO AGREGAR MÁS: mostrar SOLO lo que está en el carrito temporal
  if (vm.modoAgregar) {
    if (vm.tipoCuenta == "separada") {
      // varias cuentas: lista por cuenta
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Productos (nuevos por agregar)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
          ),
          ...vm.cuentas.expand((c) {
            final totalCuenta = (c["productos"] as List).fold<double>(
              0.0, (acc, p) => acc + (p.precio * p.cantidad),
            );
            return [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD1B0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card, size: 16, color: Color(0xFFFF6B00)),
                    const SizedBox(width: 8),
                    Text(c["nombre"], style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFFF6B00), fontSize: 14)),
                    const Spacer(),
                    Text("${(c["productos"] as List).length} productos",
                        style: const TextStyle(color: Color(0xFFFF6B00), fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 12),
                    Text("\$${totalCuenta.toStringAsFixed(2)}",
                        style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 15, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ..._buildListaDetalle(c), // o _buildListaNuevoPedido(c) si quieres controles +/-
              const SizedBox(height: 8),
            ];
          }),
        ],
      );
    } else {
      // cuenta única
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              "Productos (nuevos por agregar)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
            ),
          ),
          ..._buildListaDetalle(vm.cuentas.first), // o _buildListaNuevoPedido(vm.cuentas.first)
        ],
      );
    }
  }

    if (widget.esNuevo) {
      if (vm.tipoCuenta == "separada") {
        return _buildProductosNuevoPedido();
      } else {
        // Cuenta única en modo nuevo - mostrar con controles
        return _buildProductosNuevoPedidoCuentaUnica();
      }
    } else {
      // Modo detalle - sin controles
      return _buildProductosDetalle();
    }
  }

  Widget _buildProductosNuevoPedidoCuentaUnica() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Productos",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
        ..._buildListaNuevoPedido(vm.cuentas.first),
      ],
    );
  }

  Widget _buildProductosNuevoPedido() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, size: 18, color: Color(0xFF333333)),
            const SizedBox(width: 8),
            const Text(
              "Productos",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const Spacer(),
            Text(
              "${vm.cuentas.length} cuentas",
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF757575),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Tabs de cuentas
        Row(
          children: List.generate(vm.cuentas.length, (index) {
            final cuenta = vm.cuentas[index];
            final isSelected = _cuentaSeleccionada == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _cuentaSeleccionada = index;
                  });
                },
                child: Container(
                  margin: EdgeInsets.only(right: index < vm.cuentas.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF6B00) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt,
                        size: 16,
                        color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF757575),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        cuenta["nombre"],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF757575),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                                          ],
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        // Productos de la cuenta seleccionada con controles
        ..._buildListaNuevoPedido(vm.cuentas[_cuentaSeleccionada]),
      ],
    );
  }

Widget _buildProductosDetalle() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.only(left: 4, bottom: 12),
        child: Text(
          "Productos",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
      ),

      if (vm.tipoCuenta == "separada") ...[
  for (var c in vm.cuentas) ...[
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFD1B0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.credit_card, size: 16, color: Color(0xFFFF6B00)),
          const SizedBox(width: 8),
          Text(
            c["nombre"],
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF6B00),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            "${(c["productos"] as List).fold<int>(0, (sum, p) => sum + (p.cantidad as int))} productos",
            style: const TextStyle(
              color: Color(0xFFFF6B00),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "\$${(c["total"] as double).toStringAsFixed(2)}",
            style: const TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
    ..._buildListaDetalle(c),
    const SizedBox(height: 8),
  ],

  // 🔹 Total general al final (solo si hay más de una cuenta)
  if (vm.cuentas.length > 1)
    Padding(
      padding: const EdgeInsets.only(top: 12, right: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          "Total general: \$${vm.totalGeneral.toStringAsFixed(2)}",
          style: const TextStyle(
            color: Color(0xFF388E3C),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),
]

      // 🔹 Si es cuenta única
      else ...[
        ..._buildListaDetalle(vm.cuentas.first),
      ],
    ],
  );
}


  List<Widget> _buildListaNuevoPedido(Map<String, dynamic> cuenta) {
    final productos = cuenta["productos"] as List;

    return productos.map((p) {
      final subtotal = (p.precio * p.cantidad);
      final tieneNota = (p.nota?.trim().isNotEmpty ?? false) &&
         (p.categoria.toLowerCase() != "bebidas");

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  p.imagen,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      color: Color(0xFFFF6B00),
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            p.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "\$${subtotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${p.precio.toStringAsFixed(2)} x ${p.cantidad}",
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 13,
                      ),
                    ),
                    if (tieneNota) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFFD1B0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "Nota: ${p.nota}",
                          style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              if (p.cantidad > 1) {
                                setState(() {
                                  p.cantidad--;
                                  // Forzar reconstrucción del Provider para actualizar el total
                                  vm.cuentas = vm.cuentas.map((c) {
                                    if (c["productos"] == cuenta["productos"]) {
                                      return {...c, "productos": cuenta["productos"]};
                                    }
                                    return c;
                                  }).toList();
                                });
                              }
                            },
                            icon: const Icon(Icons.remove, size: 18),
                            color: const Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "${p.cantidad}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                p.cantidad++;
                                // Forzar reconstrucción del Provider para actualizar el total
                                vm.cuentas = vm.cuentas.map((c) {
                                  if (c["productos"] == cuenta["productos"]) {
                                    return {...c, "productos": cuenta["productos"]};
                                  }
                                  return c;
                                }).toList();
                              });
                            },
                            icon: const Icon(Icons.add, size: 18),
                            color: const Color(0xFFFF6B00),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFFFCDD2)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              setState(() {
                                cuenta["productos"].remove(p);
                                // Forzar reconstrucción completa para actualizar el total
                                vm.cuentas = vm.cuentas.map((c) {
                                  if (c["productos"] == cuenta["productos"]) {
                                    return {...c, "productos": cuenta["productos"]};
                                  }
                                  return c;
                                }).toList();
                              });
                              vm.notifyListeners();
                            },
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildListaDetalle(Map<String, dynamic> cuenta) {
    final productos = cuenta["productos"] as List;

    return productos.map((p) {
      final subtotal = (p.precio * p.cantidad);
      final tieneNota = (p.nota?.trim().isNotEmpty ?? false) &&
         (p.categoria.toLowerCase() != "bebidas");

      return Card(
        color: const Color.fromARGB(255, 255, 255, 255),
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shadowColor: const Color.fromARGB(255, 171, 179, 171),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  p.imagen,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.fastfood,
                      color: Color(0xFFFF6B00),
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "\$${p.precio.toStringAsFixed(2)} x ${p.cantidad}",
                      style: const TextStyle(
                        color: Color(0xFF757575),
                        fontSize: 13,
                      ),
                    ),
                    if (tieneNota) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0E5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFFFD1B0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          "Nota: ${p.nota}",
                          style: const TextStyle(
                            color: Color(0xFFFF6B00),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "\$${subtotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

Widget _buildBotonAccion() {
  final service = PedidoService();
  final authVM = Provider.of<AuthViewModel>(context, listen: false);

  // 🟢 CASO 1: Crear un nuevo pedido (único caso donde se muestra "Enviar a Cocina")
  if (widget.esNuevo && !vm.modoAgregar && !vm.modoLectura) {
    final mesaIngresada = _mesaController.text.trim().isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              mesaIngresada ? const Color(0xFFFF6B00) : Colors.grey.shade400,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: mesaIngresada
            ? () async {
                final mesaTexto = _mesaController.text.trim();
                final direccionEnvio = mesaTexto.toLowerCase().startsWith("mesa")
                    ? mesaTexto
                    : "Mesa $mesaTexto";
                 vm.mesa = direccionEnvio;
                try {
                  Map<String, dynamic> pedido;

                  if (vm.tipoCuenta == "separada") {
                    pedido = {
                      "usuarioId": authVM.userId,
                      "tipoCuenta": "separada",
                      "direccionEnvio": direccionEnvio,
                      "total": vm.totalGeneral,
                      "cuentas": vm.cuentas.map((c) {
                        final productos = (c["productos"] as List<Producto>);
                        return {
                          "numeroCuenta": c["numeroCuenta"],
                          "productos": productos.map((p) => {
                                "productoId": p.id,
                                "cantidad": p.cantidad,
                                "nota": p.nota ?? "",
                              }).toList(),
                        };
                      }).toList(),
                    };
                  } else {
                    pedido = {
                      "usuarioId": authVM.userId,
                      "tipoCuenta": "unica",
                     "direccionEnvio": direccionEnvio,
                      "total": vm.totalGeneral,
                      "productos": vm.cuentas.first["productos"]
                          .map((p) => {
                                "id": p.id,
                                "cantidad": p.cantidad,
                                "nota": p.nota ?? "",
                              })
                          .toList(),
                    };
                  }

                  await service.enviarPedido(pedido);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "✅ Pedido enviado a cocina para $direccionEnvio"),
                      ),
                    );
                    vm.limpiarPedido();
                    Navigator.pop(context);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("❌ Error al enviar pedido: $e")),
                  );
                }
              }
            : null,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send, size: 20),
            SizedBox(width: 8),
            Text(
              "Enviar a Cocina",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // 🟠 CASO 2: Agregar productos a un pedido existente
  if (vm.modoAgregar && widget.pedido != null) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B00),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          try {
            final pedidoId = widget.pedido.id ?? widget.pedido["id"];

           for (var cuenta in vm.cuentas) {
            final cuentaId = cuenta["id"]; // ID real de BD

            final productos = (cuenta["productos"] as List<Producto>)
                .map((p) => {
                      "productoId": p.id,
                      "cantidad": p.cantidad,
                      "nota": p.nota ?? "",
                    })
                .toList();

            if (productos.isNotEmpty) {
              if (vm.tipoCuenta == "separada") {
  // 👉 Sí enviar cuentaId
  await service.agregarProductosPedido(
    pedidoId: pedidoId,
    cuentaId: cuentaId,
    productos: productos,
  );
} else {
  // 👉 Cuenta única: NO enviar cuentaId
  await service.agregarProductosPedido(
    pedidoId: pedidoId,
    productos: productos,
  );
}

            }
          }


            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("✅ Productos agregados correctamente.")),
              );
              vm.limpiarSoloCarrito();
              Navigator.pop(context);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("❌ Error al agregar productos: $e")),
            );
          }
        },
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_shopping_cart, size: 20),
            SizedBox(width: 8),
            Text(
              "Agregar al Pedido",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
  // 🟢 CASO 3: Pedido existente en estado "Listo para entrega"
if (!widget.esNuevo && vm.estadoActual == "Listo para entrega") {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        final pedidoId = vm.idActual;
        if (pedidoId == null) return;

        try {
          final service = PedidoService();
          await service.actualizarEstadoPedido(pedidoId, "Entregado");

          vm.actualizarEstado("Entregado"); // 👉 actualizar provider

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Pedido marcado como ENTREGADO"),
              ),
            );
          }

          setState(() {}); // 👉 refrescar pantalla
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("❌ Error al marcar como entregado: $e")),
          );
        }
      },
      child: const Text(
        "Marcar como Entregado",
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

  // 🔵 CASO 3: Solo ver detalle (sin botón)
  return const SizedBox.shrink();
}

}
