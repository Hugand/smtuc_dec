import 'package:flutter/material.dart';
import 'HorariosScreen.dart';
import 'ParagensIRL.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(title: 'SMTUC Decente'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/main_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: 
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(5),
                child: 
                  RawMaterialButton(
                    fillColor: Colors.white,
                    splashColor: Colors.orangeAccent[100],
                    shape: StadiumBorder(),
                    elevation: 0,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => new ParagensIRL()));
                    },
                    child: 
                      Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                        child: 
                          Text(
                            "Paragens em tempo real",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                      )
                  ),
              ),
              Container(
                margin: EdgeInsets.all(5),
                child: 
                  RawMaterialButton(
                    fillColor: Colors.white,
                    splashColor: Colors.orangeAccent[100],
                    shape: StadiumBorder(),
                    elevation: 0,
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => new HorariosScreen()));
                    },
                    child: 
                    Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
                      child: 
                        Text(
                          "Horários",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                    )
                  ),
              ),
            ],
          ),
        )
      )
    );
  }
}
