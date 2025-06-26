# Gestión de Productos - Flutter App (Cupertino Design)

Una aplicación Flutter para gestionar productos con base de datos SQLite local, diseñada con componentes Cupertino (iOS style) para una experiencia de usuario premium.

## 🎨 Características de Diseño

- **Diseño Cupertino**: Interfaz elegante siguiendo las directrices de diseño de iOS
- **Componentes nativos**: Uso de CupertinoApp, CupertinoPageScaffold, CupertinoButton, etc.
- **Navegación suave**: Transiciones de página naturales con CupertinoPageRoute
- **Alertas y modales**: Diálogos y date pickers nativos de iOS
- **Tipografía mejorada**: Sistema de fuentes San Francisco optimizado
- **Colores del sistema**: Paleta de colores coherente con iOS

## 📱 Modelo de Producto

Cada producto contiene los siguientes campos:
- **Nombre** - Identificación del producto
- **Descripción** - Información detallada
- **Fecha de Vencimiento** - Control de caducidad
- **Precio** - Valor monetario

## ⚡ Funcionalidades

### 🔍 **Gestión Inteligente**
- ✅ Crear nuevos productos con validación completa
- ✅ Editar productos existentes
- ✅ Eliminar productos con confirmación
- ✅ Búsqueda en tiempo real por nombre o descripción
- ✅ Visualización con códigos de color según vencimiento:
  - 🔴 **Rojo**: Producto vencido
  - 🟠 **Naranja**: Vence en 7 días o menos  
  - 🟢 **Verde**: Producto en buen estado

### 🎯 **Experiencia de Usuario Mejorada**
- **Interfaz moderna**: Diseño limpio y elegante
- **Navegación intuitiva**: Flujo natural entre pantallas
- **Feedback visual**: Indicadores de estado y progreso
- **Validación inteligente**: Mensajes de error claros
- **Selector de fecha**: Date picker nativo de iOS
- **Campos optimizados**: Teclados específicos para cada tipo de dato

## 🛠 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  sqflite: ^2.4.2      # Base de datos SQLite
  path: ^1.9.1         # Utilidades de rutas
```

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada con CupertinoApp
├── product_model.dart        # Modelo de datos del producto
├── product_database.dart     # Manejo de base de datos SQLite
├── products_view.dart        # Vista principal con diseño Cupertino
└── product_details_view.dart # Vista de detalles con formularios Cupertino
```

## 🚀 Instalación y Ejecución

1. **Instalar dependencias:**
```bash
flutter pub get
```

2. **Ejecutar la aplicación:**
```bash
flutter run
```

3. **Compilar para producción:**
```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## 🎨 Pantallas y Componentes

### **Pantalla Principal (ProductsView)**
- `CupertinoPageScaffold` como contenedor principal
- `CupertinoNavigationBar` con botón de agregar
- `CupertinoSearchTextField` para búsqueda
- Cards personalizadas con bordes y colores de estado
- Lista scrolleable con pull-to-refresh

### **Pantalla de Detalles (ProductDetailsView)**
- Formulario con secciones organizadas
- `CupertinoTextField` con iconos y placeholders
- `CupertinoDatePicker` modal para fecha de vencimiento
- `CupertinoButton.filled` para acciones principales
- `CupertinoAlertDialog` para confirmaciones

### **Componentes Destacados**
- **Alertas**: `CupertinoAlertDialog` con acciones destructivas
- **Modales**: `showCupertinoModalPopup` para date picker
- **Indicadores**: `CupertinoActivityIndicator` para carga
- **Navegación**: `CupertinoPageRoute` para transiciones

## 🎯 Validaciones y Seguridad

- ✅ **Campos obligatorios**: Validación de todos los inputs
- ✅ **Formato de precio**: Solo números decimales positivos
- ✅ **Fechas futuras**: Selector limitado a fechas válidas
- ✅ **Contexto seguro**: Manejo correcto de BuildContext en async
- ✅ **Limpieza de recursos**: Dispose correcto de controladores

## 🌟 Características Avanzadas

### **Indicadores de Estado Visual**
```dart
// Códigos de color inteligentes basados en vencimiento
Color _getExpirationColor(DateTime expirationDate) {
  final difference = expirationDate.difference(DateTime.now()).inDays;
  if (difference < 0) return CupertinoColors.systemRed.withOpacity(0.1);
  if (difference <= 7) return CupertinoColors.systemOrange.withOpacity(0.1);
  return CupertinoColors.systemGreen.withOpacity(0.1);
}
```

### **Date Picker Personalizado**
- Modal nativo de iOS con header personalizado
- Limitación de fechas (solo futuras)
- Cancelación y confirmación integradas
- Actualización en tiempo real del formulario

### **Búsqueda Inteligente**
- Filtrado en tiempo real
- Búsqueda por nombre y descripción
- Mantenimiento del estado de búsqueda
- Limpieza automática de filtros

## 🔄 Flujo de Datos

1. **SQLite Database** → Modelo de datos tipado
2. **ProductDatabase** → Operaciones CRUD encapsuladas
3. **State Management** → setState para actualizaciones de UI
4. **Validación** → Feedback inmediato al usuario
5. **Navegación** → Transiciones suaves entre pantallas

## 💡 Mejoras Implementadas

### **Diseño Visual**
- Transición completa a componentes Cupertino
- Paleta de colores del sistema iOS
- Tipografía San Francisco
- Sombras y bordes sutiles
- Animaciones suaves

### **Experiencia de Usuario**
- Navegación natural con gestos iOS
- Feedback háptico en botones importantes
- Estados de carga elegantes
- Mensajes de error contextuales
- Confirmaciones no intrusivas

### **Rendimiento**
- Lazy loading en listas grandes
- Dispose correcto de recursos
- Optimización de rebuilds
- Gestión eficiente de memoria

La aplicación ahora ofrece una experiencia premium siguiendo las mejores prácticas de diseño de iOS, manteniendo toda la funcionalidad original pero con una interfaz mucho más elegante y profesional. 🎉
