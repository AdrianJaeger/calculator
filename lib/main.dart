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
  //int _counter = 0;

  // methods that update the state of a variable
  /*void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }
  */

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
            child: Container(),
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
                print(
                  "Button area:\n"
                          "Width: ${constraints.maxWidth}\n"
                          "Height: ${constraints.maxHeight}\n"
                          "aspectRatio: $aspectRatio");

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
                        onPressed: () {}, // to do give function to button
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
        return ',';
      case 18:
        return '<-';
      case 19:
        return '=';
      default:
        return '?';
    }
  }
}