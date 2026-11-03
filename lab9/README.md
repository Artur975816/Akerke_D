# Global Cart (Flutter + Provider)

Multi-screen app with a global cart and a live badge.

## Features

- CartProvider (ChangeNotifier) holds the cart: add, remove, toggle, clear, total price
- ChangeNotifierProvider wraps MaterialApp in main.dart
- Screen 1 (Catalog): 6 products, "Add to Cart" toggle buttons, live badge on the AppBar cart icon
- Screen 2 (Cart): selected items, remove button for each item, total price, "Clear All"
- Both screens listen to the same provider, so changes sync instantly

## Folder structure

```
lib/
  main.dart
  models/product.dart
  data/products.dart
  providers/cart_provider.dart
  screens/
    catalog_screen.dart
    cart_screen.dart
  widgets/product_tile.dart
```

## How to run

```
flutter pub add provider
flutter run
```
