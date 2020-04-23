import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserInfo extends StatelessWidget {
  String token;

  UserInfo({this.token});

  Future getData() async {
    var url = "http://218.91.223.15:31710/ntplatform2/api/user/info";
    var response = await http.get(url, headers: {
      "Authorization": "Bearer $token" //传入token
    });
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['data'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户信息'),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: Text("获取数据中..."));
            case ConnectionState.done:
              return ListView(
                children: <Widget>[
                  ListTile(
                    title: Text("用户名"),
                    trailing: Text(snapshot.data['username']),
                  ),
                  ListTile(
                    title: Text("用户"),
                    trailing: Text(snapshot.data['cusername']),
                  ),
                  ListTile(
                    title: Text("地区"),
                    trailing: Text(snapshot.data['district']),
                  ),
                  ListTile(
                    title: Text("地区ID"),
                    trailing: Text(snapshot.data['districtId'].toString()),
                  ),
                  ListTile(
                    title: Text("角色"),
                    trailing: Text(snapshot.data['role']),
                  )
                ],
              );
          }
        },
      ),
    );
  }
}
