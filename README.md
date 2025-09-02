# 🧮 Reto Matemático

Un juego de retos matemáticos moderno y elegante desarrollado en Flutter con Material 3, diseñado para entrenar tu mente con operaciones matemáticas rápidas.

## ✨ Características

### 🎮 **Modos de Juego**
- **Modo Fácil**: Suma y resta sobre un valor acumulado
- **Modo Difícil**: Todas las operaciones (suma, resta, multiplicación, división)
- **Reto del Día**: 3 fases de dificultad creciente con recompensas especiales

### 🏆 **Sistema de Rachas**
- Seguimiento de rachas por modo
- Récords personales
- Sistema de continuaciones con coste Fibonacci
- **Racha del Reto del Día**: Seguimiento de días consecutivos

### 💰 **Economía de Monedas**
- **Recompensas por juego**: +1 moneda cada 10 aciertos
- **Anuncios recompensados**: +1 moneda por anuncio (cooldown 10 min)
- **Bono diario**: +1 moneda al día
- **Continuar racha**: Coste progresivo (1, 2, 3, 5, 8, 13 monedas)
- **Reto del Día**: +5 monedas al completar las 3 fases

### 🎨 **Diseño Moderno**
- **Material 3**: Diseño moderno con GoogleFonts Nunito
- **Modo Oscuro**: Tema oscuro elegante y consistente
- **Animaciones**: Transiciones suaves y efectos visuales
- **Glassmorphism**: Efectos de cristal en tarjetas y elementos UI
- **UI Responsive**: Adaptada a todos los tamaños de pantalla

### 📊 **Estadísticas Detalladas**
- Mejor racha por modo
- Distribución por operación
- Tiempo promedio de respuesta
- Porcentaje de acierto
- **Estadísticas del Reto del Día**: Racha actual, mejor racha, total completados

### ⚙️ **Configuración Personalizable**
- Rango de resultados configurable
- Opción para números negativos y decimales
- Dificultad dinámica automática
- Configuración de accesibilidad

## 🚀 Tecnologías

- **Flutter**: Framework principal
- **Dart**: Lenguaje de programación
- **Riverpod**: Gestión de estado
- **go_router**: Navegación declarativa
- **Hive**: Base de datos local NoSQL
- **SharedPreferences**: Persistencia para estadísticas del reto diario
- **Google Mobile Ads**: Anuncios recompensados
- **In-App Purchase**: Compras dentro de la app

## 📱 Plataformas

- ✅ **iOS**: iPhone y iPad
- ✅ **Android**: Teléfonos y tablets

## 🛠️ Instalación

### Prerrequisitos
- Flutter SDK (versión estable)
- Dart SDK
- Android Studio / Xcode
- Dispositivo físico o emulador

### Pasos de Instalación

1. **Clonar el repositorio**
```bash
git clone https://github.com/tu-usuario/reto-matematico.git
cd reto-matematico
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Generar código Hive**
```bash
flutter packages pub run build_runner build
```

4. **Ejecutar la aplicación**
```bash
flutter run
```

## 🎯 Funcionalidades Principales

### Sistema de Juego
- **Valor inicial**: 5-20 (aleatorio)
- **Operaciones**: Generadas dinámicamente según el modo
- **Validación**: Resultados dentro del rango configurado
- **Dificultad**: Ajuste automático basado en rendimiento

### Reto del Día
- **3 fases**: Dificultad creciente con ecuaciones únicas
- **Pistas comprables**: 5 monedas por pista
- **Reintentos**: 5 monedas por reintento de fase
- **Recompensas**: +1 racha y +5 monedas al completar
- **Reset diario**: Nuevo reto cada día

### Gestión de Datos
- **Almacenamiento local**: Hive para estadísticas y configuración
- **Almacenamiento seguro**: UUID del dispositivo
- **Persistencia**: Datos mantenidos entre sesiones
- **Estadísticas del reto**: SharedPreferences para datos del reto diario

### Monetización
- **Anuncios recompensados**: Google Mobile Ads
- **Compras in-app**: Packs de monedas
- **Economía balanceada**: Sistema de recompensas equilibrado

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── app_router.dart          # Configuración de rutas
├── theme/                   # Temas y estilos
│   ├── app_theme.dart
│   ├── animated_background.dart
│   └── theme_provider.dart
├── shared/                  # Componentes compartidos
│   ├── widgets/
│   └── utils/
├── services/               # Servicios externos
│   ├── storage_service.dart
│   ├── ads_service.dart
│   ├── iap_service.dart
│   ├── analytics_service.dart
│   └── daily_challenge_service.dart
└── features/              # Funcionalidades principales
    ├── home/
    ├── game/
    ├── store/
    ├── settings/
    ├── stats/
    └── daily_challenge/
```

## 🎮 Cómo Jugar

1. **Selecciona un modo**: Fácil, Difícil o Práctica
2. **Resuelve operaciones**: El valor actual se actualiza con cada acierto
3. **Mantén tu racha**: Cada acierto suma a tu racha
4. **Gana monedas**: Cada 10 aciertos = 1 moneda
5. **Continúa o reinicia**: Al fallar, puedes continuar gastando monedas
6. **Reto del Día**: Completa 3 fases diarias para recompensas especiales

## 💡 Consejos

- **Practica regularmente**: Mejora tu velocidad y precisión
- **Usa el modo fácil**: Para calentar antes del modo difícil
- **Mira anuncios**: Para conseguir monedas extra
- **Revisa estadísticas**: Identifica tus puntos débiles
- **Ajusta configuración**: Personaliza según tu nivel
- **Completa el reto diario**: Para mantener tu racha y ganar monedas

## 🔧 Configuración de Anuncios

### IDs de Test (Incluidos)
- **Android**: `ca-app-pub-3940256099942544~3347511713`
- **iOS**: `ca-app-pub-3940256099942544~1458002511`

### Para Producción
1. Crear cuenta en [AdMob](https://admob.google.com)
2. Crear aplicaciones para Android e iOS
3. Crear Ad Units para anuncios recompensados
4. Reemplazar IDs en `android/app/src/main/AndroidManifest.xml` e `ios/Runner/Info.plist`

## 📈 Roadmap

- [x] **Reto del Día con 3 fases**
- [x] **Sistema de pistas comprables**
- [x] **UI completamente responsive**
- [ ] **Anuncios intersticiales**
- [ ] **Logros y badges**
- [ ] **Modo multijugador**
- [ ] **Leaderboards**
- [ ] **Temas personalizables**
- [ ] **Sonidos y música**
- [ ] **Modo offline mejorado**

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para detalles.

## 👨‍💻 Autor

**Tu Nombre**
- GitHub: [@tu-usuario](https://github.com/tu-usuario)

## 🙏 Agradecimientos

- **Flutter Team**: Por el increíble framework
- **Google Fonts**: Por la tipografía Nunito
- **Hive**: Por la base de datos local
- **Comunidad Flutter**: Por el apoyo y recursos

---

⭐ **¡Dale una estrella si te gusta el proyecto!**
