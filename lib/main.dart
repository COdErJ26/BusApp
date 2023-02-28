import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'DistanceTime.dart';
import 'countdowntimer.dart';

void main() {
  runApp(const MaterialApp(
    home: FrontScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class FrontScreen extends StatefulWidget {
  const FrontScreen({super.key});

  @override
  State<FrontScreen> createState() => _FrontScreenState();
}

class _FrontScreenState extends State<FrontScreen> {
  var _source = '';
  late Future<DistanceTime> result;
  var _destination = ' ';
  bool display = false;

  var answers = ['Answer 1', 'Answer 2', 'Answer 3'];
  String apiKey = "AIzaSyAkZEEYr7f9GW_63YQB6GuJA5rqnij7_JA";
  Future<DistanceTime> fetchDistanceTime(
      String apiKey, String origin, String destination) async {
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=$origin&destinations=$destination&key=$apiKey'));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final distance = result['rows'][0]['elements'][0]['distance']['text'];
      final duration = result['rows'][0]['elements'][0]['duration']['text'];
      return DistanceTime(distance: distance, time: duration);
    } else {
      throw Exception('Failed to fetch distance and time');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Where to go"),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            Container(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Source',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: 'Enter your Source',
                ),
                onChanged: (value) {
                  setState(() {
                    _source = value;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: 300,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Destination',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: 'Enter your Destination',
                ),
                onChanged: (value) {
                  setState(() {
                    _destination = value;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: (() {
                      // fetchDistanceTime(apiKey, _source, _destination);
                      setState(() {
                        display = true;
                      });
                    }),
                    child: const Text("GET")),
                ElevatedButton(
                    onPressed: (() {
                      setState(() {
                        display = false;
                      });
                    }),
                    child: Text("CLEAR")),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            if (display)
              FutureBuilder<DistanceTime>(
                future: fetchDistanceTime(apiKey, _source, _destination),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('');
                  } else if (!snapshot.hasData) {
                    return Text('No Data Found');
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Container(
                              width: 350,
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.access_time),
                                    title: Text(
                                      'TIME: ${snapshot.data!.time}',
                                      textScaleFactor: 1,
                                    ),
                                    subtitle: Text(
                                      'DISTANCE: ${snapshot.data!.distance}',
                                      textScaleFactor: 0.75,
                                    ),
                                    tileColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          CountdownTimer(
                            origin: 'Thuvakudi',
                            destination: 'Nit,Trichy',
                            apiKey: 'AIzaSyAkZEEYr7f9GW_63YQB6GuJA5rqnij7_JA',
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
