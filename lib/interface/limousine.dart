import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Limousine extends StatefulWidget {
  @override
  _LimousineState createState() => _LimousineState();
}

class _LimousineState extends State<Limousine> {
  final List<ChartData> chartData = [
            ChartData(2011, 38, 0.21),
            ChartData(2012, 34, 0.38),
            ChartData(2013, 52, 0.29),
            ChartData(2014, 40, 0.34)
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("折线图")),
      body: Column(
      children: <Widget>[
        Container(
          child: Text("散点图"),
        ),
        Container(
      color: Colors.white,
      child: SfCartesianChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <ChartSeries>[
          ScatterSeries<ChartData, double>(
            dataSource: chartData,
            xValueMapper: (ChartData sales, _) => sales.x,
            yValueMapper: (ChartData sales, _) => sales.y,
            markerSettings: MarkerSettings(
              height: 15,
              width: 15
            )
          )
        ],
      ),
    )
      ],
    ),
    );
  }
}

class ChartData {
  double x, y, z;

  ChartData(this.x, this.y, this.z);
}