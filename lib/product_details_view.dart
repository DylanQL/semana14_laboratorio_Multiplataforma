import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:semana14_laboratorio/product_model.dart';
import 'package:semana14_laboratorio/product_database.dart';

class ProductDetailsView extends StatefulWidget {
  const ProductDetailsView({super.key, this.productId});
  final int? productId;

  @override
  State<ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<ProductDetailsView> {
  ProductDatabase productDatabase = ProductDatabase.instance;

  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController fechaVencimientoController = TextEditingController();
  TextEditingController precioController = TextEditingController();

  late ProductModel product;
  bool isLoading = false;
  bool isNewProduct = false;
  DateTime? selectedDate;

  @override
  void initState() {
    refreshProduct();
    super.initState();
  }

  @override
  void dispose() {
    nombreController.dispose();
    descripcionController.dispose();
    fechaVencimientoController.dispose();
    precioController.dispose();
    super.dispose();
  }

  /// Gets the product from the database and updates the state if the productId is not null else it sets the isNewProduct to true
  refreshProduct() {
    if (widget.productId == null) {
      setState(() {
        isNewProduct = true;
      });
      return;
    }
    productDatabase.read(widget.productId!).then((value) {
      setState(() {
        product = value;
        nombreController.text = product.nombre;
        descripcionController.text = product.descripcion;
        selectedDate = product.fechaVencimiento;
        fechaVencimientoController.text = _formatDate(product.fechaVencimiento);
        precioController.text = product.precio.toString();
      });
    });
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  void _selectDate(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = selectedDate ?? DateTime.now().add(const Duration(days: 1));
        return Container(
          height: 300,
          padding: const EdgeInsets.only(top: 6.0),
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: CupertinoColors.systemBackground.resolveFrom(context),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
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
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancelar',
                          style: TextStyle(color: CupertinoColors.systemRed),
                        ),
                      ),
                      const Text(
                        'Fecha de Vencimiento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          setState(() {
                            selectedDate = tempDate;
                            fechaVencimientoController.text = _formatDate(tempDate);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    minimumDate: DateTime.now(),
                    maximumDate: DateTime(2030),
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
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

  /// Creates a new product if the isNewProduct is true else it updates the existing product
  void createProduct() {
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

    final double? precio = double.tryParse(precioController.text);
    if (precio == null || precio <= 0) {
      _showAlert(
        'Precio inválido',
        'Por favor, ingrese un precio válido mayor a 0.',
        isError: true,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final model = ProductModel(
      nombre: nombreController.text,
      descripcion: descripcionController.text,
      fechaVencimiento: selectedDate!,
      precio: precio,
      createdTime: DateTime.now(),
    );

    if (isNewProduct) {
      productDatabase.create(model).then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _showAlert(
            'Éxito',
            'Producto creado exitosamente.',
            isError: false,
            onDismiss: () => Navigator.pop(context),
          );
        }
      });
    } else {
      model.id = product.id;
      productDatabase.update(model).then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          _showAlert(
            'Éxito',
            'Producto actualizado exitosamente.',
            isError: false,
            onDismiss: () => Navigator.pop(context),
          );
        }
      });
    }
  }

  /// Deletes the product from the database and navigates back to the previous screen
  void deleteProduct() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Eliminar Producto'),
          content: const Text('¿Está seguro de que desea eliminar este producto? Esta acción no se puede deshacer.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Eliminar'),
              onPressed: () async {
                final navigator = Navigator.of(context);
                navigator.pop(); // Close dialog first
                await productDatabase.delete(product.id!);
                if (mounted) {
                  navigator.pop(); // Go back to products list
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAlert(String title, String message, {required bool isError, VoidCallback? onDismiss}) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                if (onDismiss != null) {
                  onDismiss();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    VoidCallback? onTap,
    bool readOnly = false,
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
          Icon(
            icon,
            color: CupertinoColors.systemBlue,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CupertinoTextField(
              controller: controller,
              placeholder: placeholder,
              maxLines: maxLines,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onTap: onTap,
              readOnly: readOnly,
              decoration: const BoxDecoration(),
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
        middle: Text(
          isNewProduct ? 'Nuevo Producto' : 'Editar Producto',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isNewProduct)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: deleteProduct,
                child: const Icon(
                  CupertinoIcons.delete,
                  color: CupertinoColors.systemRed,
                ),
              ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: isLoading ? null : createProduct,
              child: const Text(
                'Guardar',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(
                child: CupertinoActivityIndicator(radius: 20),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFormSection(
                      title: 'Información del Producto',
                      children: [
                        _buildTextField(
                          controller: nombreController,
                          placeholder: 'Nombre del producto',
                          icon: CupertinoIcons.cube_box,
                        ),
                        _buildTextField(
                          controller: descripcionController,
                          placeholder: 'Descripción detallada',
                          icon: CupertinoIcons.text_alignleft,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    _buildFormSection(
                      title: 'Detalles Adicionales',
                      children: [
                        _buildTextField(
                          controller: fechaVencimientoController,
                          placeholder: 'Seleccionar fecha de vencimiento',
                          icon: CupertinoIcons.calendar,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                        ),
                        _buildTextField(
                          controller: precioController,
                          placeholder: '0.00',
                          icon: CupertinoIcons.money_dollar,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton.filled(
                        onPressed: isLoading ? null : createProduct,
                        borderRadius: BorderRadius.circular(12),
                        child: Text(
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
