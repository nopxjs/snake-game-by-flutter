// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:html';

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snake_game/blank_pixel.dart';
import 'package:snake_game/food_pixel.dart';
import 'package:snake_game/highscore_tile.dart';
import 'package:snake_game/snake_pixel.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum snake_Direction { UP, DOWN, LEFT, RIGHT }

class _HomePageState extends State<HomePage> {
  //grid dism
  int rowSize = 15;
  bool _btnActive = false;
  int totalNumberOfSquare = 225;

  //SCORE
  int currentScore = 0;
//game setting
  bool started = false;
  final _nameController = TextEditingController();
  //sneak position
  List<int> snakePos = [
    0,
    1,
    2,
  ];

  //snake direction
  var currentDirection = snake_Direction.RIGHT;
  //food pos
  int foodPos = 100;

  //highscore list
  List<String> highscores_DocId = [];
  late final Future? letsGetDocIds;
  @override
  void initState() {
    letsGetDocIds = getDocId();
    super.initState();
  }

  Future getDocId() async {
    await FirebaseFirestore.instance
        .collection("highscores")
        .orderBy("score", descending: true)
        .limit(10)
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              highscores_DocId.add(
                element.reference.id,
              );
            },
          ),
        );
  }
  //startgame

  void startgame() {
    started = true;
    Timer.periodic(Duration(milliseconds: 200), (timer) {
      setState(() {
        movesnake();

        //check game is alive
        if (gameOver()) {
          timer.cancel();

          //display user massage
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return Center(
                  child: AlertDialog(
                    insetPadding: EdgeInsets.only(top: 225, bottom: 225),
                    title: Text(
                      'Game over',
                      style: GoogleFonts.pressStart2p(
                        color: Color.fromARGB(255, 243, 76, 70),
                      ),
                    ),
                    content: Column(
                      children: [
                        Text(
                          'Your score is ' + currentScore.toString(),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 10,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        TextField(
                          controller: _nameController,
                          style: GoogleFonts.pressStart2p(fontSize: 10),
                          decoration: InputDecoration(
                            labelStyle: GoogleFonts.pressStart2p(fontSize: 10),
                            hintText: "Enter name",
                            hintStyle: GoogleFonts.pressStart2p(fontSize: 10),
                          ),
                          onChanged: (value) {
                            _btnActive = value.length >= 1 ? true : false;
                          },
                        )
                      ],
                    ),
                    actions: [
                      MaterialButton(
                          onPressed: () {
                            if (_btnActive) {
                              Navigator.pop(context);
                              submitScore();
                              newGame();
                            } else {
                              null;
                            }
                          },
                          child: Text(
                            'Submit',
                            style: GoogleFonts.pressStart2p(
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          color: Colors.green[400]),
                    ],
                  ),
                );
              });
        }
      });
    });
  }

  Future newGame() async {
    highscores_DocId = [];
    await getDocId();
    setState(() {
      currentScore = 0;
      //sneak position
      snakePos = [
        0,
        1,
        2,
      ];
      foodPos == 100;
      currentDirection = snake_Direction.RIGHT;
      started = false;
    });
  }

  void submitScore() {
    //submit name and score,
    var database = FirebaseFirestore.instance;
    database.collection("highscores").add({
      "name": _nameController.text,
      "score": currentScore,
    });
  }

  void eatFood() {
    currentScore++;
    while (snakePos.contains(foodPos)) {
      foodPos = Random().nextInt(225);
    }
  }

  void movesnake() {
    switch (currentDirection) {
      case snake_Direction.RIGHT:
        {
          if (snakePos.last % rowSize == 14) {
            snakePos.add(snakePos.last + 1 - rowSize);
          } else {
            snakePos.add(snakePos.last + 1);
          }
          //remove last
        }
        break;
      case snake_Direction.LEFT:
        {
          //add head
          if (snakePos.last % rowSize == 0) {
            snakePos.add(snakePos.last - 1 + rowSize);
          } else {
            snakePos.add(snakePos.last - 1);
          } //remove last
        }
        break;
      case snake_Direction.UP:
        {
          if (snakePos.last < rowSize) {
            snakePos.add(snakePos.last - rowSize + totalNumberOfSquare);
          } else {
            snakePos.add(snakePos.last - rowSize);
          }
          //remove last
        }
        break;
      case snake_Direction.DOWN:
        {
          if (snakePos.last + rowSize > totalNumberOfSquare) {
            snakePos.add(snakePos.last + rowSize - totalNumberOfSquare);
          } else {
            snakePos.add(snakePos.last + rowSize);
          } //remove last
        }
        break;
      default:
    }
    if (snakePos.last == foodPos) {
      eatFood();
    } else {
      snakePos.removeAt(0);
    }
  }

  bool gameOver() {
    //if snake in self
    List<int> bodysnake = snakePos.sublist(0, snakePos.length - 1);

    if (bodysnake.contains(snakePos.last)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    //get responsive
    double screenWidth = MediaQuery.of(context).size.width;
    return RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.logicalKey == LogicalKeyboardKey.keyD &&
              currentDirection != snake_Direction.LEFT) {
            currentDirection = snake_Direction.RIGHT;
          }
          if (event.logicalKey == LogicalKeyboardKey.keyS &&
              currentDirection != snake_Direction.UP) {
            currentDirection = snake_Direction.DOWN;
          }
          if (event.logicalKey == LogicalKeyboardKey.keyW &&
              currentDirection != snake_Direction.DOWN) {
            currentDirection = snake_Direction.UP;
          }
          if (event.logicalKey == LogicalKeyboardKey.keyA &&
              currentDirection != snake_Direction.RIGHT) {
            currentDirection = snake_Direction.LEFT;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SizedBox(
            width: screenWidth > 428 ? 428 : screenWidth,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //hight score
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Current Score:',
                                style: GoogleFonts.pressStart2p(
                                    fontSize: 10,
                                    color: Colors.green[400],
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                currentScore.toString(),
                                style: GoogleFonts.pressStart2p(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: started
                              ? Container()
                              : FutureBuilder(
                                  future: letsGetDocIds,
                                  builder: (context, snapshot) {
                                    return ListView.builder(
                                      itemCount: highscores_DocId.length,
                                      itemBuilder: ((context, index) {
                                        return HighscoreTile(
                                            docmentId: highscores_DocId[index]);
                                      }),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),

                  //grid
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        if (details.delta.dx > 0 &&
                            currentDirection != snake_Direction.LEFT) {
                          currentDirection = snake_Direction.RIGHT;
                        } else if (details.delta.dx < 0 &&
                            currentDirection != snake_Direction.RIGHT) {
                          currentDirection = snake_Direction.LEFT;
                        }
                      },
                      onVerticalDragUpdate: (details) {
                        if (details.delta.dy > 0 &&
                            currentDirection != snake_Direction.UP) {
                          currentDirection = snake_Direction.DOWN;
                        } else if (details.delta.dy < 0 &&
                            currentDirection != snake_Direction.DOWN) {
                          currentDirection = snake_Direction.UP;
                        }
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        width: MediaQuery.of(context).size.width * 0.6,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: totalNumberOfSquare,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: rowSize,
                          ),
                          itemBuilder: (context, index) {
                            if (snakePos.contains(index)) {
                              return const SnakePixels();
                            } else if (foodPos == (index)) {
                              return const FoodPixels();
                            } else {
                              return const BlankPixels();
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  //play button
                  Expanded(
                    child: Container(
                      child: Center(
                        child: MaterialButton(
                          onPressed: () {
                            if (started) {
                              return;
                            } else {
                              startgame();
                            }
                          },
                          color: started
                              ? Color.fromARGB(255, 105, 139, 60)
                              : Color.fromARGB(255, 30, 233, 91),
                          child: Text(
                            'Play',
                            style: GoogleFonts.pressStart2p(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
