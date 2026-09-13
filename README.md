# Scaffold UI

Fastest way to add authentication or in-app purchases to your [Nylo](https://nylo.dev) Flutter application.

## Overview

Scaffold UI is a powerful CLI tool that helps Flutter developers quickly integrate common UI patterns into their Nylo projects. Instead of spending hours building authentication flows or in-app purchase screens from scratch, you can have a complete, customizable implementation in minutes.

## Features

### 🔐 Authentication UI
Generate a complete authentication flow with a single command:
```bash
dart run scaffold_ui:main auth
```

Choose from three authentication backends:
- **[Supabase](https://supabase.com)** - Full authentication service with ready-to-use UI components
- **[Laravel](https://laravel.com)** - Complete integration with Laravel Sanctum, including API services
- **[Firebase](https://firebase.google.com)** - Integration with Firebase Auth and Firestore with ready-to-use UI components
- **Basic** - Clean authentication UI templates for custom implementation

### 💳 In-App Purchases (iOS & Android)
Add subscription flows and paywalls with:
```bash
dart run scaffold_ui:main iap
```

Currently supports:
- **[RevenueCat](https://revenuecat.com)** - Complete integration with SDK and pre-built UI components for subscription management
- **[Superwall](https://superwall.com)** - Remote-configurable paywalls with the `superwallkit_flutter` SDK; the CLI also patches `AndroidManifest.xml` for you

##### IOS Prerequisites
- Open the `ios/Runner.xcworkspace` file in Xcode
- Signing & Capabilities > Add the `In-App Purchase` capability
- For Superwall: ensure your iOS deployment target is `14.0` or higher (`platform :ios, '14.0'` in `ios/Podfile`)

##### Android Prerequisites
- For Superwall: set `minSdkVersion 26` (or higher) in `android/app/build.gradle`

## Installation

Add scaffold_ui to your Flutter project:

```bash
dart pub add scaffold_ui
```

This will add the following to your pubspec.yaml:
```yaml
dependencies:
  scaffold_ui: ^2.0.3
```

> **Upgrading from 1.x?** 2.x targets Nylo v7 (`nylo_framework: ^7.1.16`+) and requires Dart `^3.12.0` and Flutter `3.44.0`+. See the [CHANGELOG](https://github.com/nylo-core/scaffold-ui/blob/2.x/CHANGELOG.md) for breaking changes.

## Setup Guides

### Supabase Authentication

1. Create a Supabase account and project at [supabase.com](https://supabase.com)
2. Run the auth scaffold command:
   ```bash
   dart run scaffold_ui:main auth
   ```
3. Select `supabase` when prompted
4. Enter your Supabase URL and Anon Key
5. The tool will automatically:
    - Configure Supabase authentication
    - Generate UI components
    - Set up necessary services

### Laravel Authentication

Prerequisites:
- A Laravel project with [Sanctum](https://laravel.com/docs/11.x/sanctum) configured
- Your User model must use the `HasApiTokens` trait

1. Install the Laravel package:
   ```bash
   composer require nylo/laravel-nylo-auth
   ```

2. Publish the package assets:
   ```bash
   php artisan vendor:publish --provider="Nylo\LaravelNyloAuth\LaravelNyloAuthServiceProvider"
   ```

3. Run the auth scaffold command:
   ```bash
   dart run scaffold_ui:main auth
   ```

4. Select `laravel` and enter your project URL
5. For additional Laravel configuration options, visit the [laravel-nylo-auth](https://github.com/nylo-core/laravel-nylo-auth) repository

### Firebase Authentication

1. Create a Firebase account and project at [firebase.google.com](https://firebase.google.com)
2. Run the auth scaffold command:
   ```bash
   dart run scaffold_ui:main auth
   ```
3. Select `firebase` when prompted
4. This will: 
    - Install the Firebase SDK
    - Generate UI components
    - Set up necessary services
5. Install `flutterfire` via https://firebase.google.com/docs/flutter/setup
6. Run `flutterfire configure` to complete the setup

### Basic Authentication

For custom authentication implementations:

1. Run `dart run scaffold_ui:main auth`
2. Select `basic`
3. The tool will generate UI components that you can customize with your authentication logic

### RevenueCat In-App Purchases

1. Create an account at [revenuecat.com](https://revenuecat.com) and grab your Apple/Android API keys
2. Run the IAP scaffold command:
   ```bash
   dart run scaffold_ui:main iap
   ```
3. Select `RevenueCat` and paste each platform's API key (type `n` to skip a platform)
4. To show the paywall: `routeTo(PaywallPage.path)`

### Superwall In-App Purchases

1. Create an account at [superwall.com](https://superwall.com) and grab your Apple/Android API keys
2. Run the IAP scaffold command:
   ```bash
   dart run scaffold_ui:main iap
   ```
3. Select `Superwall` and paste each platform's API key (type `n` to skip a platform)
4. The CLI will generate `paywall_page.dart`, `superwall_provider.dart`, and — if you supplied an Android key — register `SuperwallPaywallActivity` inside `android/app/src/main/AndroidManifest.xml`
5. Customise the placement name (default `campaign_trigger`) in `lib/resources/pages/paywall_page.dart` to match the placement you configure in the Superwall dashboard
6. To trigger the paywall: `routeTo(PaywallPage.path)`

## Changelog

See [CHANGELOG](https://github.com/nylo-core/scaffold-ui/blob/2.x/CHANGELOG.md) for recent changes.

## License

This project is licensed under the MIT License - see the [License](https://github.com/nylo-core/scaffold-ui/blob/2.x/LICENSE) file for details.