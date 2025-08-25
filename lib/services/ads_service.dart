import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:calculadora_mental/services/consent_service.dart';

class AdsService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  
  // TODO: Reemplazar con IDs reales de AdMob
  static const String _androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // Test ID
  static const String _iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313'; // Test ID

  static String get _rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidRewardedAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosRewardedAdUnitId;
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadRewardedAd();
  }

  static Future<void> _loadRewardedAd() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
            debugPrint('Anuncio recompensado cargado');
          },
          onAdFailedToLoad: (error) {
            _rewardedAd = null;
            _isLoading = false;
            debugPrint('Error al cargar anuncio recompensado: $error');
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      debugPrint('Excepción al cargar anuncio: $e');
    }
  }

  static Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      await _loadRewardedAd();
      if (_rewardedAd == null) {
        return false;
      }
    }

    bool rewardEarned = false;

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          rewardEarned = true;
          debugPrint('Usuario ganó recompensa: ${reward.amount} ${reward.type}');
        },
      );
    } catch (e) {
      debugPrint('Error al mostrar anuncio: $e');
      return false;
    } finally {
      _rewardedAd = null;
      // Precargar el siguiente anuncio
      _loadRewardedAd();
    }

    return rewardEarned;
  }

  static bool isRewardedAdReady() {
    return _rewardedAd != null;
  }

  static Future<void> dispose() async {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
