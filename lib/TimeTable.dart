import 'package:flutter/material.dart';

class TimeTable extends StatelessWidget{
  final Map timeTableData;
  final List labels;
        
  const TimeTable({Key key, this.timeTableData, this.labels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 60),
      width: MediaQuery.of(context).size.width,
      child:

        ListView(           
          children: <Widget>[
            Row(children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width/4,
                height: 60.0*labels.length,
                child: 
                  Column(
                    children: labels.asMap().map((i, e) => MapEntry(i, Container(
                        decoration: BoxDecoration(color: (i%2 == 0) ? Colors.white : Colors.orange[200]),
                        width: MediaQuery.of(context).size.width/4,
                        height: 60,
                        padding: EdgeInsets.all(10),
                        child: Center(child: Text(e.toString(), style: TextStyle(fontWeight: FontWeight.bold)))
                      ),
                    )).values.toList()
                  ,),
              ),
              Container(
                width: MediaQuery.of(context).size.width/4*3,
                height: 60.0*labels.length,
                child: 
                  ListView(
                    
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      
                      Column(
                        children: 
                          timeTableData.values.toList().asMap().map((i, v) => 
                            MapEntry(i, Container(

                              decoration: BoxDecoration(color: (i%2 == 0) ? Colors.white : Colors.orange[200]),
                              child: Row(children: 
                              List<Widget>.from(v.map((e) => 
                                Container(
                                  width: 50,
                                  height: 60,
                                  child: Center(child: Text(e.toString()))
                                )
                              ))
                            ))
                            
                          )).values.toList()
                      ,)
                    ],
                  )
              )
            ],)
          ],
        ),
            );
  }
  
}