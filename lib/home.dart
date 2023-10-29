import 'dart:developer';

import 'package:dataman/utils/shared_pref.dart';
import 'package:dataman/utils/traffic_api.dart';
import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'utils/location.dart' as loc;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State Variables
  String name = "";
  bool _isRecording = false;
  String location = "";
  Position? position;
  int selectedIntensity = 0;

  // Controllers
  TextEditingController locationController = TextEditingController();

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
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {},
            )
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
        Position? position = await loc.Location().getCurrentPosition();
        String address =
            await loc.Location().getAddressFromLatLng(position!) ?? "";

        setState(() {
          this.position = position;
          location = address;
          locationController.text = address;
          _isRecording = true;
        });

        timerController.start();

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
                // Save the name in the shared preferences
                storeValue('name', name);
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
                            _colorIcon(
                                Colors.green, 'Low traffic', 1, setSheetState),
                            _colorIcon(Colors.yellow, 'Moderate traffic', 2,
                                setSheetState),
                            _colorIcon(Colors.orange, 'High traffic', 3,
                                setSheetState),
                            _colorIcon(
                                Colors.red, 'Severe traffic', 4, setSheetState),
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
                            onPressed: () {},
                            child: Text("Submit", style: TextStyle(color: Colors.purple[300], fontSize: 16, fontWeight: FontWeight.bold),),
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

  // A function that returns a colored circle icon with a tooltip
  Widget _colorIcon(
      Color color, String tooltip, int intensity, StateSetter setSheetState) {
    return GestureDetector(
      onTap: () {
        log('The color is $color and the intensity is $intensity');
        setSheetState(() {
          selectedIntensity = intensity;
        });
      },
      child: Tooltip(
        message: tooltip,
        child: CircleAvatar(
          backgroundColor: color,
          radius: intensity == selectedIntensity ? 18 : 15,
          child: intensity == selectedIntensity
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
