import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'services.dart';
import 'xterm.dart';
import 'keys.dart';

/// Implementation of list questions. Can be used without [CLI_Dialog].
class ListChooser {
  /// The options which are presented to the user
  List<String>? items;

  /// Select the navigation mode. See dialog.dart for details.
  bool navigationMode;

  /// Default constructor for the list chooser.
  /// It is as simple as passing your [items] as a List of strings
  ListChooser(this.items, {this.navigationMode = false}) {
    _checkItems();
    //relevant when running from IntelliJ console pane for example
    if (stdin.hasTerminal) {
      // lineMode must be true to set echoMode in Windows
      // see https://github.com/dart-lang/sdk/issues/28599
      stdin.echoMode = false;
      stdin.lineMode = false;
    }
  }

  /// Named constructor mostly for unit testing.
  /// For context and an example see [CLI_Dialog], `README.md` and the `test/` folder.
  ListChooser.std(
    this._stdInput,
    this._stdOutput,
    this.items, {
    this.navigationMode = false,
  }) {
    _checkItems();
    if (stdin.hasTerminal) {
      stdin.echoMode = false;
      stdin.lineMode = false;
    }
  }

  /// Similar to [ask] this actually triggers the dialog and returns the chosen item = option.
  String choose() {
    int? input;
    var index = 0;

    _renderList(0, initial: true);

    while ((input = _userInput()) != enter) {
      if (input! < 0) {
        _resetStdin();
        return ':${-input}';
      }
      if (input == arrowUp) {
        if (index > 0) {
          index--;
        }
      } else if (input == arrowDown) {
        if (index < items!.length - 1) {
          index++;
        }
      }
      _renderList(index);
    }
    _resetStdin();
    return items![index];
  }

  // END OF PUBLIC API

  var _stdInput = StdinService();
  var _stdOutput = StdoutService();

  void _checkItems() {
    if (items == null) {
      throw ArgumentError('No options for list dialog given');
    }
  }

  int? _checkNavigation() {
    final int? input = _stdInput.readByteSync();
    if (navigationMode) {
      if (input == 58) {
        // 58 = :
        _stdOutput.write(':');
        final String inputLine = _stdInput.readLineSync(
          encoding: Encoding.getByName('utf-8'),
        )!;
        final int lineNumber = int.parse(inputLine.trim());
        _stdOutput.writeln('$lineNumber');
        return -lineNumber; // make the result negative so it can be told apart from normal key codes
      } else {
        return input;
      }
    } else {
      return input;
    }
  }

  void _deletePreviousList() {
    for (var i = 0; i < items!.length; i++) {
      _stdOutput.write(XTerm.moveUp(1) + XTerm.blankRemaining());
    }
  }

  void _renderList(int index, {bool initial = false}) {
    if (!initial) {
      _deletePreviousList();
    }
    for (var i = 0; i < items!.length; i++) {
      if (i == index) {
        _stdOutput.writeln(
          '${XTerm.rightIndicator()} ${XTerm.teal(items![i])}',
        );
        continue;
      }
      _stdOutput.writeln('  ${items![i]}');
    }
  }

  void _resetStdin() {
    if (stdin.hasTerminal) {
      //see default ctor. Order is important here
      stdin.lineMode = true;
      stdin.echoMode = true;
      // dart_console's disableRawMode (used internally by Console.readKey)
      // sets the Windows console mode to 0 because of a bitwise-AND/OR bug,
      // and stdin.lineMode/echoMode only OR-in two of the bits we need.
      // Force the full interactive-input mask back on.
      _restoreWindowsConsoleInputMode();
    }
  }

  int? _userInput() {
    final int navigationResult =
        _checkNavigation()!; // just receives the read byte, if not successful,
    if (navigationResult < 0) {
      // < 0 = user has navigated
      return navigationResult;
    }

    if (Platform.isWindows) {
      if (navigationResult == Keys.enter) {
        return enter;
      }
      if (navigationResult == Keys.arrowUp[0]) {
        return arrowUp;
      }
      if (navigationResult == Keys.arrowDown[0]) {
        return arrowDown;
      } else {
        return navigationResult;
      }
    } else {
      if (navigationResult == enter) {
        return enter;
      }
      final int? anotherByte = _stdInput.readByteSync();
      if (anotherByte == enter) {
        return enter;
      }
      final int? input = _stdInput.readByteSync();
      return input;
    }
  }
}

// STD_INPUT_HANDLE = (DWORD)-10 = 0xFFFFFFF6.
const int _stdInputHandle = 0xFFFFFFF6;

// ENABLE_PROCESSED_INPUT | ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT |
// ENABLE_EXTENDED_FLAGS | ENABLE_VIRTUAL_TERMINAL_INPUT.
const int _interactiveInputMode = 0x0001 | 0x0002 | 0x0004 | 0x0080 | 0x0200;

typedef _GetStdHandleNative = IntPtr Function(Uint32);
typedef _GetStdHandleDart = int Function(int);
typedef _SetConsoleModeNative = Int32 Function(IntPtr, Uint32);
typedef _SetConsoleModeDart = int Function(int, int);

void _restoreWindowsConsoleInputMode() {
  if (!Platform.isWindows) return;
  try {
    final kernel32 = DynamicLibrary.open('kernel32.dll');
    final _GetStdHandleDart getStdHandle = kernel32
        .lookupFunction<_GetStdHandleNative, _GetStdHandleDart>('GetStdHandle');
    final _SetConsoleModeDart setConsoleMode = kernel32
        .lookupFunction<_SetConsoleModeNative, _SetConsoleModeDart>(
          'SetConsoleMode',
        );
    setConsoleMode(getStdHandle(_stdInputHandle), _interactiveInputMode);
  } catch (e) {
    // Best-effort: if the FFI lookup fails, fall back to whatever
    // stdin.lineMode/echoMode managed to restore, but say so — a console
    // left without line input otherwise just looks like a hang.
    stderr.writeln('Could not restore the Windows console input mode: $e');
  }
}
