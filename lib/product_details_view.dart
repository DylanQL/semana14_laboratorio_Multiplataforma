import 'package:flutter/material.dart';
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fechaVencimientoController.text = _formatDate(picked);
      });
    }
  }

  /// Creates a new product if the isNewProduct is true else it updates the existing product
  createProduct() {
    if (nombreController.text.isEmpty ||
        descripcionController.text.isEmpty ||
        selectedDate == null ||
        precioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? precio = double.tryParse(precioController.text);
    if (precio == null || precio <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingrese un precio válido'),
          backgroundColor: Colors.red,
        ),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto creado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      });
    } else {
      model.id = product.id;
      productDatabase.update(model).then((_) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto actualizado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      });
    }
  }

  /// Deletes the product from the database and navigates back to the previous screen
  deleteProduct() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: const Text('¿Está seguro de que desea eliminar este producto?'),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                final navigator = Navigator.of(context);
                final parentNavigator = Navigator.of(context);
                productDatabase.delete(product.id!).then((_) {
                  if (mounted) {
                    navigator.pop(); // Close dialog
                    parentNavigator.pop(); // Go back to products list
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(isNewProduct ? 'Nuevo Producto' : 'Editar Producto'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Visibility(
            visible: !isNewProduct,
            child: IconButton(
              onPressed: deleteProduct,
              icon: const Icon(Icons.delete),
            ),
          ),
          IconButton(
            onPressed: createProduct,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              TextField(
                                controller: nombreController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre del producto',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.shopping_bag),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: descripcionController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  labelText: 'Descripción',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.description),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: fechaVencimientoController,
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                decoration: const InputDecoration(
                                  labelText: 'Fecha de vencimiento',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                  suffixIcon: Icon(Icons.arrow_drop_down),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: precioController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
                                decoration: const InputDecoration(
                                  labelText: 'Precio',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.attach_money),
                                  prefixText: '\$ ',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: createProduct,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isNewProduct ? 'Crear Producto' : 'Actualizar Producto',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
