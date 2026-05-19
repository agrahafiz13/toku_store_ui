import 'package:flutter/material.dart';
import 'package:toku_store/features/cart/data/models/cart_model.dart';
import 'package:toku_store/features/cart/data/repositories/cart_repository_impl.dart';

enum CartStatus { initial, loading, loaded, error }

class CartProvider extends ChangeNotifier {
  final CartRepositoryImpl _repository = CartRepositoryImpl();

  CartStatus _status = CartStatus.initial;
  CartModel? _cart;
  String? _error;
  bool _isAdding = false;

  // ================= GETTERS =================

  CartStatus get status => _status;
  CartModel? get cart => _cart;
  String? get error => _error;
  bool get isAdding => _isAdding;

  int get itemCount => _cart?.itemCount ?? 0;

  // ================= CEK PRODUCT ADA DI CART =================

  CartItemModel? getItemByProductId(int productId) {
    if (_cart == null) return null;

    try {
      return _cart!.items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // ================= FETCH CART =================

  Future<void> fetchCart() async {
    _status = CartStatus.loading;
    notifyListeners();

    try {
      _cart = await _repository.getCart();

      _status = CartStatus.loaded;
      _error = null;
    } catch (e) {
      _status = CartStatus.error;
      _error = e.toString();
    }

    notifyListeners();
  }

  // ================= ADD =================

  Future<bool> addToCart(int productId, int quantity) async {
    _isAdding = true;
    notifyListeners();

    try {
      await _repository.addToCart(productId, quantity);

      await fetchCart();

      _isAdding = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isAdding = false;
      notifyListeners();

      return false;
    }
  }

  // ================= UPDATE =================

  Future<void> updateItem(int cartItemId, int quantity) async {
    try {
      await _repository.updateCartItem(cartItemId, quantity);

      await fetchCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ================= REMOVE =================

  Future<void> removeItem(int cartItemId) async {
    try {
      await _repository.removeCartItem(cartItemId);

      await fetchCart();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // ================= CLEAR =================

  Future<void> clearCart() async {
    try {
      await _repository.clearCart();

      _cart = const CartModel(items: [], total: 0, itemCount: 0);

      _status = CartStatus.loaded;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
