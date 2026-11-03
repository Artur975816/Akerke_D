import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// One product in the catalog
class Product {
  final int id;
  final String title;
  final String category;
  final double price;

  const Product({
    required this.id,
    required this.title,
    required this.category,
    required this.price,
  });
}

// 6 products for the catalog screen
const List<Product> products = [
  Product(id: 1, title: 'Air Runner Pro', category: 'Running', price: 129.99),
  Product(id: 2, title: 'Street Classic', category: 'Casual', price: 89.50),
  Product(id: 3, title: 'Court Master', category: 'Basketball', price: 149.00),
  Product(id: 4, title: 'Urban Flex', category: 'Lifestyle', price: 99.90),
  Product(id: 5, title: 'Trail Blazer', category: 'Hiking', price: 139.00),
  Product(id: 6, title: 'Cloud Walker', category: 'Casual', price: 74.99),
];

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

// One product card with the "Add to Cart" toggle button
class ProductTile extends StatelessWidget {
  final Product product;

  const ProductTile({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // watch: rebuild this tile whenever the cart changes
    final cart = context.watch<CartProvider>();
    final inCart = cart.contains(product);
    final colors = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.shopping_bag,
                      color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: inCart
                  ? OutlinedButton.icon(
                      // read: only call a method, no rebuild needed here
                      onPressed: () =>
                          context.read<CartProvider>().toggle(product),
                      icon: const Icon(Icons.remove_shopping_cart),
                      label: const Text('Remove from Cart'),
                    )
                  : FilledButton.icon(
                      onPressed: () =>
                          context.read<CartProvider>().toggle(product),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen 2: items in the cart, remove buttons, total and "Clear All"
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('My Cart (${cart.itemCount})')),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined,
                        size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'Your cart is empty',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to Catalog'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colors.primaryContainer,
                      child: Icon(Icons.shopping_bag,
                          color: colors.onPrimaryContainer),
                    ),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        '${item.category}  \$${item.price.toStringAsFixed(2)}'),
                    trailing: IconButton(
                      tooltip: 'Remove',
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => context.read<CartProvider>().remove(item),
                    ),
                  ),
                );
              },
            ),
      // Bottom bar with total price and Clear All, only when cart is not empty
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Total',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(
                          '\$${cart.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.read<CartProvider>().clear(),
                            icon: const Icon(Icons.delete_sweep),
                            label: const Text('Clear All'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Screen 1: catalog with a live badge on the cart icon
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sneaker Catalog'),
        actions: [
          IconButton(
            tooltip: 'Open cart',
            icon: Badge(
              // Badge is hidden when the cart is empty
              isLabelVisible: cart.itemCount > 0,
              label: Text('${cart.itemCount}'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return ProductTile(product: products[index]);
        },
      ),
    );
  }
}

void main() {
  runApp(
    // Provider is above MaterialApp, so every screen can reach the cart
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const ShopApp(),
    ),
  );
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Global Cart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const CatalogScreen(),
    );
  }
}
