# Scaffold UI

Instantly add production-ready authentication and in-app purchase UIs to your [Nylo](https://nylo.dev) Flutter applications.

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
- **Basic** - Clean authentication UI templates for custom implementation

### 💳 In-App Purchases (iOS & Android)
Add subscription flows and paywalls with:
```bash
dart run scaffold_ui:main iap
```

Currently supports:
- **RevenueCat** - Complete integration with SDK and pre-built UI components for subscription management

## Installation

Add scaffold_ui to your Flutter project:

```bash
dart pub add scaffold_ui
```

This will add the following to your pubspec.yaml:
```yaml
dependencies:
  scaffold_ui: ^1.2.0
```

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

### Basic Authentication

For custom authentication implementations:

1. Run `dart run scaffold_ui:main auth`
2. Select `basic`
3. The tool will generate UI components that you can customize with your authentication logic

## Documentation

For detailed documentation and examples, visit our [official documentation](https://docs.nylo.dev/scaffold-ui).

## Changelog

See [CHANGELOG](https://github.com/nylo-core/nylo-core/scaffold_ui/CHANGELOG.md) for recent changes.

## License

This project is licensed under the MIT License - see the [License](https://github.com/nylo-core/nylo-core/scaffold_ui/blob/master/licence) file for details.