import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_ui/cli_dialog/cli_dialog.dart';
import 'package:scaffold_ui/cli_dialog/src/xterm.dart';

CliDialog _mockDialog({
  List? questions,
  List? listQuestions,
  List? booleanQuestions,
  List<dynamic>? buffer,
  bool trueByDefault = false,
}) {
  final out = StdoutService(mock: true);
  final input = StdinService(mock: true, informStdout: out, isTest: true);
  if (buffer != null) input.addToBuffer(buffer);
  return CliDialog.std(
    input,
    out,
    questions: questions,
    listQuestions: listQuestions,
    booleanQuestions: booleanQuestions,
    trueByDefault: trueByDefault,
  );
}

void main() {
  group('CliDialog validation', () {
    test('throws on duplicate keys across question types', () {
      expect(
        () => CliDialog(
          questions: [
            ['What is your name?', 'name'],
          ],
          booleanQuestions: [
            ['Are you sure?', 'name'], // same key as above
          ],
        ),
        throwsArgumentError,
      );
    });

    test('throws when a question is not a 2-element list', () {
      expect(
        () => CliDialog(
          questions: [
            ['only one element'],
          ],
        ),
        throwsArgumentError,
      );
    });

    test('throws when a question or key is not a String', () {
      expect(
        () => CliDialog(
          questions: [
            [123, 'key'],
          ],
        ),
        throwsArgumentError,
      );
      expect(
        () => CliDialog(
          questions: [
            ['ok', 999],
          ],
        ),
        throwsArgumentError,
      );
    });

    test('throws when a list question options is not List<String>', () {
      expect(
        () => CliDialog(
          listQuestions: [
            [
              {
                'question': 'pick one',
                'options': [1, 2, 3],
              },
              'pick',
            ],
          ],
        ),
        throwsArgumentError,
      );
    });

    test('throws when a list question question is missing or non-string', () {
      expect(
        () => CliDialog(
          listQuestions: [
            [
              {
                'question': 99,
                'options': ['a'],
              },
              'pick',
            ],
          ],
        ),
        throwsArgumentError,
      );
    });

    test('addQuestion rejects more than one type flag', () {
      final dialog = CliDialog();
      expect(
        () =>
            dialog.addQuestion(['q', 'k'], 'k', isBoolean: true, isList: true),
        throwsArgumentError,
      );
    });

    test('throws when a message has more than 2 elements', () {
      expect(
        () => CliDialog(
          messages: [
            ['banner', 'key', 'unexpected-extra'],
          ],
        ),
        throwsArgumentError,
      );
    });

    test('throws when a message list has non-string entries', () {
      expect(
        () => CliDialog(
          messages: [
            [123, 'key'],
          ],
        ),
        throwsArgumentError,
      );
    });

    test('accepts plain-string messages and [string, key] pairs', () {
      expect(
        () => CliDialog(
          messages: [
            'just a banner',
            ['banner with key', 'banner_key'],
          ],
        ),
        returnsNormally,
      );
    });

    test('accepts a well-formed mix of question types', () {
      expect(
        () => CliDialog(
          questions: [
            ['What is your name?', 'name'],
          ],
          booleanQuestions: [
            ['Continue?', 'cont'],
          ],
          listQuestions: [
            [
              {
                'question': 'pick one',
                'options': ['a', 'b'],
              },
              'pick',
            ],
          ],
        ),
        returnsNormally,
      );
    });
  });

  group('CliDialog text input (mock mode)', () {
    test('captures a single text answer from the mock buffer', () {
      final dialog = _mockDialog(
        questions: [
          ['What is your Supabase URL?', 'supabase_url'],
        ],
        buffer: ['https://abc.supabase.co'],
      );
      final answers = dialog.ask();
      expect(answers['supabase_url'], 'https://abc.supabase.co');
    });

    test('captures multiple text answers in declared order', () {
      final dialog = _mockDialog(
        questions: [
          ['What is your Supabase URL?', 'supabase_url'],
          ['What is your Supabase Anon Key?', 'supabase_anon_key'],
        ],
        buffer: ['https://abc.supabase.co', 'eyJanon'],
      );
      final answers = dialog.ask();
      expect(answers['supabase_url'], 'https://abc.supabase.co');
      expect(answers['supabase_anon_key'], 'eyJanon');
    });

    test('trims whitespace around the typed answer', () {
      final dialog = _mockDialog(
        questions: [
          ['url?', 'url'],
        ],
        buffer: ['   spaced.example.com   '],
      );
      expect(dialog.ask()['url'], 'spaced.example.com');
    });
  });

  group('CliDialog boolean input (mock mode)', () {
    test('y -> true, regardless of default', () {
      final dialog = _mockDialog(
        booleanQuestions: [
          ['Continue?', 'cont'],
        ],
        buffer: ['y'],
      );
      expect(dialog.ask()['cont'], isTrue);
    });

    test('n -> false', () {
      final dialog = _mockDialog(
        booleanQuestions: [
          ['Continue?', 'cont'],
        ],
        buffer: ['n'],
      );
      expect(dialog.ask()['cont'], isFalse);
    });

    test('empty answer falls back to trueByDefault=true', () {
      final dialog = _mockDialog(
        booleanQuestions: [
          ['Continue?', 'cont'],
        ],
        buffer: [''],
        trueByDefault: true,
      );
      expect(dialog.ask()['cont'], isTrue);
    });

    test('empty answer falls back to trueByDefault=false', () {
      final dialog = _mockDialog(
        booleanQuestions: [
          ['Continue?', 'cont'],
        ],
        buffer: [''],
        trueByDefault: false,
      );
      expect(dialog.ask()['cont'], isFalse);
    });
  });

  group('CliDialog list selection (mock mode)', () {
    test('Enter at the top picks the first option', () {
      final dialog = _mockDialog(
        listQuestions: [
          [
            {
              'question': 'Which backend?',
              'options': ['Supabase', 'Laravel', 'Firebase', 'Basic'],
            },
            'backend',
          ],
        ],
        buffer: [Keys.enter],
      );
      expect(dialog.ask()['backend'], 'Supabase');
    });

    test('arrowDown then Enter picks the second option', () {
      final dialog = _mockDialog(
        listQuestions: [
          [
            {
              'question': 'Which backend?',
              'options': ['Supabase', 'Laravel', 'Firebase', 'Basic'],
            },
            'backend',
          ],
        ],
        // ...spread the platform-correct byte sequence for arrowDown,
        // then enter.
        buffer: [...Keys.arrowDown, Keys.enter],
      );
      expect(dialog.ask()['backend'], 'Laravel');
    });

    test('arrowDown past the last option clamps to the last option', () {
      final dialog = _mockDialog(
        listQuestions: [
          [
            {
              'question': 'Pick',
              'options': ['a', 'b'],
            },
            'pick',
          ],
        ],
        buffer: [
          ...Keys.arrowDown,
          ...Keys.arrowDown,
          ...Keys.arrowDown,
          Keys.enter,
        ],
      );
      expect(dialog.ask()['pick'], 'b');
    });

    test('arrowUp at the top clamps to the first option', () {
      final dialog = _mockDialog(
        listQuestions: [
          [
            {
              'question': 'Pick',
              'options': ['a', 'b'],
            },
            'pick',
          ],
        ],
        buffer: [...Keys.arrowUp, ...Keys.arrowUp, Keys.enter],
      );
      expect(dialog.ask()['pick'], 'a');
    });

    test('down then up returns to the first option', () {
      final dialog = _mockDialog(
        listQuestions: [
          [
            {
              'question': 'Pick',
              'options': ['a', 'b', 'c'],
            },
            'pick',
          ],
        ],
        buffer: [...Keys.arrowDown, ...Keys.arrowUp, Keys.enter],
      );
      expect(dialog.ask()['pick'], 'a');
    });
  });
}
