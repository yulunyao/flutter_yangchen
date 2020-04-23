import 'package:flutter/material.dart';
import 'home.dart';
import 'graphGenerator.dart';
import 'dataLoader.dart';
class Repo extends StatefulWidget {
  @override
  _RepoState createState() => _RepoState();
}

class FirstOne extends StatefulWidget {
  @override
  _FirstOneState createState() => _FirstOneState();
}

class _FirstOneState extends State<FirstOne> {
  @override
  Widget build(BuildContext context) {
    return Text("FirstOne");
  }
}

class SecondOne extends StatefulWidget {
  @override
  _SecondOneState createState() => _SecondOneState();
}

class _SecondOneState extends State<SecondOne> {
  @override
  Widget build(BuildContext context) {
    return Text("SecondOne");
  }
}

class _RepoState extends State<Repo> {
  int _currentIndex = 0;

  List<Widget> _pageList = [HomeMain(), GraphGenerator()];

  List<BottomNavigationBarItem> _barItem = [
    BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('首页')),
    BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('新闻')),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('BottomNavigationBar'),
          backgroundColor: Colors.pink,
        ),
        body: this._pageList[this._currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: (int index) {
            setState(() {
              this._currentIndex = index;
            });
          },
          currentIndex: this._currentIndex,
          items: _barItem,
          fixedColor: Colors.pink,
          selectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}