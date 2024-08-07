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
    _SalesData('Feb', -28),
    _SalesData('Mar', 34),
    _SalesData('Apr', -2),
    _SalesData('May', 40)
  ];

  List<int> winData = [1, -1, 1, -1, 1];

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
            IconButton(
              icon: const Icon(Icons.filter_alt),
              color: _chartType != 'funnel' ? Colors.grey : Colors.green,
              onPressed: () {
                setState(() {
                  _chartType = 'funnel';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.star_border),
              color: _chartType != 'spark' ? Colors.grey : Colors.green,
              onPressed: () {
                setState(() {
                  _chartType = 'spark';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.star),
              color: _chartType != 'sparkArea' ? Colors.grey : Colors.green,
              onPressed: () {
                setState(() {
                  _chartType = 'sparkArea';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              color: _chartType != 'sparkBar' ? Colors.grey : Colors.green,
              onPressed: () {
                setState(() {
                  _chartType = 'sparkBar';
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.sports_score),
              color: _chartType != 'sparkWin' ? Colors.grey : Colors.green,
              onPressed: () {
                setState(() {
                  _chartType = 'sparkWin';
                });
              },
            ),
          ],
        ),
        body: Column(children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_chartType == 'line')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        title:
                            const ChartTitle(text: 'Half yearly sales analysis'),
                        series: <CartesianSeries<_SalesData, String>>[
                          LineSeries<_SalesData, String>(
                              dataSource: data,
                              xValueMapper: (_SalesData sales, _) => sales.year,
                              yValueMapper: (_SalesData sales, _) => sales.sales,
                              name: 'Sales',
                              // Enable data label
                              dataLabelSettings:
                                  DataLabelSettings(isVisible: true))
                        ],
                      ),
                    )
                  else if (_chartType == 'pie')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfCircularChart(
                        title: const ChartTitle(text: 'Sales distribution'),
                        series: <CircularSeries>[
                          PieSeries<_SalesData, String>(
                            explode: true,
                            dataSource: data,
                            xValueMapper: (_SalesData sales, _) => sales.year,
                            yValueMapper: (_SalesData sales, _) => sales.sales,
                            dataLabelMapper: (_SalesData sales, _) =>
                                sales.sales.toString(),
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          )
                        ],
                      ),
                    ),
                  if (_chartType == 'pyramid')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfPyramidChart(
                          title: const ChartTitle(text: 'Sales distribution'),
                          series: PyramidSeries<_SalesData, String>(
                            dataSource: data,
                            xValueMapper: (_SalesData sales, _) => sales.year,
                            yValueMapper: (_SalesData sales, _) => sales.sales,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          )),
                    ),
                  if (_chartType == 'funnel')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfFunnelChart(
                          title: const ChartTitle(text: 'Sales distribution'),
                          series: FunnelSeries<_SalesData, String>(
                            dataSource: data,
                            xValueMapper: (_SalesData sales, _) => sales.year,
                            yValueMapper: (_SalesData sales, _) => sales.sales,
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          )),
                    ),
                  if (_chartType == 'spark')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfSparkLineChart(
                          data: data.map((e) => e.sales).toList(),
                          plotBand: const SparkChartPlotBand(
                              start: 0,
                              end: 2,
                              color: Colors.red,
                              borderWidth: 2,
                              borderColor: Colors.red)),
                    ),
                  if (_chartType == 'sparkArea')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfSparkAreaChart(
                          data: data.map((e) => e.sales).toList(),
                          plotBand: const SparkChartPlotBand(
                              start: 0,
                              end: 2,
                              color: Colors.red,
                              borderWidth: 2,
                              borderColor: Colors.red)),
                    ),
                  if (_chartType == 'sparkBar')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfSparkBarChart(
                          data: data.map((e) => e.sales).toList(),
                          plotBand: const SparkChartPlotBand(
                              start: 0,
                              end: 2,
                              color: Colors.red,
                              borderWidth: 2,
                              borderColor: Colors.red)),
                    ),
                  if (_chartType == 'sparkWin')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfSparkWinLossChart(
                        data: data.map((e) => e.sales).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],),);
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
