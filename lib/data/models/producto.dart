class Producto {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final bool disponible;
  final String imagen;
  final String categoria; 
  int cantidad;
  String? nota;

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.disponible,
    required this.imagen,
    required this.categoria,
    this.cantidad = 1,
    this.nota,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['ID_Producto'],
      nombre: json['Nombre'] ?? '',
      descripcion: json['Descripcion'] ?? '',
      precio: double.tryParse(json['Precio'].toString()) ?? 0.0,
      disponible: json['Disponible'] ?? true,
      imagen: json['Imagen'] ?? '', 
      categoria: json['categorias'] != null
    ? json['categorias']['Nombre'] ?? ''
    : '',
      nota: json['nota'] ?? '',
    );
  }

  Map<String, dynamic> toPedidoJson() => {
        "id": id,
        "cantidad": cantidad,
        "nota": nota,
      };
}
