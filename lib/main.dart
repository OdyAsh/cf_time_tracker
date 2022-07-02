import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'add_problem_code_button.dart'; //implementation from "fun with flutter": https://www.youtube.com/watch?v=Bxs8Zy2O4wk

void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({Key? key}) : super(key: key);

// This widget is the root of your application.
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
// This is the theme of your application.
//
// Try running your application with "flutter run". You'll see the
// application has a blue toolbar. Then, without quitting the app, try
// changing the primarySwatch below to Colors.green and then invoke
// "hot reload" (press "r" in the console where you ran "flutter run",
// or simply save your changes to "hot reload" in a Flutter IDE).
// Notice that the counter didn't reset back to zero; the application
// is not restarted.
                primarySwatch: Colors.blue,
            ),
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
        );
    }
}

class MyHomePage extends StatefulWidget {
    const MyHomePage({Key? key, required this.title}) : super(key: key);

// This widget is the home page of your application. It is stateful, meaning
// that it has a State object (defined below) that contains fields that affect
// how it looks.

// This class is the configuration for the state. It holds the values (in this
// case the title) provided by the parent (in this case the App widget) and
// used by the build method of the State. Fields in a Widget subclass are
// always marked "final".

    final String title;

    @override
    State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    final isDialOpen = ValueNotifier(false);

    @override
    Widget build(BuildContext context) {
        return WillPopScope(
            onWillPop: () async {
                if (isDialOpen.value) {
                    isDialOpen.value = false;
                    return false; // closes floating button list when pressing back on android phone
                }
                return true;
            },
            child: Scaffold(
                appBar: AppBar(
                    title: Text(widget.title),
                ),
                floatingActionButton: const AddProblemCodeButton(),
            ),
        );
    }
}
