String stubLoginPage() => '''
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/pages/forgot_password_page.dart';
import '/app/controllers/login_controller.dart';
import '/app/forms/login_form.dart';
import '/resources/widgets/logo_widget.dart';
import '/resources/widgets/buttons/buttons.dart';

class LoginPage extends NyStatefulWidget<LoginController> {
  static RouteView path = ("/login", (_) => LoginPage());

  LoginPage({super.key}) : super(child: () => _LoginPageState());
}

class _LoginPageState extends NyPage<LoginPage> {

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
            Text("Login".tr()).headingSmall().fontWeightBold().paddingOnly(bottom: 25),
            LoginForm(
              submitButton: Button.primary(text: "Login"),
              onSubmit: (data) async {
                await widget.controller.login(data['email'], data['password']);
              },
            ),

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
