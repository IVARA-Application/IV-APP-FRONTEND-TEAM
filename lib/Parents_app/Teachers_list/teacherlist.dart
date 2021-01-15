import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ivara_app/students_app/notification.dart';

class Teacherlist extends StatefulWidget{
  @override
  State<Teacherlist> createState() {
    // TODO: implement createState
   return new TeacherlistState();
  }
  
}

class TeacherlistState extends State<Teacherlist>
{
  List<String> Names = [
    'Aman','Jugaldutt','Mayank','Sumit','Tarun','Tanishk'];


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text("IVENTORS"),
        backgroundColor: Colors.lightBlue,
        actions: <Widget>[
          Row(
            children: <Widget>[
              IconButton(
                onPressed: () {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>NotificationPage()));

                },
                icon: Stack(
                  children: <Widget>[
                    Icon(Icons.notifications,
                        color: Colors.white),
                    Positioned(
                      left: 16.0,
                      child: Icon(Icons.brightness_1,
                        color: Colors.red,
                        size: 9.0,
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    body: new Container(
      child: new ListView.builder(
          itemBuilder: (_,int index) => EachList(this.Names[index]),
           itemCount: this.Names.length,
    ),
    )
    );
  }
  
}

class EachList extends StatelessWidget{
  final String name;
  EachList(this.name);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Card(
      child: new Container(
        padding: EdgeInsets.all(12.0),
        child: new Row(
           children: <Widget>[
             new CircleAvatar(child: new Text(name[0]),),
             new Padding(padding: EdgeInsets.only(right: 10.0),),
             new Text(name,style: TextStyle(fontSize: 20.0),),
           ],
        ),
      ),
    );
  }

}