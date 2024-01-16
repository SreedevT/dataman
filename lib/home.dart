import 'dart:developer';
import 'utils/recorder.dart';
import 'utils/shared_pref.dart';
import 'widgets/color_icon.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:geolocator/geolocator.dart';
import 'utils/location.dart' as loc;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State Variables
  String name = "Default";
  int duration = 15;
  bool _isRecording = false;
  String location = "";
  Position? position;
  int selectedIntensity = 0;

  // Controllers
  TextEditingController locationController = TextEditingController();

  final nameController = TextEditingController();
  final CountDownController timerController = CountDownController();

  RecordController recordController = RecordController();

  @override
  void initState() {
    super.initState();
    // Get the name from the shared preferences
    getValue('name').then((value) {
      nameController.text = value;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.dispose();
    locationController.dispose();
    recordController.dispose();

    super.dispose();
  }

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
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {},
            )
          ],
          actionsIconTheme: IconThemeData(color: Colors.grey[100]),
        ),
        body: Stack(
          children: [
            durationBox(),
            recordingIndicator(),
          ],
        ),
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
          const SizedBox(height: 20),
          Text(
            "The coordinates are $location",
            style: TextStyle(color: Colors.grey[100]),
          ),
        ],
      ),
    );
  }

  ElevatedButton recordButton() {
    return ElevatedButton(
      onPressed: () async {
        timerController.start();

        Position? position = await loc.Location().getCurrentPosition();
        String address =
            await loc.Location().getAddressFromLatLng(position!) ?? "";

        setState(() {
          this.position = position;
          location = address;
          locationController.text = address;
        });

        // ignore: use_build_context_synchronously
        _showBottomSheet(context);
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

  Widget countDown() {
    return SizedBox(
      width: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularCountDownTimer(
            key: ValueKey(duration),
            width: 110,
            height: 110,
            duration: duration,
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
            onStart: () {
              log('The timer has started with duration $duration');
              setState(() {
                _isRecording = true;
              });
              recordController.startRecording();
            },
            onComplete: () {
              setState(() {
                _isRecording = false;
                selectedIntensity = 0;
              });

              recordController.stopRecording();
            },
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: stopButton(),
          ),
        ],
      ),
    );
  }

  Widget durationBox() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        width: 110, // Set this to the width of your record icon
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Duration',
            hintText: 'Duration',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(
                  20)), // This makes the TextField have rounded corners
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
          ),
          style: TextStyle(color: Colors.grey[100]),
          enabled: !_isRecording,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              duration = int.parse(value);
              log('The duration is $duration');
            });
          },
        ),
      ),
    );
  }

  Widget stopButton() {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          _isRecording = false;
        });
        await recordController.stopRecording();
        timerController.reset();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.grey[850]),
        shape: MaterialStateProperty.all(const CircleBorder()),
        padding: MaterialStateProperty.all(const EdgeInsets.all(20)),
        iconSize: MaterialStateProperty.all(35),
      ),
      child: const Icon(
        Icons.stop,
        color: Colors.red,
      ),
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
                // Save the name in the shared preferences
                storeValue('name', nameController.text);
                // Reinit the record controller, this updates the name value used in the filename
                recordController.init();
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return SingleChildScrollView(
            child: AnimatedPadding(
              padding: MediaQuery.of(context).viewInsets,
              duration: const Duration(milliseconds: 100),
              curve: Curves.decelerate,
              child: Container(
                height: 300,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Display the latitude and longitude in one row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                            'Latitude: ${position!.latitude.toStringAsFixed(3)}'),
                        Text(
                            'Longitude: ${position!.longitude.toStringAsFixed(3)}'),
                      ],
                    ),
                    // Display the location name in another row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: locationController,
                            decoration: InputDecoration(
                              hintText: 'Location',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                            ),
                            style: TextStyle(color: Colors.grey[100]),
                          ),
                        ),
                      ],
                    ),
                    // Display the option to pick from 4 colors which represent the traffic congestion
                    Column(
                      children: [
                        Text(
                          'Select the traffic intensity',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Call the function with different colors and tooltips
                            colorIcon(Colors.green, 'Low traffic',
                                selectedIntensity, 1,
                                onTap: () => setSheetState(() {
                                      selectedIntensity = 1;
                                    })),
                            colorIcon(Colors.yellow, 'Moderate traffic',
                                selectedIntensity, 2,
                                onTap: () => setSheetState(() {
                                      selectedIntensity = 2;
                                    })),
                            colorIcon(Colors.orange, 'High traffic',
                                selectedIntensity, 3,
                                onTap: () => setSheetState(() {
                                      selectedIntensity = 3;
                                    })),
                            colorIcon(Colors.red, 'Severe traffic',
                                selectedIntensity, 4,
                                onTap: () => setSheetState(() {
                                      selectedIntensity = 4;
                                    })),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                            onPressed: () {
                              //submitData();
                              Navigator.pop(context);
                              log("Submit button pressed");
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                  color: Colors.purple[300],
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
