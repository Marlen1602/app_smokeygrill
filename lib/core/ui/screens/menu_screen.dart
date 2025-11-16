import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/menu_viewmodel.dart';
import '../../../viewmodels/pedido_viewmodel.dart';
import '../../../data/models/producto.dart';
import '../../ui/screens/pedido_screen.dart';

class MenuScreen extends StatefulWidget {
  final bool cuentasSeparadas;
  final dynamic pedidoExistente;
  const MenuScreen({
    super.key,
    this.cuentasSeparadas = false,
    this.pedidoExistente,
  });


  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String categoriaSeleccionada = "";
  String searchQuery = "";
  int cuentaSeleccionada = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuViewModel>(context, listen: false).cargarProductos();

      final vm = Provider.of<PedidoViewModel>(context, listen: false);
      if (widget.pedidoExistente == null) {

        if (widget.cuentasSeparadas) {
          vm.cambiarTipoCuenta("separada");
        } else {
          vm.cambiarTipoCuenta("unica");
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuVM = Provider.of<MenuViewModel>(context);
    final pedidoVM = Provider.of<PedidoViewModel>(context);
    final categorias = menuVM.obtenerCategorias();

    // 🔎 Filtrado
    final productosFiltrados = categoriaSeleccionada.isEmpty
        ? menuVM.productos
        : menuVM.filtrarPorCategoria(categoriaSeleccionada);

    final lista = productosFiltrados
        .where((p) => p.nombre.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Menú"),
        backgroundColor: const Color(0xFFEA580C),
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
onPressed: () {
  final pedidoVM = Provider.of<PedidoViewModel>(context, listen: false);

  // Si no hay productos nuevos → no avanzar
  final hayProductos = pedidoVM.cuentas.any(
    (c) => (c["productos"] as List).isNotEmpty,
  );

  if (!hayProductos) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No hay productos nuevos para agregar")),
    );
    return;
  }

  if (widget.pedidoExistente == null) {
     final pedidoVM = Provider.of<PedidoViewModel>(context, listen: false);
    // SOLO si es el PRIMER producto del flujo
    if (pedidoVM.totalProductos == 0) {
      pedidoVM.activarModoAgregar(false);
      pedidoVM.activarModoLectura(false);
      pedidoVM.mesa = "No asignada";
      pedidoVM.tipoCuenta = widget.cuentasSeparadas ? "separada" : "unica";
    }


    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PedidoScreen(
          esNuevo: true,
          pedido: null,
        ),
      ),
    );
  } else {
    // agregar a pedido existente
    pedidoVM.activarModoAgregar(true);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PedidoScreen(
          esNuevo: false,
          pedido: widget.pedidoExistente,
        ),
      ),
    );
  }
}



              ),

              // Indicador de cantidad total
              if (pedidoVM.totalProductos > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${pedidoVM.totalProductos}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: menuVM.cargando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (widget.cuentasSeparadas)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButton<int>(
                    value: (cuentaSeleccionada < pedidoVM.cuentas.length)
                        ? cuentaSeleccionada
                        : 0,
                      onChanged: (nuevoValor) {
                        setState(() => cuentaSeleccionada = nuevoValor!);
                      },
                      items: List.generate(
                        pedidoVM.cuentas.length,
                        (index) => DropdownMenuItem(
                          value: index,
                          child: Text("Cuenta ${index + 1}"),
                        ),
                      ),
                    ),
                  ),
                _buildBuscador(),
                _buildCategorias(categorias),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: lista.length,
                    itemBuilder: (_, i) =>
                        _buildProductoCard(lista[i], pedidoVM),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBuscador() => Padding(
        padding: const EdgeInsets.all(8),
        child: TextField(
          onChanged: (value) => setState(() => searchQuery = value),
          decoration: InputDecoration(
            hintText: "Buscar productos...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      );

  Widget _buildCategorias(List<String> categorias) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: categorias.map((cat) {
            final seleccionada = categoriaSeleccionada == cat;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: ChoiceChip(
                label: Text(cat),
                selected: seleccionada,
                onSelected: (_) => setState(
                    () => categoriaSeleccionada = seleccionada ? "" : cat),
                selectedColor: const Color(0xFFEA580C),
                labelStyle: TextStyle(
                  color: seleccionada ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      );

  Widget _buildProductoCard(Producto p, PedidoViewModel pedidoVM) {
    TextEditingController notaController =
        TextEditingController(text: p.nota ?? '');
    bool mostrarNota = false;

    return StatefulBuilder(builder: (context, setStateCard) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- imagen e info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      p.imagen,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 90,
                        height: 90,
                        color: const Color(0xFFF0F0F0),
                        child: const Icon(Icons.fastfood, color: Colors.orange),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nombre,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(p.descripcion,
                            style: const TextStyle(
                                fontSize: 13, color: Colors.grey)),
                        const SizedBox(height: 6),
                        Text("\$${p.precio.toStringAsFixed(2)}",
                            style: const TextStyle(
                                fontSize: 15,
                                color: Colors.green,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // --- cantidad + agregar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            if (p.cantidad > 1) {
                              setStateCard(() => p.cantidad--);
                            }
                          },
                        ),
                        Text("${p.cantidad}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => setStateCard(() => p.cantidad++),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      p.nota = notaController.text.trim();

                      pedidoVM.agregarProducto(
                        widget.cuentasSeparadas ? cuentaSeleccionada : 0,
                        Producto(
                          id: p.id,
                          nombre: p.nombre,
                          descripcion: p.descripcion,
                          precio: p.precio,
                          disponible: p.disponible,
                          imagen: p.imagen,
                          categoria: p.categoria,
                          cantidad: p.cantidad,
                          nota: p.nota,
                        ),
                      );
                      pedidoVM.recalcularTotal();

                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            "${p.nombre} agregado a ${widget.cuentasSeparadas ? 'Cuenta ${cuentaSeleccionada + 1}' : 'la cuenta'}"),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ));
                    },
                    child: const Text(
                      "Agregar",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),

              // --- nota opcional
              if (p.categoria.toLowerCase() != "bebidas") ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => setStateCard(() => mostrarNota = !mostrarNota),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: const Color(0xFFEA580C), width: 1.2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.edit_note,
                            color: Color(0xFFEA580C), size: 20),
                        SizedBox(width: 5),
                        Text("Personalizar ingredientes",
                            style: TextStyle(
                                color: Color(0xFFEA580C),
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
              if (mostrarNota) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: notaController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Ej: sin cebolla, extra aguacate...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) => p.nota = value.trim(),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
