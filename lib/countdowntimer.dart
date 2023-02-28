import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CountdownTimer extends StatefulWidget {
  final String origin;
  final String destination;
  final String apiKey;

  CountdownTimer({
    required this.origin,
    required this.destination,
    required this.apiKey,
  });

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration? _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getDuration();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _getDuration() async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${widget.origin}&destinations=${widget.destination}&key=${widget.apiKey}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final durationInSeconds =
          data['rows'][0]['elements'][0]['duration']['value'];
      setState(() {
        _duration = Duration(seconds: durationInSeconds);
      });
      _startTimer();
    } else {
      throw Exception('Failed to load distance matrix API');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if ((_duration?.inSeconds ?? 0) > 0) {
          _duration = Duration(seconds: _duration!.inSeconds - 1);
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bus starting From: ${widget.origin}',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            'To: ${widget.destination}',
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          _duration == null
              ? CircularProgressIndicator()
              : Center(
                  child: Text(
                    'Will reach in : ${_formatDuration(_duration!)}',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
