import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class GraphsPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  GraphsPage({Key? key}) : super(key: key);

  @override
  GraphsPageState createState() => GraphsPageState();
}

class GraphsPageState extends State<GraphsPage> {
  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 2),
    _SalesData('May', 40)
  ];

  String _chartType = 'line';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Analysis Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            color: _chartType != 'pie' ? Colors.grey : Colors.green,
            onPressed: () {
              setState(() {
                _chartType = 'pie';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.show_chart),
            color: _chartType != 'line' ? Colors.grey : Colors.green,
            onPressed: () {
              setState(() {
                _chartType = 'line';
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.details),
            color: _chartType != 'pyramid' ? Colors.grey : Colors.green,
            onPressed: () {
              setState(() {
                _chartType = 'pyramid';
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_chartType == 'line')
            SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              title: const ChartTitle(text: 'Half yearly sales analysis'),
              series: <CartesianSeries<_SalesData, String>>[
                  LineSeries<_SalesData, String>(
                      dataSource: data,
                      xValueMapper: (_SalesData sales, _) => sales.year,
                      yValueMapper: (_SalesData sales, _) => sales.sales,
                      name: 'Sales',
                      // Enable data label
                      dataLabelSettings: DataLabelSettings(isVisible: true))
                ],
            )
          else if (_chartType == 'pie')
            SfCircularChart(
              title: const ChartTitle(text: 'Sales distribution'),
              series: <CircularSeries>[
                PieSeries<_SalesData, String>(
                  explode: true,
                  dataSource: data,
                  xValueMapper: (_SalesData sales, _) => sales.year,
                  yValueMapper: (_SalesData sales, _) => sales.sales,
                  dataLabelMapper: (_SalesData sales, _) => sales.sales.toString(),
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
            ),
          if (_chartType == 'pyramid')
            SfPyramidChart(
              title: const ChartTitle(text: 'Sales distribution'),
              series: PyramidSeries<_SalesData, String>(
                dataSource: data,
                xValueMapper: (_SalesData sales, _) => sales.year,
                yValueMapper: (_SalesData sales, _) => sales.sales,
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              )
            ),
        ],
      ),
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}