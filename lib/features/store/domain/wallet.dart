import 'package:reto_matematico/services/storage_service.dart';
import 'package:reto_matematico/services/ads_service.dart';
import 'package:reto_matematico/services/analytics_service.dart';

class WalletRepository {
  Wallet getWallet() {
    return StorageService.getWallet();
  }

  Future<void> saveWallet(Wallet wallet) async {
    await StorageService.saveWallet(wallet);
  }

  Future<void> addCoins(int amount) async {
    await StorageService.addCoins(amount);
  }

  Future<void> spendCoins(int amount) async {
    await StorageService.spendCoins(amount);
  }

  Future<bool> claimDailyBonus() async {
    final wallet = getWallet();
    
    if (!wallet.canClaimDailyBonus()) {
      return false;
    }
    
    final bonusAmount = wallet.getDailyBonusAmount();
    wallet.coins += bonusAmount;
    wallet.lastDailyBonusAt = DateTime.now();
    wallet.dailyBonusStreak++;
    
    await saveWallet(wallet);
    
    // Analytics
    AnalyticsService.logDailyBonusClaimed(bonusAmount, wallet.dailyBonusStreak);
    
    return true;
  }

  Future<void> setAdCooldown() async {
    final wallet = getWallet();
    wallet.adCooldownUntil = DateTime.now().add(const Duration(minutes: 10));
    await saveWallet(wallet);
  }

  Future<bool> watchRewardedAd() async {
    final wallet = getWallet();
    
    if (!wallet.canWatchAd()) {
      return false;
    }
    
    final success = await AdsService.showRewardedAd();
    
    if (success) {
      await addCoins(1); // +1 moneda por anuncio
      await setAdCooldown();
      
      // Analytics
      AnalyticsService.logAdReward(1);
      
      return true;
    }
    
    return false;
  }

  bool canWatchAd() {
    final wallet = getWallet();
    return wallet.canWatchAd();
  }

  bool canClaimDailyBonus() {
    final wallet = getWallet();
    return wallet.canClaimDailyBonus();
  }

  int getDailyBonusAmount() {
    final wallet = getWallet();
    return wallet.getDailyBonusAmount();
  }

  int getDailyBonusStreak() {
    final wallet = getWallet();
    return wallet.dailyBonusStreak;
  }

  Duration? getAdCooldownRemaining() {
    final wallet = getWallet();
    if (wallet.adCooldownUntil == null) return null;
    
    final remaining = wallet.adCooldownUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}
