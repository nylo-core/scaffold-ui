String stubLoginPage() => '''
import '/resources/pages/forgot_password_page.dart';
import '/resources/widgets/buttons/buttons.dart';

import '/app/controllers/login_controller.dart';
import '/resources/widgets/logo_widget.dart';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class LoginPage extends NyStatefulWidget<LoginController> {
 
  static RouteView path = ("/login", (_) => LoginPage());

  LoginPage() : super(child: () => _LoginPageState()); 
}

class _LoginPageState extends NyState<LoginPage> {

  NyLoginForm form = NyLoginForm();

  @override
  Widget build(BuildContext context) {
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
            Text("Login".tr()).headingSmall().fontWeightBold().paddingOnly(bottom: 25),
            NyForm(form: form, crossAxisSpacing: 15),

            Spacing.vertical(15),

            Button.primary(text: "Login", submitForm: (form, (data) async {
              await widget.controller.login(data['email'], data['password']);
            }), color: Colors.black87),

            Spacing.vertical(15),

            Text("Forgot your password?".tr(), textAlign: TextAlign.center)
                .onTap(() => routeTo(ForgotPasswordPage.path))
          ],
        ),
      ),
    );
  }
}
''';
