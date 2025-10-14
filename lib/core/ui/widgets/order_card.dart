import 'package:flutter/material.dart';
import '../../../../data/models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onAdd; // para el botón "Agregar más"
  const OrderCard({super.key, required this.order, this.onAdd});

  Color getStatusColor(String status) {
    if (status.toLowerCase().contains("preparación")) return Colors.amber.shade100;
    if (status.toLowerCase().contains("listo")) return Colors.green.shade100;
    if (status.toLowerCase().contains("entregado")) return Colors.blue.shade100;
    return Colors.grey.shade100;
  }

  Color getStatusTextColor(String status) {
    if (status.toLowerCase().contains("preparación")) return Colors.orange.shade800;
    if (status.toLowerCase().contains("listo")) return Colors.green.shade800;
    if (status.toLowerCase().contains("entregado")) return Colors.blue.shade800;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusTextColor(order.estado);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Encabezado de pedido (# y estado)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "#ORD-${order.id}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Agregar"),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: color),
                        foregroundColor: color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: getStatusColor(order.estado),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.estado,
                        style: TextStyle(
                          color: getStatusTextColor(order.estado),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 8),

            // 🔹 Información del cliente y hora
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                  ],
                ),
                Text(
                  order.fecha.substring(11, 16), // hora de la fecha ISO
                  style: const TextStyle(color: Colors.grey),
                ),
                Row(
                  children: const [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                  ],
                ),
                Text(
                  order.cliente,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 Productos
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: order.detalles.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    "${d.cantidad}x ${d.nombre}",
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 8),

            // 🔹 Total
            Text(
              "\$${order.total.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
