import 'package:semana14_laboratorio/product_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProductDatabase {
  static final ProductDatabase instance = ProductDatabase._internal();

  static Database? _database;

  ProductDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'productos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, _) async {
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

  Future<ProductModel> create(ProductModel product) async {
    final db = await instance.database;
    final id = await db.insert(ProductFields.tableName, product.toJson());
    return product.copy(id: id);
  }

  Future<ProductModel> read(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      ProductFields.tableName,
      columns: ProductFields.values,
      where: '${ProductFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ProductModel.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<ProductModel>> readAll() async {
    final db = await instance.database;
    const orderBy = '${ProductFields.createdTime} DESC';
    final result = await db.query(ProductFields.tableName, orderBy: orderBy);
    return result.map((json) => ProductModel.fromJson(json)).toList();
  }

  Future<int> update(ProductModel product) async {
    final db = await instance.database;
    return db.update(
      ProductFields.tableName,
      product.toJson(),
      where: '${ProductFields.id} = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      ProductFields.tableName,
      where: '${ProductFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
