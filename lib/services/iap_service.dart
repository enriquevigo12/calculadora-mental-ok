import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:calculadora_mental/services/storage_service.dart';

class IAPService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  
  // TODO: Reemplazar con SKUs reales de App Store/Google Play
  static const Set<String> _productIds = {
    'coins_100',
    'coins_300', 
    'coins_700',
  };

  static const Map<String, int> _coinAmounts = {
    'coins_100': 100,
    'coins_300': 300,
    'coins_700': 700,
  };

  static bool _isAvailable = false;
  static List<ProductDetails> _products = [];

  static Future<void> initialize() async {
    _isAvailable = await _inAppPurchase.isAvailable();
    
    if (_isAvailable) {
      await _loadProducts();
    }
  }

  static Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Productos no encontrados: ${response.notFoundIDs}');
      }
      
      if (response.error != null) {
        debugPrint('Error al cargar productos: ${response.error}');
        return;
      }
      
      _products = response.productDetails;
      debugPrint('Productos cargados: ${_products.length}');
    } catch (e) {
      debugPrint('Excepción al cargar productos: $e');
    }
  }

  static List<ProductDetails> getProducts() {
    return _products;
  }

  static bool get isAvailable => _isAvailable;

  static Future<bool> purchaseProduct(ProductDetails product) async {
    if (!_isAvailable) {
      debugPrint('Compras in-app no disponibles');
      return false;
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      bool success = false;
      
      if (product.id.startsWith('coins_')) {
        success = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        success = await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
      
      if (success) {
        debugPrint('Compra iniciada para: ${product.id}');
      } else {
        debugPrint('Error al iniciar compra para: ${product.id}');
      }
      
      return success;
    } catch (e) {
      debugPrint('Excepción al comprar producto: $e');
      return false;
    }
  }

  static Future<void> handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        debugPrint('Compra pendiente: ${purchaseDetails.productID}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
        await _handleSuccessfulPurchase(purchaseDetails);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        debugPrint('Error en compra: ${purchaseDetails.error}');
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        debugPrint('Compra cancelada: ${purchaseDetails.productID}');
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  static Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    final productId = purchaseDetails.productID;
    final coinAmount = _coinAmounts[productId];
    
    if (coinAmount != null) {
      await StorageService.addCoins(coinAmount);
      
      final purchases = StorageService.getPurchases();
      purchases.addPurchase(productId, coinAmount);
      await StorageService.savePurchases(purchases);
      
      debugPrint('Monedas añadidas: $coinAmount por compra de $productId');
    }
  }

  static Future<void> restorePurchases() async {
    if (!_isAvailable) {
      debugPrint('Compras in-app no disponibles');
      return;
    }

    try {
      await _inAppPurchase.restorePurchases();
      debugPrint('Restauración de compras iniciada');
    } catch (e) {
      debugPrint('Error al restaurar compras: $e');
    }
  }

  static String getProductPrice(String productId) {
    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw ArgumentError('Producto no encontrado: $productId'),
    );
    return product.price;
  }

  static int getCoinAmount(String productId) {
    return _coinAmounts[productId] ?? 0;
  }

  static void dispose() {
    // No hay recursos específicos que liberar
  }
}
