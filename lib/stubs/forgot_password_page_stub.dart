String stubForgotPasswordPage() => '''
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/resources/widgets/buttons/buttons.dart';
import '/resources/widgets/logo_widget.dart';
import '/app/controllers/forgot_password_controller.dart';

class ForgotPasswordPage extends NyStatefulWidget<ForgotPasswordController> {
  static RouteView path = ("/forgot-password", (_) => ForgotPasswordPage());

  ForgotPasswordPage({super.key}) : super(child: () => _ForgotPasswordPageState());
}

class _ForgotPasswordPageState extends NyPage<ForgotPasswordPage> {

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Logo(height: 40),
      ),
      body: SafeArea(
        minimum: EdgeInsets.all(16),
        child: SizedBox(
          height: double.infinity,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text("Forgot Your Password?".tr()).headingSmall().fontWeightBold().paddingOnly(bottom: 25),
              Text("Enter your email address below and we'll send you a link to reset your password.".tr()).paddingOnly(bottom: 15),
              Divider(),
              Column(children: [
                InputField.emailAddress(
                  controller: widget.controller.textEmailForgotPassword,
                  labelText: "Email",
                  autoFocus: true,
                  formValidator: FormValidator.email(),
                  validateOnFocusChange: true,
                ),

                Spacing.vertical(15),

                Button.primary(text: "Forgot Password".tr(), onPressed: widget.controller.forgotPassword),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
''';
