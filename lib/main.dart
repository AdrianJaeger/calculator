import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 80, 156, 255)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Calculator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDarkMode = false; // theme state
  // getter for isDarkMode
  bool get isDarkMode => _isDarkMode;

  // variables
  String _mathInput = "";
  int _inputLength = 0;
  int _openingBracketCounter = 0;
  int _closingBracketCounter = 0;
  bool _enteringMode = true;
  double _result = 0;

  // methods that update the state of a variable
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _buttonInput(String button) {
    _inputLength = _mathInput.length;
    setState(() {
      // numbers
      if (["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(button)){
        if (_enteringMode  && 
        (_mathInput.isEmpty || _mathInput[_inputLength - 1] != ")") &&
        (button != "0" || _mathInput[_inputLength - 1] != "/")) { //avoiding floating point error
          _mathInput += button;
        }
      }
      // operators
      if (["+", "-", "*", "/"].contains(button)){
        if (_enteringMode && _mathInput.isNotEmpty && 
          ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",")"].contains(_mathInput[_inputLength - 1])) {
            _mathInput += button;
          }
      }
      // clear
      else if (button == "AC") {
        _mathInput = "";
        _openingBracketCounter = 0;
        _closingBracketCounter = 0;
        _enteringMode = true;
      }
      // remove last symbol
      else if (button == "<-") {
        if (_enteringMode && _mathInput.isNotEmpty) {
          if (_mathInput[_inputLength - 1] == "(") {
            _openingBracketCounter -= 1;
          }
          else if (_mathInput[_inputLength - 1] == ")") {
            _closingBracketCounter -= 1;
          }
          _mathInput = _mathInput.substring(0, _inputLength - 1);
        }
      }
      // dot
      else if (button == ".") {
        if (_enteringMode && dotPlaceable(_mathInput)) {
          _mathInput += button;
        }
      }
      // brackets
      else if (button == "(") {
        if (_enteringMode && _mathInput.isEmpty || ["+", "-", "*", "/", "("].contains(_mathInput[_inputLength - 1])) {
          _mathInput += button;
          _openingBracketCounter += 1;
        }
      }
      else if (button == ")") {
        if (_enteringMode && _openingBracketCounter > _closingBracketCounter && _mathInput.isNotEmpty && 
          ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",")"].contains(_mathInput[_inputLength - 1])) {
            _mathInput += button;
            _closingBracketCounter += 1;
          }
      }
      // result
      else if (button == "=") {
        if (_enteringMode && _mathInput.isNotEmpty && _openingBracketCounter == _closingBracketCounter
            && ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ")"].contains(_mathInput[_inputLength - 1])) {
          _enteringMode = false;
        }
      }
    });
  }

  String _calculateResult() {
    // convert mathmatical term to list of all tokens as strings
    List<String> tokenList = _tokenize(_mathInput);
    // convert token list to postfix notation
    List<String> postfixTokens = shuntingYardAlgorithm(tokenList);
    // calculate the result
    try {
      _result = evaluatePostfix(postfixTokens);
      // prevent floating point error by round to 7 digits after dot
      double mod = pow(10.0, 7).toDouble();
      _result = ((_result * mod).round().toDouble() / mod);
      // if number is int, present it without ".0"
      if (_result % 1 == 0) {
        return "= ${_result.toInt().toString()}";
      }
      else {
        return _result.toString();
      }
    }
    catch (e) {
      if (e is Exception && e.toString() == "Exception: Division by zero") {
        return "Error: Division by zero";
      }
      else if (e is Exception && e.toString() == "Exception: Floating point error") {
        return "Error: Floating point";
      }
      else {
        return "Error: Calculation error";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode
          ? ThemeData.dark() // Dark Theme
          : ThemeData.light(), // Light Theme
      home: Scaffold (
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          title: Text(
            widget.title,
            style: TextStyle(color: Colors.white)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: Colors.white
              ),
              onPressed: () {
                _toggleTheme();
              }
              )
          ]
        ),
        body: Column(
          children: [
            // display area for input and result
            Expanded(
              flex: 1,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // for long input
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start, // align text to the top
                    crossAxisAlignment: CrossAxisAlignment.start, // align text to the left
                    children: [
                      Text(
                        _mathInput,
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_enteringMode)
                        Align(
                          alignment: Alignment.centerRight,
                          child:
                            Text(
                              _calculateResult(), // Display the result
                              style: TextStyle(
                                fontSize: 32.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // down three quarters with the buttons
            Expanded(
              flex: 3,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  
                  // this makes buttons the right size to fill the whole button area
                  int rows = 5;
                  double buttonHeight = constraints.maxHeight / rows;
                  double buttonWidth = constraints.maxWidth / 4;
                  double aspectRatio = buttonWidth / buttonHeight;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), //deactivates scrolling of buttons
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: aspectRatio,
                      ),
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        String buttonText = getButtonLabel(index); // function gets name for the corresponding button
                        
                        Widget button = ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();

                            switch (index) {
                              case 0: 
                                _buttonInput("AC");
                                break;
                              case 1:
                                _buttonInput("(");
                                break;
                              case 2:
                                _buttonInput(")");
                                break;
                              case 3:
                                _buttonInput("/");
                                break;
                              case 4:
                                _buttonInput("7");
                                break;
                              case 5:
                                _buttonInput("8");
                                break;
                              case 6:
                                _buttonInput("9");
                                break;
                              case 7:
                                _buttonInput("*");
                                break;
                              case 8:
                                _buttonInput("4");
                                break;
                              case 9:
                                _buttonInput("5");
                                break;
                              case 10:
                                _buttonInput("6");
                                break;
                              case 11:
                                _buttonInput("-");
                                break;
                              case 12:
                                _buttonInput("1");
                                break;
                              case 13:
                                _buttonInput("2");
                                break;
                              case 14:
                                _buttonInput("3");
                                break;
                              case 15:
                                _buttonInput("+");
                                break;
                              case 16:
                                _buttonInput("0");
                                break;
                              case 17:
                                _buttonInput(".");
                                break;
                              case 18:
                                _buttonInput("<-");
                                break;
                              case 19:
                                _buttonInput("=");
                                break;
                              default:
                                _buttonInput("?");
                                break;
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(buttonText),
                        );
                        if (index == 0) {
                          return Tooltip(
                            message: "Clear",
                            child: button,
                          );
                        }
                        else {
                          return button;
                        }
                      },
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// helper function for _buttonInput method
bool dotPlaceable(String mathInput) {
  int inputLength = mathInput.length;
  if (mathInput.isEmpty || ["+", "-", "*", "/", "(", ")"].contains(mathInput[inputLength - 1])) {
    return false;
  }
  else {
    int i = 1;
    while (i < inputLength) {
      if (mathInput[inputLength - i] == ".") {
        return false;
      }
      else if (["+", "-", "*", "/"].contains(mathInput[inputLength - i])){
        return true;
      }
      i += 1;
    }
    return true;
  }
}

// converts mathmatical expression to list of all tokens as strings
List<String> _tokenize(String input) {
  // regular expression to find integer numbers, float numbers, operators and brackets (gets rid of =)
  RegExp regex = RegExp(r'(\d+(\.\d+)?|[+\-*/()])');
  // find all matches in input string
  Iterable<Match> matches = regex.allMatches(input);
  // convert every match into a single string
  Iterable<String> tokensIterable = matches.map((match) {
    return match.group(0)!;
  });
  // convert iterable to list
  List<String> tokenList = tokensIterable.toList();
  return tokenList;
}

// converts tokenized expression to postfix notation
List<String> shuntingYardAlgorithm(List<String> tokens) {
  List<String> outputQueue = [];
  List<String> operatorStack = [];

  // operator prioritys to follow oder of operations
  Map<String, int> precedence = {
    "+": 1,
    "-": 1,
    "*": 2,
    "/": 2
  };

  for (String token in tokens) {
    // if token is a number, put it on outputQueue
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(token)) {
      outputQueue.add(token);
    }
    // if token is operator
    else if (precedence.containsKey(token)) {
      // last element on operator stack is also operator
      // and that one has higher or same priority -> it has to be evaluated first
      while (operatorStack.isNotEmpty && precedence.containsKey(operatorStack.last) &&
        precedence[operatorStack.last]! >= precedence[token]!) {
          outputQueue.add(operatorStack.removeLast());
      }
      // no higher or same prio -> put operator on operator stack
      operatorStack.add(token);
    }
    // bracket 
    // just put opening bracket on stack
    else if (token == "(") {
      operatorStack.add(token);
    }
    // put all operators that were in the brackets on output queue
    else if (token == ")") {
      while (operatorStack.isNotEmpty && operatorStack.last != "(") {
        outputQueue.add(operatorStack.removeLast());
      }
      operatorStack.removeLast(); // remove opening bracket
    }
  }
  // put remaining operators on output queue
  while (operatorStack.isNotEmpty) {
    outputQueue.add(operatorStack.removeLast());
  }
  return outputQueue;
}

// calculate postfix notation to get result of the user input expression
double evaluatePostfix(List<String> postfixTokens) {
  List<double> stack = [];

  for (String token in postfixTokens) {
    // if token is a number, converted it to a double and put it on stack
    if (RegExp(r'^\d+(\.\d+)?$').hasMatch(token)) {
      stack.add(double.parse(token));
    } 
    // token is a operator
    // take last 2 numbers from stack and use operator on them
    else {
      double b = stack.removeLast();
      double a = stack.removeLast();

      if (token == "+") {
        stack.add(a + b);
      } else if (token == "-") {
        stack.add(a - b);
      } else if (token == "*") {
        stack.add(a * b);
      } else if (token == "/") {
        // check for division by zero
        if (b == 0) {
          throw Exception("Division by zero");
        }
        // prevent of a wrong result caused by floating point error
        if ((a.abs() / b.abs() > 1e10)) {
          throw Exception("Floating point error");
        }

        stack.add(a / b);
      }
    }
  }
  // result
  return stack.last;
}

String getButtonLabel(int index) {
  switch (index) {
    case 0: 
      return'AC';
    case 1:
      return '(';
    case 2:
      return ')';
    case 3:
      return '/';
    case 4:
      return '7';
    case 5:
      return '8';
    case 6:
      return '9';
    case 7:
      return '*';
    case 8:
      return '4';
    case 9:
      return '5';
    case 10:
      return '6';
    case 11:
      return '-';
    case 12:
      return '1';
    case 13:
      return '2';
    case 14:
      return '3';
    case 15:
      return '+';
    case 16:
      return '0';
    case 17:
      return '.';
    case 18:
      return '<-';
    case 19:
      return '=';
    default:
      return '?';
  }
}