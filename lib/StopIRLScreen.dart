import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class StopsIRLScreen extends StatefulWidget{
  final Map stopData;

  const StopsIRLScreen({Key key, this.stopData}) : super(key: key);
  @override
  _StopsIRLScreenState createState() => _StopsIRLScreenState();
}

class _StopsIRLScreenState extends State<StopsIRLScreen> {

  Map _stopData;
  List _irlData;
  // Map _stopCoords;
  AppBar appBar;
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  Completer<GoogleMapController> _controller = Completer();
  CameraPosition _stopPos;

  Future<void> getBusList() async {
    var data = await http.post('http://coimbra.move-me.mobi/NextArrivals/GetScheds?providerName=${_stopData['stopProvider']}&stopCode=${_stopData['stopId']}');
    setState((){
      _irlData = json.decode(data.body);
    });
  }

  Future<Map> getStopData(String stopId) async {
    // List data = await json.decode(await DefaultAssetBundle.of(context).loadString("assets/stopsList.json")).toList();
    var response = await http.get('http://coimbra.move-me.mobi/Stops/GetStops?oLat=40.2011832&oLon=-8.4209922&meters=50000');
    List data = json.decode(response.body.toString()) as List;
    Map resultData;
    for(var i = 0; i < data.length; i++){
      if(data[i]["Code"] == stopId){
        resultData = data[i];
        break;
      }
    }
    return resultData;
  }

  @override
  void initState() {
    super.initState();
    _stopData = widget.stopData;

    appBar = AppBar(
      title: Text("${_stopData['stopName']} - ${_stopData['stopId']}"),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());

    getStopData(_stopData["stopId"].toString()).then((stopCoords) {
      setState(() {
        _stopPos = CameraPosition(
          target: LatLng(
            double.parse(stopCoords["CoordX"].toString()),
            double.parse(stopCoords["CoordY"].toString())),
          zoom: 17,
        );
      });
    });
    getBusList();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: (_irlData == null) 
      ? Center(child: CircularProgressIndicator())
      : Column(
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height/3,
              child:
              (_stopPos == null)
              ? Center(child: CircularProgressIndicator(),)
              : GoogleMap(
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                  initialCameraPosition: _stopPos,
                  markers: Set<Marker>.of({"stopId": Marker(
                    markerId: MarkerId('stopId'),
                    position: _stopPos.target,
                  )}.values),
                  myLocationButtonEnabled: false,
                ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.green,
              child: 
                Row(children: <Widget>[
                  Text("Linha", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                  Spacer(),
                  Text("Direção - Tempo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                ],)
            ,),

            Expanded(child:
              RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: getBusList,
                child: 
                  ListView.builder(
                      itemCount: _irlData.length,
                      itemBuilder: (context, index){
                        return InkWell(
                          onTap: (){
                            
                          },
                          child: Container(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: <Widget>[
                                Text(_irlData[index]["Value"][0].substring(6),
                                  style: TextStyle(
                                    color: (int.parse(_irlData[index]["Value"][2]) < 10)
                                      ? Colors.red : Colors.black,
                                    fontWeight: (int.parse(_irlData[index]["Value"][2]) < 10)
                                      ? FontWeight.bold : FontWeight.normal),
                                ),
                                Spacer(),
                                Text(_irlData[index]["Value"][1]+' - '+_irlData[index]["Value"][2]+' min',
                                  style: TextStyle(
                                    color: (int.parse(_irlData[index]["Value"][2]) < 10)
                                      ? Colors.red : Colors.black,
                                    fontWeight: (int.parse(_irlData[index]["Value"][2]) < 10)
                                      ? FontWeight.bold : FontWeight.normal),
                                )
                              ],
                            ),
                          )
                        ,);
                        
                      },
                    )
                ,),
              )
            
            
        ],)
          
    );
  }
}
