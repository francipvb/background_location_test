import 'package:background_location_test/geolocation.dart';
import 'package:background_locator/location_dto.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';

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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _locationRunning = false;
  bool _processing = false;
  Stream<LocationDto> _locationStream;

  @override
  void initState() {
    super.initState();
    _loadLocator();
  }

  Future<void> _toggleReporting() async {
    if (_processing) return;
    try {
      setState(() {
        _processing = true;
      });
      if (_locationRunning) {
        await stopListening();
      } else {
        if (await _checkAndRequestPermissions()) {
          await startListening();
        }
      }
      _checkIfRunning();
    } finally {
      setState(() {
        _processing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_locationRunning)
              Text('Reporting location data.')
            else
              Text('Reporting is disabled right now.')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: !_processing ? _toggleReporting : null,
        tooltip: _locationRunning ? 'Stop' : 'Start',
        child: Icon(_locationRunning ? Icons.stop : Icons.play_arrow),
      ),
    );
  }

  Future<void> _loadLocator() async {
    await configureLocationListener();
    await _checkIfRunning();
  }

  Future<void> _checkIfRunning() async {
    bool isRunning = await isListening;
    setState(() {
      _locationRunning = isRunning;
    });
  }

  Future<bool> _checkAndRequestPermissions() async {
    final permissions = LocationPermissions();
    var status = await permissions.checkPermissionStatus(
      level: LocationPermissionLevel.locationAlways,
    );
    if (status == PermissionStatus.granted) {
      return true;
    }

    status = await permissions.requestPermissions(
      permissionLevel: LocationPermissionLevel.locationAlways,
    );
    if (status == PermissionStatus.granted) {
      return true;
    }

    return false;
  }
}
