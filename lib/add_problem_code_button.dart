import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'custom_rect_tween.dart';
import 'hero_dialog_route.dart';
import 'globals.dart' as globals;

/// Tag-value used for the add problem-code popup button.
const String _heroAddProblem = 'add-problem-code-hero';

/// {@template add_problem_code_button}
/// Button to add a new [Problem Code].
///
/// Opens a [HeroDialogRoute] of [_AddProblemCodePopupCard].
///
/// Uses a [Hero] with tag [_heroAddProblem].
/// {@endtemplate}
class AddProblemCodeButton extends StatelessWidget {
    /// {@macro add_problem_code_button}
    const AddProblemCodeButton({Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.all(32.0), // makes the button not extremely at the bottom-right of the app's UI
            child: MouseRegion( // to change mouse from couser to pointer when hovering, source: https://www.youtube.com/watch?v=1oF3pI5umck
                cursor: SystemMouseCursors.click, // <---||
                child: GestureDetector(
                onTap: () {
                    Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                        return _AddProblemCodePopupCard();
                    }));
                },
                child: Hero(
                    tag: _heroAddProblem,
                    createRectTween: (begin, end) { // the animation done from this button to _AddProblemCodePopupCart widget (which is displayed on a new page due to Navigator.of())
                        return CustomRectTween(begin: begin!, end: end!);
                    },
                    child: Container(
                        constraints: const BoxConstraints(
                            minHeight: 50, 
                            minWidth: 50
                        ),
                        child: Material( // the actual button UI
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                            child: const Icon(
                                Icons.add_chart,
                                size: 35,
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}

/// {@template add_todo_popup_card}
/// Popup card to add a new [Problem Code]. Should be used in conjuction with
/// [HeroDialogRoute] to achieve the popup effect.
///
/// Uses a [Hero] with tag [_heroAddProblem].
/// {@endtemplate}
class _AddProblemCodePopupCard extends StatelessWidget {
    /// {@macro add_problem_code_popup_card}
    _AddProblemCodePopupCard({Key? key}) : super(key: key);
    final _myTextController1 = TextEditingController(); // for fetching problem code from top text field
    final _myTextController2 = TextEditingController(); // for fetching problem type from bottom text field
    final _myTextController3 = TextEditingController(); // for fetching Google sheets ID
    String googleSheetsID = "";
    @override
    Widget build(BuildContext context) {
        return Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width / 3,
                child: Hero(
                    tag: _heroAddProblem,
                    createRectTween: (begin, end) {
                        return CustomRectTween(begin: begin!, end: end!);
                    },
                    child: Material( // the actual rectangular card that appears in the UI
                        color: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        child: SingleChildScrollView(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0), // padding between all child elements and parent container (card)
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        TextField( // text fields look source: https://www.javatpoint.com/flutter-textfield
                                            controller: _myTextController1,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),  
                                                labelText: 'Problem Code',  
                                                hintText: 'found in codeforces url, ex: 713',  
                                            ),
                                        ),
                                        const Divider(
                                            color: Colors.white,
                                            thickness: 0.4,
                                        ),
                                        TextField(
                                            controller: _myTextController2,
                                            decoration: const InputDecoration(
                                                border: OutlineInputBorder(),  
                                                labelText: 'Problem Level',  
                                                hintText: 'ex: A,B,C,...',  
                                            ),
                                            cursorColor: Colors.blue,
                                            maxLines: 1,
                                        ),
                                        const Divider(
                                            color: Colors.white,
                                            thickness: 0.4,
                                        ),
                                        if (googleSheetsID == "") ...[
                                            TextField(
                                                controller: _myTextController3,
                                                decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),  
                                                    labelText: 'Google Sheets ID',  
                                                    hintText: 'string between d/ and /edit',  
                                                ),
                                                cursorColor: Colors.blue,
                                                maxLines: 1,
                                            ),
                                            const Divider(
                                                color: Colors.white,
                                                thickness: 0.4,
                                            ),
                                        ],
                                        SizedBox(
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                  child: (googleSheetsID == "") ? Text("Submit ID") : Text("Change ID"),
                                                  onPressed: () {
                                                      if (googleSheetsID == "") {
                                                          googleSheetsID = _myTextController3.text;
                                                          // to do: function validateID();
                                                      } else {
                                                          String oldID = googleSheetsID;
                                                          googleSheetsID = "";
                                                      }
                                                  },
                                              ),
                                              ElevatedButton(
                                                  child: const Text('Track'),
                                                  onPressed: () async {
                                                      // logic to fetch problem name
                                                      String code = _myTextController1.text;
                                                      String level = _myTextController2.text;
                                                      String newProb = await getProblemName(link: "https://codeforces.com/problemset/problem/$code/$level");
                                                      if (newProb == "-1" || newProb == "-2") {
                                                          return showDialog(
                                                                  context: context, 
                                                                  builder: (BuildContext context) => AlertDialog(
                                                                      title: const Text('Error'),
                                                                      content:  Text(
                                                                          newProb == "-1" ?
                                                                          "No internet connection"
                                                                          : "Problem not found"
                                                                          ),
                                                                      actions: [
                                                                          TextButton(
                                                                              onPressed: () => Navigator.pop(context, 'OK'),
                                                                              child: const Text('OK'),
                                                                          ),
                                                                      ],
                                                                  )
                                                              );
                                                      }
                                                      else{
                                                          globals.problemNameCard.value = true;
                                                          globals.problemName = newProb;
                                                          globals.problemCode = code;
                                                          globals.problemLevel = level;
                                                          Navigator.pop(context); // closes card
                                                      }
                                                  },
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                ),
            ),
        );
    }
}

Future<String> getProblemName({required String link}) async{
    var response = await http.get(Uri.parse(link));
    if(response.statusCode != 200){
        return "-1";
    }
    String htmlToParse = response.body;
    RegExp regex = RegExp(r'<div class="title">([^<]*)</div>');
    if (!regex.hasMatch(htmlToParse)){
        return "-2";
    }
    return regex.firstMatch(htmlToParse)!.groups([1])[0]!;
}