import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart'; // code related to "stop_watch_timer" package is from here: https://www.youtube.com/watch?v=P6OW1aKV12M
import 'package:date_format/date_format.dart';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'dart:io' show Platform;
import 'package:window_size/window_size.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'add_problem_code_button.dart'; // implementation from "fun with flutter": https://www.youtube.com/watch?v=Bxs8Zy2O4wk
import 'globals.dart' as globals; // use of globals using a "globals" file: https://stackoverflow.com/questions/29182581/global-variables-in-dart
import 'user_sheets_api.dart';
import 'cf_problem.dart';
import 'motion_toast.dart' as toast_file;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized(); // written for UserSheetsApi and Hive
  await Hive.initFlutter();
  await UserSheetsApi.initFromLocal();
  if (Platform.isWindows) {
    setWindowTitle('cf_time_tracker');
    double minWidth = 400, minHeight = 880;
    //setWindowMaxSize(const Size(max_width, max_height));
    setWindowMinSize(Size(minWidth, minHeight));
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

enum ByYourself { yes, no }
enum Accepted { yes, no }

class _MyHomePageState extends State<MyHomePage> {
  final isDialOpen = ValueNotifier(false); // redundant logic, as the speed dial buttons are not used anymore in this project
  final _roadMapTextController = TextEditingController(); // to fetch problem Road Map
  final _diffLevelTextController = TextEditingController(); // to fetch difficulty level
  final _categoryTextController = TextEditingController(); // to fetch category
  final _commentTextController = TextEditingController(); // to fetch comment about the problem
  bool _solutionCodeCard = false;
  int? _dateFormatVal;
  ByYourself _byYourself = ByYourself.yes;
  Accepted _accepted = Accepted.yes;
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
          body: Column( children: [ // to do: make the timer cards centered not left aligned
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
                  // reset button
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blueGrey,
                  ), // finish button
                  child: const Icon(Icons.restart_alt_rounded),                 
                  onPressed: () {
                    for (var item in items) {
                      item.timer.onExecute.add(
                          StopWatchExecute.reset); // resets all timers to 0
                    }
                  },

                ),
              ],
            )),
            const SizedBox(height: 30),
            ValueListenableBuilder( // Class that enables changes on returned widget to appear in the UI if a valueListenable changes, source: https://stackoverflow.com/questions/62007967/updating-a-widget-when-a-global-variable-changes-async-in-flutter
                valueListenable: globals.problemNameCard, // note: search term used to know this info: "refresh when a variable changes flutter"
                builder: (context, value, widget) { // to do: logic that animates card getting bigger/smaller
                    return Visibility(
                        visible: globals.problemNameCard.value,
                        child: SizedBox( // the if() makes the problem name card not visible unless "track" button is pressed
                          width: 400,
                          child: Material(
                              color: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32)),
                              child: Padding(
                                  padding: const EdgeInsets.all(18.0),
                                  child: Column(children: [
                                  Text(
                                      globals.problemName,
                                      style: const TextStyle(fontSize: 20, color: Colors.black),
                                      textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(
                                      height:
                                          20), // space between problem name and check mark
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                        ElevatedButton(
                                          // cancel button
                                          onPressed: () {
                                            globals.problemNameCard.value = false;
                                            globals.problemCode = '...';
                                            globals.problemDiv = '...';
                                            globals.problemLevel = '...';
                                            globals.problemName = '...';
                                            globals.problemLink = '...';
                                            _roadMapTextController.text = '';
                                            _diffLevelTextController.text = '';
                                            _categoryTextController.text = '';
                                            _commentTextController.text = '';
                                            _byYourself = ByYourself.yes;
                                            _dateFormatVal = null;
                                            _solutionCodeCard = false;
                                          },
                                          style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                          ), // finish button
                                          child: const Icon(Icons.cancel),
                                      ),
                                      ElevatedButton(
                                          // finish button
                                          style: ElevatedButton.styleFrom(
                                          primary: !_solutionCodeCard ? Colors.green : Colors.green[800],
                                          ), // finish button
                                          child: !_solutionCodeCard ? const Icon(Icons.check_circle_outline_sharp) : const Icon(Icons.check),
                                          onPressed: () async {
                                            if (!_solutionCodeCard) { 
                                                setState(() {
                                                    _solutionCodeCard = true;
                                                });
                                            } else {
                                                List<String> mins = []; // storing timers' info as minutes
                                                double secOverMin = 0;
                                                // ignore: unused_local_variable, added this comment to avoid vs code false warning 
                                                double minutes = 0;
                                                double totalTime = 0;
                                                for (var item in items) {
                                                    minutes = double.parse(StopWatchTimer.getDisplayTimeMinute(item.timer.rawTime.value)); // source: https://stackoverflow.com/questions/72231057/stop-watch-timer-on-flutter-how-can-i-print-the-time-in-the-terminal-while-pres
                                                    secOverMin = double.parse(StopWatchTimer.getDisplayTimeSecond(item.timer.rawTime.value)) / 60.0;
                                                    minutes += secOverMin;
                                                    String minApp = minutes.toStringAsFixed(1); //ex: 1 minute, 32 seconds, will mean that seconds == 92, so minutes == 1.33333, which will be 1.3 
                                                    mins.add(minApp); 
                                                    totalTime += double.parse(minApp);
                                                }
                                                mins.add(totalTime.toStringAsFixed(1));

                                                DateTime currTime = DateTime.now(); // getting current day with requested format
                                                // ignore: unused_local_variable, added this comment to avoid vs code false warning 
                                                String dateFormatted = "";
                                                switch (_dateFormatVal) {
                                                    case 1:
                                                    dateFormatted = formatDate(currTime, [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]);
                                                    break;
                                                    case 2:
                                                    dateFormatted = formatDate(currTime, [mm, '/', dd, '/', yyyy, ' ', HH, ':', nn]);
                                                    break;
                                                    case 3:
                                                    dateFormatted = formatDate(currTime, [yyyy, '/', mm, '/', dd, ' ', HH, ':', nn]);
                                                    break;
                                                    default:
                                                    dateFormatted = formatDate(currTime, [dd, '/', mm, '/', yyyy, ' ', HH, ':', nn]);
                                                }


                                                final response = await http.get(Uri.parse('https://codeforces.com/submissions/OdyAsh')); // getting submission link and submission count. Source: https://www.youtube.com/watch?v=9ZfRE_DN9a0
                                                dom.Document html = dom.Document.html(response.body);
                                                final subProbNames = html
                                                    .querySelectorAll("table > tbody > tr > td > a") // right click problem name in the inspector, copy as selector, then trim the following (by trial and error) until you obtain required tds: '#pageContent > div.datatable > div:nth-child(6) > table > tbody > tr:nth-child(38) > td:nth-child(4) > a'
                                                    .map((finalTag) => finalTag.innerHtml.trim())
                                                    .toList();
                                                int i = 0, submitCount = 0;
                                                String submissionLink = 'https://codeforces.com/contest/${globals.problemCode}/submission/';
                                                String submissionCode = '';
                                                for (final prob in subProbNames) {
                                                    if (prob.contains(globals.problemName.substring(globals.problemName.indexOf('.')+2))) {
                                                        submitCount++;
                                                        if (submissionLink[submissionLink.length-1] == '/') {
                                                            submissionCode = subProbNames[i-2];
                                                            submissionLink += submissionCode;
                                                        }
                                                    }
                                                    i++;
                                                }

                                                String commentWithDate = '$dateFormatted, ${_commentTextController.text}';
                                                
                                                final cf = { // storing all info in a Map<String, dynamic>
                                                    ProblemFields.roadMap: _roadMapTextController.text == '' ? 'CF Contests' : _roadMapTextController.text,
                                                    ProblemFields.problemName: globals.problemName,
                                                    ProblemFields.problemCode: '=HYPERLINK("${globals.problemLink}", "CF${globals.problemCode}-${globals.problemDiv}-${globals.problemLevel.toUpperCase()}")',
                                                    ProblemFields.problemSolution: '=HYPERLINK("$submissionLink", "$submissionCode")',
                                                    ProblemFields.status:  _accepted.name == "yes" ? "AC" : "CS",
                                                    ProblemFields.submitCount: submitCount,
                                                    ProblemFields.readingTime: mins[0],
                                                    ProblemFields.thinkingTime: mins[1],
                                                    ProblemFields.codingTime: mins[2],
                                                    ProblemFields.debugTime: mins[3],
                                                    ProblemFields.totalTime: mins[4],
                                                    ProblemFields.problemLevel: _diffLevelTextController.text, // difficulty level
                                                    ProblemFields.byYourself: _byYourself.name == "yes" ? "YES" : "NO",
                                                    ProblemFields.category: _categoryTextController.text,
                                                    ProblemFields.comment: commentWithDate,
                                                };
                                                try {
                                                    await UserSheetsApi.insert([cf], justAppend: true);
                                                    setState(() {
                                                        toast_file.displayResponsiveMotionToast(context, "Problem Solved!!!", "This problem's details have been added to sheets");
                                                    });
                                                } catch(e) {
                                                    print(e);
                                                }
                                            }
                                            
                                          },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                      height:
                                          20), // space between buttons and solution code textfield
                                  if (_solutionCodeCard) ...[ // using "...[]" to make multiple widgets appear using if condition. Source: https://stackoverflow.com/questions/49713189/how-to-use-conditional-statement-within-child-attribute-of-a-flutter-widget-cen#:~:text=1%20more%20comment-,169,if%20%2F%20else,-Column(%0A%20%20%20%20children%3A%20%5B%0A%20%20%20%20%20%20%20%20if
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 2,
                                          child: Focus(
                                            onFocusChange: (hasFocus) {
                                              if (!hasFocus) {
                                                // to do: function that validates submission link
                                              }
                                            },
                                            child: TextField(
                                                controller: _roadMapTextController,
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), 
                                                    labelText: 'Road Map',  
                                                    hintText: 'CF Contests',  
                                                ),
                                                textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        const Flexible(
                                            flex: 1,
                                            child: SizedBox(
                                                width: 20,
                                            )
                                        ),
                                        Flexible(
                                          flex: 2,
                                          child: TextField(
                                              controller: _diffLevelTextController,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), 
                                                  labelText: 'Difficulty Level',  
                                                  hintText: '(ex: 1.5)',  
                                              ),
                                              textAlign: TextAlign.center,
                                              onSubmitted: (String text) {
                                                  setState(() {
                                                      // to do: color border to green
                                                  });
                                              }
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height:
                                          20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: TextField(
                                              controller: _categoryTextController,
                                              decoration: InputDecoration(
                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)), 
                                                  labelText: 'Category',  
                                                  hintText: '(ex: impl, dp, greedy)',  
                                              ),
                                              textAlign: TextAlign.center,
                                              onSubmitted: (String text) {
                                                  setState(() {
                                                      // to do: color border to green
                                                  });
                                              }
                                          ),
                                        ),
                                        const Flexible(
                                            flex: 1,
                                            child: SizedBox(
                                                width: 20,
                                            )
                                        ),
                                        Flexible(
                                          flex: 3,
                                          child: DropdownButton(
                                              hint: const Text("Date Format "),
                                              value: _dateFormatVal,
                                              icon: const Icon(Icons.calendar_month),
                                              iconSize: 18.0,
                                              alignment: Alignment.center,
                                              items: const [
                                                  DropdownMenuItem(value: 1, child: Text("D/M/Y H:M")),
                                                  DropdownMenuItem(value: 2, child: Text("M/D/Y H:M")),
                                                  DropdownMenuItem(value: 3, child: Text("Y/M/D H:M")),
                                              ], 
                                              onChanged: (int? value) { 
                                                  setState(() {
                                                      _dateFormatVal = value;
                                                  });
                                               },
                                          ),
                                        ),

                                      ],
                                    ),
                                    const SizedBox(
                                      height:
                                          20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Flexible(
                                          flex: 1,
                                            child: Column(
                                                children: [
                                                    const Text("Accepted?", style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),),
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Column(
                                                              children: [
                                                                Radio(
                                                                    value: Accepted.yes,
                                                                    groupValue: _accepted,
                                                                    activeColor: MaterialStateColor.resolveWith((states) => Colors.green),
                                                                    onChanged: (Accepted? val) {
                                                                        setState(() {
                                                                          _accepted = val!;
                                                                        });
                                                                    },
                                                                ),
                                                                const Icon(Icons.check_circle_outline_sharp, color: Colors.green),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Radio(
                                                                    value: Accepted.no,
                                                                    groupValue: _accepted,
                                                                    activeColor: MaterialStateColor.resolveWith((states) => Colors.red),
                                                                    onChanged: (Accepted? val) {
                                                                        setState(() {
                                                                          _accepted = val!;
                                                                        });
                                                                    },
                                                                ),
                                                                const Icon(Icons.cancel_outlined, color: Colors.red),
                                                              ],
                                                            ),
                                                        ],
                                                    ),
                                                ],
                                            )
                                        ),
                                        Flexible(
                                            flex: 1,
                                            child: Column(
                                                children: [
                                                    const Text("By Yourself?", style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),),
                                                    Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                            Column(
                                                              children: [
                                                                Radio(
                                                                    value: ByYourself.yes,
                                                                    groupValue: _byYourself,
                                                                    activeColor: MaterialStateColor.resolveWith((states) => Colors.green),
                                                                    onChanged: (ByYourself? val) {
                                                                        setState(() {
                                                                          _byYourself = val!;
                                                                        });
                                                                    },
                                                                ),
                                                                const Icon(Icons.check_circle_outline_sharp, color: Colors.green),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                Radio(
                                                                    value: ByYourself.no,
                                                                    groupValue: _byYourself,
                                                                    activeColor: MaterialStateColor.resolveWith((states) => Colors.red),
                                                                    onChanged: (ByYourself? val) {
                                                                        setState(() {
                                                                          _byYourself = val!;
                                                                        });
                                                                    },
                                                                ),
                                                                const Icon(Icons.cancel_outlined, color: Colors.red),
                                                              ],
                                                            ),
                                                        ],
                                                    ),
                                                ],
                                            )
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                        controller: _commentTextController,
                                        decoration: InputDecoration(
                                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),  
                                                labelText: 'Comment',  
                                                hintText: 'ex: hints on how you solved the problem, corner cases',  
                                                hintStyle: const TextStyle(fontSize: 14.0),
                                            ),
                                            cursorColor: Colors.blue,
                                            minLines: 1,
                                            maxLines: 2,
                                    )
                                  ]
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
