# Arkana Setup Guide

This project uses [Arkana](https://github.com/rogerluan/arkana) to encrypt sensitive information like API keys, preventing them from being exposed in your source code or version control.

## 🔐 What is Arkana?

Arkana is a Swift/Kotlin code generator that encrypts your secrets (API keys, tokens, etc.) and generates type-safe code to access them. The encrypted values are committed to your repository, while the original `.env` files remain private.

## 📋 Prerequisites

- Ruby installed (comes with macOS)
- Arkana gem: `gem install arkana`

## 🚀 Quick Start

### 1. Copy the Sample Environment File

```bash
cp .env.sample .env
```

### 2. Add Your Real API Keys

Edit `.env` and replace the placeholder values with your actual keys:

```bash
# .env
TMDBAPIKey=your_actual_tmdb_api_key_here
FirebaseAPIKey=your_actual_firebase_key_here
APIBaseURL=https://api.themoviedb.org/3
```

**Get your TMDB API Key**: https://www.themoviedb.org/settings/api

### 3. Generate Encrypted Keys

```bash
arkana -e .env
```

This will:
- Read your secrets from `.env`
- Encrypt them using salt and obfuscation
- Generate Swift code in the `ArkanaKeys/` directory

### 4. Build the Project

The generated code is already integrated into the project via `SecretsManager.swift`:

```bash
open IMDUMB.xcodeproj
# Build and run (Cmd + R)
```

## 📁 Files Overview

### Committed to Git (Safe)
- `.arkana.yml` - Arkana configuration
- `.env.sample` - Template for developers
- `ArkanaKeys/` - Encrypted secrets (generated)
- `SecretsManager.swift` - Accesses encrypted secrets

### NOT Committed (Private)
- `.env` - Your actual API keys
- `.env.debug` - Debug environment secrets
- `.env.release` - Release environment secrets

## 🔧 Configuration

The Arkana configuration is in `.arkana.yml`:

```yaml
namespace: ArkanaKeys
package_manager: spm

global_secrets:
  - TMDBAPIKey        # TMDB API Key
  - FirebaseAPIKey    # Firebase API Key
  - APIBaseURL        # API Base URL

import_name: IMDUMB
```

## 💻 Usage in Code

The `SecretsManager` singleton provides type-safe access to all secrets:

```swift
import Foundation

// Get encrypted API key
let apiKey = SecretsManager.shared.tmdbAPIKey

// Get API base URL
let baseURL = SecretsManager.shared.apiBaseURL

// Get Firebase key
let firebaseKey = SecretsManager.shared.firebaseAPIKey
```

The NetworkService automatically uses these encrypted secrets:

```swift
// Automatically uses SecretsManager
let networkService = NetworkService.shared
```

## 🔄 Updating Secrets

When you need to change API keys:

1. Update `.env` with new values
2. Run `arkana -e .env` to regenerate encrypted code
3. Commit the updated `ArkanaKeys/` directory
4. Rebuild the project

## 🛡️ Security Benefits

✅ **Encrypted in Git**: Keys are obfuscated and encrypted in the repository
✅ **Type-Safe Access**: Compile-time safety when accessing secrets
✅ **Environment Separation**: Different keys for debug/release builds
✅ **No Plaintext**: Original `.env` files never committed
✅ **Build-Time Security**: Keys decrypted only during app runtime

## ⚠️ Important Notes

1. **Never commit `.env` files** - They're in `.gitignore`
2. **Share `.env.sample`** - This helps team members know what keys are needed
3. **Regenerate after changes** - Always run `arkana` after updating `.env`
4. **CI/CD Setup** - In CI, set environment variables or use encrypted secrets

## 🔗 Advanced Usage

### Environment-Specific Secrets

If you need different keys per environment:

```yaml
# .arkana.yml
environments:
  - Debug
  - Release

environment_secrets:
  - APIBaseURL
```

Then create:
- `.env.debug` - Debug environment keys
- `.env.release` - Production environment keys

### Using Arkana Directly (Alternative to SecretsManager)

If you prefer using Arkana's generated code directly:

```swift
import ArkanaKeys

let apiKey = ArkanaKeys.Global.current.tMDBAPIKey
let baseURL = ArkanaKeys.Global.current.aPIBaseURL
```

## 📚 Resources

- [Arkana GitHub](https://github.com/rogerluan/arkana)
- [Arkana Documentation](https://github.com/rogerluan/arkana/wiki)
- [TMDB API Docs](https://developers.themoviedb.org/3)

## 🆘 Troubleshooting

### "Secret not found" Error

Make sure the secret name in `.arkana.yml` matches the key in `.env`:

```bash
# .arkana.yml
global_secrets:
  - TMDBAPIKey

# .env
TMDBAPIKey=your_key_here  # ✅ Correct
TMDB_API_KEY=your_key     # ❌ Wrong
```

### Build Errors After Update

1. Clean build folder: `Cmd + Shift + K`
2. Regenerate Arkana: `arkana -e .env`
3. Rebuild: `Cmd + B`

### Keys Not Working

1. Verify `.env` has correct values
2. Run `arkana -e .env` to regenerate
3. Check `SecretsManager.swift` is using the right property names

---

**Security Reminder**: Never hardcode API keys in your source code. Always use environment variables and encryption tools like Arkana!
