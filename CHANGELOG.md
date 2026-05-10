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
