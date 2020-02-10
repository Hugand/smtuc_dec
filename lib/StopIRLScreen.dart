import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StopsIRLScreen extends StatefulWidget{
  final Map stopData;

  const StopsIRLScreen({Key key, this.stopData}) : super(key: key);
  @override
  _StopsIRLScreenState createState() => _StopsIRLScreenState(stopData);
}

class _StopsIRLScreenState extends State<StopsIRLScreen> {

  final Map _stopData;
  List _irlData;
  AppBar appBar = AppBar(
        title: Text("Paragens em tempo real"),
      );
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  _StopsIRLScreenState(this._stopData);

  Future<void> getBusList() async {
    var data = await http.post('http://coimbra.move-me.mobi/NextArrivals/GetScheds?providerName=${_stopData['stopProvider']}&stopCode=${_stopData['stopId']}');
    setState((){
      _irlData = json.decode(data.body);
    });
    debugPrint(_irlData.toString());
  }

  @override
  void initState() {
    super.initState();
    getBusList();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _refreshIndicatorKey.currentState.show());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: (_irlData == null) 
      ? Center(child: CircularProgressIndicator())
      : 
          Column(
          children: <Widget>[
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
