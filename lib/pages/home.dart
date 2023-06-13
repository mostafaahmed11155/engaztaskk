import 'package:engaztask/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';



class Home extends StatefulWidget {
   Home({super.key, });


  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List markers = [];

  @override
  void initState() {
    Provider.of<APIService>(context,listen: false).getMarkers().then((val){
     if(val != false){
       setState(() {
         markers = val;
       });
     }
    });
    super.initState();
  }
  Map? newPosition;

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              onTap: (tapPosition, point) {
                setState(() {
                  newPosition = {
                    'longitude' : point.longitude,
                    'latitude' :point.latitude
                  };
                });
              },
              zoom: 9.2,
            ),
            nonRotatedChildren: [
            ],
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
          Center(child: Icon(Icons.location_on,color: Colors.red.shade700,size: 50,))
        ],
      ),
    );
  }
}
