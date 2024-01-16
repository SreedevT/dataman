import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'utils/firebase.dart';
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
  // Private Variables
  String _fileName = "";
  // completers can hold futures.
  // When a specific event occurs, the future can be set to completed
  //? This is used to make sure both tasks are completed before sending data
  Completer<void> recordingCompleter = Completer<void>();
  Completer<void> bottomSheetCompleter = Completer<void>();

  // State Variables
  String name = "Default";
  int duration = 15;
  bool _isRecording = false;
  String address = "";
  Position? position;
  int selectedIntensity = 0;

  // Controllers
  TextEditingController addressController = TextEditingController();

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
    addressController.dispose();
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
            "The address is $address",
            style: TextStyle(color: Colors.grey[100]),
          ),
        ],
      ),
    );
  }

  ElevatedButton recordButton() {
    return ElevatedButton(
      onPressed: () async {
        // Assign its future to the recording variable
        Future<void> recording = recordingCompleter.future;
        timerController.start();
        recordController.startRecording();

        Position? position = await loc.Location().getCurrentPosition();
        String address = "NA";
        // Address field is not supported in web
        if (!kIsWeb) {
          address = await loc.Location().getAddressFromLatLng(position!) ?? "";
        }
        setState(() {
          this.position = position;
          this.address = address;
          addressController.text = address;
        });
        Future bottomSheet = bottomSheetCompleter.future;
        // ignore: use_build_context_synchronously
        _showBottomSheet(context);

        await Future.wait([recording, bottomSheet]).then((value) async {
          await sendData(
              fileName: _fileName,
              address: addressController.text,
              trafficIntensity: selectedIntensity,
              position: position);

          recordingCompleter = Completer<void>();
          bottomSheetCompleter = Completer<void>();

          log('The data has been sent $_fileName, ${addressController.text}, $selectedIntensity, $position');

          // Reset the selected intensity after sending data.
          setState(() {
            selectedIntensity = 0;
          });
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
            },
            onComplete: () async {
              setState(() {
                _isRecording = false;
              });

              await recordController.stopRecording().then((fileName) {
                _fileName = fileName;

                // Complete the recording completer
                recordingCompleter.complete();
              });
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

        await recordController.stopRecording().then((fileName) {
          _fileName = fileName;

          // Complete the recording completer
          recordingCompleter.complete();
        });
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

  Future<void> _showBottomSheet(BuildContext context) {
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
                            controller: addressController,
                            onChanged: (value) {
                              setSheetState(() {
                                address = addressController.text;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Address',
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
                            onPressed: () async {
                              // Complete the bottom sheet completer
                              bottomSheetCompleter.complete();

                              Navigator.pop(context);
                              Fluttertoast.showToast(
                                msg: 'Data has been saved.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.SNACKBAR,
                                backgroundColor: Colors.grey,
                                textColor: Colors.white,
                              );
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
    return Future.value();
  }
}
