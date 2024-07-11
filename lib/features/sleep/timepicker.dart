import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimePickerWidget extends StatefulWidget {
  const TimePickerWidget({super.key});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Selectează Durata Somnului',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16.0),
          const Divider(color: Colors.grey),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 150,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      selectedTime = newDateTime;
                    });
                  },
                  use24hFormat: true,
                  initialDateTime: DateTime(0, 0, 0, 7, 0),
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedTime != null) {
                Navigator.pop(context, selectedTime);
              }
            },
            child: const Text('Setează Timp'),
          ),
        ],
      ),
    );
  }
}
