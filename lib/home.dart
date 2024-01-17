import 'dart:async';
import 'dart:developer';
import 'package:dataman/widgets/metadata_form.dart';
import 'package:flutter/foundation.dart';
import 'utils/firebase.dart';
import 'utils/recorder.dart';
import 'utils/shared_pref.dart';
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
  Position? _position;
  int trafficIntesity = 0;

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

    setPositionAddress();
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
            Tooltip(
              message: 'Reset location',
              child: address == "Loading..."
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    )
                  : IconButton(
                      icon: const Icon(Icons.settings_backup_restore),
                      onPressed: () {
                        setPositionAddress();
                      },
                    ),
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

        Future bottomSheet = bottomSheetCompleter.future;
        // ignore: use_build_context_synchronously
        _showBottomSheet(context);

        await Future.wait([recording, bottomSheet]).then((value) async {
          await sendData(
              fileName: _fileName,
              address: addressController.text,
              trafficIntensity: trafficIntesity,
              position: _position);

          recordingCompleter = Completer<void>();
          bottomSheetCompleter = Completer<void>();

          log('The data has been sent $_fileName, ${addressController.text}, $trafficIntesity, $_position');

          // Reset the selected intensity after sending data.
          setState(() {
            trafficIntesity = 0;
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
        child: TextFormField(
          initialValue: duration.toString(),
          autofillHints: const ['10', '15', '30', '60'],
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
              duration = value.isNotEmpty ? int.parse(value) : 0;
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      builder: (context) {
        return MetadataForm(
            position: _position,
            address: address,
            setPatentState: (address, intensity) {
              setState(() {
                this.address = address;
                addressController.text = address;
                trafficIntesity = intensity;
              });

              bottomSheetCompleter.complete();
            });
      },
    );
  }

  void setPositionAddress() async {
    setState(() {
      this.address = "Loading...";
    });
    Position? position = await loc.Location().getCurrentPosition();
    String address = "NA";
    // Address field is not supported in web
    if (!kIsWeb) {
      address = await loc.Location().getAddressFromLatLng(position!) ?? "";
    }
    setState(() {
      _position = position;
      this.address = address;
      addressController.text = address;
    });
  }
}
