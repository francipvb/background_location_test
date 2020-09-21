import 'dart:isolate';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';

final _uiPort = ReceivePort();

const _isolateName = "location_isolate";

Future<void> configureLocationListener() async {
  IsolateNameServer.registerPortWithName(_uiPort.sendPort, _isolateName);
  await BackgroundLocator.initialize();
}

Future<bool> get isListening async =>
    await BackgroundLocator.isServiceRunning();

Future<void> startListening() async {
  if (!await BackgroundLocator.isRegisterLocationUpdate()) {
    await BackgroundLocator.registerLocationUpdate(
      _handleLocationReceived,
      initCallback: _backgroundInitialize,
      disposeCallback: _disposeBackground,
      androidSettings: AndroidSettings(
        accuracy: LocationAccuracy.HIGH,
      ),
      autoStop: false,
    );
  } else {
    throw UnsupportedError('The service is already running.');
  }
}

Future<void> stopListening() async {
  if (await BackgroundLocator.isRegisterLocationUpdate()) {
    await BackgroundLocator.unRegisterLocationUpdate();
  } else {
    throw UnsupportedError('The service is not running.');
  }
}

void _disposeBackground() {
  print('disposing...');
}

void _backgroundInitialize(Map<String, dynamic> data) {
  print('Initialized background locator.');
  print(data);
}

void _handleLocationReceived(LocationDto location) async {
  final port = IsolateNameServer.lookupPortByName(_isolateName);
  port.send(location.toJson());
  print('Location report...');
}

Stream<LocationDto> getLocationStream() {
  return _uiPort.map((event) => LocationDto.fromJson(event));
}
