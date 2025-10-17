import 'package:flutter/material.dart';
import '../../../../viewmodels/pedido_viewmodel.dart';

class ProductoCard extends StatelessWidget {
  final Producto producto;
  final VoidCallback? onAdd;
  final VoidCallback? onRemove;

  const ProductoCard({
    super.key,
    required this.producto,
    this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            producto.imagen,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.fastfood, color: Colors.deepOrange),
          ),
        ),
        title: Text(producto.nombre,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          "\$${producto.precio.toStringAsFixed(2)} x ${producto.cantidad}",
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: onAdd == null
            ? null
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: onRemove),
                  Text("${producto.cantidad}"),
                  IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: onAdd),
                ],
              ),
      ),
    );
  }
}
