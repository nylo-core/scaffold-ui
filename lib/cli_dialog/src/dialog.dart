import 'dart:convert';
import 'list_chooser.dart';
export 'list_chooser.dart';
import 'services.dart';
import 'xterm.dart';

/// This enum is used to indicate the type of question in the CLI dialog.
enum CliDialogQuestionType { message, question, booleanQuestion, listQuestion }

/// This is the most important class which should usually be instantiated when building CLI dialogs.
class CliDialog {
  /// This is where the results = answers from the CLI dialog go. This map is updated and returned when calling [ask].
  Map answers = {};

  /// This is where the boolean questions are stored during runtime. Feel free to access it like any other list.
  List? booleanQuestions;

  /// This is where the list questions are stored during runtime (where the user selects a value). Feel free to access it like any other list.
  List? listQuestions;

  /// Messages inform the user without asking a question. A key must be provided for each message if you want to use a custom [order].
  List? messages;

  /// Navigation mode means that every question is displayed with a number which you can use to navigate through questions
  bool navigationMode;

  /// Resume moed means that progress in your CLI dialog is automatically saved with each question so you can savely
  /// Quit and resume later. Specify a file path where you progress will be saved and loaded from
  String? resume;

  /// This list contains the order in which the questions are asked in the dialog. Feel free to access it like any other list.
  List<String>? order;

  /// This is where the regular questions are stored during runtime.
  List? questions;

  /// Indicates the default behaviour of boolean questions when no input (except '\n') is given.
  bool trueByDefault;

  /// This is the default constructor to create a CLI Dialog
  /// You can pass lists of normal [questions], [booleanQuestions], [listQuestions].
  /// All these named parameters are optional as long as at least one of them is given.
  /// Furthermore you can pass a particular order. If no order is given then the default order is used (see README.md)
  /// There is also [trueByDefault] (false by default) which indicates how booleanQuestions behave if no input is given
  /// There are basic format checks which try to prevent you from passing invalid argmuents.
  CliDialog({
    this.messages,
    this.questions,
    this.booleanQuestions,
    this.listQuestions,
    this.order,
    this.trueByDefault = false,
    this.navigationMode = false,
    this.resume = '',
  }) {
    _checkQuestions();
    _initializeLists();
  }

  /// This named constructor should mostly be used when unit testing.
  ///
  /// ```
  /// var std_output = StdoutService(mock: true);
  /// var std_input = StdinService(mock: true, informStdout: std_output);
  /// std_input.addToBuffer(...Keys.arrowDown, Keys.enter);
  /// final dialog = CLI_Dialog.std(std_input, std_output, listQuestions: listQuestions);
  /// ```
  CliDialog.std(
    this._stdInput,
    this._stdOutput, {
    this.messages,
    this.questions,
    this.booleanQuestions,
    this.listQuestions,
    this.order,
    this.trueByDefault = false,
    this.navigationMode = false,
  }) {
    _checkQuestions();
    _initializeLists();
  }

  /// This method is another way of adding questions after instantiating [CliDialog].
  /// Pass [isBoolean], [isList], or [isMessage] as a named argument to indicate
  /// the type of question you are adding.
  ///
  /// ```
  /// final dialog = CliDialog();
  /// // Plain text question:
  /// dialog.addQuestion('What is your name?', 'name');
  /// // List/multiple-choice question — the first positional arg is the
  /// // {question, options} map, the second is the answer key:
  /// dialog.addQuestion(
  ///   {'question': 'How are you?', 'options': ['Good', 'Not so good']},
  ///   'mood',
  ///   isList: true,
  /// );
  /// ```
  void addQuestion(
    Object pQuestion,
    String key, {
    bool isBoolean = false,
    bool isList = false,
    bool isMessage = false,
  }) {
    if ((isBoolean ? 1 : 0) + (isList ? 1 : 0) + (isMessage ? 1 : 0) > 1) {
      throw ArgumentError(
        'A question can not have more than one boolean qualifier.',
      );
    }
    final List<Object> newItem = [pQuestion, key];
    if (isBoolean) {
      booleanQuestions!.add(newItem);
    } else if (isList) {
      listQuestions!.add(newItem);
    } else if (isMessage) {
      messages!.add(newItem);
    } else {
      questions!.add(newItem);
    }
  }

  /// Same as [addQuestion] but you can add multiple questions (of the same type)
  void addQuestions(
    Iterable<dynamic> pQuestions, {
    bool isBoolean = false,
    bool isList = false,
    bool isMessage = false,
  }) {
    if (isBoolean) {
      booleanQuestions!.addAll(pQuestions);
    } else if (isList) {
      listQuestions!.addAll(pQuestions);
    } else if (isMessage) {
      messages!.addAll(pQuestions);
    } else {
      questions!.addAll(pQuestions);
    }
  }

  /// Use this method to retrieve the results from your CLI dialog.
  /// A map is being returned which you can query using your keys.
  ///
  /// ```
  /// final dialog = CLI_Dialog();
  /// dialog.addQuestion('What is your name?', 'name');
  /// var answers = dialog.ask();
  /// print('Your name is ${answers["name"]}');
  /// ```
  Map ask() {
    _navigationIndex = 0; // reset navigation
    if (order == null) {
      _standardOrder();
    } else {
      _customOrder();
    }
    return answers;
  }

  // END OF PUBLIC API

  var _stdInput = StdinService();
  var _stdOutput = StdoutService();

  void _askBooleanQuestion(String question, String key) {
    _stdOutput.write(_booleanQuestion(question));
    _getBooleanAnswer(question, key);
  }

  void _askListQuestion(Map optionsMap, String key) {
    _stdOutput.writeln(_listQuestion(optionsMap['question']));
    _getListAnswer(optionsMap['options'], key);
  }

  void _askQuestion(String question, String key) {
    _stdOutput.write(_question(question));
    _getAnswer(question, key);
  }

  String _booleanQuestion(String str) =>
      '${_question(str)}${_comment(trueByDefault ? '(Y/n)' : '(y/N)')} ';

  void _checkDuplicateKeys() {
    List<dynamic> keyList = [];

    for (List<dynamic>? entry in [questions, booleanQuestions, listQuestions]) {
      if (entry != null) {
        for (List<dynamic> element in entry) {
          keyList.add(element[1]);
        }
      }
    }

    //check for duplicates
    if (keyList.length != keyList.toSet().length) {
      throw ArgumentError('You have two or more keys with the same name.');
    }
  }

  bool _checkNavigation(String input) {
    if (navigationMode) {
      if (input[0] == ':') {
        // -1 because of zero index
        _navigationIndex = int.parse(input.substring(1)) - 1;
        // -1 because _navigationIndex will be incremented in _iterateCustomOrder()
        _navigationIndex += _messagesBefore - 1;
        _stdOutput.writeln('');
        return true;
      }
      return false;
    }
    return false;
  }

  void _checkQuestions() {
    if (messages != null) {
      for (Object? element in messages!) {
        final isPlainString = element is String;
        final bool isStringKeyedPair =
            element is List &&
            element.length == 2 &&
            element[0] is String &&
            element[1] is String;
        if (!isPlainString && !isStringKeyedPair) {
          throw ArgumentError(
            'Each message is either just a string or a list with a string and a key.',
          );
        }
      }
    }

    for (List<dynamic>? entry in [questions, booleanQuestions, listQuestions]) {
      if (entry != null) {
        for (Object? element in entry) {
          if (element != null) {
            if (element is! List || element.length != 2) {
              throw ArgumentError(
                'Each question entry must be a list consisting of a question and a key.',
              );
            }
          } else {
            throw ArgumentError('All questions and keys must be Strings.');
          }
        }
      }
    }

    for (List<dynamic>? entry in [questions, booleanQuestions]) {
      if (entry != null) {
        for (List<dynamic> element in entry) {
          if (element[0] is! String || element[1] is! String) {
            throw ArgumentError('All questions and keys must be Strings.');
          }
        }
      }
    }

    if (listQuestions != null) {
      for (List<dynamic> element in listQuestions!) {
        if (element[0]['question'] is! String) {
          throw ArgumentError('Your question must be a String.');
        }
        if (element[0]['options'] is! List<String>) {
          throw ArgumentError('Your list options must be a list of Strings.');
        }

        if (element[0].length != 2) {
          throw ArgumentError(
            'Your list dialog map must have exactly two entries.',
          );
        }
      }
    }
    _checkDuplicateKeys();
  }

  String _comment(String str) => XTerm.gray(str);

  void _customOrder() {
    if (navigationMode) {
      _iterateCustomOrder(getCustomNavList());
    } else {
      _customOrderWithoutNavigation();
    }
  }

  void _customOrderWithoutNavigation() {
    for (var i = 0; i < order!.length; i++) {
      final dynamic questionAndFunction = _findQuestion(order![i]);
      if (questionAndFunction != null) {
        questionAndFunction[1](
          questionAndFunction[0][0],
          questionAndFunction[0][1],
        );
      }
    }
  }

  void _displayMessage(dynamic msg, String key) {
    if (msg is String) {
      _stdOutput.writeln(_comment(msg));
    } else {
      _stdOutput.writeln(_comment(msg[0]));
    }
  }

  dynamic _findQuestion(String key) {
    dynamic ret;
    for (List<Object?> element in [
      [messages, _displayMessage],
      [questions, _askQuestion],
      [booleanQuestions, _askBooleanQuestion],
      [listQuestions, _askListQuestion],
    ]) {
      if (element[0] != null) {
        dynamic retVal = _search(element[0], element[1], key);
        if (retVal != null) {
          ret = retVal;
          continue;
        }
      }
    }
    return ret;
  }

  void _getAnswer(String question, String key) {
    final String input = _getInput(_question(question));
    if (!_checkNavigation(input)) {
      answers[key] = input;
      _stdOutput.writeln(
        '\r${_question(question)}${XTerm.teal(answers[key])}${XTerm.blankRemaining()}',
      );
    }
  }

  void _getBooleanAnswer(String question, String key) {
    String input = _getInput(
      _booleanQuestion(question),
      acceptEmptyAnswer: true,
    );
    if (!_checkNavigation(input)) {
      if (input.isEmpty) {
        answers[key] = trueByDefault;
      } else {
        answers[key] = (input[0] == 'y' || input[0] == 'Y');
      }
      var replaceStr =
          '\r${_booleanQuestion(question)}${XTerm.blankRemaining()}';
      replaceStr += (answers[key] ? XTerm.teal('Yes') : XTerm.teal('No'));
      _stdOutput.writeln(replaceStr);
    }
  }

  Function? _getFunctionForQuestionType(CliDialogQuestionType? type) {
    if (type == CliDialogQuestionType.message) {
      return _displayMessage;
    }
    if (type == CliDialogQuestionType.question) {
      return _askQuestion;
    }
    if (type == CliDialogQuestionType.booleanQuestion) {
      return _askBooleanQuestion;
    }
    if (type == CliDialogQuestionType.listQuestion) {
      return _askListQuestion;
    }
    return null;
  }

  String _getInput(String formattedQuestion, {bool acceptEmptyAnswer = false}) {
    var input = '';
    if (!acceptEmptyAnswer) {
      while (input.isEmpty) {
        input = _stdInput
            .readLineSync(encoding: Encoding.getByName('utf-8'))!
            .trim();
        _stdOutput.write(XTerm.moveUp(1) + formattedQuestion);
      }
    } else {
      input = _stdInput
          .readLineSync(encoding: Encoding.getByName('utf-8'))!
          .trim();
      _stdOutput.write(XTerm.moveUp(1) + formattedQuestion);
    }
    return input;
  }

  void _getListAnswer(List<String>? options, String key) {
    var chooser = ListChooser.std(
      _stdInput,
      _stdOutput,
      options,
      navigationMode: navigationMode,
    );
    final String input = chooser.choose();
    if (!_checkNavigation(input)) {
      answers[key] = input;
    }
  }

  List _getStdNavList() => [
    ...messages!,
    ...questions!,
    ...booleanQuestions!,
    ...listQuestions!,
  ];

  List getCustomNavList() {
    List<dynamic> navList = [];
    for (String key in order!) {
      navList.add(_simpleSearch(key));
    }
    return navList;
  }

  CliDialogQuestionType? _getQuestionType(Object? item) {
    if (messages!.contains(item)) {
      return CliDialogQuestionType.message;
    }
    if (questions!.contains(item)) {
      return CliDialogQuestionType.question;
    }
    if (booleanQuestions!.contains(item)) {
      return CliDialogQuestionType.booleanQuestion;
    }
    if (listQuestions!.contains(item)) {
      return CliDialogQuestionType.listQuestion;
    }
    return null;
  }

  // this is needed because only unmodifiable lists can be used as default values
  void _initializeLists() {
    messages ??= [];
    booleanQuestions ??= [];
    listQuestions ??= [];
    questions ??= [];
  }

  void _iterateCustomOrder(List navlist) {
    for (
      _navigationIndex;
      _navigationIndex < navlist.length;
      _navigationIndex++
    ) {
      final dynamic element = navlist[_navigationIndex];
      _getFunctionForQuestionType(_getQuestionType(element))!(
        element[0],
        element[1],
      );
    }
  }

  String _listQuestion(String str) =>
      _question(str) + _comment('(Use arrow keys)');

  int get _messagesBefore {
    var messagesBefore = 0;
    if (navigationMode && order != null) {
      for (int i = _navigationIndex - 1; i >= 0; i--) {
        if (_getQuestionType(_simpleSearch(order![i])) ==
            CliDialogQuestionType.message) {
          messagesBefore++;
        }
      }
    }
    return messagesBefore;
  }

  int _navigationIndex = 0;

  String _question(String str) =>
      '${navigationMode ? '(${_navigationIndex + 1 - _messagesBefore}) ' : ''}${XTerm.green('?')} ${XTerm.bold(str)} ';
  dynamic _search(dynamic list, dynamic fn, String key) {
    dynamic ret;
    list.forEach((element) {
      if (element[1] == key) {
        ret = [element, fn];
        return; // corresponds to a break in a normal for-loop
      }
    });
    return ret;
  }

  dynamic _simpleSearch(String key) {
    dynamic ret;
    for (List<dynamic>? list in [
      messages,
      questions,
      booleanQuestions,
      listQuestions,
    ]) {
      for (Object? element in list!) {
        if (element is List && element[1] == key) {
          ret = element;
          continue; // break
        }
      }
      if (ret != null) {
        continue;
      }
    }
    return ret;
  }

  // Standard behaviour if no order is given
  void _standardOrder() {
    if (navigationMode) {
      _iterateCustomOrder(_getStdNavList());
    } else {
      _standardOrderNoNavigation();
    }
  }

  void _standardOrderNoNavigation() {
    for (var i = 0; i < messages!.length; i++) {
      _displayMessage(messages![i], messages![i][1]);
    }
    for (var i = 0; i < questions!.length; i++) {
      _askQuestion(questions![i][0], questions![i][1]);
    }
    for (var i = 0; i < booleanQuestions!.length; i++) {
      _askBooleanQuestion(booleanQuestions![i][0], booleanQuestions![i][1]);
    }
    for (var i = 0; i < listQuestions!.length; i++) {
      _askListQuestion(listQuestions![i][0], listQuestions![i][1]);
    }
  }
}
