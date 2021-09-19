import 'dart:math' as math;
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:location/location.dart' as lc;

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with AfterLayoutMixin<MyApp> {
  ///class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;

//coordinates of lysaya gora 22 for exaple
  Offset lg22 = Offset(43.581352, 39.738845);
  Tangent? tangent;

  ///double get tangentAngle => tangent!.angle;
  ///double get tangentAngle => (tangent!.angle) - math.pi / 2;
  double get tangentAngle => (tangent?.angle ?? math.pi / 2) - math.pi / 2;
  //final imageAngle = math.pi / 4.5;

  @override
  void initState() {
    super.initState();

    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Flutter Compass'),
        ),
        body: Builder(builder: (context) {
          if (_hasPermissions) {
            return Column(
              children: <Widget>[
                //_buildManualReader(),
                Container(width: 250, height: 250, child: _buildCompass()),
              ],
            );
          } else {
            return _buildPermissionSheet();
          }
        }),
      ),
    );
  }

  Widget _buildCompass() {
    return Material(
      shape: CircleBorder(),
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      color: Colors.pink,
      shadowColor: Colors.pink,
      child: Container(
        //padding: EdgeInsets.all(16.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              ///double? direction = snapshot.data!.heading;
              double angle = 0.3;

              ///= ((snapshot.data!.heading!) * (math.pi / 180) * -1);
              if (snapshot.hasError) {
                return Text('Error reading heading: ${snapshot.error}');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.connectionState == ConnectionState.active) {
                angle = ((snapshot.data!.heading!) * (math.pi / 180) * -1);
              }

              return Transform.rotate(
                angle: (angle - tangentAngle),

                ///angle: (direction! * (math.pi / 180) * -1) - tangentAngle,
                child: Image.asset('assets/compass.jpg'),
              );
            }),
      ),
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          ElevatedButton(
            child: Text('Request Permissions'),
            onPressed: () {
              ph.Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Open App Settings'),
            onPressed: () {
              ph.openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    ph.Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == ph.PermissionStatus.granted);
      }
    });
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    ///lc.LocationData currentLocation;
    ///currentLocation = await lc.Location().getLocation();
    ///print(currentLocation);

    lc.Location().getLocation().then((locationData) {
      setState(() {
        Offset myLocation =
            Offset(locationData.latitude!, locationData.longitude!);
        tangent = Tangent(Offset.zero, lg22 - myLocation);
        print("myLocation =" + myLocation.toString());
        print("tangentAngle =" + tangentAngle.toString());
      });
    });
  }
}
