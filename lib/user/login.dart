import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import '../interface/dataLoader.dart';
import '../interface/home.dart';
import '../main.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../interface/repoTest.dart';
import '../interface/limousine.dart';

String _username, _password, _token, _userId;
String loginText = "登陆";
Color loginColor = Color(0xff01A0C7);

var selected_Enterprise;

class UserLogin extends StatefulWidget {
  @override
  _UserLoginState createState() => _UserLoginState();
}

class _UserLoginState extends State<UserLogin> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  var loggedIn = false;

  GlobalKey<FormState> formKey = new GlobalKey<FormState>();
  GlobalKey<ScaffoldState> mainKey = new GlobalKey<ScaffoldState>();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  /** 点击提交表单后 **/
  void FormOnPressed() {
    var form = formKey.currentState;

    if (form.validate()) {
      // 遍历该Form下的所有TextField的validate函数
      form.save(); // 遍历该Form下所有TextField的onSaved函数
      setState(() {
        loggedIn = true;
        loginText = "登陆";
        loginColor = Colors.red;
      });

      /** 传递参数到 HomeTest页面*/
      var route = new MaterialPageRoute(
          builder: (BuildContext context) => new HomeScreen(
              // 不可用HomeScreen来替代
              username: _username,
              password: _password,
              token: _token,
              userId: "$_userId"));

      debugPrint("U: $_username, P: $_password, T: $_token, U: $_userId");
      Navigator.pushReplacement(context, route);
    }
  }

  Future<NData> checkUserInfo() async {
    debugPrint("$_username AND $_password");
    var url = "http://218.91.223.15:31710/ntplatform2/api/user/login";
    var response = await http.post(url,
        headers: {
          'Accept': "application/json",
          'Content-Type': 'application/json'
        },
        body: json.encode({"username": _username, "password": _password}));
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      _token = responseBody['data']['token'];
      _userId = "${responseBody['data']['id']}";
      setState(() {
        loginColor = Colors.red;
      });

      FormOnPressed();
      // return singleData;
    } else {
      setState(() {
        loginText = "验证失败，请重试。";
        loginColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usernameField = TextFormField(
      autocorrect: false,
      obscureText: false,
      style: style,
      validator: (str) => str.length == 0 ? "请输入用户名" : null,
      onSaved: (str) {
        _username = str;
      },
      onChanged: (val) {
        setState(() {
          _username = val;
          loginText = "登陆";
          loginColor = Color(0xff01A0C7);
        });
      },
      controller: _usernameController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "用户名",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final passwordField = TextFormField(
      autocorrect: false,
      obscureText: true,
      style: style,
      onChanged: (val) {
        setState(() {
          _password = val;
          loginText = "登陆";
          loginColor = Color(0xff01A0C7);
        });
      },
      validator: (str) => str.length == 0 ? "请输入密码" : null,
      onSaved: (str) => _password = str,
      controller: _passwordController,
      decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
          hintText: "密码",
          border:
              OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))),
    );
    final loginButon = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: loginColor,
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        onPressed: checkUserInfo,
        child: Text("$loginText",
            textAlign: TextAlign.center,
            style: style.copyWith(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );

    return Scaffold(
      key: mainKey,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: loggedIn == false
                  ? Form(
                      key: formKey, //将该GlobalKey和此Form下的所有TextFormField关联起来
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 155.0,
                            child: Text(
                              "扬尘平台",
                              style: TextStyle(
                                fontSize: 35.0,
                              ),
                            ),
                          ),
                          SizedBox(height: 25.0),
                          usernameField,
                          SizedBox(height: 25.0),
                          passwordField,
                          SizedBox(
                            height: 35.0,
                          ),
                          loginButon,
                          SizedBox(
                            height: 15.0,
                          ),
                        ],
                      ),
                    )
                  : null),
        ),
      ),
    );
  }
}

class UserAuth {
  int code;
  String msg;
  Null count;
  NData data;

  UserAuth({this.code, this.msg, this.count, this.data});

  UserAuth.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    msg = json['msg'];
    count = json['count'];
    data = json['data'] != null ? new NData.fromJson(json['data']) : null;
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

class NData {
  int id;
  String username;
  String cusername;
  String district;
  int districtId;
  String districtCode;
  String role;
  Null psId;
  Null psName;
  String token;

  NData(
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

  NData.fromJson(Map<String, dynamic> json) {
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
