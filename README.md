# Gestión de Productos - Flutter App

Una aplicación Flutter para gestionar productos con base de datos SQLite local.

## Características

- **Modelo de Producto**: Cada producto tiene los siguientes campos:
  - Nombre
  - Descripción
  - Fecha de Vencimiento
  - Precio

- **Funcionalidades**:
  - Crear nuevos productos
  - Editar productos existentes
  - Eliminar productos
  - Buscar productos por nombre o descripción
  - Visualización con códigos de color según fecha de vencimiento:
    - 🔴 Rojo: Producto vencido
    - 🟠 Naranja: Vence en 7 días o menos
    - 🟢 Verde: Producto en buen estado

## Dependencias

- `sqflite: ^2.4.2` - Base de datos SQLite para Flutter
- `path: ^1.9.1` - Utilidades para manejo de rutas

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── product_model.dart        # Modelo de datos del producto
├── product_database.dart     # Manejo de base de datos SQLite
├── products_view.dart        # Vista principal con lista de productos
└── product_details_view.dart # Vista para crear/editar productos
```

## Instalación y Ejecución

1. Instalar las dependencias:
```bash
flutter pub get
```

2. Ejecutar la aplicación:
```bash
flutter run
```

## Funcionalidades Principales

### Vista Principal (ProductsView)
- Lista todos los productos registrados
- Barra de búsqueda para filtrar productos
- Indicadores visuales de estado de vencimiento
- Botón flotante para agregar nuevos productos

### Vista de Detalles (ProductDetailsView)
- Formulario para crear nuevos productos
- Edición de productos existentes
- Selector de fecha para fecha de vencimiento
- Validación de campos obligatorios
- Confirmación antes de eliminar productos

### Base de Datos
- Almacenamiento local con SQLite
- Operaciones CRUD completas
- Consultas optimizadas
- Manejo de errores

## Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo multiplataforma
- **Dart**: Lenguaje de programación
- **SQLite**: Base de datos local
- **Material Design**: Diseño de interfaz de usuario

## Pantallas

1. **Pantalla Principal**: Lista de productos con búsqueda
2. **Pantalla de Detalles**: Formulario para crear/editar productos
3. **Diálogos de Confirmación**: Para eliminar productos

## Validaciones

- Todos los campos son obligatorios
- El precio debe ser un número positivo
- La fecha de vencimiento debe ser futura
- Validación de formato de entrada

## Características de UX/UI

- Interfaz moderna y limpia
- Códigos de color intuitivos
- Mensajes de confirmación
- Indicadores de carga
- Navegación fluida
- Responsivo y accesible
