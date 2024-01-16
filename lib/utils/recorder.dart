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
    if (!kIsWeb && !await directoryPath.exists()) {
      await directoryPath.create();
    }

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
    String path = "";
    await record.stop().then((value) {
      path = value!;
      if (kIsWeb) saveRecordingWeb(value);
    });

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

  void saveRecordingWeb(String url) {
    // Create a link with the Blob URL
    AnchorElement(href: url)
      ..setAttribute('download', '${unixTime}_$name.wav')
      ..click();

    // Revoke the Blob URL
    Url.revokeObjectUrl(url);
  }
}
