import 'package:flutter/material.dart';
import '../../../../viewmodels/pedido_viewmodel.dart';
import '../widgets/producto_card.dart';

class CuentaTab extends StatelessWidget {
  final int cuentaIndex;
  final Map<String, dynamic> cuenta;
  final PedidoViewModel pedidoVM;

  const CuentaTab({
    super.key,
    required this.cuentaIndex,
    required this.cuenta,
    required this.pedidoVM,
  });

  @override
  Widget build(BuildContext context) {
    final productos = cuenta["productos"] as List<Producto>;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        Text("${cuenta["nombre"]} - \$${cuenta["total"].toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (productos.isEmpty)
          const Text("No hay productos en esta cuenta",
              style: TextStyle(color: Colors.grey))
        else
          ...productos.map((p) {
            return ProductoCard(
              producto: p,
              onAdd: pedidoVM.modoLectura
                  ? null
                  : () => pedidoVM.cambiarCantidad(cuentaIndex, p, 1),
              onRemove: pedidoVM.modoLectura
                  ? null
                  : () => pedidoVM.cambiarCantidad(cuentaIndex, p, -1),
            );
          }).toList(),
      ],
    );
  }
}
