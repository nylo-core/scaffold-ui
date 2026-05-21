String stubRegisterForm() => '''
import 'package:nylo_framework/nylo_framework.dart';

/* Register Form
|--------------------------------------------------------------------------
| Usage: https://nylo.dev/docs/7.x/forms#how-it-works
| Casts: https://nylo.dev/docs/7.x/forms#form-casts
| Validation Rules: https://nylo.dev/docs/7.x/validation#validation-rules
|-------------------------------------------------------------------------- */

class RegisterForm extends NyFormWidget {
  RegisterForm({super.key, super.submitButton, super.onSubmit, super.onFailure});

  @override
  fields() => [
     Field.capitalizeWords("Name",
        autofocus: true,
         validator: FormValidator.notEmpty(),
    ),
    Field.email("Email",
        validator: FormValidator.email(),
    ),
    Field.password("Password",
        validator: FormValidator.password(strength: 1),
    ),
  ];

  static NyFormActions get actions => const NyFormActions('RegisterForm');
}
''';
