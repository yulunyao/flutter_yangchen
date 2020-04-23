import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'liveStream.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:time_formatter/time_formatter.dart';
import '../user/login.dart';
import 'graphGenerator.dart';
import 'dataLoader.dart';
import 'userInfo.dart';

String selected_Enterprise; // 下拉框确定选中的企业对应的id
String selected_EnterpriseName; // 绑定的企业名称
int selected_Point = 032;
String data_UpdateTime; // 绑定的企业实时数据更新的时间
String _token;
String enterpriseBanner;

class HomeTest extends StatefulWidget {
  final String username;
  final String password;

  HomeTest({this.username, this.password});
  @override
  _HomeTestState createState() => _HomeTestState();
}

class _HomeTestState extends State<HomeTest> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("${widget.username}"),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String username;
  final String password;
  final String token;
  final String userId;

  HomeScreen({this.username, this.password, this.token, this.userId});
  // const HomeScreen({
  //   this.username,
  //   this.password
  // });
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List _pageList;
  // int _currentIndex;
  // List<BottomNavigationBarItem> bnbi;

  // @override
  // void initState() {
  //   _pageList = [HomeMain(), GraphGenerator()]; // 用于tabber切换
  //   _currentIndex = 0;
  //   bnbi = [
  //     BottomNavigationBarItem(icon: Icon(Icons.data_usage), title: Text("数据")),
  //     BottomNavigationBarItem(icon: Icon(Icons.broken_image), title: Text("图表"))
  //   ];
  //   super.initState();

  // }
  // final String username;
  // final String password;

  // _HomeScreenState({
  //   this.username,
  //   this.password
  // });

  @override
  Widget build(BuildContext context) {
    // debugPrint("TOKEN: ${widget.token}"); // 使用widget方法来调用父级资源
    _token = widget.token;
    debugPrint("Here: $_token");
    return Scaffold(
      drawer: Drawer(
        // 侧滑左边栏
        child: ListView(padding: EdgeInsets.zero, children: <Widget>[
          UserAccountsDrawerHeader(
              accountName: new Text(
                "当前用户",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text("${widget.username}"),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                // image: DecorationImage(
                //   image: NetworkImage('https://resources.ninghao.org/images/candy-shop.jpg'),
                //   fit: BoxFit.cover,
                //   colorFilter: ColorFilter.mode(
                //     Colors.yellow[400].withOpacity(0.6),
                //     BlendMode.hardLight
                //   )
                // )
              )),
          ListTile(
            title: Text("选择企业", textAlign: TextAlign.right),
            trailing: Icon(
              Icons.message,
              color: Colors.black12,
              size: 26.0,
            ),
            onTap: () => {
              showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                        color: Colors.grey[100],
                        height: 300,
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FlatButton(
                                  child: Text(
                                    '取消',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context); // 点击取消则弹出框关闭
                                  },
                                ),
                                FlatButton(
                                  child: Text(
                                    '确定',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  onPressed: () {
                                    debugPrint(
                                        "点击确定后的值: $selected_Enterprise"); // 调用根据id的值来获取企业实时数据的函数
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    setState(() {
                                      HomeMain(token: _token, selected: selected_Enterprise);
                                    });
                                  },
                                ),
                              ],
                            ),
                            Expanded(child: testData())
                          ],
                        ));
                  })
            },
          ),
          ListTile(
              title: Text(
                "用户信息",
                textAlign: TextAlign.right,
              ),
              trailing: Icon(
                Icons.favorite,
                color: Colors.black12,
                size: 26.0,
              ),
              onTap: () => Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context) => new UserInfo(token: _token,) // 将token传给UserInfo页面
              ))),
          ListTile(
              title: Text(
                "视频直播",
                textAlign: TextAlign.right,
              ),
              trailing: Icon(
                Icons.favorite,
                color: Colors.black12,
                size: 26.0,
              ),
              onTap: () => Navigator.push(context, new MaterialPageRoute(
                builder: (BuildContext context) => new LiveStream(userId: "${widget.userId}",) // 将token传给UserInfo页面
              ))),
          // ListTile(
          //   title: Text(
          //     "扬尘系统介绍",
          //     textAlign: TextAlign.right,
          //   ),
          //   trailing: Icon(
          //     Icons.favorite,
          //     color: Colors.black12,
          //     size: 22.0,
          //   ),
          //   onTap: () => Navigator.pushNamed(context, '/home/intro'),
          // ),
          ListTile(
            title: Text(
              "登出账户",
              textAlign: TextAlign.right,
              style: TextStyle(color: Colors.redAccent),
            ),
            trailing: Icon(
              Icons.settings,
              color: Colors.redAccent,
              size: 26.0,
            ),
            onTap: () => {Navigator.pushReplacementNamed(context, '/login')},
          ),
        ]),
      ),
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                HomeMain(token: _token,); // 点击按钮手动刷新主页内容
              });
            },
          )
        ],
        title: Text(
          "数据查看",
          style: TextStyle(fontSize: 18),
        ),
      ),
      body: HomeMain(token: _token, selected: selected_Enterprise,),
    );
  }
}

class testData extends StatefulWidget {
  @override
  _testDataState createState() => _testDataState();
}

class _testDataState extends State<testData> {
  String result;

  Future getData() async {
    var url = "http://218.91.223.15:31710/ntplatform2/api/yc/pointtree";
    var response = await http.get(url, headers: {
      "Authorization": "Bearer $_token" //传入token
    });
    // var jsonData = json.decode(response.body);

    // List<YangChenData> RData = [];

    // for(var u in jsonData) {
    //   YangChenData singleData = YangChenData();
    //   RData.add(singleData);
    // }

    // print(RData);
    // return RData;

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      // List<Data> singleData = responseBody['data']
      //     .map<Data>((item) => Data.fromJson(item))
      //     .toList();
      // return singleData;

      /**
       * !!!添加一个传入token的操作
       */

      Enterprise single = new Enterprise.fromJson(responseBody);
      // debugPrint("The value of single is : ${single.data}");

      var pushList = [];

      for (var i = 0; i < single.data.length; i++) {
        var dataitself = single.data[i].text;
        var dataitselfwithId = single.data[i].id;
        pushList.add({"text": dataitself, "id": dataitselfwithId});
      }

      return pushList;
    } else {
      /**
       * 1. 无网络情况
       */
      if (response.statusCode == 500) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        throw Exception("Failed to fetch data");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: Text("获取数据中..."));
          case ConnectionState.done:
            if (snapshot.hasError) {
              debugPrint("网络请求出错");
              return Center(
                child: Text("网络请求出错"),
              );
            } else if (snapshot.hasData) {
              return CupertinoPicker(
                itemExtent: 50,
                children: new List<Widget>.generate(snapshot.data.length,
                    (int index) {
                  return new Center(
                    child: new Text(
                      "${snapshot.data[index]['text']}", // text获取到所有企业的名称, id获取到所有企业的id
                      style: TextStyle(fontSize: 18.0),
                    ),
                  );
                }),
                onSelectedItemChanged: (t) {
                  selected_Enterprise = snapshot.data[t]['id'];
                  debugPrint("滑动至: ${snapshot.data[t]['id'].toString()}");
                },
              );
            }
            debugPrint(selected_Enterprise);
        }
        // return ListView(
        //   children: snapshot.data.map<Widget>((item) {
        //     return ListTile(
        //       title: Text(item.text),
        //     );
        //   }).toList()
        // );
        // }
        return null;
      },
    );
  }
}

class IntroData extends StatefulWidget {
  @override
  _IntroDataState createState() => _IntroDataState();
}

class _IntroDataState extends State<IntroData> {
  Column LoadImage(imgUrl) {
    return Column(
      children: <Widget>[
        CachedNetworkImage(
          imageUrl: imgUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        SizedBox(
          height: 10.0,
        )
      ],
    );
  }

  var text =
      "TINZ-TSMS-1010型扬尘在线监测系统是我司研制的新产品，本产品技术指标参照了上海市环境保护局2015年底颁布的《上海市建筑施工颗粒物与噪声在线监测技术规范（试行）》标准内的相关技术指标。其实现了各类环境与气象参数的集成，针对建筑施工工地、市政公用工程、园林绿化工程、交通工程、水利工程、码头堆场等产所进行设计，其系统功能主要实现实时监控、超标抓拍、数据图表统计分析、可实时进行扬尘在线监管，解决了这类扬尘无组织排放的技术难题，满足了环保部门精细化监督执法的要求。";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("扬尘在线监测系统介绍"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () => {Navigator.pushNamed(context, '/home')},
          )),
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            Container(
              color: Colors.grey.withOpacity(0.3),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 15.0),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/x1.jpg"),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/x2.png"),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/x3.jpg"),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/x4.jpg"),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/x5.png"),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/x6.jpg"),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/xtzc1.jpg"),
            LoadImage("http://218.91.223.15:31710/pics/yangchen/xtzc2.jpg")
          ],
        ),
      ),
    );
  }
}

/**
 * JSON MODEL
 */

class Enterprise {
  int code;
  String msg;
  Null count;
  List<Data> data;

  Enterprise({this.code, this.msg, this.count, this.data});

  Enterprise.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    count = json['count'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String id;
  String text;
  double value;
  String state;
  bool checked;
  Null attributes;
  Null children;
  String icon;
  Null pid;
  Null taskNum;
  Null adminWant;

  Data(
      {this.id,
      this.text,
      this.value,
      this.state,
      this.checked,
      this.attributes,
      this.children,
      this.icon,
      this.pid,
      this.taskNum,
      this.adminWant});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
    value = json['value'];
    state = json['state'];
    checked = json['checked'];
    attributes = json['attributes'];
    children = json['children'];
    icon = json['icon'];
    pid = json['pid'];
    taskNum = json['taskNum'];
    adminWant = json['adminWant'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    data['value'] = this.value;
    data['state'] = this.state;
    data['checked'] = this.checked;
    data['attributes'] = this.attributes;
    data['children'] = this.children;
    data['icon'] = this.icon;
    data['pid'] = this.pid;
    data['taskNum'] = this.taskNum;
    data['adminWant'] = this.adminWant;
    return data;
  }
}

class YangChenData {
  int code;
  String msg;
  Null count;
  List<YangChenInside> data;

  YangChenData({this.code, this.msg, this.count, this.data});

  YangChenData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    count = json['count'];
    if (json['data'] != null) {
      data = new List<YangChenInside>();
      json['data'].forEach((v) {
        data.add(new YangChenInside.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class YangChenInside {
  String unit;
  int pointId;
  double a01007;
  String entpName;
  String factorName;
  String canton;
  int time;
  int entpId;
  double value;
  String point;
  double a01001;
  double leq;
  double a01002;
  double a01008;
  double a34004;
  double a34002;
  double a34001;
  double a01006;

  YangChenInside(
      {this.unit,
      this.pointId,
      this.a01007,
      this.entpName,
      this.factorName,
      this.canton,
      this.time,
      this.entpId,
      this.value,
      this.point,
      this.a01001,
      this.leq,
      this.a01002,
      this.a01008,
      this.a34004,
      this.a34002,
      this.a34001,
      this.a01006});

  YangChenInside.fromJson(Map<String, dynamic> json) {
    unit = json['unit'];
    pointId = json['pointId'];
    a01007 = json['a01007'];
    entpName = json['entpName'];
    factorName = json['factorName'];
    canton = json['canton'];
    time = json['time'];
    entpId = json['entpId'];
    value = json['value'];
    point = json['point'];
    a01001 = json['a01001'];
    leq = json['Leq'];
    a01002 = json['a01002'];
    a01008 = json['a01008'];
    a34004 = json['a34004'];
    a34002 = json['a34002'];
    a34001 = json['a34001'];
    a01006 = json['a01006'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unit'] = this.unit;
    data['pointId'] = this.pointId;
    data['a01007'] = this.a01007;
    data['entpName'] = this.entpName;
    data['factorName'] = this.factorName;
    data['canton'] = this.canton;
    data['time'] = this.time;
    data['entpId'] = this.entpId;
    data['value'] = this.value;
    data['point'] = this.point;
    data['a01001'] = this.a01001;
    data['Leq'] = this.leq;
    data['a01002'] = this.a01002;
    data['a01008'] = this.a01008;
    data['a34004'] = this.a34004;
    data['a34002'] = this.a34002;
    data['a34001'] = this.a34001;
    data['a01006'] = this.a01006;
    return data;
  }
}

class UserDetail {
  int code;
  String msg;
  Null count;
  UserDetailInfo data;

  UserDetail({this.code, this.msg, this.count, this.data});

  UserDetail.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    count = json['count'];
    data =
        json['data'] != null ? new UserDetailInfo.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    return data;
  }
}

class UserDetailInfo {
  int id;
  String username;
  String cusername;
  String district;
  int districtId;
  String districtCode;
  String role;
  Null psId;
  Null psName;
  Null token;

  UserDetailInfo(
      {this.id,
      this.username,
      this.cusername,
      this.district,
      this.districtId,
      this.districtCode,
      this.role,
      this.psId,
      this.psName,
      this.token});

  UserDetailInfo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    cusername = json['cusername'];
    district = json['district'];
    districtId = json['districtId'];
    districtCode = json['districtCode'];
    role = json['role'];
    psId = json['psId'];
    psName = json['psName'];
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['cusername'] = this.cusername;
    data['district'] = this.district;
    data['districtId'] = this.districtId;
    data['districtCode'] = this.districtCode;
    data['role'] = this.role;
    data['psId'] = this.psId;
    data['psName'] = this.psName;
    data['token'] = this.token;
    return data;
  }
}

class GraphOutside {
  int code;
  String msg;
  Null count;
  List<Graph> data;

  GraphOutside({this.code, this.msg, this.count, this.data});

  GraphOutside.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    count = json['count'];
    if (json['data'] != null) {
      data = new List<Graph>();
      json['data'].forEach((v) {
        data.add(new Graph.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['msg'] = this.msg;
    data['count'] = this.count;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Graph {
  String name;
  String unit;
  String title;
  List<GraphInside> datas;

  Graph({this.name, this.unit, this.title, this.datas});

  Graph.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    unit = json['unit'];
    title = json['title'];
    if (json['datas'] != null) {
      datas = new List<GraphInside>();
      json['datas'].forEach((v) {
        datas.add(new GraphInside.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['unit'] = this.unit;
    data['title'] = this.title;
    if (this.datas != null) {
      data['datas'] = this.datas.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GraphInside {
  Null id;
  int statCodeId;
  int devCodeId;
  String monitorTime;
  int monitorFactorId;
  Null min;
  double avg;
  Null max;
  Null unit;
  Null factorName;

  GraphInside(
      {this.id,
      this.statCodeId,
      this.devCodeId,
      this.monitorTime,
      this.monitorFactorId,
      this.min,
      this.avg,
      this.max,
      this.unit,
      this.factorName});

  GraphInside.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    statCodeId = json['statCodeId'];
    devCodeId = json['devCodeId'];
    monitorTime = json['monitorTime'];
    monitorFactorId = json['monitorFactorId'];
    min = json['min'];
    avg = json['avg'];
    max = json['max'];
    unit = json['unit'];
    factorName = json['factorName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['statCodeId'] = this.statCodeId;
    data['devCodeId'] = this.devCodeId;
    data['monitorTime'] = this.monitorTime;
    data['monitorFactorId'] = this.monitorFactorId;
    data['min'] = this.min;
    data['avg'] = this.avg;
    data['max'] = this.max;
    data['unit'] = this.unit;
    data['factorName'] = this.factorName;
    return data;
  }
}

class DataToGraph {
  final String hourNMinute;
  final String value;

  DataToGraph(this.hourNMinute, this.value);
}

class GraphToBeUsed {
  final String time;
  final double value;

  GraphToBeUsed(this.time, this.value);
}
