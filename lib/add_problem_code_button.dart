import 'package:flutter/material.dart';
import 'package:popup_card/popup_card.dart';

import 'custom_rect_tween.dart';
import 'hero_dialog_route.dart';

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
        return MouseRegion( // to change mouse from couser to pointer when hovering
            cursor: SystemMouseCursors.click, // <---||
            child: Padding(
                padding: const EdgeInsets.all(32.0), // makes the button not extremely at the bottom-right of the app's UI
                child: GestureDetector(
                onTap: () {
                    Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                        return const _AddProblemCodePopupCard();
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
            )
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
    const _AddProblemCodePopupCard({Key? key}) : super(key: key);
    @override
    Widget build(BuildContext context) {
        return Center(
            child: Padding(
                padding: const EdgeInsets.all(32.0),
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
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                        const TextField(
                                            decoration: InputDecoration(
                                                hintText: 'New problem',
                                                border: InputBorder.none,
                                            ),
                                            cursorColor: Colors.white,
                                        ),
                                        const Divider(
                                            color: Colors.white,
                                            thickness: 0.2,
                                        ),
                                        const TextField(
                                            decoration: InputDecoration(
                                                hintText: 'Write a note',
                                                border: InputBorder.none,
                                            ),
                                            cursorColor: Colors.white,
                                            maxLines: 6,
                                        ),
                                        const Divider(
                                            color: Colors.white,
                                            thickness: 0.2,
                                        ),
                                        ElevatedButton(
                                            onPressed: () {},
                                            child: const Text('Add'),
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