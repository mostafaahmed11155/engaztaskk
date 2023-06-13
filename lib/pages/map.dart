import 'dart:async';
import 'dart:math';

import 'package:engaztask/services/api_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class map extends StatefulWidget {
  const map({Key? key}) : super(key: key);

  @override
  State<map> createState() =>
      _mapPageState();
}



class _mapPageState extends State<map> {
  final PopupController _popupController = PopupController();

  late List<Marker> markers = [];
  late int pointIndex;
  List<LatLng> points = [];
  Timer? _timer;

  @override
  void initState() {
    pointIndex = 0;

    Provider.of<APIService>(context,listen: false).getMarkers().then((val){
      val['data'].forEach((element){

        setState(() {
          points.add(
            LatLng(double.parse(element['Lat']), double.parse(element['Longt'])),
          );
        });
      });
    });
    setState(() {
      markers = points.map((e) => Marker(
        anchorPos: AnchorPos.align(AnchorAlign.center),
        height: 30,
        width: 30,
        point: e,
        builder: (ctx) => const Icon(Icons.pin_drop),
      )).toList();
    });


    _timer = Timer.periodic(Duration(minutes: 1), (timer)async {
      // Call your desired function here
     await sendLocationToRealtimeDB();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Markers'),actions: [
        IconButton(onPressed: ()async{
          Provider.of<APIService>(context,listen: false).getMarkers().then((val){
            val['data'].forEach((element){

            setState(() {
              points.add(
                LatLng(double.parse(element['Lat']), double.parse(element['Longt'])),
              );
            });
            });
          });
         setState(() {
           markers = points.map((e) => Marker(
             anchorPos: AnchorPos.align(AnchorAlign.center),
             height: 30,
             width: 30,
             point: e,
             builder: (ctx) => const Icon(Icons.pin_drop),
           )).toList();
         });
          await sendLocationToRealtimeDB();
        }, icon: Icon(Icons.pin_drop))
      ]),
      body: points.isNotEmpty ? FlutterMap(
        options: MapOptions(
          center: points[0] ,
          zoom: 5,
          maxZoom: 15,
          onTap: (_, __) => _popupController
              .hideAllPopups(), // Hide popup when the map is tapped.
        ),
        children: <Widget>[
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
      MarkerClusterLayerWidget(
        options: MarkerClusterLayerOptions(
          spiderfyCircleRadius: 80,
          spiderfySpiralDistanceMultiplier: 2,
          circleSpiralSwitchover: 12,
          maxClusterRadius: 120,
          rotate: true,
          size: const Size(40, 40),
          anchor: AnchorPos.align(AnchorAlign.center),
          fitBoundsOptions: const FitBoundsOptions(
            padding: EdgeInsets.all(50),
            maxZoom: 15,
          ),
          markers: markers,
          polygonOptions: const PolygonOptions(
              borderColor: Colors.blueAccent,
              color: Colors.black12,
              borderStrokeWidth: 3),
          popupOptions: PopupOptions(
              popupState: PopupState(),
              popupSnap: PopupSnap.markerTop,
              popupController: _popupController,
              popupBuilder: (_, marker) => Container(
                width: 200,
                height: 100,
                color: Colors.white,
                child: GestureDetector(
                  onTap: () => debugPrint('Popup tap!'),
                  child: Text(
                    'Container popup for marker at ${marker.point}',
                  ),
                ),
              )),
          builder: (context, markers) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blue),
              child: Center(
                child: Text(
                  markers.length.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        )),
        ],
      ) : Center(child: Text('Loading')),
    );
  }

  sendLocationToRealtimeDB()async{
    Position _currentPosition = await _determinePosition();
    DatabaseReference ref = FirebaseDatabase.instance.ref('users/${Provider.of<APIService>(context,listen: false).userId}');
    await ref.set({
      "Lat": _currentPosition.latitude,
      'Long' : _currentPosition.longitude
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
}