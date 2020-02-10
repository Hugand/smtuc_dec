import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MapStopInfo extends StatefulWidget{
  final Map stopData;
  final List stopBusData;
  final double infoCardHeight;
  final Function handleCloseButton;
  final List stopRoutes;

  const MapStopInfo({Key key, this.stopData, this.stopBusData, this.stopRoutes, this.handleCloseButton, this.infoCardHeight}) : super(key: key);

  @override
  _MapStopInfoState createState() => _MapStopInfoState();
}

class _MapStopInfoState extends State<MapStopInfo>{
  bool _isLoadingData = false;
  Map _stopData;
  List _stopBusData;
  double _infoCardHeight;

  @override
  void initState() {
    super.initState();
    // getBusList();
  }

  @override
  Widget build(BuildContext context) {
    _stopData = widget.stopData;
    _stopBusData = widget.stopBusData;
    _infoCardHeight = widget.infoCardHeight;
    
    debugPrint(_stopData['Code'].toString());
    return 
    AnimatedContainer(
      duration: Duration(milliseconds: 400),
      curve: Curves.fastOutSlowIn,
      height: _infoCardHeight,
      child: Stack(children: <Widget>[
        Container(
          height: _infoCardHeight,
          padding: EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20),),
            boxShadow: [BoxShadow(
              color: Colors.grey[700],
              blurRadius: 10.0,
              offset: Offset(5, -5)
            ),],
          ),
          child: 
          (_isLoadingData) 
          ? Center(child: CircularProgressIndicator())
          : Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      _stopData["Name"],
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ),
                Spacer(),
                Text(_stopData["Code"],
                  style: TextStyle(color: Colors.grey[700]),)
              ],),
              
              Container(
                margin: EdgeInsets.all(10),
                child: Text(widget.stopRoutes.join(' ')),
              ),
              (_stopBusData.length == 0)
              ? Text("Não existem autocarros próximos")
              : Expanded(child: 
                ListView.builder(
                  itemCount: (_stopBusData.length < 4) ? _stopBusData.length : 4,
                  itemBuilder: (context, index){
                    return Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: <Widget>[
                          Text(_stopBusData[index]["Value"][0],
                            style: TextStyle(
                              color: (int.parse(_stopBusData[index]["Value"][2].replaceAll('*', '')) < 10)
                                ? Colors.red : Colors.black,
                              fontWeight: (int.parse(_stopBusData[index]["Value"][2].replaceAll('*', '')) < 10)
                                ? FontWeight.bold : FontWeight.normal),
                          ),
                          Spacer(),
                          Text(_stopBusData[index]["Value"][1]+' - '+_stopBusData[index]["Value"][2].replaceAll('*', '')+' min',
                            style: TextStyle(
                              color: (int.parse(_stopBusData[index]["Value"][2].replaceAll('*', '')) < 10)
                                ? Colors.red : Colors.black,
                              fontWeight: (int.parse(_stopBusData[index]["Value"][2].replaceAll('*', '')) < 10)
                                ? FontWeight.bold : FontWeight.normal),
                          )
                        ],
                      ),
                    );
                  }
                ),
              )
          ],)
        ),

        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            onPressed: (){
              widget.handleCloseButton();
            },
            icon: Icon(Icons.clear),),
        ),
      ],),
    );
    
  }
  
}