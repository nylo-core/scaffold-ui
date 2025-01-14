# Scaffold UI

Scaffolds an authentication UI in your [Nylo](https://nylo.dev) project.

### Getting Started

In your Flutter project add the dependency:

With Dart:

``` bash
dart pub add scaffold_ui
```

This will add a line like this to your package's pubspec.yaml (and run an implicit dart pub get):

``` dart 
dependencies:
  ...
  scaffold_ui: ^1.1.11
```

## Usage

Step 1: Run the below command in your project.

``` bash
dart run scaffold_ui:main auth
```

Select from the following options:

- Supabase - `supabase`
- Laravel - `laravel`
- Basic - `basic`

## Supabase Installation

You'll first need a Supabase account and a project setup.

After you run `dart run scaffold_ui:main auth` and select `supabase`, you'll be prompted to enter your Supabase URL and Anon Key.

## Laravel Installation

You'll first need a Laravel project setup.

You're `User` model should be using the `HasApiTokens` trait ([Laravel Sanctum](https://laravel.com/docs/11.x/sanctum)).

Next, you'll need to install the Laravel composer package [laravel-nylo-auth](https://github.com/nylo-core/laravel-nylo-auth).

You can install the package via composer:

``` bash
composer require nylo/laravel-nylo-auth
```

You can publish with:

``` bash
php artisan vendor:publish --provider="Nylo\LaravelNyloAuth\LaravelNyloAuthServiceProvider"
```

Now, run `dart run scaffold_ui:main auth` and select `laravel`.

It will ask you for your Laravel project URL.

Check out the Laravel package [here](https://github.com/nylo-core/laravel-nylo-auth) for more information.

## Basic Installation

If you select `basic` when running `dart run scaffold_ui:main auth`, it will scaffold a basic authentication UI.

You will need to implement the authentication logic yourself.

## Changelog
Please see [CHANGELOG](https://github.com/nylo-core/nylo-core/scaffold_ui/CHANGELOG.md) for more information what has changed recently.

## Licence

The MIT License (MIT). Please view the [License](https://github.com/nylo-core/nylo-core/scaffold_ui/blob/master/licence) File for more information.
