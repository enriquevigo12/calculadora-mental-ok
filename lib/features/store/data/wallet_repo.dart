import 'package:calculadora_mental/features/store/domain/wallet.dart';
import 'package:calculadora_mental/services/storage_service.dart';
import 'package:calculadora_mental/services/iap_service.dart';
import 'package:calculadora_mental/services/analytics_service.dart';

class StoreRepository {
  final WalletRepository _walletRepo = WalletRepository();

  Wallet getWallet() {
    return _walletRepo.getWallet();
  }

  Future<bool> purchaseCoins(String productId) async {
    final products = IAPService.getProducts();
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw ArgumentError('Producto no encontrado: $productId'),
    );

    final success = await IAPService.purchaseProduct(product);
    
    if (success) {
      AnalyticsService.logIAPPurchase(productId, IAPService.getCoinAmount(productId));
    }
    
    return success;
  }

  Future<bool> watchRewardedAd() async {
    return await _walletRepo.watchRewardedAd();
  }

  Future<bool> claimDailyBonus() async {
    return await _walletRepo.claimDailyBonus();
  }

  bool canWatchAd() {
    return _walletRepo.canWatchAd();
  }

  bool canClaimDailyBonus() {
    return _walletRepo.canClaimDailyBonus();
  }

  int getDailyBonusAmount() {
    return _walletRepo.getDailyBonusAmount();
  }

  int getDailyBonusStreak() {
    return _walletRepo.getDailyBonusStreak();
  }

  Duration? getAdCooldownRemaining() {
    return _walletRepo.getAdCooldownRemaining();
  }

  List<Map<String, dynamic>> getAvailableProducts() {
    final products = IAPService.getProducts();
    return products.map((product) => {
      'id': product.id,
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'coins': IAPService.getCoinAmount(product.id),
    }).toList();
  }

  bool get isIAPAvailable => IAPService.isAvailable;

  Future<void> restorePurchases() async {
    await IAPService.restorePurchases();
  }
}
