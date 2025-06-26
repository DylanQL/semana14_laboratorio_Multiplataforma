class ProductFields {
  static const List<String> values = [
    id,
    nombre,
    descripcion,
    fechaVencimiento,
    precio,
    createdTime,
  ];
  static const String tableName = 'productos';
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
  static const String textType = 'TEXT NOT NULL';
  static const String realType = 'REAL NOT NULL';
  static const String id = '_id';
  static const String nombre = 'nombre';
  static const String descripcion = 'descripcion';
  static const String fechaVencimiento = 'fecha_vencimiento';
  static const String precio = 'precio';
  static const String createdTime = 'created_time';
}

class ProductModel {
  int? id;
  final String nombre;
  final String descripcion;
  final DateTime fechaVencimiento;
  final double precio;
  final DateTime? createdTime;

  ProductModel({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.precio,
    this.createdTime,
  });

  Map<String, Object?> toJson() => {
        ProductFields.id: id,
        ProductFields.nombre: nombre,
        ProductFields.descripcion: descripcion,
        ProductFields.fechaVencimiento: fechaVencimiento.toIso8601String(),
        ProductFields.precio: precio,
        ProductFields.createdTime: createdTime?.toIso8601String(),
      };

  factory ProductModel.fromJson(Map<String, Object?> json) => ProductModel(
        id: json[ProductFields.id] as int?,
        nombre: json[ProductFields.nombre] as String,
        descripcion: json[ProductFields.descripcion] as String,
        fechaVencimiento: DateTime.parse(json[ProductFields.fechaVencimiento] as String),
        precio: json[ProductFields.precio] as double,
        createdTime: DateTime.tryParse(json[ProductFields.createdTime] as String? ?? ''),
      );

  ProductModel copy({
    int? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaVencimiento,
    double? precio,
    DateTime? createdTime,
  }) =>
      ProductModel(
        id: id ?? this.id,
        nombre: nombre ?? this.nombre,
        descripcion: descripcion ?? this.descripcion,
        fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
        precio: precio ?? this.precio,
        createdTime: createdTime ?? this.createdTime,
      );
}
