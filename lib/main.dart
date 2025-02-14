import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  // variables
  String mathInput = "";
  int inputLength = 0;
  int openingBracketCounter = 0;
  int closingBracketCounter = 0;
  bool enteringMode = true;

  // methods that update the state of a variable
  // helper variables used here are defined outside of the class
  void _buttonInput(String button) {
    int inputLength = mathInput.length;
    setState(() {
      // numbers
      if (["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(button)){
        if (enteringMode && (mathInput.isNotEmpty || button != "0")) {
          mathInput += button;
        }
      }
      // operators
      if (["+", "-", "*", "/"].contains(button)){
        if (enteringMode && mathInput.isNotEmpty && 
          ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",")"].contains(mathInput[inputLength - 1])) {
            mathInput += button;
          }
      }
      // clear
      else if (button == "AC") {
        mathInput = "";
        openingBracketCounter = 0;
        closingBracketCounter = 0;
        enteringMode = true;
      }
      // remove last symbol
      else if (button == "<-") {
        if (enteringMode && mathInput.isNotEmpty) {
          if (mathInput[inputLength - 1] == "(") {
            openingBracketCounter -= 1;
          }
          else if (mathInput[inputLength - 1] == ")") {
            closingBracketCounter -= 1;
          }
          mathInput = mathInput.substring(0, inputLength - 1);
        }
      }
      // dot
      else if (button == ".") {
        if (enteringMode && dotPlaceable(mathInput)) {
          mathInput += button;
        }
      }
      // brackets
      else if (button == "(") {
        if (enteringMode && mathInput.isEmpty || ["+", "-", "*", "/"].contains(mathInput[inputLength - 1])) {
          mathInput += button;
          openingBracketCounter += 1;
        }
      }
      else if (button == ")") {
        if (enteringMode && openingBracketCounter > closingBracketCounter && mathInput.isNotEmpty && 
          ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",")"].contains(mathInput[inputLength - 1])) {
            mathInput += button;
            closingBracketCounter += 1;
          }
      }
      // result
      else if (button == "=") {
        if (enteringMode && mathInput.isNotEmpty && openingBracketCounter == closingBracketCounter
            && ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ")"].contains(mathInput[inputLength - 1])) {
          mathInput += button;
          enteringMode = false;
          _calculateResult(mathInput);
        }
      }
    });
  }

  void _calculateResult(String mathInputString) {
    // convert mathmatical term to list of all tokens as strings
    List<String> tokenList = _tokenize(mathInputString);
    List<String> postfixTokens = shuntingYardAlgorithm(tokenList);
    double result = evaluatePostfix(postfixTokens);
    mathInput += result.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Column(
        children: [

          // upper quarter stays empty
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16.0), // Optional padding for better appearance
              alignment: Alignment.centerRight, // Align text to the right
              child: Text(
                mathInput,
                style: TextStyle(
                  fontSize: 32.0, // Change the font size as needed
                  fontWeight: FontWeight.bold,
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