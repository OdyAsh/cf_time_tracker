import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart'; // code related to "stop_watch_timer" package is from here: https://www.youtube.com/watch?v=P6OW1aKV12M
import 'dart:io' show Platform;
import 'package:window_size/window_size.dart';
import 'add_problem_code_button.dart'; // implementation from "fun with flutter": https://www.youtube.com/watch?v=Bxs8Zy2O4wk
import 'globals.dart' as globals; // use of globals using a "globals" file: https://stackoverflow.com/questions/29182581/global-variables-in-dart

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    setWindowTitle('cf_time_tracker');
    //double minWidth = 800, minHeight = 720;
    //setWindowMaxSize(const Size(max_width, max_height));
    //setWindowMinSize(Size(minWidth, minHeight));
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'cf_time_tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Problem Details'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final isDialOpen = ValueNotifier(false); // redundant logic, as the speed dial buttons are not used anymore in this project
  List<CardItem> items = [
    CardItem(id: 0, solvingStage: "Reading", timer: StopWatchTimer()),
    CardItem(id: 1, solvingStage: "Thinking", timer: StopWatchTimer()),
    CardItem(id: 2, solvingStage: "Coding", timer: StopWatchTimer()),
    CardItem(id: 3, solvingStage: "Debugging", timer: StopWatchTimer()),
  ];

  @override
  void dispose() {
    super.dispose();
    for (var item in items) {
      item.timer.dispose();
    }
  }

  void startOneTimer({required int id}) {
    for (var item in items) {
      if (item.id == id) {
        item.timer.onExecute.add(StopWatchExecute
            .start); // starts only the stopwatch related to the clicked button
      } else {
        item.timer.onExecute
            .add(StopWatchExecute.stop); // pauses other stopwatches
      }
    }
  }

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
          body: Column(children: [
            const SizedBox(height: 50), // gives space between app bar and cards
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: SizedBox(
                  // the cards layed out horizontally
                  height: 150, // ensures cards don't use height of entire app
                  child: ScrollConfiguration(
                    // workaround as horizontal scrolling isn't working in flutter desktop apps
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.mouse,
                        PointerDeviceKind.touch,
                      },
                    ),
                    child: ListView.separated(
                      // if you want resizable cards, replace this (and remove Container() parent) with SingleChildScrollView() (but note that this will render all cards) (source: https://youtu.be/baA_J5tUtEU?t=190)
                      clipBehavior: Clip.none,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) =>
                          _buildCard(item: items[index], app: this),
                      separatorBuilder: (context, _) => const SizedBox(
                          width:
                              12), //separation between cards is an invisible box of width 12
                      itemCount: 4,
                    ),
                  )),
            ),
            const SizedBox(height: 30),
            SizedBox(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  // pause button
                  child: const Icon(Icons.pause),
                  onPressed: () {
                    for (var item in items) {
                      item.timer.onExecute
                          .add(StopWatchExecute.stop); // pauses all timers
                    }
                  },
                ),
                ElevatedButton(
                  // finish button
                  onPressed: () {
                    for (var item in items) {
                      item.timer.onExecute
                          .add(StopWatchExecute.stop); // pauses all timers
                    }
                    // LOGIC TO COPY MINUTES AND SECONDS
                    for (var item in items) {
                      item.timer.onExecute.add(
                          StopWatchExecute.reset); // resets all timers to 0
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueGrey,
                  ), // finish button
                  child: const Icon(Icons.restart_alt_rounded)
                ),
              ],
            )),
            const SizedBox(height: 30),
            ValueListenableBuilder( // Class that enables changes on returned widget to appear in the UI if a valueListenable changes, source: https://stackoverflow.com/questions/62007967/updating-a-widget-when-a-global-variable-changes-async-in-flutter
                valueListenable: globals.problemNameCard,
                builder: (context, value, widget) {
                    return Visibility(
                        visible: globals.problemNameCard.value,
                        child: SizedBox( // the if() makes the problem name card not visible unless "track" button is pressed
                          child: Material(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(children: [
                                  Text(
                                      globals.problemName,
                                      style: const TextStyle(fontSize: 20, color: Colors.black),
                                  ),
                                  const SizedBox(
                                      height:
                                          15), // space between problem name and check mark
                                  ElevatedButton(
                                      // finish button
                                      onPressed: () {
                                        // To-do: make custom card to get solution code 
                                      },
                                      style: ElevatedButton.styleFrom(
                                      primary: Colors.green,
                                      ), // finish button
                                      child: const Icon(Icons.check),
                                  ),
                                  ]),
                        ))),
                    );
                }
            )
          ]),
        ));
  }
}

class CardItem {
  final int id;
  final String solvingStage;
  StopWatchTimer timer;

  CardItem({
    required this.id,
    required this.solvingStage,
    required this.timer,
  });
}

Widget _buildCard({required CardItem item, required _MyHomePageState app}) {
  return SizedBox(
    width: 200,
    height:
        200, // doesn't matter, as height is controlled by SizedBox() that encapsulates ListView.Separated()
    child: Material(
      color: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      child: Column(children: [
        Text(
          item.solvingStage,
          style: const TextStyle(fontSize: 20, color: Colors.black),
        ),
        const SizedBox(height: 4), // space between text and timer
        StreamBuilder<int>(
            // to make timer work
            stream: item.timer.rawTime,
            initialData: item.timer.rawTime.value,
            builder: (context, snapshot) {
              final value = snapshot.data;
              final displayTime =
                  StopWatchTimer.getDisplayTime(value!, hours: false);
              return Text(displayTime,
                  style: const TextStyle(
                      fontSize: 40, fontWeight: FontWeight.bold));
            }),
        const SizedBox(height: 4),
        ElevatedButton(
          onPressed: () {
            app.startOneTimer(id: item.id);
          },
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(14),
          ),
          child: const Icon(Icons.play_arrow_outlined)
        )
      ]),
    ),
  );
}
