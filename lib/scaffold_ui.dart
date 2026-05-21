// ignore: unnecessary_library_name
library scaffold_ui;

import '/models/ny_revenuecat_slate_config.dart';
import '/stubs/iap/revenuecat/paywall_page_stub.dart';
import '/stubs/iap/revenuecat/revenue_cat_provider_stub.dart';

import '/models/ny_superwall_slate_config.dart';
import '/stubs/iap/superwall/superwall_paywall_page_stub.dart';
import '/stubs/iap/superwall/superwall_provider_stub.dart';

/// Basic
import '/stubs/basic/basic_forgot_password_controller_stub.dart';
import '/stubs/basic/basic_login_controller_stub.dart';
import '/stubs/basic/basic_register_controller_stub.dart';
import '/stubs/basic/basic_dashboard_stub.dart';

/// Supabase
import '/models/ny_supabase_slate_config.dart';
import '/stubs/supabase/supabase_register_page_stub.dart';
import '/stubs/supabase/supabase_dashboard_stub.dart';
import '/stubs/supabase/supabase_forgot_password_controller_stub.dart';
import '/stubs/supabase/supabase_login_controller_stub.dart';
import '/stubs/supabase/supabase_provider_stub.dart';
import '/stubs/supabase/supabase_register_controller_stub.dart';
import '/stubs/supabase/supabase_logout_event_stub.dart';

/// Firebase
import '/stubs/firebase/firebase_register_page_stub.dart';
import '/stubs/firebase/firebase_dashboard_stub.dart';
import '/stubs/firebase/firebase_forgot_password_controller_stub.dart';
import '/stubs/firebase/firebase_login_controller_stub.dart';
import '/stubs/firebase/firebase_provider_stub.dart';
import '/stubs/firebase/firebase_register_controller_stub.dart';
import '/stubs/firebase/firebase_logout_event_stub.dart';
import '/stubs/firebase/firebase_user_model_stub.dart';

/// Laravel
import '/stubs/laravel/laravel_register_controller_stub.dart';
import '/stubs/laravel/laravel_login_controller_stub.dart';
import '/stubs/laravel/laravel_dashboard_stub.dart';
import '/models/ny_laravel_slate_config.dart';
import '/stubs/laravel/laravel_auth_response_stub.dart';
import '/stubs/laravel/laravel_api_service_stub.dart';
import '/stubs/laravel/laravel_auth_event_stub.dart';
import '/stubs/laravel/laravel_auth_api_service_stub.dart';
import 'stubs/laravel/laravel_forgot_password_controller_stub.dart';

/// default
import '/stubs/login_form.dart';
import '/stubs/register_form.dart';
import '/stubs/landing_stub.dart';
import 'stubs/laravel/laravel_user_model_stub.dart';
import '/stubs/register_page_stub.dart';
import '/stubs/forgot_password_page_stub.dart';
import '/stubs/login_page_stub.dart';

import 'package:nylo_support/metro/ny_metro.dart';

/* Publish template files
|--------------------------------------------------------------------------
| Add your stub templates inside the /stubs directory.
| Then add them into the `run` method like in the example below.
| Install the package in your project and run the below in the terminal.
| "dart run scaffold_ui:main auth"
|
| Learn more https://nylo.dev/docs/7.x
|-------------------------------------------------------------------------- */

/// In-App Purchases

/// RevenueCat Slate
List<NyTemplate> revenueCatRun(
  NyRevenueCatSlateConfig nyRevenueCatSlateConfig,
) => [
  /// PAGES
  NyTemplate(
    name: "paywall_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework", "purchases_ui_flutter"],
    stub: stubRevenueCatPaywall(),
  ),

  /// CONFIG
  NyTemplate(
    name: "revenue_cat_provider",
    saveTo: providerFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubRevenueCatProvider(nyRevenueCatSlateConfig),
  ),
];

/// Superwall Slate
List<NyTemplate> superwallRun(NySuperwallSlateConfig nySuperwallSlateConfig) =>
    [
      /// PAGES
      NyTemplate(
        name: "paywall_page",
        saveTo: pagesFolder,
        pluginsRequired: ["nylo_framework", "superwallkit_flutter"],
        stub: stubSuperwallPaywall(),
      ),

      /// CONFIG
      NyTemplate(
        name: "superwall_provider",
        saveTo: providerFolder,
        pluginsRequired: ["nylo_framework", "superwallkit_flutter"],
        stub: stubSuperwallProvider(nySuperwallSlateConfig),
      ),
    ];

/// Basic Authentication Slate
List<NyTemplate> basicRun() => [
  /// PAGES
  NyTemplate(
    name: "landing_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLandingPage(),
  ),

  NyTemplate(
    name: "login_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLoginPage(),
  ),

  NyTemplate(
    name: "register_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubRegisterPage(),
  ),

  NyTemplate(
    name: "forgot_password_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubForgotPasswordPage(),
  ),

  NyTemplate(
    name: "dashboard_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubBasicDashboard(),
    options: {"is_auth_page": true},
  ),

  /// CONTROLLERS
  NyTemplate(
    name: "login_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubBasicLoginController(),
  ),

  NyTemplate(
    name: "register_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubBasicRegisterController(),
  ),

  NyTemplate(
    name: "forgot_password_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubBasicForgotPasswordController(),
  ),

  /// FORMS
  NyTemplate(
    name: "register_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubRegisterForm(),
  ),

  NyTemplate(
    name: "login_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubLoginForm(),
  ),
];

/// Laravel Authentication Slate
List<NyTemplate> laravelRun(NyLaravelSlateConfig nyLaravelSlateConfig) => [
  /// MODELS
  NyTemplate(
    name: "user",
    saveTo: modelsFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelUserModel(),
  ),

  NyTemplate(
    name: "laravel_auth_response",
    saveTo: modelsFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelAuthResponseModel(),
  ),

  /// PAGES
  NyTemplate(
    name: "landing_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLandingPage(),
  ),

  NyTemplate(
    name: "login_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLoginPage(),
  ),

  NyTemplate(
    name: "register_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubRegisterPage(),
  ),

  NyTemplate(
    name: "forgot_password_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubForgotPasswordPage(),
  ),

  NyTemplate(
    name: "dashboard_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelDashboard(),
    options: {"is_auth_page": true},
  ),

  /// CONTROLLERS
  NyTemplate(
    name: "login_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelLoginController(),
  ),

  NyTemplate(
    name: "register_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelRegisterController(),
  ),

  NyTemplate(
    name: "forgot_password_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelForgotPasswordController(),
  ),

  /// API SERVICES
  NyTemplate(
    name: "laravel_auth_api_service",
    saveTo: networkingFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelAuthApiService(nyLaravelSlateConfig),
  ),

  NyTemplate(
    name: "laravel_api_service",
    saveTo: networkingFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelApiService(nyLaravelSlateConfig),
  ),

  /// EVENTS
  NyTemplate(
    name: "laravel_auth_event",
    saveTo: eventsFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLaravelAuthEvent(),
  ),

  /// FORMS
  NyTemplate(
    name: "register_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubRegisterForm(),
  ),

  NyTemplate(
    name: "login_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubLoginForm(),
  ),
];

/// Supabase Authentication Slate
List<NyTemplate> supabaseRun(NySupabaseSlateConfig nySupabaseSlateConfig) => [
  /// PAGES
  NyTemplate(
    name: "landing_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLandingPage(),
  ),

  NyTemplate(
    name: "login_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLoginPage(),
  ),

  NyTemplate(
    name: "register_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubSupabaseRegister(),
  ),

  NyTemplate(
    name: "forgot_password_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubForgotPasswordPage(),
  ),

  NyTemplate(
    name: "dashboard_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubSupabaseDashboard(),
    options: {"is_auth_page": true},
  ),

  /// CONTROLLERS
  NyTemplate(
    name: "login_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubSupabaseLoginController(),
  ),

  NyTemplate(
    name: "register_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubSupabaseRegisterController(),
  ),

  NyTemplate(
    name: "forgot_password_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubSupabaseForgotPasswordController(),
  ),

  /// PROVIDERS
  NyTemplate(
    name: "supabase_provider",
    saveTo: providerFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubSupabaseProvider(nySupabaseSlateConfig),
  ),

  /// FORMS
  NyTemplate(
    name: "register_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubRegisterForm(),
  ),

  NyTemplate(
    name: "login_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubLoginForm(),
  ),

  /// EVENTS
  NyTemplate(
    name: "logout_event",
    saveTo: eventsFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubSupabaseLogoutEvent(),
  ),
];

/// Firebase Authentication Slate
List<NyTemplate> firebaseRun() => [
  /// PAGES
  NyTemplate(
    name: "landing_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLandingPage(),
  ),

  NyTemplate(
    name: "login_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubLoginPage(),
  ),

  NyTemplate(
    name: "register_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseRegister(),
  ),

  NyTemplate(
    name: "forgot_password_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubForgotPasswordPage(),
  ),

  NyTemplate(
    name: "dashboard_page",
    saveTo: pagesFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseDashboard(),
    options: {"is_auth_page": true},
  ),

  /// CONTROLLERS
  NyTemplate(
    name: "login_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseLoginController(),
  ),

  NyTemplate(
    name: "register_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseRegisterController(),
  ),

  NyTemplate(
    name: "forgot_password_controller",
    saveTo: controllersFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseForgotPasswordController(),
  ),

  /// PROVIDERS
  NyTemplate(
    name: "firebase_provider",
    saveTo: providerFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseProvider(),
  ),

  /// FORMS
  NyTemplate(
    name: "register_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubRegisterForm(),
  ),

  NyTemplate(
    name: "login_form",
    saveTo: formsFolder,
    pluginsRequired: [],
    stub: stubLoginForm(),
  ),

  /// EVENTS
  NyTemplate(
    name: "logout_event",
    saveTo: eventsFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseLogoutEvent(),
  ),

  /// MODELS
  NyTemplate(
    name: "user",
    saveTo: modelsFolder,
    pluginsRequired: ["nylo_framework"],
    stub: stubFirebaseUserModel(),
  ),
];
