import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:smtuc/MapStopInfo.dart';
import 'KeywordSearchedStopsScreen.dart';
import 'package:flutter/services.dart' show rootBundle;

class ParagensIRL extends StatefulWidget{
  
  @override
  _ParagensIRLState createState() => _ParagensIRLState();
}

class _ParagensIRLState extends State<ParagensIRL> {

  TextEditingController _paragemNameController = new TextEditingController();
  Map<MarkerId, Marker> stopsMarkers = <MarkerId, Marker>{}; // CLASS MEMBER, MAP OF MARKS
  // List stopsMarkers = [];
  Marker posSearchMarker;

  bool _markersLoaded = true;
  String _radiusDist;
  bool _displayStopInfo = false;
  Map _stopInfoToDisplay;
  List _stopBusData;

  List<Map> stopsList;
  List _stopRoutes;
  MapStopInfo mapStopInfo;

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(40.2011832, -8.4209922),
    zoom: 14.4746,
  );
  
  Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
    return rootBundle.loadString(assetsPath)
        .then((jsonStr) => jsonDecode(jsonStr));
  }

  Future<http.Response> fetchPost() {
    return http.get('https://jsonplaceholder.typicode.com/posts/1');
  }

  Future<List> getBusList(Map stopData) async {
    var data = await http.post('http://coimbra.move-me.mobi/NextArrivals/GetScheds?providerName=${stopData["Provider"]}&stopCode=${stopData["Code"]}');
    return json.decode(data.body);
  }

  Future<Map> getStopCardInfoData(Map stopData) async{
    List stopBusData = await getBusList(stopData);
    List stopRoutes = await getStopRoutes(stopData["Code"].toString());
    return {
      "stopBusData": stopBusData,
      "stopRoutes": stopRoutes
    };
  }

  Future<List> getStopRoutes(String busId) async{
    var data = await http.get('http://coimbra.move-me.mobi/Lines/GetLinesByStop?stopCode=$busId');
    return json.decode(data.body);
  }

  @override
  void initState() {
    super.initState();
    // _loadStopsListJsonData();
  }

  void _createMarker(Map stopData) {
    var markerIdVal = stopData["Code"];
    final MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(
        stopData["CoordX"],
        stopData["CoordY"]
      ),
      onTap: () async {
        // _onMarkerTapped(markerId);
        Map stopCardInfoData = await getStopCardInfoData(stopData);

        setState(() {
          _stopInfoToDisplay = stopData;
          _displayStopInfo = true;
          _stopBusData = stopCardInfoData["stopBusData"];
          _stopRoutes = stopCardInfoData["stopRoutes"];
        });
        debugPrint("Clicked ${_stopInfoToDisplay['Code']} ${_stopBusData.length}");

      },
    );

    setState(() {
      stopsMarkers[markerId] = marker;
    });
  }

  _handleTap(LatLng point) {
    // var markerIdVal = stopData["Code"];
    final MarkerId markerId = MarkerId("myMarker");

    // creating a new MARKER
    final Marker marker = Marker(
      markerId: markerId,
      position: point,
      onTap: () {
        // _onMarkerTapped(markerId);
      },
      icon:
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    );

    setState(() {
      posSearchMarker = marker;
      stopsMarkers[markerId] = marker;
    });
  }

  handleStopInfoCardClose(){
    setState(() {
      _displayStopInfo = false;
    });
  }

  
  Future<void> getStopsListInRadius() async {
    String lat = posSearchMarker.position.latitude.toString();
    String long = posSearchMarker.position.longitude.toString();
    var data = await http.get('http://coimbra.move-me.mobi/Stops/GetStops?oLat=$lat&oLon=$long&meters=$_radiusDist');
    
    setState(() {
      stopsList = List.from(json.decode(data.body.toString()));
      debugPrint(stopsList[0].toString());

      stopsList.forEach((stop){
        _createMarker(stop);
      });

      _markersLoaded = true;
    });
    debugPrint(stopsList.toString());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paragens em tempo real"),
      ),
      body:
        (!_markersLoaded) ? Center(child: CircularProgressIndicator(),)
        : Stack(
          children: <Widget>[
            GoogleMap(
              mapType: MapType.normal,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              initialCameraPosition: _kGooglePlex,
              markers: Set<Marker>.of(stopsMarkers.values),
              onTap: _handleTap,
              myLocationButtonEnabled: false,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                child: 
                  Row(children: <Widget>[
                    Expanded(child: 
                      TextField(
                        onChanged: (text) {
                          setState(() {});
                        },
                        controller: _paragemNameController,
                        decoration: InputDecoration(
                          hintText: 'Paragem',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search),
                      tooltip: 'Search',
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => new KeywordSearchedStopsScreen(searchKeyword: _paragemNameController.text,)));
                      },
                    ),
                  ],
                ),
                margin: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,//(_paragemNameController.text.isNotEmpty) ? Colors.white : Colors.white54,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                  boxShadow: [BoxShadow(
                    color: Colors.grey[600],
                    blurRadius: 10.0,
                    offset: Offset(5, 5)
                  ),],
                ),
              ),
            (_stopInfoToDisplay != null && _stopBusData != null)
            ? Align(
              alignment: Alignment.bottomCenter,
              child: MapStopInfo(
                stopData: _stopInfoToDisplay,
                stopBusData: _stopBusData,
                stopRoutes: _stopRoutes,
                handleCloseButton: handleStopInfoCardClose,
                infoCardHeight: (_displayStopInfo) ? 350 : 0,
              ),
            )
            : Container()
          ],
        ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.search),
          onPressed: () {
            debugPrint("HE");
            return Alert(
              context: context,
              title: "Raio de pesquisa",
              buttons: [DialogButton(child: Text("Search"), onPressed: (){
                debugPrint(posSearchMarker.position.latitude.toString());
                Navigator.pop(context);
                getStopsListInRadius();
              },)],
              content:
              StatefulBuilder(  // You need this, notice the parameters below:
                builder: (BuildContext context, StateSetter setState) {
                  return DropdownButton<String>(
                    items: [
                      DropdownMenuItem<String>(
                        child: Text("50m"),
                        value: "50"
                      ),
                      DropdownMenuItem<String>(
                        child: Text("100m"),
                        value: "100"
                      ),
                      DropdownMenuItem<String>(
                        child: Text("300m"),
                        value: "300"
                      ),
                      DropdownMenuItem<String>(
                        child: Text("500m"),
                        value: "500"
                      ),
                      DropdownMenuItem<String>(
                        child: Text("1000m"),
                        value: "1000"
                      ),
                    ],
                    onChanged: (String value) {
                      setState(() {
                        _radiusDist = value;
                      });
                      debugPrint(_radiusDist);
                    },
                    hint: Text("Seleciona uma distância"),
                    value: _radiusDist,
                  );
                })
            ).show();
          },
        ),
        
    );
  }
}
