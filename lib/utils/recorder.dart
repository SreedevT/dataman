import 'package:dataman/utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:record/record.dart';
// import 'package:path_provider/path_provider.dart';
import 'dart:developer';
import 'dart:io';

class RecordController {
  final record = AudioRecorder();
  final Directory directoryPath =
      Directory('/storage/emulated/0/Documents/dataman');
  String? name;
  String? unixTime;

  RecordController() {
    init();
  }

  void init() async {
    if (!await directoryPath.exists()) {
      await directoryPath.create();
    }

    getValue('name').then((value) {
      name = value;
    });
  }

  void startRecording() async {
    // TODO: Maybe add support for multiple platforms or better compatibility in android
    // List<Directory>? appDocDir = await getExternalStorageDirectories();
    // log("The appDocDir is $appDocDir");

    if (await record.hasPermission()) {
      //Unit time in seconds
      unixTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

      // Start recording to file
      await record.start(const RecordConfig(encoder: AudioEncoder.wav),
          path: '${directoryPath.path}/${name}_$unixTime.wav');
    }
  }

  Future<String> stopRecording() async {
    //Stop recording
    final path = await record.stop();

    Fluttertoast.showToast(
      msg: 'Recording is complete', // Todo Maybe add filename in msg
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );

    log("Recording is complete $path");
    return '${name}_$unixTime.wav';
  }

  void dispose() {
    record.dispose();
  }
}
