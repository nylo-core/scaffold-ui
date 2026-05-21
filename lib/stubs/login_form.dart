String stubLoginForm() => '''
import 'package:nylo_framework/nylo_framework.dart';

/* Login Form
|--------------------------------------------------------------------------
| Usage: https://nylo.dev/docs/7.x/forms#how-it-works
| Casts: https://nylo.dev/docs/7.x/forms#form-casts
| Validation Rules: https://nylo.dev/docs/7.x/validation#validation-rules
|-------------------------------------------------------------------------- */

class LoginForm extends NyFormWidget {
  LoginForm({super.key, super.submitButton, super.onSubmit, super.onFailure});

  @override
  fields() => [
    Field.email("Email",
        autofocus: true,
        validator: FormValidator.email(),
    ),
    Field.password("Password",
        validator: FormValidator.password(strength: 1),
    ),
  ];

  static NyFormActions get actions => const NyFormActions('LoginForm');
}
''';
