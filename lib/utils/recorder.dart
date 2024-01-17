import 'package:universal_html/html.dart';
import 'dart:io';
import 'package:dataman/utils/shared_pref.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:record/record.dart';
import 'dart:developer';

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
    // Create a directory if it doesn't exist in android
    if (!kIsWeb && !await directoryPath.exists()) {
      await directoryPath.create();
    }

    // Request permission to record audio
    if (await record.hasPermission()) {
      log('Permission to record granted');
    } else {
      Fluttertoast.showToast(
        msg: 'Permission to record denied',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
      );
    }

    // Get name from shared preferences
    getValue('name').then((value) {
      name = value;
    });
  }

  void startRecording() async {
    // TODO: Maybe add support for multiple platforms or better compatibility in android

    if (await record.hasPermission()) {
      //Unit time in seconds
      unixTime = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();

      // Start recording to file
      await record.start(const RecordConfig(encoder: AudioEncoder.wav),
          path: '${directoryPath.path}/${unixTime}_$name.wav');
    }
  }

  Future<String> stopRecording() async {
    //Stop recording
    String? path = await record.stop();
    if (kIsWeb) saveRecordingWeb(path);

    Fluttertoast.showToast(
      msg: 'Recording is complete', // Todo Maybe add filename in msg
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );

    log("Recording is complete $path");
    return '${unixTime}_$name';
  }

  void dispose() {
    record.dispose();
  }

  void saveRecordingWeb(String? url) {
    // Create a link with the Blob URL
    AnchorElement(href: url)
      ..setAttribute('download', '${unixTime}_$name.wav')
      ..click();

    // Revoke the Blob URL
    Url.revokeObjectUrl(url!);
  }
}
