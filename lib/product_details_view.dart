// Importaciones necesarias para la vista de detalles de producto
import 'package:flutter/cupertino.dart'; // Framework de UI con estilo iOS
import 'package:flutter/services.dart'; // Servicios del sistema (formatters, etc.)
import 'package:semana14_laboratorio/product_model.dart'; // Modelo de datos de producto
import 'package:semana14_laboratorio/product_database.dart'; // Clase para operaciones de base de datos

/// Vista de detalles de producto - permite crear nuevos productos o editar existentes
/// Es un StatefulWidget porque maneja formularios y estado de carga
/// Recibe un productId opcional: null = crear nuevo, int = editar existente
class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key, this.productId});
  final int? productId; // ID del producto a editar (null para nuevo producto)

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

/// Estado de la vista de detalles del producto
/// Maneja formularios, validación, operaciones CRUD y estados de carga
class _ProductDetailsViewState extends State<ProductDetailsView> {
  // Instancia de la base de datos para operaciones CRUD
  ProductDatabase productDatabase = ProductDatabase.instance;

  // Controladores para los campos del formulario
  TextEditingController nombreController = TextEditingController();      // Campo nombre
  TextEditingController descripcionController = TextEditingController(); // Campo descripción
  TextEditingController fechaVencimientoController = TextEditingController(); // Campo fecha (solo lectura)
  TextEditingController precioController = TextEditingController();      // Campo precio

  // Variables de estado
  late ProductModel product;    // Producto actual (para modo edición)
  bool isLoading = false;       // Estado de carga durante operaciones async
  bool isNewProduct = false;    // true = crear nuevo, false = editar existente
  DateTime? selectedDate;       // Fecha seleccionada en el date picker

  /// Se ejecuta cuando se inicializa el widget
  /// Determina si es modo creación o edición y carga los datos correspondientes
  @override
  void initState() {
    refreshProduct(); // Carga el producto o configura modo creación
    super.initState();
  }

  /// Se ejecuta cuando se destruye el widget
  /// Libera todos los controladores para evitar memory leaks
  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    fechaVencimientoController.dispose();
    precioController.dispose();
    super.dispose();
  }

  /// Obtiene el producto de la base de datos y actualiza el estado
  /// Si productId es null, configura el modo de creación de nuevo producto
  /// Si productId existe, carga los datos del producto para edición
  refreshProduct() {
    if (widget.productId == null) {
      // Modo creación: nuevo producto
      setState(() {
        isNewProduct = true;
      });
      return;
    }
    
    // Modo edición: cargar producto existente
    productDatabase.read(widget.productId!).then((value) {
      setState(() {
        product = value; // Almacena el producto cargado
        
        // Llena los controladores con los datos existentes
        nombreController.text = product.nombre;
        descripcionController.text = product.descripcion;
        selectedDate = product.fechaVencimiento;
        fechaVencimientoController.text = _formatDate(product.fechaVencimiento);
        precioController.text = product.precio.toString();
      });
    });
  }

  /// Formatea una fecha DateTime al formato DD/MM/YYYY
  /// Utilizado para mostrar fechas de forma legible en el campo de fecha
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  /// Muestra un selector de fecha modal estilo iOS
  /// Permite seleccionar fechas futuras para el vencimiento del producto
  /// Incluye botones de cancelar y confirmar para mejorar la UX
  void _selectDate(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        // Fecha inicial: la seleccionada actualmente o mañana
        DateTime tempDate = selectedDate ?? DateTime.now().add(const Duration(days: 1));
        
        return Container(
          height: 300, // Altura fija del modal
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Evita que el teclado tape el modal
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Barra superior con botones de acción
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: CupertinoColors.separator,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Botón cancelar (no guarda cambios)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: CupertinoColors.systemRed),
                        ),
                      ),
                      // Título del modal
                      const Text(
                        'Fecha de Vencimiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // Botón confirmar (guarda la fecha seleccionada)
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            selectedDate = tempDate; // Guarda la fecha temporal
                            fechaVencimientoController.text = _formatDate(tempDate); // Actualiza el campo de texto
                          });
                          Navigator.pop(context); // Cierra el modal
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                ),
                // Selector de fecha (rueda estilo iOS)
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date, // Solo fecha, sin hora
                    initialDateTime: tempDate, // Fecha inicial mostrada
                    minimumDate: DateTime.now(), // No permite fechas pasadas
                    maximumDate: DateTime(2030), // Límite superior arbitrario
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate; // Actualiza la fecha temporal mientras se mueve la rueda
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Crea un nuevo producto o actualiza uno existente
  /// Incluye validación completa de campos y manejo de errores
  /// Muestra mensajes de confirmación al usuario
  void createProduct() {
    // Validación de campos requeridos
    if (nombreController.text.isEmpty ||
        descripcionController.text.isEmpty ||
        selectedDate == null ||
        precioController.text.isEmpty) {
      _showAlert(
        'Campos requeridos',
        'Por favor, complete todos los campos.',
        isError: true,
      );
      return;
    }

    // Validación del precio (debe ser un número válido y mayor a 0)
    final double? precio = double.tryParse(precioController.text);
    if (precio == null || precio <= 0) {
      _showAlert(
        'Precio inválido',
        'Por favor, ingrese un precio válido mayor a 0.',
        isError: true,
      );
      return;
    }

    // Muestra indicador de carga durante la operación async
    setState(() {
      isLoading = true;
    });

    // Crea el modelo del producto con los datos del formulario
    final model = ProductModel(
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      fechaVencimiento: selectedDate!,
      precio: precio,
      createdTime: DateTime.now(), // Marca el momento de creación
    );

    if (isNewProduct) {
      // Modo creación: inserta nuevo producto en la base de datos
      productDatabase.create(model).then((_) {
        if (mounted) { // Verifica que el widget siga activo
          setState(() {
            isLoading = false;
          });
          _showAlert(
            'Éxito',
            'Producto creado exitosamente.',
            isError: false,
            onDismiss: () => Navigator.pop(context), // Regresa a la lista al confirmar
          );
        }
      });
    } else {
      // Modo edición: actualiza producto existente
      model.id = product.id; // Mantiene el ID original
      productDatabase.update(model).then((_) {
        if (mounted) { // Verifica que el widget siga activo
          setState(() {
            isLoading = false;
          });
          _showAlert(
            'Éxito',
            'Producto actualizado exitosamente.',
            isError: false,
            onDismiss: () => Navigator.pop(context), // Regresa a la lista al confirmar
          );
        }
      });
    }
  }

  /// Elimina el producto de la base de datos y navega de regreso a la pantalla anterior
  /// Incluye confirmación para prevenir eliminaciones accidentales
  /// Solo disponible en modo edición (no para productos nuevos)
  void deleteProduct() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text('¿Está seguro de que desea eliminar este producto? Esta acción no se puede deshacer.'),
          actions: [
            // Botón para cancelar la eliminación
            CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Solo cierra el diálogo
              },
            ),
            // Botón para confirmar la eliminación (destructivo)
            CupertinoDialogAction(
              isDestructiveAction: true, // Aplica estilo de acción destructiva (rojo)
              child: const Text('Eliminar'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop(); // Cierra el diálogo de confirmación
                await productDatabase.delete(product.id!); // Elimina de la base de datos
                if (mounted) { // Verifica que el widget siga activo
                  navigator.pop(); // Regresa a la lista de productos
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Muestra un diálogo de alerta con mensaje personalizado
  /// Utilizado para mostrar errores de validación y confirmaciones de éxito
  /// Incluye callback opcional para ejecutar acción al cerrar
  void _showAlert(String title, String message, {required bool isError, VoidCallback? onDismiss}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title), // Título del diálogo
          content: Text(message), // Mensaje del diálogo
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                if (onDismiss != null) {
                  onDismiss(); // Ejecuta callback si existe
                }
              },
            ),
          ],
        );
      },
    );
  }

  /// Construye una sección del formulario con título y campos agrupados
  /// Crea un contenedor estilizado que agrupa campos relacionados
  /// Mejora la organización visual del formulario
  Widget _buildFormSection({
    required String title,      // Título de la sección
    required List<Widget> children, // Widgets que contiene la sección
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20), // Espaciado entre secciones
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground, // Fondo blanco/gris según tema
        borderRadius: BorderRadius.circular(12), // Bordes redondeados
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la sección
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CupertinoColors.label,
              ),
            ),
          ),
          ...children, // Expande la lista de widgets hijos
        ],
      ),
    );
  }

  /// Construye un campo de texto personalizado con ícono y estilo consistente
  /// Reutilizable para todos los campos del formulario
  /// Soporta diferentes tipos de entrada y comportamientos
  Widget _buildTextField({
    required TextEditingController controller,  // Controlador del campo
    required String placeholder,               // Texto de placeholder
    required IconData icon,                   // Ícono que se muestra a la izquierda
    int maxLines = 1,                        // Número máximo de líneas
    TextInputType keyboardType = TextInputType.text, // Tipo de teclado
    List<TextInputFormatter>? inputFormatters, // Formateadores de entrada
    VoidCallback? onTap,                     // Callback al tocar el campo
    bool readOnly = false,                   // Si el campo es de solo lectura
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Ícono del campo
          Icon(
            icon,
            color: CupertinoColors.systemBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          // Campo de texto expandido
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              maxLines: maxLines,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onTap: onTap,
              readOnly: readOnly,
              decoration: const BoxDecoration(), // Sin decoración (estilo limpio)
              style: const TextStyle(fontSize: 16),
              placeholderStyle: const TextStyle(
                color: CupertinoColors.placeholderText,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la interfaz de usuario de la vista de detalles
  /// Incluye formulario completo, validación y manejo de estados de carga
  /// Adapta la UI según el modo (creación vs edición)
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      
      // Barra de navegación con botones contextuales
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemBackground.withOpacity(0.9),
        border: const Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0.5,
          ),
        ),
        // Título dinámico según el modo
        middle: Text(
          isNewProduct ? 'Nuevo Producto' : 'Editar Producto',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        // Botón cancelar (lado izquierdo)
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        // Botones de acción (lado derecho)
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón eliminar (solo en modo edición)
            if (!isNewProduct)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: deleteProduct,
                child: const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                ),
              ),
            // Botón guardar
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: isLoading ? null : createProduct, // Deshabilitado durante carga
              child: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      // Contenido principal
      child: SafeArea(
        child: isLoading
            ? // Estado de carga - muestra indicador de actividad
              const Center(
                child: CupertinoActivityIndicator(radius: 20),
              )
            : // Formulario principal - scroll para campos largos
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Sección 1: Información básica del producto
                    _buildFormSection(
                      title: 'Información del Producto',
                      children: [
                        // Campo nombre
                        _buildTextField(
                          controller: nombreController,
                          placeholder: 'Nombre del producto',
                          icon: CupertinoIcons.cube_box,
                        ),
                        // Campo descripción (múltiples líneas)
                        _buildTextField(
                          controller: descripcionController,
                          placeholder: 'Descripción detallada',
                          icon: CupertinoIcons.text_alignleft,
                          maxLines: 3, // Permite hasta 3 líneas
                        ),
                      ],
                    ),
                    
                    // Sección 2: Detalles comerciales
                    _buildFormSection(
                      title: 'Detalles Adicionales',
                      children: [
                        // Campo fecha (solo lectura, abre selector al tocar)
                        _buildTextField(
                          controller: fechaVencimientoController,
                          placeholder: 'Seleccionar fecha de vencimiento',
                          icon: CupertinoIcons.calendar,
                          readOnly: true, // No editable directamente
                          onTap: () => _selectDate(context), // Abre el date picker
                        ),
                        // Campo precio (solo números decimales)
                        _buildTextField(
                          controller: precioController,
                          placeholder: '0.00',
                          icon: CupertinoIcons.money_dollar,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            // Solo permite números y punto decimal
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Botón principal de acción (ancho completo)
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: isLoading ? null : createProduct, // Deshabilitado durante carga
                        borderRadius: BorderRadius.circular(12),
                        child: Text(
                          // Texto dinámico según el modo
                          isNewProduct ? 'Crear Producto' : 'Actualizar Producto',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
