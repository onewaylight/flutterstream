import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final StreamController<int> _streamController = StreamController();
  final StreamController<bool> _ctrl = StreamController();
  final Stream<int> stream =
      Stream.periodic(Duration(seconds: 1), (int x) => x);

  void _incrementCounter() {
    _streamController.sink.add(++_counter);
    bool mi = _counter % 2 == 0 ? true : false;
    _ctrl.sink.add(mi);

    setState(() {
      // _counter++;
    });
  }

  Stream<http.Response> btcstream() async* {
    yield* Stream.periodic(Duration(seconds: 5), (_) {
      developer.log('Call Bitcoin Data');
      return http.get(Uri.parse("https://api.bithumb.com/public/ticker/BTC"));
    }).asyncMap((event) async => await event);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            StreamBuilder(
                stream: btcstream(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    Map bitcoinData = jsonDecode(snapshot.data.body);
                    return Text(
                        '${bitcoinData['data']['closing_price']} Price of Bitcoin');
                  } else {
                    return Text('No Data');
                  }
                }),
            StreamBuilder<int>(
                stream: _streamController.stream,
                initialData: _counter,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  return Text('You hit me ${snapshot.data} times');
                }),
            StreamBuilder<bool>(
                stream: _ctrl.stream,
                initialData: (_counter % 2 == 0 ? true : false),
                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                  return Text('Even or Odd?  ${snapshot.data.toString()}');
                }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
