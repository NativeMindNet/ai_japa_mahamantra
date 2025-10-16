import 'package:flutter/material.dart';
import 'dart:math';
import 'lib/widgets/japa_mala_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Beads Widget',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentBead = 0;
  final int totalBeads = 108;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Beads and Circles'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Bead: $currentBead',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Container(
              width: 300,
              height: 300,
              child: JapaMalaWidget(
                currentBead: currentBead,
                totalBeads: totalBeads,
                onBeadTap: (int beadIndex) {
                  setState(() {
                    currentBead = beadIndex;
                  });
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentBead = (currentBead + 1) % (totalBeads + 1);
                    });
                  },
                  child: Text('Next'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentBead = 0;
                    });
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
