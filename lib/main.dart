import 'package:flutter/cupertino.dart';
import 'package:semana14_laboratorio/products_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Gestión de Productos',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        scaffoldBackgroundColor: CupertinoColors.systemGroupedBackground,
        barBackgroundColor: CupertinoColors.systemBackground,
        brightness: Brightness.light,
      ),
      home: const ProductsView(),
      debugShowCheckedModeBanner: false,
    );
  }
}

