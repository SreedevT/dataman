import 'dart:developer';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

Future<void> sendData(
    {required String fileName,
    required String address,
    required int trafficIntensity,
    required Position? position}) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  DateTime recordTime = getRecordTime(fileName); 

  final data = <String, dynamic>{
    'address': address,
    'trafficIntensity': trafficIntensity,
    'position': GeoPoint(position!.latitude, position.longitude),
    'recordTime': recordTime,
  };

  await db.doc('data/$fileName').set(data);

  Fluttertoast.showToast(
    msg: 'Data sent to firebase',
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.SNACKBAR,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
  );

  log('Data sent to firebase');
}

DateTime getRecordTime(String fileName) {
  String unixTime = fileName.split('_')[1];
  DateTime recordTime = DateTime.fromMillisecondsSinceEpoch(int.parse(unixTime) * 1000);
  return recordTime;
}