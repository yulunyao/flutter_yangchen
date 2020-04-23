import 'package:flutter/material.dart';
import 'home.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'home.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

var selected_factor = "温度";
var innerList;
var unit;
List<DropdownMenuItem> showNumberOfItems = [
  DropdownMenuItem(
    child: Text("20"),
    value: Text("20"),
  ),
  DropdownMenuItem(
    child: Text("20"),
    value: Text("20"),
  )
];

var selectedNumberOfItems = '';
List<DropdownMenuItem> dropdownList = [];

class GraphGenerator extends StatefulWidget {
  String sp; //sp = Selected_Point;
  GraphGenerator({this.sp});
  @override
  _GraphGeneratorState createState() => _GraphGeneratorState();
}

class _GraphGeneratorState extends State<GraphGenerator> {
  List<GraphToBeUsed> pushList = [];
  String title = '';
  @override
  Widget build(BuildContext context) {
    Future getGraphData(param) async {
      String url =
          "http://218.91.223.15:31710/ntplatform2/api/yc/monitor/hour2/0/$selected_Point";
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var outerList = json.decode(response.body);

        var centerList = outerList['data'];
        dropdownList = [];
        for (int i = 0; i < centerList.length; i++) {
          dropdownList.add(DropdownMenuItem(
            child: new Text(centerList[i]['name']),
            value: centerList[i]['name'],
          ));

          if (centerList[i]['name'] == param) {
            unit = centerList[i]['unit'];
            title = centerList[i]['title'];
            innerList = centerList[i]['datas'];
          }
        }

        for (int i = 0; i < innerList.length; i++) {
          // 可限制显示的数量
          // 仅展示最近20条记录
          pushList.add(
              GraphToBeUsed(innerList[i]['monitorTime'], innerList[i]['avg']));
        }

        debugPrint("查询到${innerList.length}条记录");
        print("HERE IS PUSHLIST ${pushList.length}");
        return pushList;
      } else {
        return null;
      }
    }

    // List<charts.Series<GraphToBeUsed, String>> _createSampleData() {
    //   print("PUSHLIST:$pushList");

    //   return [
    //     new charts.Series<GraphToBeUsed, String>(
    //         id: 'Sales',
    //         domainFn: (GraphToBeUsed global, _) => global.time,
    //         measureFn: (GraphToBeUsed global, _) => global.value,
    //         data: pushList,
    //         // Set a label accessor to control the text of the bar label.
    //         labelAccessorFn: (GraphToBeUsed global, _) =>
    //             '【${global.time}】: ${global.value.toString()} $unit')
    //   ];
    // }

    var helo = SfCartesianChart(
      zoomPanBehavior: ZoomPanBehavior(
          enableSelectionZooming: true,
          enablePinching: true,
          enablePanning: true,
          selectionRectBorderColor: Colors.red,
          selectionRectBorderWidth: 1,
          selectionRectColor: Colors.grey
      ),
      title: ChartTitle(text: '24小时数据 - ${selected_factor}'),
      primaryXAxis: CategoryAxis(),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <ChartSeries>[
        ScatterSeries<GraphToBeUsed, String>(
            dataSource: pushList,
            xValueMapper: (GraphToBeUsed dt, _) => dt.time,
            yValueMapper: (GraphToBeUsed dt, _) => dt.value)
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("24小时数据"),
      ),
      body: FutureBuilder(
        future: getGraphData(selected_factor),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return Container(
                alignment: Alignment.center,
                color: Colors.blueGrey,
                child: Text(
                  "网络受限或无连接，请重试...",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            case ConnectionState.active:
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
              return SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 12)),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                          flex: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                  child: DropdownButton(
                                onChanged: (value) {
                                  setState(() {
                                    selected_factor = value;
                                  });
                                  setState(() {
                                    pushList = [];
                                  });
                                  getGraphData(
                                      selected_factor); // 调用getGraphData函数，以更改柱状图的参数。
                                },
                                items: dropdownList,
                                hint: Text('请选择污染物因子'),
                                value: selected_factor,
                              )),
                              // Container(
                              //   child: DropdownButton(
                              //     onChanged: (value) {
                              //       setState(() {
                              //         selectedNumberOfItems = value;
                              //       });
                              //     },
                              //     items: showNumberOfItems,
                              //     hint: Text("请选择展示数目"),
                              //     value: selectedNumberOfItems,
                              //   ),
                              // )
                            ],
                          )),
                      Expanded(
                          flex: 92,
                          child: Container(
                              color: Colors.lightBlueAccent.withOpacity(0.1),
                              // child: new HorizontalBarLabelChart(
                              //   _createSampleData()
                              //   animate: true,
                              // ),
                              child: helo))
                    ],
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
