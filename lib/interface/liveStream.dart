import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class LiveStream extends StatefulWidget {
  String userId;
  LiveStream({this.userId});
  @override
  _LiveStreamState createState() => _LiveStreamState();
}

// 根据appKey, appSecret获取accessToken

// 根据accessToken获取绑定的摄像头列表

class _LiveStreamState extends State<LiveStream> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            "视频直播",
            style: TextStyle(fontSize: 18),
          ),
        ),
        body: BindIdCamera(
          userId: widget.userId,
        ));
  }
}

class BindIdCamera extends StatefulWidget {
  String userId;
  BindIdCamera({this.userId});
  @override
  _BindIdCameraState createState() => _BindIdCameraState();
}

class _BindIdCameraState extends State<BindIdCamera> {
  Future getBindCamera() async {
    var url =
        "http://218.91.223.15:31710/ntplatform2/api/yc/webcam/pointsinfo/${widget.userId}";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      BindCamera bc = new BindCamera.fromJson(responseBody);
      return bc.data;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getBindCamera(),
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
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2),
                        child: Card(
                            child: FlatButton(
                                child: ListTile(
                                    leading: Text(snapshot.data[index].canton),
                                    title: Text(snapshot.data[index].entp),
                                    subtitle: Text(snapshot.data[index].point),
                                    trailing:
                                        Text(snapshot.data[index].camCode)),
                                onPressed: () => Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            new LiveStreamPage(
                                                camCode: snapshot
                                                    .data[index].camCode,
                                                point: snapshot.data[index]
                                                    .point) // 将token传给UserInfo页面
                                        )))));
                  });
          }
          ;
        });
  }
}

class LiveStreamPage extends StatefulWidget {
  String camCode, point;
  LiveStreamPage({this.camCode, this.point});
  @override
  _LiveStreamPageState createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.point),
      ),
      body: LiveStreamRealtimeNew(
        camCode: widget.camCode,
      ),
    );
  }
}

class LiveStreamRealtimeNew extends StatefulWidget {
  String camCode;
  LiveStreamRealtimeNew({this.camCode});
  final appKey = "f61034c02b434e15af8b60e99ef96c56";
  final secret = "faddec8dde6d12193b2ccfcb6706a5c3";
  String accessToken;
  @override
  _LiveStreamRealtimeNewState createState() => _LiveStreamRealtimeNewState();
}

class _LiveStreamRealtimeNewState extends State<LiveStreamRealtimeNew> {
  String pushUrl;
  String deviceName;
  String deviceHasAddress;
  String hasError;

  IjkMediaController controller = IjkMediaController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget buildIjkPlayer() {
    return Container(
      height: 340, // 这里随意
      child: IjkPlayer(
        mediaController: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Future getAccessToken() async {
      String url = "https://open.ys7.com/api//lapp/token/get";
      var response = await http.post(url, headers: {
        'Accept': "application/json",
        'Content-Type': 'application/x-www-form-urlencoded'
      }, body: {
        "appKey": widget.appKey,
        "appSecret": widget.secret
      } // 不可加json.encoded前缀
          );

      if (response.statusCode == 200) {
        var res_Decode = json.decode(response.body);
        AccessToken at = new AccessToken.fromJson(res_Decode);
        widget.accessToken = at.data.accessToken;

        // access token成功获取后, 开始获取videolist
        String url1 = "https://open.ys7.com/api/lapp/live/video/list";
        var response1 = await http.post(url1, headers: {
          'Accept': "application/json",
          'Content-Type': 'application/x-www-form-urlencoded',
        }, body: {
          "accessToken": widget.accessToken,
          "pageSize": "20"
        });
        if (response1.statusCode == 200) {
          var cameraList = json.decode(response1.body);
          CameraList cl = new CameraList.fromJson(cameraList);
          for (int i = 0; i < cl.data.length; i++) {
            if (cl.data[i].deviceSerial == widget.camCode) {
              deviceName = cl.data[i].deviceName;
              cl.data[i].liveAddress != null? deviceHasAddress = "存在" : deviceHasAddress = "不存在";
              cl.data[i].exception == 0? hasError = "无异常": hasError = "存在异常";
              pushUrl = cl.data[i].liveAddress;
            }
          }
          return pushUrl;
        } else {
          debugPrint("ERROR");
        }
      } else {
        debugPrint("ERROR");
      }
    }

    return FutureBuilder(
      future: getAccessToken(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container(
              alignment: Alignment.center,
              color: Colors.blueGrey,
              child: Text(
                "获取数据中, 请耐心等待...",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            );
          case ConnectionState.done:
            controller.setNetworkDataSource('${snapshot.data}', autoPlay: true);
            return Container(
              // width: MediaQuery.of(context).size.width,
              // height: 400,
              child: ListView(children: <Widget>[
                Container(
                  color: Colors.black,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("设备名称: $deviceName", style: TextStyle(color: Colors.white)),
                      Text("是否存在视频地址: $deviceHasAddress", style: TextStyle(color: Colors.white)),
                      Text("是否异常: $hasError", style: TextStyle(color: Colors.white))
                    ],
                  ),
                ),
                buildIjkPlayer()
              ]),
            );
        }
      },
    );
  }
}

class AccessToken {
  AccessTokenData data;
  String code;
  String msg;

  AccessToken({this.data, this.code, this.msg});

  AccessToken.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? new AccessTokenData.fromJson(json['data'])
        : null;
    code = json['code'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['code'] = this.code;
    data['msg'] = this.msg;
    return data;
  }
}

class AccessTokenData {
  String accessToken;
  int expireTime;

  AccessTokenData({this.accessToken, this.expireTime});

  AccessTokenData.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    expireTime = json['expireTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['accessToken'] = this.accessToken;
    data['expireTime'] = this.expireTime;
    return data;
  }
}

/*           CAMERA           */

class CameraList {
  CameraListSize page;
  List<CameraListData> data;
  String code;
  String msg;

  CameraList({this.page, this.data, this.code, this.msg});

  CameraList.fromJson(Map<String, dynamic> json) {
    page =
        json['page'] != null ? new CameraListSize.fromJson(json['page']) : null;
    if (json['data'] != null) {
      data = new List<CameraListData>();
      json['data'].forEach((v) {
        data.add(new CameraListData.fromJson(v));
      });
    }
    code = json['code'];
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.page != null) {
      data['page'] = this.page.toJson();
    }
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['code'] = this.code;
    data['msg'] = this.msg;
    return data;
  }
}

class CameraListSize {
  int total;
  int page;
  int size;

  CameraListSize({this.total, this.page, this.size});

  CameraListSize.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    page = json['page'];
    size = json['size'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['total'] = this.total;
    data['page'] = this.page;
    data['size'] = this.size;
    return data;
  }
}

class CameraListData {
  String deviceSerial;
  int channelNo;
  String deviceName;
  String liveAddress;
  String hdAddress;
  String rtmp;
  String rtmpHd;
  String flvAddress;
  String hdFlvAddress;
  int status;
  int exception;
  int beginTime;
  int endTime;

  CameraListData(
      {this.deviceSerial,
      this.channelNo,
      this.deviceName,
      this.liveAddress,
      this.hdAddress,
      this.rtmp,
      this.rtmpHd,
      this.flvAddress,
      this.hdFlvAddress,
      this.status,
      this.exception,
      this.beginTime,
      this.endTime});

  CameraListData.fromJson(Map<String, dynamic> json) {
    deviceSerial = json['deviceSerial'];
    channelNo = json['channelNo'];
    deviceName = json['deviceName'];
    liveAddress = json['liveAddress'];
    hdAddress = json['hdAddress'];
    rtmp = json['rtmp'];
    rtmpHd = json['rtmpHd'];
    flvAddress = json['flvAddress'];
    hdFlvAddress = json['hdFlvAddress'];
    status = json['status'];
    exception = json['exception'];
    beginTime = json['beginTime'];
    endTime = json['endTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deviceSerial'] = this.deviceSerial;
    data['channelNo'] = this.channelNo;
    data['deviceName'] = this.deviceName;
    data['liveAddress'] = this.liveAddress;
    data['hdAddress'] = this.hdAddress;
    data['rtmp'] = this.rtmp;
    data['rtmpHd'] = this.rtmpHd;
    data['flvAddress'] = this.flvAddress;
    data['hdFlvAddress'] = this.hdFlvAddress;
    data['status'] = this.status;
    data['exception'] = this.exception;
    data['beginTime'] = this.beginTime;
    data['endTime'] = this.endTime;
    return data;
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  IjkMediaController controller = IjkMediaController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: MediaQuery.of(context).size.width,
      // height: 400,
      child: ListView(children: <Widget>[
        buildIjkPlayer(),
      ]),
    );
    floatingActionButton:
    FloatingActionButton(
      child: Icon(Icons.play_arrow),
      onPressed: () async {
        await controller.setNetworkDataSource(
            'http://hls01open.ys7.com/openlive/8f0b8780b4ca4f78b9dd8ec68ef17690.m3u8',
            autoPlay: true);
        print("set data source success");
        // controller.playOrPause();
      },
    );
  }

  Widget buildIjkPlayer() {
    return Container(
      height: 400, // 这里随意
      child: IjkPlayer(
        mediaController: controller,
      ),
    );
  }
}

class BindCamera {
  int code;
  String msg;
  Null count;
  List<BindCameraData> data;

  BindCamera({this.code, this.msg, this.count, this.data});

  BindCamera.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    count = json['count'];
    if (json['data'] != null) {
      data = new List<BindCameraData>();
      json['data'].forEach((v) {
        data.add(new BindCameraData.fromJson(v));
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

class BindCameraData {
  String canton;
  String camCode;
  String entp;
  String point;

  BindCameraData({this.canton, this.camCode, this.entp, this.point});

  BindCameraData.fromJson(Map<String, dynamic> json) {
    canton = json['canton'];
    camCode = json['camCode'];
    entp = json['entp'];
    point = json['point'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['canton'] = this.canton;
    data['camCode'] = this.camCode;
    data['entp'] = this.entp;
    data['point'] = this.point;
    return data;
  }
}
