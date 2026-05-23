import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:toku_store/features/cart/presentation/providers/cart_provider.dart';
import 'package:toku_store/features/order/presentation/providers/order_provider.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _addressController = TextEditingController();

  final _notesController = TextEditingController();

  String _paymentMethod = 'cash';

  final List<String> _paymentMethods = ['cash', 'gopay', 'bank_transfer'];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    final orderProvider = context.read<OrderProvider>();

    final cartProvider = context.read<CartProvider>();

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman wajib diisi')),
      );
      return;
    }

    final success = await orderProvider.checkout(
      shippingAddress: _addressController.text,

      notes: _notesController.text,

      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;

    if (success) {
      // refresh cart biar badge kosong
      await cartProvider.fetchCart();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderSuccessPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orderProvider.error ?? 'Checkout gagal')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = theme.colorScheme;

    final cart = context.watch<CartProvider>();

    final order = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ================= TOTAL =================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text('Total Belanja'),

                    Text(
                      'Rp ${cart.cart?.total.toStringAsFixed(0) ?? '0'}',
                      style: TextStyle(
                        color: color.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= ADDRESS =================
            TextField(
              controller: _addressController,

              maxLines: 3,

              decoration: const InputDecoration(
                labelText: 'Alamat Pengiriman',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= NOTES =================
            TextField(
              controller: _notesController,

              maxLines: 2,

              decoration: const InputDecoration(
                labelText: 'Catatan (opsional)',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // ================= PAYMENT =================
            DropdownButtonFormField<String>(
              value: _paymentMethod,

              items: _paymentMethods
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),

              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },

              decoration: const InputDecoration(
                labelText: 'Metode Pembayaran',
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // ================= CHECKOUT BUTTON =================
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: order.checkoutStatus == OrderStatus.loading
                    ? null
                    : _handleCheckout,

                child: order.checkoutStatus == OrderStatus.loading
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(),
                      )
                    : const Text('Checkout Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
