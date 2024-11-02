String stubRegisterPage() => '''
import '/resources/widgets/buttons/buttons.dart';

import '/app/controllers/register_controller.dart';
import 'package:flutter/gestures.dart';
import '/app/forms/register_form.dart';
import 'package:url_launcher/url_launcher.dart';
import '/resources/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class RegisterPage extends NyStatefulWidget<RegisterController> {
  
  static RouteView path = ("/register", (_) => RegisterPage());

  RegisterPage() : super(child: () => _RegisterPageState());
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
              text: new TextSpan(
                style: new TextStyle(
                  fontSize: 14.0,
                  color: Colors.black54,
                ),
                children: <TextSpan>[
                  new TextSpan(
                    text: 'By tapping "Register", you agree to our ',
                  ),
                  new TextSpan(
                    text: 'terms and conditions',
                    style: new TextStyle(fontWeight: FontWeight.bold),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () => launchUrl(termsUrl()),
                  ),
                  new TextSpan(text: '. You can also view our '),
                  new TextSpan(
                    text: 'privacy policy',
                    style: new TextStyle(fontWeight: FontWeight.bold),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () => launchUrl(privacyUrl()),
                  ),
                  new TextSpan(text: ' here.'),
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
