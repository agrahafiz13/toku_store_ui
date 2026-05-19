import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toku_store/core/providers/theme_provider.dart';
import 'package:toku_store/core/routes/app_router.dart';
import 'package:toku_store/features/auth/presentation/providers/auth_provider.dart';

import 'package:toku_store/features/cart/presentation/pages/cart_page.dart';
import 'package:toku_store/features/cart/presentation/providers/cart_provider.dart';

import '../providers/product_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _searchQuery = '';

  String _selectedCategory = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Kamen Rider',
    'Ultraman',
    'Super Sentai',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();

      context.read<CartProvider>().fetchCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = theme.colorScheme;

    final themeProvider = context.watch<ThemeProvider>();

    final isDark = themeProvider.isDark;

    final auth = context.watch<AuthProvider>();

    final product = context.watch<ProductProvider>();

    final cart = context.watch<CartProvider>();

    final filteredProducts = product.products.where((p) {
      final matchSearch = p.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      final matchCategory =
          _selectedCategory == 'Semua' || p.category == _selectedCategory;

      return matchSearch && matchCategory;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        child: switch (product.status) {
          ProductStatus.loading || ProductStatus.initial => const Center(
            child: CircularProgressIndicator(),
          ),

          ProductStatus.error => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Icon(Icons.error_outline, size: 48, color: color.error),

                const SizedBox(height: 16),

                Text(product.error ?? 'Terjadi Kesalahan'),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () => product.fetchProducts(),

                  icon: const Icon(Icons.refresh),

                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),

          ProductStatus.loaded => Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // ================= HEADER =================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    // ================= USER INFO =================
                    Expanded(
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,

                            backgroundColor: color.primary.withOpacity(0.2),

                            child: Text(
                              (auth.firebaseUser?.displayName ?? 'U')[0]
                                  .toUpperCase(),

                              style: TextStyle(
                                color: color.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  'Selamat datang,',

                                  style: TextStyle(
                                    fontSize: 12,

                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),

                                Text(
                                  '${auth.firebaseUser?.displayName ?? 'User'} 👋',

                                  overflow: TextOverflow.ellipsis,

                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ================= ACTION BUTTONS =================
                    Row(
                      children: [
                        // ================= CART =================
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart_outlined),

                              onPressed: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (_) => const CartPage(),
                                  ),
                                );
                              },
                            ),

                            if (cart.itemCount > 0)
                              Positioned(
                                right: 4,
                                top: 4,

                                child: Container(
                                  padding: const EdgeInsets.all(4),

                                  decoration: const BoxDecoration(
                                    color: Colors.red,

                                    shape: BoxShape.circle,
                                  ),

                                  child: Text(
                                    '${cart.itemCount}',

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 10,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),

                        // ================= DARK MODE =================
                        Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,

                          size: 20,

                          color: isDark ? Colors.amber : theme.iconTheme.color,
                        ),

                        Switch(
                          value: isDark,

                          onChanged: (_) {
                            context.read<ThemeProvider>().toggle();
                          },
                        ),

                        const SizedBox(width: 6),

                        // ================= LOGOUT =================
                        IconButton(
                          icon: const Icon(Icons.logout_rounded),

                          color: Colors.redAccent,

                          onPressed: () async {
                            await auth.logout();

                            if (!mounted) return;

                            Navigator.pushReplacementNamed(
                              context,
                              AppRouter.login,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ================= SEARCH =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Container(
                  decoration: BoxDecoration(
                    color: color.surface,

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },

                    decoration: const InputDecoration(
                      hintText: 'Cari mainan atau produk...',

                      prefixIcon: Icon(Icons.search),

                      border: InputBorder.none,

                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // ================= CATEGORY =================
              SizedBox(
                height: 40,

                child: ListView.builder(
                  scrollDirection: Axis.horizontal,

                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  itemCount: _categories.length,

                  itemBuilder: (context, index) {
                    final category = _categories[index];

                    final isSelected = _selectedCategory == category;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10),

                      child: ChoiceChip(
                        label: Text(category),

                        selected: isSelected,

                        onSelected: (_) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },

                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyMedium?.color,
                        ),

                        backgroundColor: color.surface,

                        selectedColor: color.primary,

                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // ================= TITLE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Text('Produk Tersedia', style: theme.textTheme.titleMedium),

                    Text(
                      '${filteredProducts.length} Item',

                      style: TextStyle(color: color.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ================= GRID =================
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => product.fetchProducts(),

                  child: GridView.builder(
                    padding: const EdgeInsets.all(20),

                    itemCount: filteredProducts.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,

                          childAspectRatio: 0.65,

                          crossAxisSpacing: 16,

                          mainAxisSpacing: 16,
                        ),

                    itemBuilder: (context, i) {
                      final p = filteredProducts[i];

                      return Container(
                        decoration: BoxDecoration(
                          color: color.surface,

                          borderRadius: BorderRadius.circular(16),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),

                                child: Image.network(
                                  p.imageUrl,

                                  width: double.infinity,

                                  fit: BoxFit.cover,

                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.image),
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(12),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),

                                    decoration: BoxDecoration(
                                      color: color.primary.withOpacity(0.1),

                                      borderRadius: BorderRadius.circular(8),
                                    ),

                                    child: Text(
                                      p.category,

                                      style: TextStyle(
                                        fontSize: 10,
                                        color: color.primary,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    p.name,

                                    maxLines: 2,

                                    overflow: TextOverflow.ellipsis,

                                    style: theme.textTheme.bodyMedium,
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    'Rp ${p.price.toStringAsFixed(0)}',

                                    style: const TextStyle(
                                      color: Colors.orange,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Builder(
                                    builder: (_) {
                                      final cartItem = cart.getItemByProductId(
                                        p.id,
                                      );

                                      // ================= BELUM ADA DI CART =================
                                      if (cartItem == null) {
                                        return SizedBox(
                                          width: double.infinity,

                                          child: ElevatedButton.icon(
                                            onPressed: cart.isAdding
                                                ? null
                                                : () async {
                                                    final success = await cart
                                                        .addToCart(p.id, 1);

                                                    if (!mounted) return;

                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          success
                                                              ? 'Berhasil ditambahkan ke keranjang'
                                                              : 'Gagal menambahkan ke keranjang',
                                                        ),
                                                      ),
                                                    );
                                                  },

                                            icon: cart.isAdding
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.add_shopping_cart,
                                                  ),

                                            label: Text(
                                              cart.isAdding
                                                  ? 'Loading...'
                                                  : 'Keranjang',
                                            ),
                                          ),
                                        );
                                      }

                                      // ================= SUDAH ADA DI CART =================
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 2,
                                        ),

                                        decoration: BoxDecoration(
                                          color: color.primary.withOpacity(0.1),

                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),

                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,

                                          children: [
                                            // MINUS
                                            IconButton(
                                              icon: const Icon(Icons.remove),

                                              onPressed: () async {
                                                if (cartItem.quantity > 1) {
                                                  await cart.updateItem(
                                                    cartItem.id,
                                                    cartItem.quantity - 1,
                                                  );
                                                } else {
                                                  await cart.removeItem(
                                                    cartItem.id,
                                                  );
                                                }
                                              },
                                            ),

                                            // QTY
                                            Text(
                                              '${cartItem.quantity}',

                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),

                                            // PLUS
                                            IconButton(
                                              icon: const Icon(Icons.add),

                                              onPressed: () async {
                                                await cart.updateItem(
                                                  cartItem.id,
                                                  cartItem.quantity + 1,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        },
      ),
    );
  }
}
