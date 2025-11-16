import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/orders_viewmodel.dart';
import '../../../viewmodels/auth_viewmodel.dart';
import '../../../data/models/order.dart';
import '../../../viewmodels/pedido_viewmodel.dart';
import '../screens/menu_screen.dart';
import '../screens/pedido_screen.dart';
import 'package:flutter/services.dart';

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
// ===== Modal para configuración de cuentas =====
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
                  const Row(
                    children: [
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
                    _mostrarNumeroCuentas(context); 
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
                      '/menu',
                      arguments: {'tipoCuenta': 'unica', 'numeroCuentas': 1},
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

// ===== Segundo modal: número de cuentas =====
void _mostrarNumeroCuentas(BuildContext context) {
  final TextEditingController cuentasController = TextEditingController(text: "2");
  int numeroCuentas = 2;
  bool esValido = true;

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.settings, color: Color(0xFFFF6B00)),
                      SizedBox(width: 8),
                      Text("Número de Cuentas",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "¿En cuántas cuentas separadas desea dividir el pedido?",
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: cuentasController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        numeroCuentas = int.tryParse(value) ?? 0;
                        esValido = numeroCuentas >= 2 && numeroCuentas <= 10;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: esValido ? Colors.grey : Colors.red,
                            width: esValido ? 1 : 2,
                          )),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: esValido ? Colors.grey : Colors.red,
                            width: esValido ? 1 : 2,
                          )),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: esValido ? const Color(0xFFFF6B00) : Colors.red,
                            width: 2,
                          )),
                      suffixIcon:
                          const Icon(Icons.numbers, color: Color(0xFFFF6B00)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    esValido 
                        ? "Mínimo 2, máximo 10 cuentas"
                        : "Por favor ingrese un número entre 2 y 10",
                    style: TextStyle(
                      color: esValido ? Colors.grey : Colors.red,
                      fontSize: 12,
                      fontWeight: esValido ? FontWeight.normal : FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (esValido)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4CAF50)),
                      ),
                      child: Text(
                        "Se crearán $numeroCuentas cuentas separadas:\n${List.generate(numeroCuentas, (i) => "• Cuenta ${i + 1}").join("\n")}",
                        style: const TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancelar"),
                      ),
                     ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: esValido ? const Color(0xFFFF6B00) : Colors.grey,
  ),
                      onPressed: esValido
                          ? () {
                              Navigator.pop(context);

                              // 🔹 Obtener el ViewModel y configurar las cuentas
                              final pedidoVM = Provider.of<PedidoViewModel>(context, listen: false);
                              pedidoVM.configurarCuentasSeparadas(numeroCuentas);

                              // 🔹 Ir al menú con el flag activado
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MenuScreen(cuentasSeparadas: true),
                                ),
                              );
                            }
                          : null,
                      child: const Text("Confirmar"),
                    ),

                    ],
                  ),
                ],
              ),
            ),
          );
        },
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
     return PopScope(
    canPop: false,
    onPopInvokedWithResult: (bool didPop, Object? result) {
      if (!didPop) {
        SystemNavigator.pop();
      }
    },

    child:  Scaffold(
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
     )
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
  return InkWell(
    onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => PedidoViewModel()
                ..cargarDesdePedidoExistente(o)
                ..activarModoLectura(true),
              child: const PedidoScreen(esNuevo: false),
            ),
          ),
        );
      },

    child: Card(
      elevation: 0.8,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Encabezado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("# ORD-${o.id}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                   OutlinedButton.icon(
                      onPressed: () {
                       final pedidoVM = Provider.of<PedidoViewModel>(context, listen: false);

                        // 1) Cargar el pedido completo desde el backend en el ViewModel
                        pedidoVM.cargarDesdePedidoExistente(o);

                        // 2) Vaciar solo los productos, pero conservar las cuentas y sus ids
                        pedidoVM.limpiarSoloCarrito();

                        // 3) Activar modo agregar
                        pedidoVM.activarModoAgregar(true);
                        pedidoVM.activarModoLectura(false);

                        // 4) Navegar al menú usando el mismo PedidoViewModel global
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MenuScreen(
                              cuentasSeparadas: o.tipoCuenta == "separada",
                              pedidoExistente: o,
                            ),
                          ),
                        );
                    },

                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Agregar más"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: color,
                        side: BorderSide(color: color),
                      ),
                    ),

                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
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

            // 🔹 Hora y mesa
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

Builder(
  builder: (_) {
    // Agrupar productos por nombre y sumar cantidades
    final Map<String, int> agrupados = {};
    double total = 0;

    for (var d in o.detalles) {
      final nombre = d.nombre ?? "Producto sin nombre";
      final cantidad = d.cantidad ?? 1;
      final precio = d.precio ?? 0.0;

      agrupados[nombre] = (agrupados[nombre] ?? 0) + cantidad;
      total += precio * cantidad;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔸 Lista agrupada
        ...agrupados.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                "${e.value}x ${e.key}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            )),
        const SizedBox(height: 6),
        // 🔸 Total actualizado
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          );
        },
      ),
          ],
        ),
      ),
    ),
  );
}

}