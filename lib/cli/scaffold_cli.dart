import 'package:nylo_support/metro/ny_metro.dart';

import '/models/ny_laravel_slate_config.dart';
import '/models/ny_revenuecat_slate_config.dart';
import '/models/ny_superwall_slate_config.dart';
import '/models/ny_supabase_slate_config.dart';
import '/scaffold_ui.dart';

/// Callback used by the planners to read a single line of user input. The
/// runtime wires this to a `CliDialog` text question; tests substitute a
/// canned-answer recorder.
typedef Prompt = String Function(String question);

/// The output of a planner: a deterministic description of what the CLI
/// intends to do for the chosen backend/service.
///
/// `auth()` / `iap()` execute the plan by:
///  1. running `dart pub add` for each entry in [packagesToAdd];
///  2. handing [templates] to `MetroService.createSlate`;
///  3. (optionally) reading [config] to template the post-success message.
///
/// Tests assert against this value object instead of running the side effects.
class SlatePlan {
  final List<String> packagesToAdd;
  final List<NyTemplate> templates;

  /// The backend/service-specific slate config that produced [templates]. Let
  /// the runtime template the success message (e.g. "iOS setup needed?")
  /// without re-prompting. `null` for choices that take no input — Basic and
  /// Firebase.
  final Object? config;

  const SlatePlan({
    required this.packagesToAdd,
    required this.templates,
    this.config,
  });
}

/// Backend choices presented to the user for `dart run scaffold_ui:main auth`.
const List<String> supportedAuthBackends = [
  'Supabase',
  'Laravel',
  'Firebase',
  'Basic',
];

/// Service choices presented to the user for `dart run scaffold_ui:main iap`.
const List<String> supportedIapServices = ['RevenueCat', 'Superwall'];

// The exact prompt strings shown to the user. Centralised here so the planners
// and the tests reference the same constants.
const String supabaseUrlPrompt = 'What is your Supabase Url?';
const String supabaseAnonKeyPrompt = 'What is your Supabase Anon Key?';
const String laravelUrlPrompt = 'What is your Laravel Url?';
const String appleRevenueCatKeyPrompt =
    "What is your Apple RevenueCat API Key? If you don't know, enter 'n'";
const String androidRevenueCatKeyPrompt =
    "What is your Android RevenueCat API Key? If you don't know, enter 'n'";
const String appleSuperwallKeyPrompt =
    "What is your Apple Superwall API Key? If you don't know, enter 'n'";
const String androidSuperwallKeyPrompt =
    "What is your Android Superwall API Key? If you don't know, enter 'n'";

/// Validates the CLI invocation and returns the parsed command name (`auth`
/// or `iap`). Returns `null` for any other shape — the caller is responsible
/// for printing a usage hint and exiting with a non-zero status code.
String? parseCommand(List<String> args) {
  if (args.length != 1) return null;
  final cmd = args[0];
  if (cmd != 'auth' && cmd != 'iap') return null;
  return cmd;
}

/// Builds the slate plan for an `auth` invocation. Pure: the only side effect
/// is calling [prompt] (which the runtime backs with `CliDialog.ask()`).
///
/// Returns `null` for an unsupported backend so the runtime can fall through
/// to its default branch.
SlatePlan? planAuthSlate({required String backend, required Prompt prompt}) {
  switch (backend) {
    case 'Supabase':
      final url = prompt(supabaseUrlPrompt);
      final anonKey = prompt(supabaseAnonKeyPrompt);
      final config = NySupabaseSlateConfig(url: url, anonKey: anonKey);
      return SlatePlan(
        packagesToAdd: const ['supabase_flutter'],
        templates: supabaseRun(config),
        config: config,
      );
    case 'Laravel':
      // Trailing-slash trimming is handled by `NyLaravelSlateConfig.url`.
      final config = NyLaravelSlateConfig(url: prompt(laravelUrlPrompt));
      return SlatePlan(
        packagesToAdd: const [],
        templates: laravelRun(config),
        config: config,
      );
    case 'Firebase':
      return SlatePlan(
        packagesToAdd: const [
          'firebase_core',
          'firebase_auth',
          'cloud_firestore',
        ],
        templates: firebaseRun(),
      );
    case 'Basic':
      return SlatePlan(packagesToAdd: const [], templates: basicRun());
    default:
      return null;
  }
}

/// Builds the slate plan for an `iap` invocation. Mirrors [planAuthSlate] in
/// shape; for RevenueCat and Superwall the user can type `n` to skip a
/// platform key, which is normalised to the empty string (the stub treats
/// `''` as "leave the configure line commented out with placeholder text").
SlatePlan? planIapSlate({required String service, required Prompt prompt}) {
  switch (service) {
    case 'RevenueCat':
      var apple = prompt(appleRevenueCatKeyPrompt);
      if (apple == 'n') apple = '';
      var android = prompt(androidRevenueCatKeyPrompt);
      if (android == 'n') android = '';
      final config = NyRevenueCatSlateConfig(
        appleAppId: apple,
        androidAppId: android,
      );
      return SlatePlan(
        packagesToAdd: const ['purchases_flutter', 'purchases_ui_flutter'],
        templates: revenueCatRun(config),
        config: config,
      );
    case 'Superwall':
      var apple = prompt(appleSuperwallKeyPrompt);
      if (apple == 'n') apple = '';
      var android = prompt(androidSuperwallKeyPrompt);
      if (android == 'n') android = '';
      final config = NySuperwallSlateConfig(
        appleApiKey: apple,
        androidApiKey: android,
      );
      return SlatePlan(
        packagesToAdd: const ['superwallkit_flutter'],
        templates: superwallRun(config),
        config: config,
      );
    default:
      return null;
  }
}

/// The post-install hint printed at the end of a RevenueCat run. Returns the
/// empty string when no Apple key was provided (the user picked `n`), so the
/// hint is silently omitted for Android-only setups. Pulled out of `iap()`
/// so the conditional is testable.
String iosSetupHintFor({required bool appleKeyProvided}) {
  if (!appleKeyProvided) return '';
  return 'IOS Setup'
      '\n- Open the `ios/Runner.xcworkspace` file in Xcode'
      '\n- Navigate to the `Runner` target'
      '\n- Under the `Signing & Capabilities` tab, add the `In-App Purchase` capability'
      '\n- Run "cd ios && pod repo update"'
      '\n\n';
}

/// Superwall-specific iOS hint. Mirrors [iosSetupHintFor] but adds the
/// iOS 14.0+ deployment-target requirement (Superwall's documented minimum).
/// Empty when no Apple key was provided so Android-only projects don't see
/// noisy iOS guidance.
String superwallIosSetupHintFor({required bool appleKeyProvided}) {
  if (!appleKeyProvided) return '';
  return 'IOS Setup'
      '\n- Ensure your iOS deployment target is 14.0 or higher (set `platform :ios, \'14.0\'` in `ios/Podfile`)'
      '\n- Open the `ios/Runner.xcworkspace` file in Xcode'
      '\n- Navigate to the `Runner` target'
      '\n- Under the `Signing & Capabilities` tab, add the `In-App Purchase` capability'
      '\n- Run "cd ios && pod repo update"'
      '\n\n';
}

/// Superwall-specific Android hint. The runtime auto-injects the
/// `SuperwallPaywallActivity` per Superwall's install docs, so the only thing
/// the consumer must do manually is raise `minSdkVersion` to 26 — Flutter's
/// historical default of 21 fails the build.
///
/// Empty when no Android key was provided so iOS-only projects don't see
/// noisy Android guidance.
String superwallAndroidSetupHintFor({required bool androidKeyProvided}) {
  if (!androidKeyProvided) return '';
  return 'Android Setup'
      '\n- Set `minSdkVersion 26` (or higher) in `android/app/build.gradle` — Superwall requires it'
      '\n\n';
}

/// The `<activity>` element Superwall's install docs ask developers to
/// register inside `<application>` in
/// `android/app/src/main/AndroidManifest.xml`. The plugin's bundled manifest
/// declares it too, but with `Theme.AppCompat.NoActionBar`; injecting this
/// here lets the consumer's app override that with the docs-recommended
/// `Theme.MaterialComponents.DayNight.NoActionBar` (main-app manifest wins on
/// attribute conflicts via Gradle manifest-merger priority).
const String superwallAndroidActivityXml =
    '<activity\n'
    '            android:name="com.superwall.sdk.paywall.view.SuperwallPaywallActivity"\n'
    '            android:theme="@style/Theme.MaterialComponents.DayNight.NoActionBar"\n'
    '            android:configChanges="orientation|screenSize|keyboardHidden" />';

/// Outcome of trying to inject the Superwall activity into a manifest.
enum AndroidManifestPatchResult {
  /// Activity was inserted; [PatchedManifest.content] is the new XML.
  added,

  /// Activity is already present; the manifest was left untouched.
  alreadyRegistered,

  /// The manifest didn't have an `<application>` opening tag we could find,
  /// so we left it untouched and the caller should print a manual hint.
  malformedManifest,
}

/// The result of [patchAndroidManifestForSuperwall]: the (possibly unchanged)
/// XML and a tag describing what happened, so the runtime can decide whether
/// to write the file back and what to print to the user.
class PatchedManifest {
  final String content;
  final AndroidManifestPatchResult result;
  const PatchedManifest(this.content, this.result);
}

/// Idempotently inserts [superwallAndroidActivityXml] just after the opening
/// `<application ...>` tag in [manifestContent]. Pure — does no IO so it can
/// be unit-tested against canned manifest strings.
PatchedManifest patchAndroidManifestForSuperwall(String manifestContent) {
  // Idempotency: any existing reference to the SuperwallPaywallActivity means
  // we've already patched (or the developer pasted it manually). Bail.
  if (manifestContent.contains('SuperwallPaywallActivity')) {
    return PatchedManifest(
      manifestContent,
      AndroidManifestPatchResult.alreadyRegistered,
    );
  }

  final appTagStart = manifestContent.indexOf('<application');
  if (appTagStart == -1) {
    return PatchedManifest(
      manifestContent,
      AndroidManifestPatchResult.malformedManifest,
    );
  }
  // Find the closing `>` of the `<application ...>` opening tag. A real
  // Flutter manifest always has children inside it, so we don't special-case
  // a self-closing `<application .../>`.
  final appTagEnd = manifestContent.indexOf('>', appTagStart);
  if (appTagEnd == -1) {
    return PatchedManifest(
      manifestContent,
      AndroidManifestPatchResult.malformedManifest,
    );
  }

  final insertion = '\n        $superwallAndroidActivityXml';
  final patched =
      manifestContent.substring(0, appTagEnd + 1) +
      insertion +
      manifestContent.substring(appTagEnd + 1);

  return PatchedManifest(patched, AndroidManifestPatchResult.added);
}
