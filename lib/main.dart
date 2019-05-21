import 'dart:async';

import 'package:arduino_drum_emulator/common/model/drum_type.dart';
import 'package:arduino_drum_emulator/common/repository/firestore_repository.dart';
import 'package:arduino_drum_emulator/common/widget/tick_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'common/model/iteration.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Emulate());
  }
}

class Emulate extends StatefulWidget {
  @override
  _EmulateState createState() => _EmulateState();
}

class _EmulateState extends State<Emulate> with SingleTickerProviderStateMixin {
  final SessionProvider sessionProvider = SessionProvider();
  Iteration currentIteration;
  bool play = false;
  Firestore firestore = Firestore.instance;
  AnimationController animationController;
  Animation<Duration> animation;
  Tween<Duration> tween;
  List<Iteration> iteration;
  bool left_drum = false;
  bool right_drum = false;
  bool middle_left_drum = false;
  bool middle_right_drum = false;
  bool init = true;
  var currentStatus;
  int score = 0;
  var doc;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('drum_emulator'),
          centerTitle: true,
        ),
        body: StreamBuilder(
            stream: sessionProvider.getSessionStream(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data != null) {
                if (snapshot.data.documents.isNotEmpty) {
                  doc = snapshot.data.documents.where((doc) => doc.data['instrumentId'] == '3224').toList().first;
                  if(init) {
                    iteration = Iteration.listFromDocuments(doc.data['iteration']);
                    initAnimation(iteration, doc.data['duration']);
                    init = false;
                  }
                  if (doc.data['statusMap']['status'] == 'play' && currentStatus != 'play') {
                    sessionProvider.sendResponse('play').then((_){
                      currentStatus = 'play';
                      playTrack();
                    });
                  } else if (doc.data['statusMap']['status'] == 'pause' && currentStatus != 'pause') {
                    sessionProvider.sendResponse('pause').then((_){
                      currentStatus = 'pause';
                      pauseTrack();
                      animationController.animateBack(doc.data['curDuration']/doc.data['duration'],
                          duration: Duration(microseconds: 1000)).then((_){
                            print('seconds: ${animation.value.inSeconds}');
                      });
                    });
                  } else if (doc.data['statusMap']['status'] == 'stop' && currentStatus !='stop') {
                    currentIteration = iteration.first;
                    sessionProvider.sendResponse('stop').then((_){
                      currentStatus = 'stop';
                      restartTrack();
                    });
                  }
                }
                else{
                  currentStatus = null;
                  doc = null;
                }
              }
              return Column(
                children: <Widget>[
                  Container(child: doc?.data==null ? Text('no status') : Text(doc.data['statusMap']['status'])),
                  Expanded(
                    child: Center(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Expanded(
                              child: DrumTile(
                            color: left_drum ? Colors.white : Colors.red,
                            name: DrumType.left_drum,
                            onTap: () {
                              setState(() {
                                left_drum ? score++ : score--;
                              });
                            },
                          )),
                          Expanded(
                              child: DrumTile(
                            color:
                                middle_left_drum ? Colors.white : Colors.yellow,
                            name: DrumType.middle_left,
                            onTap: () {
                              setState(() {
                                middle_left_drum ? score++ : score--;
                              });
                            },
                          )),
                          Expanded(
                              child: DrumTile(
                            color:
                                middle_right_drum ? Colors.white : Colors.green,
                            name: DrumType.middle_right,
                            onTap: () {
                              setState(() {
                                middle_right_drum ? score++ : score--;
                              });
                            },
                          )),
                          Expanded(
                              child: DrumTile(
                            color: right_drum ? Colors.white : Colors.blue,
                            name: DrumType.right_drum,
                            onTap: () {
                              setState(() {
                                right_drum ? score++ : score--;
                              });
                            },
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
      );
  }

  void initAnimation(List<dynamic> iterations, int duration) {
    List<Iteration> iteration = iterations;
    currentIteration = iteration.first;
    animationController = AnimationController(duration: Duration(seconds: duration), vsync: this);
    tween = Tween(begin: Duration(seconds: 0), end: Duration(seconds: duration));
    animation = tween.animate(animationController);
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        sessionProvider.clearSession('3224');
      }
    });
    animation.addListener(() {
      if (animation.value.inSeconds == currentIteration.start.inSeconds) {
        check();
        if (iteration.indexOf(currentIteration) + 1 < iteration.length) {
          currentIteration = iteration[iteration.indexOf(currentIteration) + 1];
        }
      }
    });
  }

  check() {
    currentIteration.drumTypes.forEach((type) {
      if (type == DrumType.left_drum) {
        setState(() {
          left_drum = true;
          Timer(Duration(seconds: 1), () {
            setState(() {
              left_drum = false;
            });
          });
        });
      } else if (type == DrumType.right_drum) {
        setState(() {
          right_drum = true;
          Timer(Duration(seconds: 1), () {
            setState(() {
              right_drum = false;
            });
          });
        });
      } else if (type == DrumType.middle_left) {
        setState(() {
          middle_left_drum = true;
          Timer(Duration(seconds: 1), () {
            setState(() {
              middle_left_drum = false;
            });
          });
        });
      } else if (type == DrumType.middle_right) {
        setState(() {
          middle_right_drum = true;
          Timer(Duration(seconds: 1), () {
            setState(() {
              middle_right_drum = false;
            });
          });
        });
      }
    });
  }

  void playTrack() {
    animationController.forward();
  }

  void pauseTrack() {
    animationController.stop();
  }

  void restartTrack() {
    animationController.reset();
  }
}

class DrumTile extends StatefulWidget {
  final Color color;
  final String name;
  final VoidCallback onTap;

  const DrumTile({Key key, this.color, this.name, this.onTap})
      : super(key: key);

  @override
  _DrumTileState createState() => _DrumTileState();
}

class _DrumTileState extends State<DrumTile> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(widget.name),
        Card(
            shape:
                CircleBorder(side: BorderSide(color: Colors.grey, width: 20.0)),
            child: InkWell(
                onTap: () => widget.onTap(),
                child: CircleAvatar(
                  backgroundColor: widget.color,
                  radius: 100.0,
                ),),),
      ],
    );
  }
}
