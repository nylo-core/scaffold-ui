## [2.0.0] - 2026-05-21

### Added

* **Superwall IAP integration.** `dart run scaffold_ui:main iap` now offers `Superwall` alongside `RevenueCat`. The slate generates a `paywall_page` (calling `Superwall.shared.registerPlacement('campaign_trigger', ...)`) and a `superwall_provider` that configures the SDK per-platform from the Apple/Android API keys collected at prompt time. Empty keys fall back to commented-out placeholder lines so an Android-only or iOS-only project can be scaffolded without leaking `Superwall.configure("null")` calls. New types: `NySuperwallSlateConfig`, `stubSuperwallProvider`, `stubSuperwallPaywall`, `superwallRun()`.
* **Automatic `AndroidManifest.xml` patching for Superwall.** When the user provides an Android API key, the CLI idempotently injects `<activity android:name="com.superwall.sdk.paywall.view.SuperwallPaywallActivity" ...>` inside `<application>` per Superwall's install docs. The patch is exposed as a pure function (`patchAndroidManifestForSuperwall`) and falls back to printing a manual XML snippet if the manifest is missing or malformed.
* `superwallIosSetupHintFor` / `superwallAndroidSetupHintFor` — Superwall-specific post-install hints (iOS 14.0+ deployment target, Android `minSdkVersion 26`).

### Changed

* **BREAKING** Bumped `nylo_support` dependency from `^6.38.1` to `^7.24.2`. `scaffold_ui` now targets Nylo v7 boilerplates (`nylo_framework: ^7.1.16`+).
* **BREAKING** Dart SDK floor raised to `^3.10.7` to match `nylo_support 7.24.2`'s minimum.
* **BREAKING** `stubLaravelApiService` no longer emits a `String get bearerToken` getter. The v7 stub overrides `setAuthHeaders(RequestHeaders headers)` and calls `headers.addBearerToken(token)` instead, matching `nylo_support 7.24.x`'s `NyApiService` contract. Consumers regenerating the Laravel slate should remove any hand-written `bearerToken` overrides from their existing `LaravelApiService`.
* Regenerated both Laravel API service stubs for v7's `NyApiService` contract. `stubLaravelApiService` and `stubLaravelAuthApiService` now import decoders from `/bootstrap/decoders.dart` (v6: `/config/decoders.dart`) and generate context-free constructors — the `{BuildContext? buildContext}` parameter and the `super(buildContext, ...)` positional are gone. `stubLaravelAuthApiService` additionally drops the `displayError(DioException, BuildContext)` override and rewrites `forgotPassword` to read v7's `NyResponse` (`response.isSuccessful` / `response.rawData`) instead of the v6 `response.statusCode` / `response.data`.
* Laravel `login`, `register`, and `forgot_password` controller stubs drop the `context: context` argument from their `api<LaravelAuthApiService>(...)` calls — v7's `api()` helper no longer accepts it.
* Normalized generated page state classes from `extends NyState<T>` to `extends NyPage<T>` across login, register, forgot-password, landing, and dashboard stubs (all backends).
* Dashboard stubs (basic, Firebase, Laravel, Supabase) now read the card color via `ThemeColorResolver.get(context).general.background`; v7 replaced the v6 `ThemeColor.get(context).background` accessor.
* Updated stub doc-comment links from `nylo.dev/docs/6.x` to `nylo.dev/docs/7.x`.
* Renamed v6 `boot`/`afterBoot` lifecycle methods to the v7 `setup`/`boot` names in RevenueCat, Firebase, and Supabase provider stubs. Generated provider files now compile cleanly against `nylo_support 7.24.x` and use the correct lifecycle slot for configuration.
* Migrated form stubs from the v6 `NyFormData` + `NyForm` wrapper pattern to the v7 `NyFormWidget` pattern. `LoginForm` and `RegisterForm` now extend `NyFormWidget`, expose `static NyFormActions get actions`, and use the `validator:` field arg. Page stubs (login, register, supabase register, firebase register) now embed `submitButton` and `onSubmit` inside the form widget instead of wrapping it with `NyForm(...)` and a sibling `Button.primary(submitForm: ...)`. Also fixed `login_page_stub.dart` which still emitted the long-removed framework class `NyLoginForm(emailValidationRule: ..., passwordValidationRule: ...)` — it now references the project-local `LoginForm`.
* The forgot-password page stub's email field migrates from `NyTextField` (with `validationRules: "email"`) to v7's `InputField.emailAddress` with `formValidator: FormValidator.email()`.
* Replaced the hand-rolled `RichText` + `TextSpan` + `TapGestureRecognizer` terms/privacy block in the register page stubs (basic, supabase, firebase) with `StyledText.template(...)`. Generated register pages are now ~15 lines shorter, no longer import `package:flutter/gestures.dart`, and use placeholder syntax (`{{terms:terms and conditions}}`, `{{privacy:privacy policy}}`) with `styles`/`onTap` maps instead of manual `TextSpan` children with `recognizer:` cascades.
* The landing page stub's "Already have an account? Login" line migrates from the v6 `NyRichText` widget to `StyledText.template(...)`, consistent with the register-page change above.
* Generated `Button.primary` widgets on the login, register, and forgot-password pages no longer hard-code `color: Colors.black87`, so they inherit the app theme's button color.
* `stdin_service.dart` now imports from `nylo_support/dart_console/ny_dart_console.dart` (v7's renamed re-export) instead of the v6 `dart_console.dart` path.
* `bin/main.dart`, `lib/cli/scaffold_cli.dart`, and `lib/scaffold_ui.dart` now import the consolidated `nylo_support/metro/ny_metro.dart` barrel instead of v6's separate `metro/metro_console.dart`, `metro/metro_service.dart`, `metro/constants/strings.dart`, and `metro/models/ny_template.dart` paths.
* The `auth` command's Laravel setup instructions are rewritten as a numbered checklist — now including the `php artisan install:api` step — and printed in yellow (previously green prose).

### Fixed

* Supabase dashboard stub no longer imports the unused `/app/models/user.dart`. That import pulled the default Nylo `User` model into scope alongside the `User` type re-exported by `supabase_flutter`, making every generated Supabase `dashboard_page.dart` fail to compile with an ambiguous-import error. The `_user` getter only ever returns the Supabase auth user (`supabase.auth.currentUser`), so the app-model import was dead code.

## [1.4.0] - 2026-05-10

### Fixed

* **CLI no longer hangs after a list selection on Windows 11** ([#2](https://github.com/nylo-core/scaffold-ui/issues/2)). After picking a backend, the next text prompt could not be submitted because `dart_console`'s raw-mode reset (in nylo_support's bundled `dart_console`) zeroes the Windows console mode. `ListChooser._resetStdin` now restores the full interactive input mask via FFI on Windows.
* **CLI no longer exits silently after `dart pub add`** ([#3](https://github.com/nylo-core/scaffold-ui/issues/3)). `MetroService.addPackage` wired `stdin.pipe(process.stdin)` to the child, which left the parent's stdin in a consumed state and the next `readLineSync` returning null tore the program down. The CLI now installs packages via a local `_addPackage` helper backed by `Process.start(..., mode: ProcessStartMode.inheritStdio)`, which leaves the parent's stdin untouched.
* `CliDialog` now actually validates each `messages` entry — the previous check fired only if you passed more than two messages total.
* `stubRevenueCatProvider` no longer emits `PurchasesConfiguration("null")` when an app ID is null; the placeholder branch now matches the comment-toggle branch and handles both null and empty string.
* `NyLaravelSlateConfig.url` now strips every trailing slash (`/+$`), not just one, so a URL like `https://api.example.com//` no longer leaks `//app/v1` into the generated stub.

### Added

* New `lib/cli/scaffold_cli.dart` exposing the per-command logic as a testable layer: `SlatePlan`, `parseCommand`, `planAuthSlate`, `planIapSlate`, `iosSetupHintFor`, plus the `supportedAuthBackends` / `supportedIapServices` constants and the prompt strings.
* Comprehensive test suite — 120 tests covering models, slate runners, stubs, the CLI dialog (validation + mock-mode interactions), the list chooser (arrow-key navigation), the XTerm helpers, and the new CLI command planners.

### Changed

* `bin/main.dart` is now a thin runtime wrapper over the new planner functions.
* `addQuestion` doc-comment example fixed — now matches the actual two-positional-arg signature with valid Dart Map literal syntax.
* Renamed three Laravel stub source files for naming consistency (only affects code that imported the files directly via `package:scaffold_ui/stubs/laravel/...`, which is not the documented usage):
  * `lib/stubs/laravel/laravel_auth_api_serivce_stub.dart` → `laravel_auth_api_service_stub.dart`
  * `lib/stubs/laravel/laravel_api_service.dart` → `laravel_api_service_stub.dart`
  * `lib/stubs/laravel/laravel_auth_response.dart` → `laravel_auth_response_stub.dart`

### Chore

* `.gitignore` now covers Flutter-generated artifacts (`.flutter-plugins`, `.flutter-plugins-dependencies`, `example/pubspec.lock`); previously-tracked copies untracked.

## [1.3.1] - 2025-12-13

* Dependency updates

## [1.3.0] - 2025-09-06

* Dependency updates

## [1.2.9] - 2025-07-17

* Dependency updates

## [1.2.8] - 2025-05-23

* Dependency updates

## [1.2.7] - 2025-04-09

* Dependency updates

## [1.2.6] - 2025-03-27

* Dependency updates

## [1.2.5] - 2025-03-21

* Small fix for login_page stub
* Dependency updates

## [1.2.4] - 2025-03-09

* Update Laravel controller stubs
* Dependency updates

## [1.2.3] - 2025-02-27

* Dependency updates

## [1.2.2] - 2025-02-23

* Update stubs as per analysis
* Update GitHub workflows
* Dependency updates

## [1.2.1] - 2025-02-04

* Dependency updates

## [1.2.0] - 2025-02-03

* Ability to scaffold in-app purchases via RevenueCat
* Use `dart run scaffold_ui:main iap` and then select `RevenueCat`
* Added `firebase` to the list of available auth scaffolds
* Dependency updates

## [1.1.14] - 2025-01-26

* Dependency updates

## [1.1.13] - 2024-01-16

* Update Laravel dashboard stub

## [1.1.12] - 2024-01-16

* Dependency updates

## [1.1.11] - 2024-01-14

* Fix Laravel api service stub
* Update `NyLaravelSlateConfig` to remove trailing slash from urls
* Dependency updates

## [1.1.10] - 2024-01-13

* Dependency updates
 
## [1.1.9] - 2024-01-04

* Dependency updates

## [1.1.8] - 2024-12-31

* Update copyright year
* Dependency updates

## [1.1.7] - 2024-12-18

* Dependency updates

## [1.1.6] - 2024-12-16

* Dependency updates

## [1.1.5] - 2024-12-02

* refactor stubs
* Dependency updates

## [1.1.4] - 2024-11-25

* Dependency updates

## [1.1.3] - 2024-11-10

* Dependency updates

## [1.1.2] - 2024-11-06

* Fix GitHub actions

## [1.1.1] - 2024-11-06

* Update GitHub actions
* Update Readme

## [1.1.0] - 2024-11-05

* Update stubs

## [1.0.0] - 2024-11-02

* Initial release.
