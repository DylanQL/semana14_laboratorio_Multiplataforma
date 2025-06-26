import 'package:flutter/cupertino.dart';
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
      CupertinoPageRoute(builder: (context) => ProductDetailsView(productId: id)),
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
      return CupertinoColors.systemRed.withOpacity(0.1);
    } else if (difference <= 7) {
      return CupertinoColors.systemOrange.withOpacity(0.1);
    } else {
      return CupertinoColors.systemGreen.withOpacity(0.1);
    }
  }

  Color _getExpirationBorderColor(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return CupertinoColors.systemRed;
    } else if (difference <= 7) {
      return CupertinoColors.systemOrange;
    } else {
      return CupertinoColors.systemGreen;
    }
  }

  IconData _getExpirationIcon(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return CupertinoIcons.exclamationmark_circle_fill;
    } else if (difference <= 7) {
      return CupertinoIcons.clock_fill;
    } else {
      return CupertinoIcons.checkmark_circle_fill;
    }
  }

  String _getExpirationText(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return 'Vencido hace ${(-difference)} días';
    } else if (difference == 0) {
      return 'Vence hoy';
    } else if (difference <= 7) {
      return 'Vence en $difference días';
    } else {
      return 'Vence: ${_formatDate(expirationDate)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
        middle: const Text(
          'Productos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: goToProductDetailsView,
          child: const Icon(
            CupertinoIcons.add,
            size: 24,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16),
              color: CupertinoColors.systemBackground,
              child: CupertinoSearchTextField(
                controller: searchController,
                onChanged: _filterProducts,
                placeholder: 'Buscar productos...',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            // Products list
            Expanded(
              child: filteredProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            products.isEmpty 
                                ? CupertinoIcons.cube_box 
                                : CupertinoIcons.search,
                            size: 80,
                            color: CupertinoColors.placeholderText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            products.isEmpty 
                                ? 'No hay productos registrados'
                                : 'No se encontraron productos',
                            style: const TextStyle(
                              color: CupertinoColors.placeholderText,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (products.isEmpty)
                            const Text(
                              'Toca + para agregar tu primer producto',
                              style: TextStyle(
                                color: CupertinoColors.placeholderText,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => goToProductDetailsView(id: product.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getExpirationColor(product.fechaVencimiento),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getExpirationBorderColor(product.fechaVencimiento),
                                  width: 1.5,
                                ),
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
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: CupertinoColors.label,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          _getExpirationIcon(product.fechaVencimiento),
                                          color: _getExpirationBorderColor(product.fechaVencimiento),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      product.descripcion,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: CupertinoColors.secondaryLabel,
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
                                              _getExpirationText(product.fechaVencimiento),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _getExpirationBorderColor(product.fechaVencimiento),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Agregado: ${_formatDate(product.createdTime!)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: CupertinoColors.tertiaryLabel,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemBlue,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '\$${product.precio.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontWeight: FontWeight.w700,
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
          ],
        ),
      ),
    );
  }
}
