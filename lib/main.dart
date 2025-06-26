// Importaciones necesarias para el funcionamiento de la aplicación
import 'package:flutter/cupertino.dart'; // Framework de UI con estilo iOS
import 'package:semana14_laboratorio/products_view.dart'; // Vista principal de productos

/// Función main - Punto de entrada de la aplicación Flutter
/// Ejecuta la aplicación llamando a runApp con nuestro widget principal
void main() {
  runApp(const MyApp());
}

/// Widget principal de la aplicación
/// Es un StatelessWidget porque no maneja estado interno
/// Define la configuración global de la app incluyendo tema y rutas
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Método build - Construye la interfaz de usuario
  /// Retorna un CupertinoApp que define el estilo iOS de la aplicación
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Gestión de Productos', // Título de la aplicación
      
      // Configuración del tema visual de la aplicación
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue, // Color principal azul del sistema
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground, // Fondo agrupado
        barBackgroundColor: CupertinoColors.systemBackground, // Fondo de barras de navegación
        brightness: Brightness.light, // Tema claro
      ),
      
      home: const ProductsView(), // Pantalla inicial - Vista de productos
      debugShowCheckedModeBanner: false, // Oculta el banner de debug
    );
  }
}

