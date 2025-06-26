/// Clase que define los campos y estructura de la tabla de productos en la base de datos
/// Esta clase actúa como un esquema que define cómo se almacenan los productos en SQLite
class ProductFields {
  /// Lista de todos los campos de la tabla - usada para consultas SQL
  static const List<String> values = [
    id,
    nombre,
    descripcion,
    fechaVencimiento,
    precio,
    createdTime,
  ];
  
  // Configuración de la tabla
  static const String tableName = 'productos'; // Nombre de la tabla en la base de datos
  
  // Tipos de datos SQL para la creación de la tabla
  static const String idType = 'INTEGER PRIMARY KEY AUTOINCREMENT'; // ID auto-incremental
  static const String textType = 'TEXT NOT NULL'; // Texto requerido
  static const String realType = 'REAL NOT NULL'; // Número decimal requerido
  
  // Nombres de las columnas en la base de datos
  static const String id = '_id'; // Identificador único del producto
  static const String nombre = 'nombre'; // Nombre del producto
  static const String descripcion = 'descripcion'; // Descripción detallada
  static const String fechaVencimiento = 'fecha_vencimiento'; // Fecha de vencimiento
  static const String precio = 'precio'; // Precio del producto
  static const String createdTime = 'created_time'; // Fecha de creación del registro
}

/// Modelo de datos para representar un producto
/// Esta clase define la estructura de un producto con todos sus atributos
/// y métodos para convertir entre diferentes formatos (JSON, base de datos, etc.)
class ProductModel {
  // Propiedades del producto
  int? id; // ID único (puede ser null para productos nuevos)
  final String nombre; // Nombre del producto (requerido)
  final String descripcion; // Descripción detallada (requerido)
  final DateTime fechaVencimiento; // Fecha de vencimiento (requerido)
  final double precio; // Precio del producto (requerido)
  final DateTime? createdTime; // Fecha de creación (opcional, se asigna automáticamente)

  /// Constructor para crear una instancia de ProductModel
  /// Todos los campos son requeridos excepto id y createdTime
  ProductModel({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.precio,
    this.createdTime,
  });

  /// Convierte el objeto ProductModel a un Map<String, Object?>
  /// Este formato es necesario para guardar en la base de datos SQLite
  /// Las fechas se convierten a formato ISO8601 string para almacenamiento
  Map<String, Object?> toJson() => {
        ProductFields.id: id,
        ProductFields.nombre: nombre,
        ProductFields.descripcion: descripcion,
        ProductFields.fechaVencimiento: fechaVencimiento.toIso8601String(), // Convierte DateTime a String
        ProductFields.precio: precio,
        ProductFields.createdTime: createdTime?.toIso8601String(), // Convierte DateTime opcional a String
      };

  /// Factory constructor para crear un ProductModel desde un Map
  /// Se usa para convertir datos de la base de datos de vuelta a objetos Dart
  /// Las fechas en formato string se convierten de vuelta a DateTime
  factory ProductModel.fromJson(Map<String, Object?> json) => ProductModel(
        id: json[ProductFields.id] as int?, // Cast seguro a int opcional
        nombre: json[ProductFields.nombre] as String, // Cast a String requerido
        descripcion: json[ProductFields.descripcion] as String, // Cast a String requerido
        fechaVencimiento: DateTime.parse(json[ProductFields.fechaVencimiento] as String), // Parse string a DateTime
        precio: json[ProductFields.precio] as double, // Cast a double requerido
        createdTime: DateTime.tryParse(json[ProductFields.createdTime] as String? ?? ''), // Parse opcional con fallback
      );

  /// Método copy para crear una nueva instancia con algunos campos modificados
  /// Útil para actualizaciones parciales sin mutar el objeto original
  /// Si no se proporciona un valor, se mantiene el valor actual
  ProductModel copy({
    int? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaVencimiento,
    double? precio,
    DateTime? createdTime,
  }) =>
      ProductModel(
        id: id ?? this.id, // Usa el nuevo ID o mantiene el actual
        nombre: nombre ?? this.nombre, // Usa el nuevo nombre o mantiene el actual
        descripcion: descripcion ?? this.descripcion, // Usa la nueva descripción o mantiene la actual
        fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento, // Usa la nueva fecha o mantiene la actual
        precio: precio ?? this.precio, // Usa el nuevo precio o mantiene el actual
        createdTime: createdTime ?? this.createdTime, // Usa la nueva fecha de creación o mantiene la actual
      );
}
