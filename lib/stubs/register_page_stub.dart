String stubRegisterPage() => '''
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/app/controllers/register_controller.dart';
import '/app/forms/register_form.dart';
import '/resources/widgets/logo_widget.dart';

class RegisterPage extends NyStatefulWidget<RegisterController> {
  static RouteView path = ("/register", (_) => RegisterPage());

  RegisterPage({super.key}) : super(child: () => _RegisterPageState());
}

class _RegisterPageState extends NyPage<RegisterPage> {

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
        title: Logo(height: 40),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(16),
        child: ListView(
          children: [
            Text("Register".tr()).headingSmall(fontWeight: FontWeight.bold).paddingOnly(bottom: 25),
            RegisterForm(
              submitButton: Button.primary(text: "Register"),
              onSubmit: (data) async {
                await widget.controller.register(data['name'], data['email'], data['password']);
              },
            ),

            Spacing.vertical(15),

            StyledText.template(
              'By tapping "Register", you agree to our {{terms:terms and conditions}}. You can also view our {{privacy:privacy policy}} here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.0, color: Colors.black54),
              styles: {
                'terms|privacy': TextStyle(fontWeight: FontWeight.bold),
              },
              onTap: {
                'terms': () => launchUrl(termsUrl()),
                'privacy': () => launchUrl(privacyUrl()),
              },
            ),
          ],
        ),
      ),
    );
  }

  // Your privacy policy URL
  Uri privacyUrl() => Uri.parse("\${getEnv('APP_URL')}/privacy-policy");

  // Your terms and conditions URL
  Uri termsUrl() => Uri.parse("\${getEnv('APP_URL')}/terms-and-conditions");
}
''';
