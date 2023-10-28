import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";
  bool _isRecording = false;

  final nameController = TextEditingController();
  final CountDownController timerController = CountDownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text(
            'Record The Cityscape',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.grey[900],
          actions: [
            IconButton(icon: const Icon(Icons.history), onPressed: () {},)
          ],
          actionsIconTheme: IconThemeData(color: Colors.grey[100]),
        ),
        body: recordingIndicator(),
        floatingActionButton: FloatingActionButton(
          onPressed: showNameDialog,
          backgroundColor: Colors.red,
          child: Icon(Icons.person_add_alt_1_rounded, color: Colors.grey[100]),
        ));
  }

  Center recordingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Offstage(
            offstage: !_isRecording,
            child: countDown(),
          ),
          Offstage(
            offstage: _isRecording,
            child: recordButton(),
          ),
          // countDown(),
          // const SizedBox(height: 20),
          // recordButton(),
        ],
      ),
    );
  }

  ElevatedButton recordButton() {
    return ElevatedButton(
      onPressed: () {
        timerController.start();
        setState(() {
          _isRecording = true;
        });
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey[850]),
        shape: MaterialStateProperty.all(const CircleBorder()),
        padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
        iconSize: MaterialStateProperty.all(75),
      ),
      child: const Icon(
        Icons.radio_button_checked_rounded,
        color: Colors.red,
      ),
    );
  }

  CircularCountDownTimer countDown() {
    return CircularCountDownTimer(
      width: 110,
      height: 110,
      duration: 3, // Set the duration to 15 seconds
      fillColor: Colors.blue,
      ringColor: Colors.white,
      controller: timerController,
      textStyle: TextStyle(
        fontSize: 25,
        color: Colors.grey[100],
        fontWeight: FontWeight.bold,
      ),
      textFormat: CountdownTextFormat.S,
      isTimerTextShown: true, // Show the timer text
      autoStart: false,
      isReverse: true,
      isReverseAnimation: true,
      onStart: () {},
      onComplete: () {
        setState(() {
          _isRecording = false;
        });

        Fluttertoast.showToast(
          msg: 'Recording is complete', // Todo Maybe add filename in msg
          toastLength: Toast.LENGTH_SHORT, 
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
        );
      },
    );
  }

  void showNameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Enter your name')),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Name',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: TextStyle(color: Colors.grey[100]),
          ),
          actions: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey[900]),
              ),
              onPressed: () {
                // Get the name from the controller and save it in the variable
                setState(() {
                  name = nameController.text;
                });
                // Close the dialog box
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(color: Colors.purple[200]),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey[900]),
              ),
              onPressed: () {
                // Close the dialog box without saving the name
                Navigator.pop(context);
              },
              child:
                  Text('Cancel', style: TextStyle(color: Colors.purple[200])),
            ),
          ],
        );
      },
    );
  }
}
