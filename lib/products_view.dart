// Importaciones necesarias para la vista de productos
import 'package:flutter/cupertino.dart'; // Framework de UI con estilo iOS
import 'package:semana14_laboratorio/product_model.dart'; // Modelo de datos de producto
import 'package:semana14_laboratorio/product_database.dart'; // Clase para operaciones de base de datos
import 'package:semana14_laboratorio/product_details_view.dart'; // Vista de detalles/edición de producto

/// Vista principal que muestra la lista de productos
/// Es un StatefulWidget porque maneja estado dinámico (lista de productos, búsqueda, etc.)
/// Permite ver, buscar, agregar y navegar a los detalles de productos
class ProductsView extends StatefulWidget {
  const ProductsView({super.key});

  @override
  State<ProductsView> createState() => _ProductsViewState();
}

/// Estado de la vista de productos
/// Maneja toda la lógica de la pantalla principal: lista, búsqueda, navegación
class _ProductsViewState extends State<ProductsView> {
  // Instancia de la base de datos para operaciones CRUD
  ProductDatabase productDatabase = ProductDatabase.instance;

  // Listas para manejar los productos
  List<ProductModel> products = []; // Lista completa de productos de la BD
  List<ProductModel> filteredProducts = []; // Lista filtrada según búsqueda
  
  // Controlador para el campo de búsqueda
  TextEditingController searchController = TextEditingController();

  /// Método que se ejecuta cuando se inicializa el widget
  /// Carga los productos de la base de datos al abrir la pantalla
  @override
  void initState() {
    refreshProducts(); // Carga inicial de productos
    super.initState();
  }

  /// Método que se ejecuta cuando se destruye el widget
  /// Libera recursos y cierra conexiones para evitar memory leaks
  @override
  dispose() {
    productDatabase.close(); // Cierra la conexión a la base de datos
    searchController.dispose(); // Libera el controlador del campo de búsqueda
    super.dispose();
  }

  /// Obtiene todos los productos de la base de datos y actualiza el estado
  /// Se llama al inicializar la vista y después de crear/editar/eliminar productos
  /// Actualiza tanto la lista completa como la filtrada
  refreshProducts() {
    productDatabase.readAll().then((value) {
      setState(() {
        products = value; // Actualiza la lista completa
        filteredProducts = value; // Inicialmente, la lista filtrada es igual a la completa
      });
    });
  }

  /// Filtra productos basándose en la consulta de búsqueda
  /// Busca coincidencias en el nombre y descripción del producto (case-insensitive)
  /// Actualiza la lista filtrada que se muestra en la UI
  void _filterProducts(String query) {
    List<ProductModel> filtered = products.where((product) {
      // Convierte a minúsculas para búsqueda case-insensitive
      return product.nombre.toLowerCase().contains(query.toLowerCase()) ||
          product.descripcion.toLowerCase().contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredProducts = filtered; // Actualiza la lista filtrada
    });
  }

  /// Navega a la vista de detalles del producto y actualiza la lista al regresar
  /// Si no se proporciona ID, abre la vista para crear un nuevo producto
  /// Si se proporciona ID, abre la vista para editar el producto existente
  goToProductDetailsView({int? id}) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => ProductDetailsView(productId: id)),
    );
    refreshProducts(); // Actualiza la lista al regresar (en caso de cambios)
  }

  /// Formatea una fecha DateTime al formato DD/MM/YYYY
  /// Utilizado para mostrar fechas de forma legible en la UI
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  /// Determina el color de fondo según la fecha de vencimiento del producto
  /// Rojo: Producto vencido, Naranja: Vence en 7 días o menos, Verde: Más de 7 días
  /// Ayuda a identificar visualmente el estado de vencimiento
  Color _getExpirationColor(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return CupertinoColors.systemRed.withOpacity(0.1); // Fondo rojo claro para vencidos
    } else if (difference <= 7) {
      return CupertinoColors.systemOrange.withOpacity(0.1); // Fondo naranja claro para próximos a vencer
    } else {
      return CupertinoColors.systemGreen.withOpacity(0.1); // Fondo verde claro para productos frescos
    }
  }

  /// Determina el color del borde según la fecha de vencimiento del producto
  /// Misma lógica que _getExpirationColor pero para bordes (colores más intensos)
  /// Proporciona una señal visual clara del estado de vencimiento
  Color _getExpirationBorderColor(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return CupertinoColors.systemRed; // Borde rojo para vencidos
    } else if (difference <= 7) {
      return CupertinoColors.systemOrange; // Borde naranja para próximos a vencer
    } else {
      return CupertinoColors.systemGreen; // Borde verde para productos frescos
    }
  }

  /// Selecciona el ícono apropiado según la fecha de vencimiento
  /// Exclamación: Vencido, Reloj: Próximo a vencer, Check: Producto fresco
  /// Refuerza visualmente el estado del producto
  IconData _getExpirationIcon(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return CupertinoIcons.exclamationmark_circle_fill; // Ícono de advertencia para vencidos
    } else if (difference <= 7) {
      return CupertinoIcons.clock_fill; // Ícono de reloj para próximos a vencer
    } else {
      return CupertinoIcons.checkmark_circle_fill; // Ícono de check para productos frescos
    }
  }

  /// Genera el texto descriptivo del estado de vencimiento
  /// Proporciona información específica sobre cuándo vence o cuánto tiempo lleva vencido
  /// Ayuda al usuario a entender rápidamente el estado del producto
  String _getExpirationText(DateTime expirationDate) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    if (difference < 0) {
      return 'Vencido hace ${(-difference)} días'; // Texto para productos vencidos
    } else if (difference == 0) {
      return 'Vence hoy'; // Texto para productos que vencen hoy
    } else if (difference <= 7) {
      return 'Vence en $difference días'; // Texto para productos próximos a vencer
    } else {
      return 'Vence: ${_formatDate(expirationDate)}'; // Fecha completa para productos frescos
    }
  }

  /// Construye la interfaz de usuario de la vista de productos
  /// Incluye: barra de navegación, campo de búsqueda y lista de productos
  /// Maneja estados vacíos y muestra diferentes layouts según el contenido
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground, // Fondo agrupado estilo iOS
      
      // Barra de navegación superior
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9), // Fondo translúcido
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
        // Botón '+' para agregar nuevo producto
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: goToProductDetailsView, // Abre vista para nuevo producto (sin ID)
          child: const Icon(
            CupertinoIcons.add,
            size: 24,
          ),
        ),
      ),
      // Contenido principal de la pantalla
      child: SafeArea(
        child: Column(
          children: [
            // Barra de búsqueda
            Container(
              padding: const EdgeInsets.all(16),
              color: CupertinoColors.systemBackground,
              child: CupertinoSearchTextField(
                controller: searchController, // Controlador del campo de texto
                onChanged: _filterProducts, // Ejecuta filtrado en tiempo real
                placeholder: 'Buscar productos...', // Texto de ayuda
                style: const TextStyle(fontSize: 16),
              ),
            ),
            
            // Lista de productos (ocupa el espacio restante)
            Expanded(
              child: filteredProducts.isEmpty
                  ? // Estado vacío - no hay productos o no se encontraron en la búsqueda
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            // Ícono diferente según si la lista está vacía o es resultado de búsqueda
                            products.isEmpty 
                                ? CupertinoIcons.cube_box  // Caja vacía si no hay productos
                                : CupertinoIcons.search,   // Lupa si no se encontraron en búsqueda
                            size: 80,
                            color: CupertinoColors.placeholderText,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            // Mensaje diferente según el estado
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
                          // Mensaje adicional solo si no hay productos registrados
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
                  : // Lista de productos - se muestra cuando hay productos filtrados
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredProducts.length, // Número de productos a mostrar
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index]; // Producto actual del índice
                        
                        // Container para cada producto en la lista
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12), // Espaciado entre tarjetas
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            // Al tocar, navega a la vista de detalles con el ID del producto
                            onPressed: () => goToProductDetailsView(id: product.id),
                            child: Container(
                              decoration: BoxDecoration(
                                // Color de fondo según estado de vencimiento
                                color: _getExpirationColor(product.fechaVencimiento),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  // Color de borde según estado de vencimiento
                                  color: _getExpirationBorderColor(product.fechaVencimiento),
                                  width: 1.5,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    // Fila superior: Nombre del producto e ícono de estado
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            product.nombre, // Nombre del producto
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w700,
                                              color: CupertinoColors.label,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          // Ícono según estado de vencimiento
                                          _getExpirationIcon(product.fechaVencimiento),
                                          color: _getExpirationBorderColor(product.fechaVencimiento),
                                          size: 24,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    
                                    // Descripción del producto (máximo 2 líneas)
                                    Text(
                                      product.descripcion,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: CupertinoColors.secondaryLabel,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis, // Añade "..." si es muy largo
                                    ),
                                    const SizedBox(height: 12),
                                    // Fila inferior: Información de vencimiento y precio
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Columna izquierda: Información de fechas
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Estado de vencimiento con color dinámico
                                            Text(
                                              _getExpirationText(product.fechaVencimiento),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _getExpirationBorderColor(product.fechaVencimiento),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // Fecha de creación del producto
                                            Text(
                                              'Agregado: ${_formatDate(product.createdTime!)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: CupertinoColors.tertiaryLabel,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        // Precio del producto en contenedor destacado
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemBlue, // Fondo azul
                                            borderRadius: BorderRadius.circular(20), // Bordes redondeados
                                          ),
                                          child: Text(
                                            '\$${product.precio.toStringAsFixed(2)}', // Precio con 2 decimales
                                            style: const TextStyle(
                                              color: CupertinoColors.white, // Texto blanco
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
