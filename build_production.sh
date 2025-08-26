#!/bin/bash

# 🚀 Script de Build para Producción - Calculadora Mental

echo "🚀 Iniciando build de producción..."

# Verificar que Flutter esté instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter no está instalado. Por favor instala Flutter primero."
    exit 1
fi

# Limpiar builds anteriores
echo "🧹 Limpiando builds anteriores..."
flutter clean

# Obtener dependencias
echo "📦 Obteniendo dependencias..."
flutter pub get

# Generar iconos de la app
echo "🎨 Generando iconos de la app..."
flutter pub run flutter_launcher_icons:main

# Build para Android
echo "🤖 Construyendo para Android..."
flutter build appbundle --release

if [ $? -eq 0 ]; then
    echo "✅ Build de Android completado exitosamente"
    echo "📱 Archivo generado: build/app/outputs/bundle/release/app-release.aab"
else
    echo "❌ Error en build de Android"
    exit 1
fi

# Build para iOS
echo "🍎 Construyendo para iOS..."
flutter build ios --release

if [ $? -eq 0 ]; then
    echo "✅ Build de iOS completado exitosamente"
    echo "📱 Archivo generado: build/ios/archive/Runner.xcarchive"
else
    echo "❌ Error en build de iOS"
    exit 1
fi

echo ""
echo "🎉 ¡Build de producción completado!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Subir .aab a Google Play Console"
echo "2. Subir .xcarchive a App Store Connect"
echo "3. Configurar IDs de AdMob reales"
echo "4. Configurar In-App Purchases"
echo ""
echo "📁 Archivos generados:"
echo "- Android: build/app/outputs/bundle/release/app-release.aab"
echo "- iOS: build/ios/archive/Runner.xcarchive"
