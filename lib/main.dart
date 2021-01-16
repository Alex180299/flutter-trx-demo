import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class Session {
  int id;
  int approved;
  int disapproved;

  Session(this.id, this.approved, this.disapproved);

  static Session fromJson(json) {
    return Session(json['id'], json['approved'], json['disapproved']);
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int touchedIndex;
  StompClient stompClient;

  @override
  void initState() {
    stompClient = StompClient(
        config: StompConfig(
            url: 'ws://192.168.100.40:8080/socket',
            onConnect: (StompClient client, StompFrame frame) {
              client.subscribe(
                  destination: '/sessions/config',
                  callback: (StompFrame frame) {
                    updateSessions(frame.body);
                  });
            },
            onWebSocketError: (dynamic error) => print(error.toString()),
            stompConnectHeaders: {'Authorization': 'Bearer yourToken'},
            webSocketConnectHeaders: {'Authorization': 'Bearer yourToken'}));
    super.initState();
  }

  void updateSessions(String body) {
    setState(() {
      sections = (json.decode(body) as List)
          .map((jsonSession) => Session.fromJson(jsonSession))
          .map((session) => [
                PieChartSectionData(
                  color: const Color(0xff0293ee),
                  value: session.approved.toDouble() + 1,
                  title: '${session.approved}%',
                  radius: 50,
                  titleStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffffffff)),
                ),
                PieChartSectionData(
                  color: const Color(0xff0293ee),
                  value: session.disapproved.toDouble() + 1,
                  title: '${session.disapproved}%',
                  radius: 50,
                  titleStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffffffff)),
                )
              ])
          .toList();
    });
  }

  List<List<PieChartSectionData>> sections = [];

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = List.generate(
        sections.length,
        (index) => Row(
              children: [
                PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse.touchedSectionIndex;
                          }
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: sections[index]),
                ),
                PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse.touchedSectionIndex;
                          }
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: sections[index]),
                ),
              ],
            ));

    widgets.add(RaisedButton(
      onPressed: () {
        activate();
      },
      child: Text('Generate'),
    ));

    widgets.add(Padding(padding: EdgeInsets.only(bottom: 20)));

    return Scaffold(
      appBar: AppBar(
        title: Text("KS Example"),
      ),
      body: SingleChildScrollView(
        child: Column(children: widgets),
      ),
    );
  }

  activate() {
    stompClient.activate();
  }
}
