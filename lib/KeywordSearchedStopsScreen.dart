import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:smtuc/StopIRLScreen.dart';

class KeywordSearchedStopsScreen extends StatefulWidget{
  final String searchKeyword;

  const KeywordSearchedStopsScreen({Key key, this.searchKeyword}) : super(key: key);
  @override
  _KeywordSearchedStopsScreenState createState() => _KeywordSearchedStopsScreenState(searchKeyword);
}

class _KeywordSearchedStopsScreenState extends State<KeywordSearchedStopsScreen> {

  final String _searchKeyword;
  List _stopsData;

  _KeywordSearchedStopsScreenState(this._searchKeyword);

  getStopsList() async {
    var data = await http.post('http://coimbra.move-me.mobi/Find/SearchByStops?keyword=$_searchKeyword');
    List splitedList = data.body.split(';');
    splitedList.removeLast();
    List<Map> parsedData = splitedList.map((e){
      int stopIdStartIndex = e.indexOf('[');
      Map data = Map();
      data.addAll({
        "stopId": e.substring(stopIdStartIndex+1, e.toString().length-1),
        "stopName": e.substring(8, stopIdStartIndex-1),
        "stopProvider": e.substring(0, 7)
      });

      return data;
    }).toList();
    setState(() {
      _stopsData = parsedData;
    });
    debugPrint(parsedData.toString());
  }

  @override
  void initState() {
    super.initState();
    getStopsList();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Paragens em tempo real"),
      ),
      body: (_stopsData == null) ? Center(child: CircularProgressIndicator())
      : ListView.builder(
        itemCount: _stopsData.length,
        itemBuilder: (context, index){
          return InkWell(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => new StopsIRLScreen(stopData: _stopsData[index])));
            },
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                children: <Widget>[
                  Text(_stopsData[index]["stopId"].toString()),
                  Spacer(),
                  Text(_stopsData[index]["stopName"].toString())
                ],
              ),
            )
          ,);
          
        },
      )
          
    );
  }
}
