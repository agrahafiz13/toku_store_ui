import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), elevation: 0),

      body: Column(
        children: [
          // 🔍 SEARCH BAR
          _buildSearchBar(),

          // 📦 CONTENT (SWITCH STATE)
          Expanded(
            child: switch (product.status) {
              // 🔄 LOADING
              ProductStatus.loading || ProductStatus.initial => const Center(
                child: CircularProgressIndicator(),
              ),

              // ❌ ERROR
              ProductStatus.error => _buildError(product),

              // ✅ LOADED
              ProductStatus.loaded => _buildProductGrid(product),
            },
          ),
        ],
      ),
    );
  }

  // ================= UI COMPONENT =================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildError(ProductProvider product) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 12),

          Text(product.error ?? 'Terjadi kesalahan'),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () => product.fetchProducts(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(ProductProvider product) {
    final filtered = _filteredProducts(product.products);

    return RefreshIndicator(
      onRefresh: () => product.fetchProducts(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemBuilder: (_, i) => ProductCard(product: filtered[i]),
      ),
    );
  }

  List _filteredProducts(List products) {
    final query = _searchCtrl.text.toLowerCase();

    return products.where((p) {
      final matchSearch =
          query.isEmpty || p.title.toLowerCase().contains(query);

      return matchSearch;
    }).toList();
  }
}
