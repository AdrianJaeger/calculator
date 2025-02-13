import 'package:flutter/material.dart';

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
      home: const MyHomePage(title: 'Calculator Home Page'),
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
        if (enteringMode && _dotPlaceable(mathInput)) {
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

  bool _dotPlaceable(String mathInput) {
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

  void _calculateResult(String mathInputString) {
    // TO DO
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
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
                      
                      return ElevatedButton(
                        onPressed: () {
                          switch (index) {
                            case 0: 
                              _buttonInput("AC");
                            case 1:
                              _buttonInput("(");
                            case 2:
                              _buttonInput(")");
                            case 3:
                              _buttonInput("/");
                            case 4:
                              _buttonInput("7");
                            case 5:
                              _buttonInput("8");
                            case 6:
                              _buttonInput("9");
                            case 7:
                              _buttonInput("*");
                            case 8:
                              _buttonInput("4");
                            case 9:
                              _buttonInput("5");
                            case 10:
                              _buttonInput("6");
                            case 11:
                              _buttonInput("-");
                            case 12:
                              _buttonInput("1");
                            case 13:
                              _buttonInput("2");
                            case 14:
                              _buttonInput("3");
                            case 15:
                              _buttonInput("+");
                            case 16:
                              _buttonInput("0");
                            case 17:
                              _buttonInput(".");
                            case 18:
                              _buttonInput("<-");
                            case 19:
                              _buttonInput("=");
                            default:
                              _buttonInput("?");
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
}