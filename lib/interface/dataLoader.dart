import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'home.dart';
import 'graphGenerator.dart';

/** 主页面代码 */
class HomeMain extends StatefulWidget {
  String token;
  String selected;
  HomeMain({this.token, this.selected}); // 此处没加this，导致年后的问题
  @override
  _HomeMainState createState() => _HomeMainState();
}

/**
 * 卡片内需要显示的
 *    - 更新时间
 *    - 因子名称
 *    - 实时值
 *    - 实时值单位
 */
class _HomeMainState extends State<HomeMain> {
  String convertTimestampSingleLine(int time) {
    String result = '';
    String hour = DateTime.fromMillisecondsSinceEpoch(time).hour.toString();
    String minute = DateTime.fromMillisecondsSinceEpoch(time).minute.toString();
    String second = DateTime.fromMillisecondsSinceEpoch(time).second.toString();
    hour.length == 1 ? result += "0" + hour + ":" : result += hour + ":";
    minute.length == 1 ? result += "0" + minute + ":" : result += minute + ":";
    second.length == 1 ? result += "0" + second : result += second;
    return DateTime.fromMillisecondsSinceEpoch(time).year.toString() +
        "." +
        DateTime.fromMillisecondsSinceEpoch(time).month.toString() +
        "." +
        DateTime.fromMillisecondsSinceEpoch(time).day.toString() +
        "\n" +
        " " +
        result;
  }

  Future getRealTimeData() async {
    /**
     * 写：如果断网下加载数据的情况
     */
    debugPrint("W: ${widget.selected}");
    debugPrint("T: ${widget.token}");
    if (widget.selected == null) {
      debugPrint("SETETETET");
      try {
        var url = "http://218.91.223.15:31710/ntplatform2/api/yc/pointtree";
        var response = await http.get(url, headers: {
          "Authorization": "Bearer ${widget.token}" //得到从HomeMain中传入的token
        });

        if (response.statusCode == 200) {
          debugPrint("SETETETET1");
          var responseBody = json.decode(response.body);
          Enterprise single = new Enterprise.fromJson(responseBody);
          // selected_Enterprise = single.data[0].id;
          setState(() {
            widget.selected = single.data[0].id; // 赋予selectedId一个初始值，为获取到数据的第一个企业id
          });
          debugPrint("JJJ" + widget.selected);
          getRealTimeData();
        }
      } catch (e) {}
    } else {
      debugPrint("THE VALUE OF SELECTED " + widget.selected);
      try {
        var response = await http.get(
            "http://218.91.223.15:31710/ntplatform2/api/yc/monitor/realtime/0/${widget.selected}");
        debugPrint("SEND URL: ${widget.selected}");
        debugPrint("${response.statusCode}");

        if (response.statusCode == 200) {
          final responseBody = json.decode(response.body);
          // List<Data> singleData = responseBody['data']
          //     .map<Data>((item) => Data.fromJson(item))
          //     .toList();
          // return singleData;

          /**
       * 稍后写～～～
       */

          YangChenData single = new YangChenData.fromJson(responseBody);

          List pushList = [];

          if (single.data.length == 0) {
            setState(() {
              selected_EnterpriseName = "该企业无污染物数据";
              data_UpdateTime = "无更新数据时间";
            });
          } else {
            for (var i = 0; i < single.data.length; i++) {
              var factorName = single.data[i].factorName; // 污染物因子名称
              var factorValue = single.data[i].value;
              var updateTime = single.data[i].time;
              var factorUnit = single.data[i].unit;
              // var entpName = single.data[i].entpName;
              var point = single.data[i].point;
              pushList.add({
                // "entpName": entpName,
                "factorname": factorName,
                "value": factorValue,
                "time": updateTime,
                "unit": factorUnit,
                "point": point
              });
            }

            // setState(() {
            //   selected_EnterpriseName = single.data[0].entpName;
            //   data_UpdateTime = convertTimestampSingleLine(single.data[0].time);
            // });
            selected_Point = single.data[0].pointId;
          }
          debugPrint("The value of pushList is : ${pushList}");
          return pushList;
        } else {
          /**
       * 1. 如果该企业因为网络原因无法刷新出来内容
       */

          return Text("网络无连接");
          // throw Exception("Failed to fetch data");

        }
      } catch (e) {
        print(e);
      }
    }
  }

  var routeToGraph = new MaterialPageRoute(
          builder: (BuildContext context) => new GraphGenerator( // 不可用HomeScreen来替代
              sp: selected_Enterprise,
          )
          // builder: (BuildContext context) => new Limousine()
  );

  var routeToVideo = new MaterialPageRoute(
          builder: (BuildContext context) => new GraphGenerator( // 不可用HomeScreen来替代
              sp: selected_Enterprise
          )
          // builder: (BuildContext context) => new Limousine()
  );
  

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: getRealTimeData(),
    //   builder: (BuildContext context, AsyncSnapshot snapshot) {
    //     switch (snapshot.connectionState) {
    //       case ConnectionState.none:
    //       case ConnectionState.active:
    //       case ConnectionState.waiting:
    //         return Center(child: Text("获取数据中..."));
    //       case ConnectionState.done:
    //         if (snapshot.hasError) {
    //           debugPrint("网络请求出错");
    //           return Center(
    //             child: Text("网络请求出错"),
    //           );
    //         } else if (snapshot.hasData) {
    //           new List<Widget>.generate(snapshot.data.length, (int index) {
    //             debugPrint("END WITH ${snapshot.data[index]['factorName']}");
    //             return ListView(
    //               children: <Widget>[
    //                 ListTile(
    //                   title: Text(snapshot.data[index]['factorName']),
    //                 )
    //               ],
    //             );
    //           });
    //         }
    //     }
    //   },
    // );

    return Container(
        color:
            Colors.blueGrey.withOpacity(0.95), // Color.fromRGBO(58, 66, 86, 1.0).withOpacity(0.7)
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 85,
              child: FutureBuilder(
                future: getRealTimeData(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                      debugPrint('NONE PHASE');
                      return Container(
                        alignment: Alignment.center,
                        color: Colors.blueGrey,
                        child: Text(
                          "网络受限或无连接，请重试...",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      );
                    case ConnectionState.active:
                      debugPrint("ACTIVE PHASE");
                      return Text("Connection: ACTIVE");
                    case ConnectionState.waiting:
                      debugPrint("WAITING PHASE: ${widget.selected}");
                      return Container(
                        alignment: Alignment.center,
                        color: Colors.blueGrey,
                        child: Text(
                          "获取数据中, 请耐心等待...",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      );
                    case ConnectionState.done:
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return FlatButton(
                            onPressed: () => GraphGenerator(),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 10.0),
                              leading: Container(
                                width: 80,
                                padding: EdgeInsets.only(left: 10),
                                decoration: new BoxDecoration(
                                    border: new Border(
                                        right: new BorderSide(
                                            width: 2.0,
                                            color: Colors.white24))),
                                child: Text(
                                  '${snapshot.data[index]['factorname']}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white),
                                ),
                              ),
                              // leading: Text(
                              //   '${snapshot.data[index]['factorname']}',
                              //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              // ),
                              title: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                child: Text(
                                    '${snapshot.data[index]['value']} ${snapshot.data[index]['unit']}',
                                    style: TextStyle(
                                        fontSize: 30, color: Colors.white)),
                              ),
                              subtitle: Container(
                                child: Text(
                                  '${snapshot.data[index]['point'].toString()}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              trailing: Text(
                                  "${convertTimestampSingleLine(snapshot.data[index]['time'])}",
                                  style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      );
                  }

                  // child: ListView(
                  //   children: <Widget>[
                  //     ListTile(
                  //       leading: Text('${snapshot.data[0]['factorname']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                  //       title: Text('${snapshot.data[0]['value']}${snapshot.data[0]['unit']}', style: TextStyle(fontSize: 20),),
                  //       subtitle: Text('${snapshot.data[0]['time']}'),
                  //     ),
                  //   ],
                  // ),
                },
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    // Text(
                    //   "当前查看企业: $selected_EnterpriseName",
                    //   style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
                    // ),
                    // Text(
                    //   "数据更新时间: $data_UpdateTime",
                    //   style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                        onPressed: () =>
                            {Navigator.pushNamed(context, '/graph')},
                        child: Text(
                          "查看图表",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontStyle: FontStyle.italic),
                        ))
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ));

    // return Container(
    //     color: Colors.grey.withOpacity(0.2),
    //     child: SafeArea(
    //       child: ListView(
    //         children: <Widget>[
    //           ListTile(
    //             leading: Text(
    //               'PM2.5',
    //               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    //             ),
    //             title: Text('12.0'),
    //             subtitle: Text('2019.12.12 13:24:33'),
    //           ),
    //         ],
    //       ),
    //     ));
  }
}
