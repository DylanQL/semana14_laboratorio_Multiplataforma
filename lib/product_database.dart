// Importaciones necesarias para el manejo de base de datos
import 'package:semana14_laboratorio/product_model.dart'; // Modelo de datos de producto
import 'package:sqflite/sqflite.dart'; // Plugin para SQLite en Flutter
import 'package:path/path.dart'; // Utilidades para manejo de rutas de archivos

/// Clase que maneja todas las operaciones de base de datos para productos
/// Implementa el patrón Singleton para asegurar una sola instancia de la base de datos
/// Proporciona métodos CRUD (Create, Read, Update, Delete) para productos
class ProductDatabase {
  /// Instancia única de la clase (patrón Singleton)
  /// Se inicializa una sola vez y se reutiliza en toda la aplicación
  static final ProductDatabase instance = ProductDatabase._internal();

  /// Variable estática que mantiene la referencia a la base de datos
  /// Es nullable porque se inicializa de forma lazy (cuando se necesita)
  static Database? _database;

  /// Constructor privado para implementar el patrón Singleton
  /// Previene la creación de múltiples instancias desde fuera de la clase
  ProductDatabase._internal();

  /// Getter que proporciona acceso a la base de datos
  /// Implementa inicialización lazy - solo crea la BD cuando se necesita por primera vez
  /// Retorna la instancia existente si ya está inicializada
  Future<Database> get database async {
    if (_database != null) {
      return _database!; // Retorna la instancia existente
    }

    // Si no existe, inicializa la base de datos
    _database = await _initDatabase();
    return _database!;
  }

  /// Método privado para inicializar la base de datos
  /// 1. Obtiene la ruta donde se almacenan las bases de datos del dispositivo
  /// 2. Crea la ruta completa al archivo de la base de datos
  /// 3. Abre/crea la base de datos con la versión especificada
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath(); // Obtiene el directorio de bases de datos del sistema
    final path = join(databasePath, 'productos.db'); // Combina la ruta con el nombre del archivo
    
    // Abre la base de datos y ejecuta onCreate si es la primera vez
    return await openDatabase(
      path, // Ruta completa al archivo de base de datos
      version: 1, // Versión de la base de datos (para migraciones futuras)
      onCreate: _createDatabase, // Función que se ejecuta al crear la BD por primera vez
    );
  }

  /// Método para crear la estructura de la base de datos
  /// Se ejecuta automáticamente cuando se crea la BD por primera vez
  /// Define la tabla 'productos' con todas sus columnas y tipos de datos
  Future<void> _createDatabase(Database db, _) async {
    // Ejecuta el comando SQL para crear la tabla productos
    return await db.execute('''
        CREATE TABLE ${ProductFields.tableName} (
          ${ProductFields.id} ${ProductFields.idType},
          ${ProductFields.nombre} ${ProductFields.textType},
          ${ProductFields.descripcion} ${ProductFields.textType},
          ${ProductFields.fechaVencimiento} ${ProductFields.textType},
          ${ProductFields.precio} ${ProductFields.realType},
          ${ProductFields.createdTime} ${ProductFields.textType}
        )
      ''');
  }

  /// Crea un nuevo producto en la base de datos (operación CREATE del CRUD)
  /// Recibe un ProductModel, lo convierte a JSON y lo inserta en la tabla
  /// Retorna el producto con el ID asignado por la base de datos
  Future<ProductModel> create(ProductModel product) async {
    final db = await instance.database; // Obtiene la instancia de la base de datos
    final id = await db.insert(ProductFields.tableName, product.toJson()); // Inserta y obtiene el ID generado
    return product.copy(id: id); // Retorna una copia del producto con el ID asignado
  }

  /// Lee un producto específico de la base de datos por su ID (operación READ del CRUD)
  /// Busca un producto usando su ID único
  /// Lanza una excepción si no encuentra el producto
  Future<ProductModel> read(int id) async {
    final db = await instance.database; // Obtiene la instancia de la base de datos
    
    // Ejecuta una consulta SELECT con filtro WHERE por ID
    final maps = await db.query(
      ProductFields.tableName, // Tabla a consultar
      columns: ProductFields.values, // Columnas a seleccionar (todas)
      where: '${ProductFields.id} = ?', // Condición WHERE con placeholder
      whereArgs: [id], // Valor para reemplazar el placeholder (previene SQL injection)
    );

    // Verifica si se encontró el producto
    if (maps.isNotEmpty) {
      return ProductModel.fromJson(maps.first); // Convierte el primer resultado a ProductModel
    } else {
      throw Exception('ID $id not found'); // Lanza excepción si no existe
    }
  }

  /// Lee todos los productos de la base de datos (operación READ del CRUD)
  /// Retorna una lista con todos los productos ordenados por fecha de creación (más recientes primero)
  /// Útil para mostrar la lista completa en la interfaz de usuario
  Future<List<ProductModel>> readAll() async {
    final db = await instance.database; // Obtiene la instancia de la base de datos
    const orderBy = '${ProductFields.createdTime} DESC'; // Ordena por fecha de creación descendente
    
    // Ejecuta SELECT * FROM productos ORDER BY created_time DESC
    final result = await db.query(ProductFields.tableName, orderBy: orderBy);
    
    // Convierte cada Map del resultado a ProductModel y retorna la lista
    return result.map((json) => ProductModel.fromJson(json)).toList();
  }

  /// Actualiza un producto existente en la base de datos (operación UPDATE del CRUD)
  /// Busca el producto por ID y actualiza todos sus campos con los nuevos valores
  /// Retorna el número de filas afectadas (debería ser 1 si la actualización fue exitosa)
  Future<int> update(ProductModel product) async {
    final db = await instance.database; // Obtiene la instancia de la base de datos
    
    // Ejecuta UPDATE productos SET ... WHERE _id = ?
    return db.update(
      ProductFields.tableName, // Tabla a actualizar
      product.toJson(), // Nuevos valores convertidos a Map
      where: '${ProductFields.id} = ?', // Condición WHERE por ID
      whereArgs: [product.id], // Valor del ID para el WHERE
    );
  }

  /// Elimina un producto de la base de datos por su ID (operación DELETE del CRUD)
  /// Busca el producto por ID y lo elimina permanentemente
  /// Retorna el número de filas afectadas (debería ser 1 si la eliminación fue exitosa)
  Future<int> delete(int id) async {
    final db = await instance.database; // Obtiene la instancia de la base de datos
    
    // Ejecuta DELETE FROM productos WHERE _id = ?
    return await db.delete(
      ProductFields.tableName, // Tabla de la cual eliminar
      where: '${ProductFields.id} = ?', // Condición WHERE por ID
      whereArgs: [id], // Valor del ID para el WHERE
    );
  }

  /// Cierra la conexión a la base de datos
  /// Importante llamar este método al finalizar la aplicación para liberar recursos
  /// Generalmente se llama en el dispose() de los widgets que usan la base de datos
  Future close() async {
    final db = await instance.database; // Obtiene la instancia de la base de datos
    db.close(); // Cierra la conexión
  }
}
