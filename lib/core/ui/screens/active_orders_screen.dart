import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/orders_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../data/models/order.dart';

class ActiveOrdersScreen extends StatefulWidget {
  const ActiveOrdersScreen({super.key});

  @override
  State<ActiveOrdersScreen> createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrdersViewModel>(context, listen: false).loadPedidos();
    });
  }
  //Modal para configuracion de cuentas 
 void _mostrarConfiguracionCuentas(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ======= ENCABEZADO =======
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.groups_2, color: Color(0xFFFF6B00)),
                      SizedBox(width: 8),
                      Text(
                        "Configurar Pedido",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                "Configura cómo deseas manejar las cuentas para este pedido",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
              const SizedBox(height: 18),
              const Text(
                "¿Desea dividir este pedido en cuentas separadas?",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),

              // ======= BOTÓN NARANJA (CUENTAS SEPARADAS) =======
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/registrarPedido',
                      arguments: {'tipoCuenta': 'separada'},
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.group, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sí, dividir en cuentas",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Cada cliente pagará por separado",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ======= BOTÓN BLANCO (CUENTA ÚNICA) =======
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(
                      context,
                      '/registrarPedido',
                      arguments: {'tipoCuenta': 'unica'},
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Icon(Icons.person_outline,
                          color: Colors.black87, size: 22),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No, cuenta única",
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Todo en una sola cuenta",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final ordersVM = Provider.of<OrdersViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final nombreUsuario = authVM.nombreUsuario;
    final preparando = ordersVM.getPedidosPorEstado("preparación");
    final listo = ordersVM.getPedidosPorEstado("Listo");
    final entregado = ordersVM.getPedidosPorEstado("Entregado");


    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFF6B00), Colors.black],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y saludo dinámico
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pedidos Activos",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                      "¡Hola, $nombreUsuario!",
                      style: const TextStyle(
                        color: Color.fromARGB(244, 255, 255, 255),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ],
                  ),
                  // Iconos de acción
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: () => ordersVM.loadPedidos(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ordersVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildSection("En preparación", preparando, Colors.orange.shade700),
                _buildSection("Listo para entrega", listo, Colors.green.shade700),
                _buildSection("Entregado", entregado, Colors.blue.shade700),
              ],
            ),
      floatingActionButton: FloatingActionButton(
       backgroundColor: const Color(0xFFFF6B00), 
       shape: const CircleBorder(),               
       elevation: 3,                              
       onPressed: () {
          _mostrarConfiguracionCuentas(context);
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,                     
          size: 30,                               
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Order> pedidos, Color color) {
    if (pedidos.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pedidos.length.toString(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        ...pedidos.map((o) => _buildCard(o, color)).toList(),
      ],
    );
  }

    Widget _buildCard(Order o, Color color) {
    return Card(
      elevation: 0.8,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== ENCABEZADO =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("# ORD-${o.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Agregar más"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        o.estado,
                        style: TextStyle(
                          color: color,
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

            // ===== HORA Y MESA =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(o.fecha.substring(11, 16),
                      style: const TextStyle(color: Colors.grey)),
                ]),
                Row(children: [
                  const Icon(Icons.chair_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(o.mesa, style: const TextStyle(color: Colors.grey)),
                ]),
              ],
            ),

            const SizedBox(height: 8),

            // ===== PRODUCTOS =====
            if (o.tipoCuenta == "separada") ...[
              // 👉 Mostrar por cuentas
              for (var cuenta in o.cuentas) ...[
                Text(
                  "Cuenta ${cuenta.numeroCuenta}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                for (var d in cuenta.productos)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      "${d.cantidad}x ${d.nombre}"
                      "${d.nota != null && d.nota!.isNotEmpty ? ' (${d.nota})' : ''}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                const Divider(height: 10, color: Colors.grey),
              ],
            ] else ...[
              // 👉 Pedido normal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: o.detalles.map((d) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      "${d.cantidad}x ${d.nombre}"
                      "${d.nota != null && d.nota!.isNotEmpty ? ' (${d.nota})' : ''}",
                      style: const TextStyle(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 8),

            // ===== TOTAL =====
            Text(
              "\$${o.total.toStringAsFixed(2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}