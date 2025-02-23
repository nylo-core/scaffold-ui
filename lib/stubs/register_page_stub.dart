String stubRegisterPage() => '''
import 'package:flutter/gestures.dart';
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

class _RegisterPageState extends NyState<RegisterPage> {

  RegisterForm form = RegisterForm();

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
            NyForm(form: form, crossAxisSpacing: 15),

            Spacing.vertical(15),
            
            Button.primary(text: "Register", submitForm: (form, (data) async {
              await widget.controller.register(data['name'], data['email'], data['password']);
            }), color: Colors.black87),

            Spacing.vertical(15),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'By tapping "Register", you agree to our ',
                  ),
                  TextSpan(
                    text: 'terms and conditions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(termsUrl()),
                  ),
                  TextSpan(text: '. You can also view our '),
                  TextSpan(
                    text: 'privacy policy',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => launchUrl(privacyUrl()),
                  ),
                  TextSpan(text: ' here.'),
                ],
              ),
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
