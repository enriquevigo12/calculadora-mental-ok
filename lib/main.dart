import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reto_matematico/app_router.dart';
import 'package:reto_matematico/theme/app_theme.dart';
import 'package:reto_matematico/theme/theme_provider.dart';
import 'package:reto_matematico/services/storage_service.dart';
import 'package:reto_matematico/services/consent_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Hive
  await Hive.initFlutter();
  await StorageService.initialize();
  
  // Inicializar Mobile Ads
  await MobileAds.instance.initialize();
  
  // Configurar orientación
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configurar barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(const ProviderScope(child: CalculadoraMentalApp()));
}

class CalculadoraMentalApp extends ConsumerWidget {
  const CalculadoraMentalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    
    return MaterialApp.router(
      title: 'Calculadora Mental',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: AppTheme.darkTheme, // Solo tema oscuro
      themeMode: ThemeMode.dark, // Forzar modo oscuro
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      locale: const Locale('es', 'ES'),
    );
  }
}
