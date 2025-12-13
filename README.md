# IMDUMB - Aplicación iOS de Base de Datos de Películas

[![CI](https://github.com/jesersu/IMDUMP/actions/workflows/ci.yml/badge.svg)](https://github.com/jesersu/IMDUMP/actions/workflows/ci.yml)
[![Build](https://github.com/jesersu/IMDUMP/actions/workflows/build.yml/badge.svg)](https://github.com/jesersu/IMDUMP/actions/workflows/build.yml)

IMDUMB es una aplicación iOS que muestra categorías y detalles de películas, construida con el patrón **MVP + Arquitectura Limpia**. La aplicación demuestra prácticas profesionales de desarrollo iOS incluyendo una adecuada separación de responsabilidades, principios SOLID, diseño de interfaz con UIKit y archivos XIB, **gestión encriptada de secretos con Arkana**, e **integración continua/despliegue con Fastlane y GitHub Actions**.

 - [Video rapido explicativo](https://youtu.be/9EaVBrL78RA)
   
## 🔐 Características de Seguridad

- **Integración con Arkana** - Las claves API y datos sensibles se encriptan usando Arkana
- **Configuración basada en Entornos** - Diferentes configuraciones para compilaciones Debug/Release
- **Secretos Type-Safe** - Seguridad en tiempo de compilación al acceder a claves encriptadas
- **Firebase Remote Config** - Gestión de configuración dinámica sin actualizaciones de la aplicación

## 📱 Características

- **Pantalla de Presentación** con carga de configuración de Firebase
- **Pantalla de Categorías** que muestra películas organizadas por categoría (Popular, Mejor Valoradas, Próximas, En Cines Ahora)
- **Patrón de UI Único**: UICollectionView con UITableView dentro de cada celda
- **Soporte sin Conexión**:
  - Almacenamiento en caché con CoreData con TTL de 24 horas
  - Estrategia cache-first con actualización en segundo plano
  - Notificación toast cuando se visualizan datos en caché sin conexión
  - Migración automática de UserDefaults a CoreData
- **Programación Reactiva**:
  - RxSwift para todas las operaciones asincrónicas
  - Patrón Single<T> para operaciones de una sola vez
  - DisposeBag para gestión automática de memoria
  - MainScheduler para actualizaciones de UI thread-safe
- **Pantalla de Detalles de Película** que presenta:
  - Carrusel horizontal de imágenes con paginación
  - Título de película, calificación y descripción con formato HTML
  - Lista de actores en colección de desplazamiento horizontal
  - Botón fijo inferior "Recomendar"
- **Modal de Recomendación** con:
  - Altura dinámica que se ajusta al contenido
  - Visualización de descripción de película
  - Campo de texto para comentarios
  - Funcionalidad de confirmación

## 🏗️ Arquitectura

El proyecto implementa una **Arquitectura Limpia** con el patrón **MVP (Modelo-Vista-Presentador)**, mejorado con **RxSwift** para el flujo de datos reactivo. Esta arquitectura asegura una completa separación de responsabilidades, capacidad de prueba y mantenibilidad.

### Capas de Arquitectura

La aplicación está dividida en cuatro capas distintas, cada una con responsabilidades específicas:

#### 1. **Capa de Dominio** (Lógica de Negocio - Sin Dependencias de Framework)
El núcleo de la aplicación, que contiene lógica de negocio pura sin dependencias en frameworks o librerías externas.

- **Entidades** (`Domain/Entities/`):
  - Structs puros de Swift representando modelos de negocio
  - `Movie.swift`: Entidad de película con todas sus propiedades
  - `Actor.swift`: Entidad de actor/miembro del elenco
  - `Category.swift`: Agrupación de categorías de películas
  - Sin dependencias, sin frameworks, solo estructuras de datos

- **Protocolos de Repositorio** (`Domain/Repositories/`):
  - Interfaces abstractas que definen operaciones de datos
  - `MovieRepositoryProtocol`: Define métodos para obtener categorías y detalles de películas
  - Retorna `Single<T>` (RxSwift) para flujo de datos reactivo
  - Permite inversión de dependencias (módulos de alto nivel no dependen de detalles de bajo nivel)

- **Casos de Uso** (`Domain/UseCases/`):
  - Operaciones de negocio de propósito único siguiendo SRP
  - `GetCategoriesUseCase`: Obtiene categorías de películas, filtra categorías vacías
  - `GetMovieDetailsUseCase`: Obtiene información completa de películas
  - `LoadConfigurationUseCase`: Carga Firebase Remote Config
  - Cada caso de uso depende solo de protocolos de repositorio (DIP)

#### 2. **Capa de Datos** (Gestión de Datos)
Maneja todas las operaciones de datos: solicitudes de red, almacenamiento en caché local y transformación de datos.

- **DTOs** (`Data/DTOs/`):
  - Objetos de Transferencia de Datos para respuestas de API y almacenamiento en caché
  - `MovieDTO`, `ActorDTO`: Coinciden con la estructura de API/base de datos
  - `CachedMoviesDTO`, `CachedMovieDetailsDTO`: Envoltorios de caché CoreData
  - `DTO+Mapping.swift`: Métodos de extensión para convertir DTOs a entidades de dominio
  - Separados de modelos de dominio para permitir evolución independiente

- **DataStores** (`Data/DataStores/`):
  - Diferentes implementaciones de fuentes de datos siguiendo OCP
  - `RemoteMovieDataStore`: Obtiene de la API TMDB a través de Alamofire, retorna `Single<T>`
  - `LocalMovieDataStore`: Recupera del caché CoreData con TTL de 24 horas
  - `MockMovieDataStore`: Proporciona datos de ejemplo para pruebas
  - `FirebaseConfigDataStore`: Obtiene Remote Config de Firebase
  - Todos se ajustan a `MovieDataStoreProtocol` (LSP - intercambiables)

- **Repositorios** (`Data/Repositories/`):
  - Implementaciones concretas de protocolos de repositorio de dominio
  - `MovieRepository`: Coordina entre múltiples fuentes de datos
  - Implementa estrategia cache-first con actualización en segundo plano
  - Usa `Single.zip()` para paralelizar 4 obtenciones de categorías
  - Convierte DTOs a entidades de dominio usando extensiones de mapeo

#### 3. **Capa de Presentación** (UI - Patrón MVP)
Maneja todas las preocupaciones de interfaz de usuario siguiendo el patrón MVP.

Cada pantalla está organizada con:
- **Protocolo de Vista**: Define qué puede hacer la vista (mostrar datos, mostrar carga, mostrar errores)
- **Protocolo de Presentador**: Define qué acciones maneja el presentador
- **View Controller**: Vista UIKit que se ajusta al Protocolo de Vista
  - Muestra datos recibidos del presentador
  - Reenvía interacciones del usuario al presentador
  - Usa archivos XIB (sin SwiftUI, sin vistas programáticas)
- **Presentador**: Coordinador de lógica de negocio
  - Se suscribe a observables `Single<T>` del caso de uso
  - Transforma datos para visualización en vista
  - Maneja errores y casos edge
  - Usa `DisposeBag` para gestión automática de memoria
  - Usa `MainScheduler.instance` para actualizaciones de UI thread-safe

**Pantallas:**
- `Splash/`: Carga de configuración de Firebase, navegación a pantalla principal
- `Categories/`: Categorías de películas con UICollectionView/UITableView anidados
- `MovieDetail/`: Detalles de película con carrusel de imágenes, elenco y recomendación
- `Recommendation/`: Modal para recomendación de película con altura dinámica

#### 4. **Capa Core** (Utilidades Compartidas)
Responsabilidades transversales e infraestructura compartida.

- **Red** (`Core/Network/`):
  - `NetworkService`: Cliente HTTP basado en Alamofire con manejo genérico de solicitudes
  - Thread-safe, reutilizable en todos los data stores

- **Caché** (`Core/Cache/`):
  - `CacheServiceProtocol`: Interfaz de caché abstracta
  - `CoreDataCacheService`: Implementación CoreData con soporte de TTL
  - `ImageCacheService`: Almacenamiento en caché de imágenes en memoria para rendimiento

- **Extensiones** (`Core/Extensions/`):
  - `UIViewController+Loading.swift`: Indicadores de carga y notificaciones toast
  - `String+HTML.swift`: Análisis de HTML para descripciones de películas
  - `UIImageView+Alamofire.swift`: Carga asincrónica de imágenes con Alamofire

- **Utilidades** (`Core/Utils/`):
  - `NetworkReachability`: Detecta estado en línea/fuera de línea para UX cache-first

### Estructura del Proyecto

```
IMDUMB/
├── Domain/                          # 🎯 Lógica de Negocio (Swift Puro)
│   ├── Entities/                   # Modelos de negocio
│   │   ├── Movie.swift
│   │   ├── Actor.swift
│   │   └── Category.swift
│   ├── Repositories/               # Interfaces de datos abstractas
│   │   └── MovieRepositoryProtocol.swift
│   └── UseCases/                   # Operaciones de negocio
│       ├── GetCategoriesUseCase.swift
│       ├── GetMovieDetailsUseCase.swift
│       └── LoadConfigurationUseCase.swift
│
├── Data/                            # 💾 Gestión de Datos
│   ├── DTOs/                       # Objetos de transferencia de datos
│   │   ├── MovieDTO.swift
│   │   ├── ActorDTO.swift
│   │   ├── CachedDTOs.swift
│   │   └── DTO+Mapping.swift       # Mapeo DTO → Dominio
│   ├── DataStores/                 # Implementaciones de fuentes de datos
│   │   ├── MovieDataStoreProtocol.swift
│   │   ├── RemoteMovieDataStore.swift    # Red (Alamofire)
│   │   ├── LocalMovieDataStore.swift     # Caché (CoreData)
│   │   ├── MockMovieDataStore.swift      # Pruebas
│   │   └── FirebaseConfigDataStore.swift # Remote Config
│   └── Repositories/               # Implementaciones de repositorio
│       └── MovieRepository.swift   # Cache-first + obtención paralela
│
├── Presentation/                    # 🎨 Capa de UI (Patrón MVP)
│   ├── Splash/
│   │   ├── SplashViewController.swift     # Vista (XIB)
│   │   ├── SplashPresenter.swift          # Presentador (RxSwift)
│   │   └── SplashContracts.swift          # Protocolos Vista/Presentador
│   ├── Categories/
│   │   ├── CategoriesViewController.swift # Vista (XIB)
│   │   ├── CategoriesPresenter.swift      # Presentador (RxSwift + detección de sin conexión)
│   │   ├── CategoryCollectionViewCell.swift
│   │   └── MovieTableViewCell.swift
│   ├── MovieDetail/
│   │   ├── MovieDetailViewController.swift
│   │   └── MovieDetailPresenter.swift
│   └── Recommendation/
│       └── RecommendationViewController.swift
│
├── Core/                            # 🔧 Infraestructura Compartida
│   ├── Network/
│   │   └── NetworkService.swift    # Cliente HTTP Alamofire
│   ├── Cache/
│   │   ├── CacheServiceProtocol.swift
│   │   ├── CoreDataCacheService.swift
│   │   └── ImageCacheService.swift
│   ├── Extensions/
│   │   ├── UIViewController+Loading.swift
│   │   ├── String+HTML.swift
│   │   └── UIImageView+Alamofire.swift
│   ├── Utils/
│   │   └── NetworkReachability.swift
│   └── Protocols/
│       └── BaseViewProtocol.swift
│
└── Packages/                        # 📦 Paquetes Swift
    └── IMDUMBPersistence/          # Módulo de persistencia CoreData
        ├── Sources/
        │   └── IMDUMBPersistence/
        │       ├── CoreDataModels.xcdatamodeld
        │       ├── CacheService.swift
        │       ├── MovieDTO.swift
        │       └── ActorDTO.swift
        └── Tests/
```

### Flujo de Datos con RxSwift

La aplicación utiliza **RxSwift** para flujo de datos reactivo y declarativo:

```
┌─────────────┐
│    Vista    │  Usuario toca "Cargar Películas"
└──────┬──────┘
       │ viewDidLoad()
       ▼
┌─────────────┐
│ Presentador │  getCategoriesUseCase.execute()
└──────┬──────┘       .observe(on: MainScheduler.instance)
       │              .subscribe(onSuccess: { view.display($0) })
       │              .disposed(by: disposeBag)
       ▼
┌─────────────┐
│  Caso Uso   │  repository.getCategories() → Single<[Category]>
└──────┬──────┘       .map { $0.filter { !$0.movies.isEmpty } }
       │
       ▼
┌─────────────┐
│ Repositorio │  1. Intentar caché: localDataStore.fetchMovies()
└──────┬──────┘                   .catch { remoteDataStore.fetchMovies() }
       │         2. Obtención paralela 4 categorías: Single.zip(...)
       │         3. Actualización en segundo plano: .do(onSuccess: { refresh() })
       │         4. Mapear DTOs → Dominio: dtos.map { $0.toDomain() }
       ▼
┌─────────────┐
│  DataStore  │  RemoteDataStore: Solicitud HTTP Alamofire → Single<[MovieDTO]>
└──────┬──────┘  LocalDataStore:  Búsqueda CoreData → Single<[MovieDTO]>
       │
       ▼
┌─────────────┐
│    Red /    │  API TMDB o CoreData
│   Caché     │
└─────────────┘

La respuesta fluye hacia arriba a través de la cadena Single:
MovieDTO[] → (mapeo) → Movie[] → Category[] → Vista muestra
```

### Patrones Reactivos Utilizados

**1. Single para Operaciones de Una Sola Vez:**
```swift
func getCategories() -> Single<[Category]> {
    return repository.getCategories()
        .map { categories in categories.filter { !$0.movies.isEmpty } }
}
```

**2. Ejecución Paralela con Single.zip:**
```swift
let singles = [popular, topRated, upcoming, nowPlaying].map { endpoint in
    dataStore.fetchMovies(endpoint: endpoint)
}
Single.zip(singles) // Ejecuta todas las 4 obtenciones en paralelo
```

**3. Cache-First con Fallback:**
```swift
localDataStore.fetchMovies(endpoint)
    .do(onSuccess: { refreshInBackground() })  // Actualización en segundo plano
    .catch { remoteDataStore.fetchMovies(endpoint) }  // Fallback a red
```

**4. Actualizaciones de UI Thread-Safe:**
```swift
useCase.execute()
    .observe(on: MainScheduler.instance)  // Asegura actualizaciones de UI en hilo principal
    .subscribe(onSuccess: { view.display($0) })
    .disposed(by: disposeBag)  // Limpieza automática en deinit
```

**5. Operaciones No Críticas:**
```swift
fetchMovieCredits(movieId)
    .catchAndReturn([])  // Continuar con matriz vacía si los créditos fallan
```

### Flujo de Soporte sin Conexión

```
Usuario abre la aplicación (sin conexión)
    ↓
NetworkReachability.shared.isReachable → false
    ↓
Repositorio intenta LocalDataStore primero (cache-first)
    ↓
Acierto en caché → Retorna datos en caché
    ↓
Presentador detecta sin conexión: if !isReachable { view.showToast("Sin conexión") }
    ↓
Vista muestra datos en caché + notificación toast
    ↓
Cuando está en línea: Actualización en segundo plano actualiza caché
```

## 🎯 Implementación de Principios SOLID

El código demuestra principios SOLID a través de:

### 1. **Principio de Responsabilidad Única (SRP)**
- **Ubicación**: `IMDUMB/Domain/Entities/Movie.swift:5`
  ```swift
  // SOLID: Principio de Responsabilidad Única - Esta struct solo representa datos de películas
  struct Movie { ... }
  ```
- Cada clase/struct tiene una responsabilidad clara
- Los presentadores manejan lógica de negocio, las vistas manejan UI, los casos de uso manejan operaciones de dominio

### 2. **Principio Abierto/Cerrado (OCP)**
- **Ubicación**: `IMDUMB/Data/DataStores/MockMovieDataStore.swift:5`
  ```swift
  // SOLID: Principio Abierto/Cerrado - Abierto para extensión (diferentes implementaciones), cerrado para modificación
  protocol MovieDataStoreProtocol { ... }
  ```
- Los data stores pueden extenderse con nuevas implementaciones sin modificar código existente
- El diseño basado en protocolos permite múltiples implementaciones (Remoto, Mock, Local)

### 3. **Principio de Sustitución de Liskov (LSP)**
- **Ubicación**: `IMDUMB/Data/DataStores/MockMovieDataStore.swift:7`
  ```swift
  // SOLID: Principio de Sustitución de Liskov - Puede sustituir RemoteMovieDataStore sin romper funcionalidad
  class MockMovieDataStore: MovieDataStoreProtocol { ... }
  ```
- MockMovieDataStore puede reemplazar RemoteMovieDataStore sin problemas
- Todas las implementaciones de DataStore son intercambiables

### 4. **Principio de Segregación de Interfaz (ISP)**
- **Ubicación**: `IMDUMB/Domain/Repositories/MovieRepositoryProtocol.swift:5`
  ```swift
  // SOLID: Principio de Segregación de Interfaz - Interfaz específica para operaciones de películas
  protocol MovieRepositoryProtocol { ... }
  ```
- Los protocolos están enfocados y específicos a su dominio
- BaseViewProtocol proporciona interfaz mínima para vistas

### 5. **Principio de Inversión de Dependencias (DIP)**
- **Ubicación**: `IMDUMB/Domain/UseCases/GetCategoriesUseCase.swift:9`
  ```swift
  // SOLID: Inversión de Dependencias - Depende de abstracción (protocolo), no de implementación concreta
  init(repository: MovieRepositoryProtocol) { ... }
  ```
- Módulos de alto nivel dependen de abstracciones (protocolos)
- La inyección de dependencias se utiliza en toda la aplicación

## 🛠️ Stack Tecnológico

- **Lenguaje**: Swift 5.0
- **Versión Mínima de iOS**: 15.0
- **Framework de UI**: UIKit con archivos XIB (sin SwiftUI, sin vistas programáticas)
- **Arquitectura**: MVP + Arquitectura Limpia
- **Programación Reactiva**: RxSwift 6.9.1 para operaciones asincrónicas y flujos de datos
- **Redes**: Alamofire 5.10.2 para solicitudes HTTP y carga de imágenes
- **Gestión de Dependencias**: Swift Package Manager (SPM)
- **Persistencia**: CoreData para almacenamiento en caché sin conexión (paquete IMDUMBPersistence)
- **Firebase**: Firebase Remote Config para configuración dinámica

## 📦 Dependencias

Las dependencias se gestionan a través de Swift Package Manager:

- **Arkana** - Encriptación y gestión de secretos (gema Ruby)
- **Alamofire 5.10.2** - Redes HTTP y carga de imágenes asincrónicas
- **RxSwift 6.9.1** - Programación reactiva para operaciones asincrónicas
  - RxSwift - Extensiones reactivas principales
  - RxCocoa - Extensiones reactivas UIKit
  - RxBlocking - Soporte de pruebas sincrónicas
- **Firebase iOS SDK 11.15.0** - Remote Config para configuración dinámica
- **IMDUMBPersistence** - Paquete Swift local para almacenamiento en caché CoreData

## 🚀 Instalación y Configuración

### Requisitos Previos

- Xcode 16.0 o superior
- macOS con herramientas de desarrollo iOS
- Git
- Ruby (para Arkana - viene con macOS)

### Pasos

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/jesersu/IMDUMP.git
   cd IMDUMB
   ```

2. **Instalar Arkana** (para secretos encriptados)
   ```bash
   gem install arkana
   ```

3. **Configurar Claves API** (Recomendado - Usar Arkana)
   ```bash
   # Copiar el archivo de entorno de ejemplo
   cp .env.sample .env

   # Editar .env y agregar tu clave API de TMDB
   # Obtén tu clave de: https://www.themoviedb.org/settings/api

   # Generar secretos encriptados
   arkana -e .env
   ```

4. **Abrir el proyecto**
   ```bash
   open IMDUMB.xcodeproj
   ```

5. **Configurar Firebase** (Requerido para funcionalidad completa)
   - Descargar `GoogleService-Info.plist` desde la Consola de Firebase
   - Agregarlo a la raíz del proyecto en Xcode
   - Configurar parámetros de Remote Config en la Consola de Firebase
   - Nota: El archivo está excluido de git a través de .gitignore

6. **Compilar y Ejecutar**
   - Seleccionar un simulador o dispositivo
   - Presionar `Cmd + R` o hacer clic en el botón Ejecutar
   - La aplicación se iniciará con la pantalla de presentación

### Ejecutar con Datos Mock

La aplicación actualmente está configurada para usar `MockMovieDataStore` para desarrollo. Para probar sin claves API:

- Archivo: `IMDUMB/Presentation/Categories/CategoriesViewController.swift:59`
- La aplicación utiliza datos mock por defecto, por lo que funciona inmediatamente sin configuración

### Cambiar a API Real

Para utilizar la API real de TMDB:

1. Obtener una clave API gratuita de [TMDB](https://www.themoviedb.org/settings/api)
2. Actualizar el NetworkService con tu clave API
3. Cambiar data store en `CategoriesViewController.swift:59`:
   ```swift
   // Cambiar de:
   let dataStore = MockMovieDataStore()
   // A:
   let dataStore = RemoteMovieDataStore()
   ```

## 📡 Puntos Finales de API

La aplicación utiliza The Movie Database (TMDB) API:

### URL Base
```
https://api.themoviedb.org/3
```

### Puntos Finales Utilizados

| Punto Final | Descripción |
|----------|-------------|
| `/movie/popular` | Películas populares |
| `/movie/top_rated` | Películas mejor valoradas |
| `/movie/upcoming` | Películas próximas |
| `/movie/now_playing` | Películas en cines ahora |
| `/movie/{id}` | Detalles de película |
| `/movie/{id}/credits` | Elenco de película |
| `/movie/{id}/images` | Imágenes de película |

## 🧪 Pruebas

### Implementaciones de DataStore

La aplicación incluye múltiples implementaciones de DataStore para pruebas:

- **MockMovieDataStore**: Proporciona datos de ejemplo sin llamadas de red
- **RemoteMovieDataStore**: Obtiene datos de la API TMDB
- **LocalDataStore**: (Futuro) Para almacenamiento en caché sin conexión con CoreData/Realm

### Pruebas Unitarias

El proyecto incluye pruebas unitarias completas que cubren componentes principales:

**Cobertura de Pruebas:**
- ✅ **Casos de Uso** (8 pruebas): GetCategoriesUseCase, GetMovieDetailsUseCase
- ✅ **Repositorios** (4 pruebas): Mapeo DTO de MovieRepository y manejo de errores
- ✅ **Presentadores** (4 pruebas): Ciclo de vida de vista de CategoriesPresenter y gestión de estado
- ✅ **DataStores** (8 pruebas): Validación de calidad de datos de MockMovieDataStore
- ✅ **Extensiones** (10 pruebas): Análisis de String+HTML y casos edge

**Total: 34 pruebas unitarias**

**Ejecutar Pruebas:**

1. En Xcode: Presionar `Cmd + U`
2. Línea de comandos:
   ```bash
   xcodebuild test -project IMDUMB.xcodeproj -scheme IMDUMB -destination 'platform=iOS Simulator,name=iPhone 15'
   ```

**Ubicación de Archivos de Prueba:** `IMDUMBTests/`

**Nota:** Para ejecutar pruebas en Xcode, necesitas agregar el objetivo IMDUMBTests al proyecto primero (los archivos de prueba están incluidos en el repositorio).

## 📖 Detalles de Estructura del Proyecto

### Capas

1. **Capa de Dominio**: Lógica de negocio pura, sin dependencias en frameworks
2. **Capa de Datos**: Implementa obtención de datos y mapeo
3. **Capa de Presentación**: Componentes de UI usando patrón MVP
4. **Capa Core**: Utilidades compartidas y extensiones

### Patrones de Diseño Clave

- **Patrón MVP**: Separación de Vista y lógica de negocio
- **Patrón de Repositorio**: Abstraer fuentes de datos
- **Inyección de Dependencias**: A través de inicializadores
- **Programación Orientada a Protocolos**: Uso extensivo de protocolos

## 🎨 Componentes de UI

Toda la UI se construye con **archivos XIB**:

- ✅ Sin SwiftUI
- ✅ Sin vistas programáticas
- ✅ Interface Builder para todas las pantallas
- ✅ Celdas reutilizables personalizadas

## 🚀 CI/CD y Automatización

### Fastlane

El proyecto utiliza Fastlane para automatización iOS. Lanes disponibles:

**Configuración y Dependencias:**
```bash
bundle exec fastlane setup              # Configurar proyecto y dependencias
bundle exec fastlane update_dependencies # Actualizar dependencias SPM
```

**Compilación:**
```bash
bundle exec fastlane build_debug        # Compilar configuración Debug
bundle exec fastlane build_release      # Compilar configuración Release
bundle exec fastlane archive            # Crear archivo IPA
```

**Pruebas:**
```bash
bundle exec fastlane test               # Ejecutar todas las pruebas unitarias
bundle exec fastlane test_with_coverage # Ejecutar pruebas con cobertura de código
```

**CI/CD:**
```bash
bundle exec fastlane ci                 # Pipeline CI completo (lint, test, build)
bundle exec fastlane ci_quick           # CI rápido (test + build)
```

**Utilidades:**
```bash
bundle exec fastlane clean              # Limpiar artefactos de compilación
bundle exec fastlane lint               # Ejecutar SwiftLint
```

### Flujos de Trabajo de GitHub Actions

El proyecto incluye flujos de trabajo automatizados de CI/CD:

**1. Flujo de Trabajo CI** (`.github/workflows/ci.yml`)
- Se ejecuta en: Push a main/develop, Pull Requests
- Pasos: Instalar dependencias → Generar secretos → Ejecutar pruebas → Compilación de lanzamiento
- Carga: Resultados de pruebas, informes de cobertura de código

**2. Verificación de PR** (`.github/workflows/pr-check.yml`)
- Se ejecuta en: Eventos de pull request
- Validación rápida y comentarios automáticos de PR

**3. Compilación** (`.github/workflows/build.yml`)
- Se ejecuta en: Etiquetas (`v*`), Activación manual
- Crea archivos de liberación y lanzamientos de GitHub

**4. Actualización de Dependencias** (`.github/workflows/dependency-update.yml`)
- Se ejecuta en: Horario semanal (lunes), Activación manual
- Auto-crea PRs para actualizaciones de dependencias

### Configurar CI/CD

**1. Instalar Fastlane:**
```bash
bundle install
```

**2. Configurar Secretos (para CI):**

Agregar estos secretos a tu repositorio de GitHub (Configuración → Secretos y variables → Acciones):
- `TMDB_API_KEY`: Tu clave API de TMDB
- `FIREBASE_API_KEY`: Tu clave API de Firebase

**3. Ejecutar Localmente:**
```bash
# Primera vez configuración
bundle exec fastlane setup

# Ejecutar pruebas
bundle exec fastlane test

# Verificación CI completa
bundle exec fastlane ci
```

## 📝 Notas Adicionales

### Configuración de Firebase

La aplicación lee configuración desde Firebase al inicio. La implementación mock retorna:

```json
{
  "api_base_url": "https://api.themoviedb.org/3",
  "api_key": "YOUR_TMDB_API_KEY",
  "welcome_message": "¡Bienvenido a IMDUMB!",
  "enable_features": {
    "dark_mode": true,
    "recommendations": true,
    "social_sharing": false
  }
}
```

### Carga de Imágenes

Las imágenes se cargan de forma asincrónica usando URLSession. Para producción, considera usar una librería de almacenamiento en caché como Kingfisher o SDWebImage.

### Representación de HTML

Las descripciones de películas soportan formato HTML a través de la extensión `String+HTML.swift`.
