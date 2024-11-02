import 'dart:convert';
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
  ListChooser.std(this._stdInput, this._stdOutput, this.items,
      {this.navigationMode = false}) {
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
    final input = _stdInput.readByteSync();
    if (navigationMode) {
      if (input == 58) {
        // 58 = :
        _stdOutput.write(':');
        final inputLine =
            _stdInput.readLineSync(encoding: Encoding.getByName('utf-8'))!;
        final lineNumber = int.parse(inputLine.trim());
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

  void _renderList(index, {initial = false}) {
    if (!initial) {
      _deletePreviousList();
    }
    for (var i = 0; i < items!.length; i++) {
      if (i == index) {
        _stdOutput
            .writeln('${XTerm.rightIndicator()} ${XTerm.teal(items![i])}');
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
    }
  }

  int? _userInput() {
    final navigationResult =
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
      final anotherByte = _stdInput.readByteSync();
      if (anotherByte == enter) {
        return enter;
      }
      final input = _stdInput.readByteSync();
      return input;
    }
  }
}
