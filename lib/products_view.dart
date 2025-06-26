import 'package:flutter/material.dart';
import 'package:semana14_laboratorio/product_model.dart';
import 'package:semana14_laboratorio/product_database.dart';
import 'package:semana14_laboratorio/product_details_view.dart';

class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<ProductsView> {
  ProductDatabase productDatabase = ProductDatabase.instance;

  List<ProductModel> products = [];
  List<ProductModel> filteredProducts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    refreshProducts();
    super.initState();
  }

  @override
  dispose() {
    //close the database
    productDatabase.close();
    searchController.dispose();
    super.dispose();
  }

  /// Gets all the products from the database and updates the state
  refreshProducts() {
    productDatabase.readAll().then((value) {
      setState(() {
        products = value;
        filteredProducts = value;
      });
    });
  }

  /// Filters products based on search query
  void _filterProducts(String query) {
    List<ProductModel> filtered = products.where((product) {
      return product.nombre.toLowerCase().contains(query.toLowerCase()) ||
          product.descripcion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = filtered;
    });
  }

  /// Navigates to the ProductDetailsView and refreshes the products after the navigation
  goToProductDetailsView({int? id}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailsView(productId: id)),
    );
    refreshProducts();
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  Color _getExpirationColor(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return Colors.red[100]!; // Expired
    } else if (difference <= 7) {
      return Colors.orange[100]!; // Expires soon
    } else {
      return Colors.green[100]!; // Safe
    }
  }

  IconData _getExpirationIcon(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return Icons.error; // Expired
    } else if (difference <= 7) {
      return Icons.warning; // Expires soon
    } else {
      return Icons.check_circle; // Safe
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'Buscar productos...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: filteredProducts.isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    products.isEmpty ? 'No hay productos registrados' : 'No se encontraron productos',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];
                  return GestureDetector(
                    onTap: () => goToProductDetailsView(id: product.id),
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _getExpirationColor(product.fechaVencimiento),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      product.nombre,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _getExpirationIcon(product.fechaVencimiento),
                                    color: _getExpirationColor(product.fechaVencimiento) == Colors.red[100]
                                        ? Colors.red
                                        : _getExpirationColor(product.fechaVencimiento) == Colors.orange[100]
                                            ? Colors.orange[700]
                                            : Colors.green,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.descripcion,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Vence: ${_formatDate(product.fechaVencimiento)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Creado: ${_formatDate(product.createdTime!)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[600],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '\$${product.precio.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: goToProductDetailsView,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        tooltip: 'Crear Producto',
        child: const Icon(Icons.add),
      ),
    );
  }
}
