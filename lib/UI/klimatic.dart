import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../utilitites/util.dart'as util;
import 'package:http/http.dart' as http;

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
String _cityEntered;

  Future _gotoScreen(BuildContext context) async{
    Map results = await Navigator.of(context).push(
         new MaterialPageRoute<Map>(builder: (BuildContext context){
           return new ChangeCity();
         })
    );
    if(results !=null && results.containsKey('info')){
      _cityEntered = results['info'];
    //  print(results['info'].toString());
    }
  }

  void showStuff() async{
    Map data = await getKlimatic(util.appId,util.defaultCity);
    print(data.toString());
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("Klimatic"),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        actions: [
          new IconButton(icon: Icon(Icons.menu,color: Colors.white,),
           onPressed:(){
             _gotoScreen(context);
           }
            )
        ],
      ),
      body: new Stack(
        children: [
          new Center(
            child: Image.asset("images/umbrella.jpg",
            width: 490,
            height: 1500,
            fit: BoxFit.fill,
            ),            
          ),
          new Container(
            margin: const EdgeInsets.fromLTRB(0.0, 5, 20, 0.0),
            alignment: Alignment.topRight,
            child: Text("${_cityEntered==null?util.defaultCity:_cityEntered}",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontStyle: FontStyle.italic,            
            ),
            ),
          ),
           new Container(
             alignment: Alignment.center,
             child: Image.asset("images/light_rain.png",
             width: 150,height: 150,
             ),
           ),
           new Container(
             alignment: Alignment.center,
             margin: const EdgeInsets.fromLTRB(50, 120, 220, 0.0),
             child: updateTemp(_cityEntered),
           )
          
       ],
      ),
    );
  }
}

Widget updateTemp(String city){
  return new FutureBuilder(
    future: getKlimatic(util.appId, city==null?util.defaultCity:city),
    builder: (BuildContext context,AsyncSnapshot<Map>snapshot){
       if(snapshot.hasData){
         Map content = snapshot.data;
         return new Container(
           margin: const EdgeInsets.fromLTRB(0.0,190, 10, 0.0),
           child: new ListView(
             children: [
               ListTile(
                 title: Text(content["main"]["temp"].toString() + " F" ,
                 style: TextStyle(
                   color: Colors.white,
                   fontWeight: FontWeight.w500,
                   fontSize: 20,),
                 ),
                 subtitle: Text(
                   "humidy:${content["main"]["humidity"].toString()} \n"
                    "min:${content["main"]["temp_min"].toString()}"
                 ),
               )
             ],
           ),
         );
       }else{
         return new Container();
       }
    });
}

class ChangeCity extends StatelessWidget{
final _backScreenTextField = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("city"),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body:new Stack(
        children: [
          new Center(
            child: Image.asset("images/snow.jpg",
            width: 490,height: 1200,
            fit: BoxFit.fill,
            
            ),
          ),
          ListView(
            children: [
              ListTile(
                title: new TextField(
                  controller: _backScreenTextField,
                  decoration: InputDecoration(
                    hintText: "Enter City"
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              ListTile(
                title: new FlatButton
                (onPressed: (){
                  Navigator.pop(context,{
                    'info' : _backScreenTextField.text,
                  });
                },
                 child: Text("press for City data",
                 style: TextStyle(
                   fontWeight: FontWeight.w500,
                   color: Colors.white,
                 ),
                 ),
                 color: Colors.greenAccent,
                 ),
              )
            ],
          )
        ],
      )
    );
    
  }

}

TextStyle tempStyle(){
  return TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 40,
  );
}

Future<Map>getKlimatic(String appId,String city) async{
  String apiUrl = "http://api.openweathermap.org/data/2.5/weather?q=$city&appid=${util.appId}&units=imperial";
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body);
}