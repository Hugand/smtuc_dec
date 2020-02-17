import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'TimeTable.dart';

class HorariosScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen>{
  String busNumberLabel = "bn";
  String routeLabel = "rt";

  String busNumber = "";
  String route = "";
  String dayType = "";

  List busNumberData;
  List routesData;
  List dayTypeData;

  List busNumberDropdownData;
  List routesDropdownData;
  List dayTypesDropdownData;

  Map timetableData;

  double _dropdownContainerBarHeight = 60;
  bool _showDropdownContainer = false;
  Map _dropdownContainerValues = {
    true: 0.0,
    false: -215.0
  };

  Future<List> _getBusNumbers() async{
    // http://coimbra.move-me.mobi/Scheds/GetLines?providerName=SMTUC
    var data = await http.get('http://coimbra.move-me.mobi/Scheds/GetLines?providerName=SMTUC');
    return json.decode(data.body);
  }

  Future<List> _getRoutes(String busCode) async{
    // http://coimbra.move-me.mobi/Scheds/GetDirections?lineCode=SMTUC_2F
    var data = await http.get('http://coimbra.move-me.mobi/Scheds/GetDirections?lineCode=$busCode');
    List parsedData = json.decode(data.body);
    return parsedData.map((e) => e.split('§')).toList();
  }

  Future<List> _getDayTypes(String busCode) async{
    // http://coimbra.move-me.mobi/Scheds/GetDayTypes?lineCode=SMTUC_2F
    var data = await http.get('http://coimbra.move-me.mobi/Scheds/GetDayTypes?lineCode=$busCode');
    return json.decode(data.body);
  }
  Map<String, String> headers = {};

  Future<Map> _getTimetable(String bus, String dir, String dayType) async{
    List dirProperties = dir.split('  ');
    Map body = {
      "provider": "SMTUC",
      "line": bus,
      "direction": dirProperties[0],
      "dayType": dayType,
      "lineDescription": busNumberData.firstWhere((e) => e["Key"] == bus)["Value"],
      "directionDescription": dirProperties[1],
      "dayTypeDescription": dayTypeData.firstWhere((e) => e["Item1"][0] == dayType)["Item2"],
    };
    print(body.toString());

    var getCookiesReq = await http.post("http://coimbra.move-me.mobi/Scheds/Select", headers: headers, body: body);
    updateCookie(getCookiesReq);
    var data = await http.post('http://coimbra.move-me.mobi/Scheds/Details', body: body, headers: headers);
    var bodyData = data.body.toString();
    return parseHtmlTableData(bodyData);
  }

  Map parseHtmlTableData(String html){
    String tableMarkdown = html.substring(html.indexOf("<table "), html.indexOf("</table>"));
    List trSplit = tableMarkdown.split("<tr>").map((e) => e.substring(0, e.length-5)).toList();
    trSplit.removeRange(0, 2);
    List tdSplit = trSplit.map((e) => e.split("<td>")).toList();
    tdSplit.forEach((e) {
      e.removeAt(0);
      // e = e.map((ec) => ec.substring(0, ec.length-5));
      return e;
    });
    tdSplit = tdSplit.map((e) => e.map((ec) => ec.substring(0, ec.length-5)).toList()).toList();
    tdSplit = removeDuplicates(tdSplit);
    print(tdSplit.toString());

    Map parsedHtml = {};
    List labels = [];

    tdSplit.forEach((row) {
      String stopLabel = row[0].trim();

      if(parsedHtml[stopLabel] == null){
        parsedHtml[stopLabel] = [];
        labels.add(stopLabel);
      }
      row.removeAt(0);
      parsedHtml[stopLabel].insertAll(parsedHtml[stopLabel].length, row);

    });
    return {
      "labels": labels,
      // "timetableData": parsedHtml
      "timetableData": resizeRowSize(parsedHtml)
    };

  }

  Map resizeRowSize(Map data){
    int size = _getBiggestRowSize(data);
    print(data.toString());

    return data.map((k, v){
      int sizeToAppend = size - v.length;
      v.addAll(List<String>.filled(sizeToAppend, ""));
      print(v.toString());
      return MapEntry(k, v);
    });
  }

  int _getBiggestRowSize(Map data){
    int size = 0;
    data.entries.forEach((v){
      if(v.value.length > size)
        size = v.value.length;
    });

    return size;
  }

  List removeDuplicates(List array){
    for(int i = 1; i < array.length; i++){
      if(array[i].toString() == array[i-1].toString()){
        array.removeAt(i);
      }
    }
    return array;
  }
  
  void updateCookie(http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['Cookie'] =
          (index == -1) ? rawCookie : rawCookie.substring(0, index);
    }
    // print("HEADERS");
    // print(headers.toString());
    // print("REQ HEADERS");
    // print(response.headers.toString());
  }

  Future<void> _setupBusNumberDropdownFieldItems() async {
    busNumberData = await _getBusNumbers();

    setState(() {
      busNumberDropdownData = busNumberData.map((busNumber) {
        return DropdownMenuItem<String>(
          child: Text(busNumber["Value"]),
          value: busNumber["Key"]
        );
      }).toList();

      busNumber = busNumberData[0]["Key"];
    });
  }

  Future<void> _setupRouteDropdownFieldItems(String busCode) async {
    routesData = await _getRoutes(busCode);

    setState(() {
      routesDropdownData = routesData.map((route) {
        return DropdownMenuItem<String>(
          child: Text(route.join('  ')),
          value: route.join('  ')
        );
      }).toList();

      route = routesData[0].join('  ');

    });
  }

  Future<void> _setupDayTypeDropdownFieldItems(String busCode) async {
    dayTypeData = await _getDayTypes(busCode);

    setState(() {
      dayTypesDropdownData = dayTypeData.map((dayType) {
        return DropdownMenuItem<String>(
          child: Text(dayType["Item2"]),
          value: dayType["Item1"][0].toString()
        );
      }).toList();

      dayType = dayTypeData[0]["Item1"][0].toString();
    });
  }


  @override
  void initState() {
    super.initState();
    _setupBusNumberDropdownFieldItems()
      .then((_) async {
        await _setupRouteDropdownFieldItems(busNumber);
        await _setupDayTypeDropdownFieldItems(busNumber);
        setState(() {
          busNumberLabel = busNumberData.firstWhere((e) => e["Key"] == busNumber)["Key"].substring(6);
          routeLabel = route.split('  ')[2];
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Horarios"),
        elevation: 0.0,
      ),
      body: 
        Stack(children: <Widget>[
          Positioned(
            top: _dropdownContainerBarHeight,
            left: 0,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height-_dropdownContainerBarHeight,
            child:
              (timetableData == null) ? Center(child: Text("Selecione uma linha"),)
              : TimeTable(
                  labels: timetableData["labels"],
                  timeTableData: timetableData["timetableData"]
                ),
            ),

            AnimatedPositioned(
              left: 0,
              right: 0,
              duration: Duration(milliseconds: 400),
              curve: Curves.fastOutSlowIn,
              top: _dropdownContainerValues[_showDropdownContainer],
              child: 
              Container(
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(
                    color: Colors.grey[700],
                    blurRadius: 20.0,
                    offset: Offset(0, 0)
                  ),],
                ),
                child: Column(children: <Widget>[
                Container(
                  decoration: BoxDecoration(color: Colors.white),
                  padding: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    DropdownButton<String>(
                      isExpanded: true,
                      items: busNumberDropdownData,
                      onChanged: (String value) {
                        setState(() {
                          busNumber = value;
                          busNumberLabel = busNumberData.firstWhere((e) => e["Key"] == busNumber)["Key"].substring(6);
                        });

                        _setupRouteDropdownFieldItems(busNumber)
                          .then((_) {
                            _setupDayTypeDropdownFieldItems(busNumber);
                          });
                      },
                      hint: Text("Linha do autocarro"),
                      value: busNumber,
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      items: routesDropdownData,
                      onChanged: (String value) {
                        setState(() {
                          route = value;
                          routeLabel = value.split('  ')[2];
                        });

                        _setupDayTypeDropdownFieldItems(busNumber);
                      },
                      hint: Text("Direção"),
                      value: route,
                    ),
                    DropdownButton<String>(
                      isExpanded: true,
                      items: dayTypesDropdownData,
                      onChanged: (String value) {
                        setState(() {
                          // _radiusDist = value;
                          dayType = value;
                        });
                      },
                      hint: Text("Tipo de dia"),
                      value: dayType,
                    ),

                    SizedBox(
                      width: 200,
                      child: 
                        RawMaterialButton(
                          fillColor: Colors.orange,
                          splashColor: Colors.orangeAccent[100],
                          onPressed: () async {
                            print("Search again");
                            setState(() {
                              _showDropdownContainer = !_showDropdownContainer;
                            });
                            timetableData = await _getTimetable(busNumber, route, dayType);

                            setState(() {
                            });

                          },
                          shape: StadiumBorder(),
                          child:
                            Container(
                              child: Text("Procurar")
                            )
                          )
                      ,)
                      
                  ],),
                ),
                
                InkWell(
                  onTap: (){
                    setState(() {
                      _showDropdownContainer = !_showDropdownContainer;
                    });
                  },
                  child: 
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight : Radius.circular(10), ),
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: _dropdownContainerBarHeight,
                      padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 10),
                      child: 
                        Row(
                          children: <Widget>[
                            Text(busNumberLabel, style: TextStyle(fontSize: 16),),
                            Spacer(),
                            Text(routeLabel, style: TextStyle(fontSize: 14),),
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Icon(
                                _showDropdownContainer
                                ? Icons.arrow_drop_up
                                : Icons.arrow_drop_down
                              ),
                            )
                            
                          ],
                        ),
                    ),
                )


              
            ],)
          )
            
          ,),
    
          
        ],)

    );
  }
  
}
