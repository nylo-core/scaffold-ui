import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_ui/cli_dialog/cli_dialog.dart';
import 'package:scaffold_ui/cli_dialog/src/xterm.dart';

ListChooser _chooser(List<String> items, List<dynamic> buffer) {
  final out = StdoutService(mock: true);
  final input = StdinService(mock: true, informStdout: out, isTest: true);
  input.addToBuffer(buffer);
  return ListChooser.std(input, out, items);
}

void main() {
  group('ListChooser.choose', () {
    test('rejects null items at construction', () {
      final out = StdoutService(mock: true);
      final input = StdinService(mock: true, informStdout: out, isTest: true);
      expect(
        () => ListChooser.std(input, out, null),
        throwsArgumentError,
      );
    });

    test('Enter at the top picks the first item', () {
      final chooser = _chooser(
        ['Supabase', 'Laravel', 'Firebase', 'Basic'],
        [Keys.enter],
      );
      expect(chooser.choose(), 'Supabase');
    });

    test('arrowDown then Enter picks the second item', () {
      final chooser = _chooser(
        ['Supabase', 'Laravel', 'Firebase', 'Basic'],
        [...Keys.arrowDown, Keys.enter],
      );
      expect(chooser.choose(), 'Laravel');
    });

    test('multiple arrowDowns walk the list and stop at the last item', () {
      final chooser = _chooser(
        ['Supabase', 'Laravel', 'Firebase', 'Basic'],
        [
          ...Keys.arrowDown,
          ...Keys.arrowDown,
          ...Keys.arrowDown,
          Keys.enter,
        ],
      );
      expect(chooser.choose(), 'Basic');
    });

    test('arrowDown past the end clamps to the last item', () {
      final chooser = _chooser(
        ['only', 'two'],
        [
          ...Keys.arrowDown,
          ...Keys.arrowDown, // would go past the end, must clamp
          ...Keys.arrowDown,
          Keys.enter,
        ],
      );
      expect(chooser.choose(), 'two');
    });

    test('arrowUp at the top clamps to the first item', () {
      final chooser = _chooser(
        ['first', 'second'],
        [
          ...Keys.arrowUp, // already at index 0; should not underflow
          Keys.enter,
        ],
      );
      expect(chooser.choose(), 'first');
    });

    test('down twice then up once lands on the middle item', () {
      final chooser = _chooser(
        ['a', 'b', 'c', 'd'],
        [
          ...Keys.arrowDown,
          ...Keys.arrowDown,
          ...Keys.arrowUp,
          Keys.enter,
        ],
      );
      expect(chooser.choose(), 'b');
    });
  });
}
