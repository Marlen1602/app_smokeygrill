import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/pedido_viewmodel.dart';
import '../../../data/services/pedido_service.dart';

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

    if (!widget.esNuevo && widget.pedido != null) {
      vm.cargarDesdePedidoExistente(widget.pedido);
      vm.activarModoLectura(true);
    } else {
      vm.activarModoLectura(false);
    }
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
          colors: [Color(0xFFFF6B00), Colors.black], // Naranja → Negro
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                        ? Colors.orange
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
      (acc, c) => acc + (c["productos"] as List).length,
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
                Icon(Icons.receipt_long, color: Color(0xFF333333), size: 20),
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
                _miniInfo("Mesa", vm.mesa ?? "No asignada"),
              ],
            ),
            if (widget.esNuevo) ...[
              const SizedBox(height: 16),
              const Text(
                "Número de Mesa (Opcional)",
                style: TextStyle(
                  color: Color(0xFF757575),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _mesaController,
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
    if (widget.esNuevo && vm.tipoCuenta == "separada") {
      return _buildProductosNuevoPedido();
    } else {
      return _buildProductosDetalle();
    }
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
                      Text(
                        "${(cuenta["productos"] as List).length}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFFFF6B00) : const Color(0xFF757575),
                          fontSize: 14,
                        ),
                      ),
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
        if (vm.tipoCuenta == "unica") ..._buildListaDetalle(vm.cuentas.first),
        if (vm.tipoCuenta == "separada")
          ...vm.cuentas.expand((c) {
            final totalCuenta = (c["productos"] as List).fold<double>(
              0.0,
              (acc, p) => acc + (p.precio * p.cantidad),
            );
            return [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 171, 179, 171), 
                      blurRadius: 6, // Difuminado
                      offset: const Offset(0, 3), // Posición (x, y)
                    ),
                  ],
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
                      "${(c["productos"] as List).length} productos",
                      style: const TextStyle(
                        color: Color(0xFFFF6B00),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "\$${totalCuenta.toStringAsFixed(2)}",
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
            ];
          }),
      ],
    );
  }

  List<Widget> _buildListaNuevoPedido(Map<String, dynamic> cuenta) {
    final productos = cuenta["productos"] as List;

    return productos.map((p) {
      final subtotal = (p.precio * p.cantidad);

      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 1,
        shadowColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
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
              const SizedBox(height: 12),
              // Controles de cantidad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (p.cantidad > 1) {
                            setState(() {
                              p.cantidad--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                        color: const Color(0xFF757575),
                        iconSize: 24,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          "${p.cantidad}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF333333),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            p.cantidad++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        color: const Color(0xFFFF6B00),
                        iconSize: 24,
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        productos.remove(p);
                      });
                    },
                    icon: const Icon(Icons.delete_outline),
                    color: Colors.red,
                    iconSize: 24,
                  ),
                ],
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
      final tieneNota =
          (p.descripcion as String?)?.trim().isNotEmpty ?? false;

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
                          "Nota: ${p.descripcion}",
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

    if (widget.esNuevo) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFB380),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            // Lógica para enviar a cocina
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pedido enviado a cocina")),
              );
            }
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send, size: 20),
              SizedBox(width: 8),
              Text(
                "Enviar a Cocina",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final texto = vm.estadoActual == "En preparación"
        ? "Marcar como Listo"
        : vm.estadoActual == "Listo para entrega"
            ? "Marcar como Entregado"
            : "Reiniciar a En preparación";

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        onPressed: () async {
          try {
            final nuevoEstado = vm.estadoActual == "En preparación"
                ? "Listo para entrega"
                : vm.estadoActual == "Listo para entrega"
                    ? "Entregado"
                    : "En preparación";

            await service.actualizarEstadoPedido(vm.idActual!, nuevoEstado);
            vm.actualizarEstado(nuevoEstado);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Estado cambiado a $nuevoEstado")),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Error: $e")),
              );
            }
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 20),
            const SizedBox(width: 8),
            Text(
              texto,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
