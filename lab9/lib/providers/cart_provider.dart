import 'package:flutter/foundation.dart';
import '../models/product.dart';

// Global cart state. Every screen that listens to it rebuilds on notifyListeners().
class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  // Read only view, screens cannot change the list directly
  List<Product> get items => List.unmodifiable(_items);

  int get itemCount => _items.length;

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.price);

  bool contains(Product product) => _items.any((p) => p.id == product.id);

  void add(Product product) {
    if (contains(product)) return;
    _items.add(product);
    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere((p) => p.id == product.id);
    notifyListeners();
  }

  // Used by the "Add to Cart" toggle button
  void toggle(Product product) {
    if (contains(product)) {
      remove(product);
    } else {
      add(product);
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
