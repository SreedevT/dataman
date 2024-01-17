import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart' show Position;

class MetadataForm extends StatefulWidget {
  final Position? position;
  final String? address;
  final Function(String, int) setPatentState;

  const MetadataForm(
      {super.key,
      required this.position,
      required this.address,
      required this.setPatentState});

  @override
  State<MetadataForm> createState() => _MetadataFormState();
}

class _MetadataFormState extends State<MetadataForm> {
  // State Varialbles
  int selectedIntensity = 0;
  TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    addressController.text = widget.address!;
  }

  @override
  Widget build(BuildContext context) {
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
                        'Latitude: ${widget.position!.latitude.toStringAsFixed(3)}'),
                    Text(
                        'Longitude: ${widget.position!.longitude.toStringAsFixed(3)}'),
                  ],
                ),

                // Display the location name in another row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: addressController,
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
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Call the function with different colors and tooltips
                        colorIcon(
                            Colors.green, 'Low traffic', selectedIntensity, 1,
                            onTap: () => setSheetState(() {
                                  selectedIntensity = 1;
                                })),
                        colorIcon(Colors.yellow, 'Moderate traffic',
                            selectedIntensity, 2,
                            onTap: () => setSheetState(() {
                                  selectedIntensity = 2;
                                })),
                        colorIcon(
                            Colors.orange, 'High traffic', selectedIntensity, 3,
                            onTap: () => setSheetState(() {
                                  selectedIntensity = 3;
                                })),
                        colorIcon(
                            Colors.red, 'Severe traffic', selectedIntensity, 4,
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
                          // Call function to set parent state
                          widget.setPatentState(
                              addressController.text, selectedIntensity);

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
  }

  /// A function that returns a colored circle icon with a tooltip
  Widget colorIcon(
      Color color, String tooltip, int selectedIntensity, int intensity,
      {required Function() onTap}) {
    return GestureDetector(
      onTap: () {
        log('The color is $color and the intensity is $intensity');
        onTap();
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
