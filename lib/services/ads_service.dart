import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:calculadora_mental/services/consent_service.dart';
import 'package:calculadora_mental/services/storage_service.dart';
import 'package:calculadora_mental/services/analytics_service.dart';
import 'package:calculadora_mental/services/gdpr_service.dart';

class AdsService {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;
  
  // IDs de producción - Reemplazar con tus IDs reales de AdMob
  // Para obtener estos IDs: https://admob.google.com/
  static const String _androidRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917'; // TODO: Reemplazar con ID real
  static const String _iosRewardedAdUnitId = 'ca-app-pub-8350683051968543/4534328065';
  
  // Banner Ads IDs
  static const String _androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // TODO: Reemplazar con ID real
  static const String _iosBannerAdUnitId = 'ca-app-pub-8350683051968543/2099736415'; // Banner ID real

  static String get _rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidRewardedAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosRewardedAdUnitId;
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  static String get _bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidBannerAdUnitId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _iosBannerAdUnitId;
    }
    throw UnsupportedError('Plataforma no soportada');
  }

  static Future<void> initialize() async {
    // Inicializar GDPR primero
    await GDPRService.initialize();
    
    // Solo inicializar anuncios si hay consentimiento
    if (GDPRService.hasConsent()) {
      await MobileAds.instance.initialize();
      await _loadRewardedAd();
      debugPrint('Anuncios inicializados con consentimiento');
    } else {
      debugPrint('Anuncios no inicializados - sin consentimiento');
    }
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
          
          // Agregar 1 moneda directamente
          _addCoinsFromAd();
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

  static Future<void> _addCoinsFromAd() async {
    try {
      final wallet = StorageService.getWallet();
      wallet.addCoins(1); // +1 moneda por anuncio
      await StorageService.saveWallet(wallet);
      
      // Analytics
      AnalyticsService.logAdReward(1);
      
      debugPrint('Monedas agregadas por anuncio recompensado: +1');
    } catch (e) {
      debugPrint('Error al agregar monedas por anuncio: $e');
    }
  }

  static bool isRewardedAdReady() {
    return _rewardedAd != null;
  }

  static Future<void> dispose() async {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  // Banner Ad methods
  static BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }
}
