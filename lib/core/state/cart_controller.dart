import 'package:flutter/foundation.dart';

import '../../features/catalog/domain/models/catalog_models.dart';

class CartController extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalQuantity => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0, (sum, i) => sum + i.totalPrice);

  double get estimatedTotal => subtotal;

  bool get isEmpty => _items.isEmpty;

  CartItem? itemForVariant(String variantId) {
    for (final item in _items) {
      if (item.variant.id == variantId) return item;
    }
    return null;
  }

  int quantityOf(String variantId) => itemForVariant(variantId)?.quantity ?? 0;

  void addVariant(ProductVariant variant, {int quantity = 1}) {
    if (quantity <= 0) return;
    final minQty = variant.minimumOrderQuantity;
    final addQty = quantity < minQty ? minQty : quantity;
    final index = _items.indexWhere((i) => i.variant.id == variant.id);
    if (index >= 0) {
      final current = _items[index];
      _items[index] = current.copyWith(quantity: current.quantity + addQty);
    } else {
      _items.add(CartItem(variant: variant, quantity: addQty));
    }
    notifyListeners();
  }

  void setQuantity(String variantId, int quantity) {
    final index = _items.indexWhere((i) => i.variant.id == variantId);
    if (index < 0) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void increase(String variantId) {
    setQuantity(variantId, quantityOf(variantId) + 1);
  }

  void decrease(String variantId) {
    setQuantity(variantId, quantityOf(variantId) - 1);
  }

  void remove(String variantId) {
    _items.removeWhere((i) => i.variant.id == variantId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
