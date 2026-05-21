import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:scaffold_ui/cli_dialog/src/xterm.dart';

const _esc = '';
const _reset = '$_esc[0m';

void main() {
  group('XTerm color and weight wrappers', () {
    test('bold wraps text in the bold escape + reset', () {
      expect(XTerm.bold('hello'), '$_esc[1mhello$_reset');
    });

    test('green wraps text in green + reset', () {
      expect(XTerm.green('?'), '$_esc[32m?$_reset');
    });

    test('teal wraps text in 256-color teal (38;5;6) + reset', () {
      expect(XTerm.teal('Yes'), '$_esc[38;5;6mYes$_reset');
    });

    test('gray wraps text in 256-color gray (38;5;246) + reset', () {
      expect(XTerm.gray('hint'), '$_esc[38;5;246mhint$_reset');
    });
  });

  group('XTerm cursor / line helpers', () {
    test('blankRemaining is the standard ESC[0K erase-line sequence', () {
      expect(XTerm.blankRemaining(), '$_esc[0K');
    });

    test('moveUp(n) emits ESC[<n>A', () {
      expect(XTerm.moveUp(1), '$_esc[1A');
      expect(XTerm.moveUp(3), '$_esc[3A');
    });

    test(
      'replacePreviousLine combines moveUp(1), the payload and erase-line',
      () {
        expect(XTerm.replacePreviousLine('foo'), '$_esc[1Afoo$_esc[0K');
      },
    );
  });

  group('XTerm.rightIndicator', () {
    test('uses a portable ">" on Windows and a fancy chevron elsewhere', () {
      // The function reads Platform.isWindows at call-time. We can only assert
      // the output for whichever platform we're actually on, but we can pin
      // the colour wrapping in both cases.
      final indicator = XTerm.rightIndicator();
      expect(indicator, contains(_esc)); // teal-wrapped
      if (Platform.isWindows) {
        expect(indicator, contains('>'));
        expect(indicator.contains('❯'), isFalse);
      } else {
        expect(indicator, contains('❯')); // ❯
      }
    });
  });

  group('Keys constants', () {
    test(
      'arrowDown is a 3-byte escape on Unix or a single byte on Windows',
      () {
        if (Platform.isWindows) {
          expect(Keys.arrowDown.length, 1);
        } else {
          expect(Keys.arrowDown, [27, 91, 66]); // ESC [ B
        }
      },
    );

    test('arrowUp is a 3-byte escape on Unix or a single byte on Windows', () {
      if (Platform.isWindows) {
        expect(Keys.arrowUp.length, 1);
      } else {
        expect(Keys.arrowUp, [27, 91, 65]); // ESC [ A
      }
    });

    test('enter is the platform-appropriate single byte', () {
      if (Platform.isWindows) {
        expect(Keys.enter, 13); // CR
      } else {
        expect(Keys.enter, 10); // LF
      }
    });
  });
}
