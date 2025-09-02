# 🚀 Configuración para Producción - Reto Matemático

## 📱 **Configuración de AdMob**

### **1. Crear cuenta en AdMob**
1. Ve a [https://admob.google.com/](https://admob.google.com/)
2. Crea una cuenta nueva
3. Crea una nueva app: "Reto Matemático"

### **2. Obtener App IDs**
Después de crear la app, obtendrás:
- **Android App ID**: `ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy`
- **iOS App ID**: `ca-app-pub-xxxxxxxxxxxxxxxx~zzzzzzzzzz`

### **3. Crear Ad Units**
Crea los siguientes Ad Units:

#### **Banner Ads:**
- **Android Banner**: `ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa`
- **iOS Banner**: `ca-app-pub-xxxxxxxxxxxxxxxx/bbbbbbbbbb`

#### **Rewarded Ads:**
- **Android Rewarded**: `ca-app-pub-xxxxxxxxxxxxxxxx/cccccccccc`
- **iOS Rewarded**: `ca-app-pub-xxxxxxxxxxxxxxxx/dddddddddd`

### **4. Reemplazar IDs en el código**

#### **En `lib/services/ads_service.dart`:**
```dart
// Reemplazar estos IDs con los tuyos
static const String _androidRewardedAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/cccccccccc';
static const String _iosRewardedAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/dddddddddd';
static const String _androidBannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/aaaaaaaaaa';
static const String _iosBannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/bbbbbbbbbb';
```

#### **En `android/app/src/main/AndroidManifest.xml`:**
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy"/>
```

#### **En `ios/Runner/Info.plist`:**
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-xxxxxxxxxxxxxxxx~zzzzzzzzzz</string>
```

## 🏪 **Configuración de App Store Connect (iOS)**

### **1. Crear app en App Store Connect**
1. Ve a [https://appstoreconnect.apple.com/](https://appstoreconnect.apple.com/)
2. Crea una nueva app
3. Bundle ID: `com.tudominio.retoMatematico`

### **2. Configurar In-App Purchases**
Crea los siguientes productos:
- **Monedas Pequeñas**: 50 monedas - $0.99
- **Monedas Medianas**: 150 monedas - $2.99
- **Monedas Grandes**: 500 monedas - $6.99

### **3. Configurar App Store Review**
- **Categoría**: Games > Puzzle
- **Edad**: 4+
- **Contenido**: Sin contenido inapropiado

## 📱 **Configuración de Google Play Console (Android)**

### **1. Crear app en Google Play Console**
1. Ve a [https://play.google.com/console/](https://play.google.com/console/)
2. Crea una nueva app
3. Package name: `com.tudominio.retoMatematico`

### **2. Configurar In-App Products**
Crea los mismos productos que en iOS:
- **Monedas Pequeñas**: 50 monedas - $0.99
- **Monedas Medianas**: 150 monedas - $2.99
- **Monedas Grandes**: 500 monedas - $6.99

### **3. Configurar Store Listing**
- **Categoría**: Games > Puzzle
- **Clasificación de contenido**: 3+
- **Etiquetas**: Matemáticas, Educación, Puzzle

## 🔧 **Configuración de Build**

### **1. Versión de la app**
En `pubspec.yaml`:
```yaml
version: 1.1.0+2
```

### **2. Icono de la app**
Asegúrate de tener el icono en `assets/icon/app_icon.png` (1024x1024px)

### **3. Build para producción**

#### **Android:**
```bash
flutter build appbundle --release
```

#### **iOS:**
```bash
flutter build ios --release
```

## 📋 **Checklist de Producción**

### **✅ Antes de publicar:**

- [ ] IDs de AdMob configurados
- [ ] In-App Purchases configurados
- [ ] Icono de la app listo
- [ ] Política de privacidad creada
- [ ] Términos de servicio creados
- [ ] App probada en modo release
- [ ] Anuncios funcionando correctamente
- [ ] Compras funcionando correctamente

### **✅ Configuración legal:**

- [ ] Política de privacidad en la app
- [ ] Términos de servicio en la app
- [ ] Consentimiento GDPR implementado
- [ ] Información sobre anuncios

## 🎯 **Monetización Esperada**

### **Anuncios:**
- **Banners**: $0.50 - $2.00 por 1000 impresiones
- **Rewarded**: $2.00 - $8.00 por 1000 vistas completas

### **In-App Purchases:**
- **Conversión esperada**: 2-5% de usuarios
- **ARPU esperado**: $0.50 - $2.00 por usuario

## 📞 **Soporte**

Para problemas técnicos:
- **AdMob**: [https://support.google.com/admob/](https://support.google.com/admob/)
- **App Store**: [https://developer.apple.com/support/](https://developer.apple.com/support/)
- **Google Play**: [https://support.google.com/googleplay/](https://support.google.com/googleplay/)
