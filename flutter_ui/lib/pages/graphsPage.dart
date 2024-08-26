import 'package:flutter/material.dart';
import 'package:flutter_ui/main.dart';
import 'package:flutter_ui/pages/dataInsertionPage.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GraphsPage extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  GraphsPage({Key? key}) : super(key: key);

  @override
  GraphsPageState createState() => GraphsPageState();
}

class GraphsPageState extends State<GraphsPage> {
  String  xAxis = workingData.isNotEmpty ? workingData[0].keys.first : '';
  String  yAxis = workingData.isNotEmpty ? workingData[0].keys.last : '';
  String numberModifier = 'none';
  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', -28),
    _SalesData('Mar', 34),
    _SalesData('Apr', -2),
    _SalesData('May', 40)
  ];
  List<_CloudData> userData = [];

  List<int> winData = [1, -1, 1, -1, 1];

  String _chartType = 'line';

  @override
  Widget build(BuildContext context) {

    if (workingData.isEmpty) {
      workingData = [];
    }
    if (email != '' && userData.isEmpty) {
      getUserCloudData();
    }
    debugPrint('Working Data: $workingData');
    // debugPrint('Keys: ${workingData[0].keys}');
    // debugPrint('first object: ${workingData[0]}');
    debugPrint('Number Modifier: $numberModifier');
    debugPrint('User Data: $userData');
    return Scaffold(
      appBar: graphBar(),
      body: mainGraphContent(context),
    );
  }

  Column mainGraphContent(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (email != '' && userData.isNotEmpty)
                    DropdownMenu<List<Map<String, dynamic>>>(
                      label: const Text('Select Available Data'),
                      onSelected: (List<Map<String, dynamic>>? value) {
                        if (value != null) {
                          debugPrint('Data: $value');
                          setState(() {
                            workingData =
                                List<Map<String, dynamic>>.from(value);
                          });
                        }
                      },
                      dropdownMenuEntries: [
                        for (var columns in userData)
                          DropdownMenuEntry<List<Map<String, dynamic>>>(
                            value: columns.jsonData,
                            label: columns.title,
                          )
                      ],
                    ),
                  if (_chartType == 'line')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfCartesianChart(
                        trackballBehavior: TrackballBehavior(
                            enable: false,
                            activationMode: ActivationMode.singleTap),
                        primaryXAxis: CategoryAxis(),
                        title: const ChartTitle(
                            text: 'Half yearly sales analysis'),
                        series: <CartesianSeries<Map<String, dynamic>, String>>[
                          LineSeries<Map<String, dynamic>, String>(
                              dataSource: () {
                                switch (numberModifier) {
                                  case 'sum':
                                    getSumByXAxis();
                                    // return data;
                                    return workingData;
                                  default:
                                    return workingData;
                                }
                              }(),
                              xValueMapper:
                                  (Map<String, dynamic> workingData, _) {
                                return workingData[xAxis];
                              },
                              yValueMapper:
                                  (Map<String, dynamic> workingData, _) {
                                switch (numberModifier) {
                                  default:
                                    return num.tryParse(workingData[yAxis]);
                                }
                              },
                              name: 'Sales',
                              // Enable data label
                              dataLabelSettings:
                                  const DataLabelSettings(isVisible: true))
                        ],
                      ),
                    )
                  else if (_chartType == 'pie')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfCircularChart(
                        title: const ChartTitle(text: 'Sales distribution'),
                        series: <CircularSeries>[
                          PieSeries<Map<String, dynamic>, String>(
                            explode: true,
                            dataSource: workingData,
                            xValueMapper:
                                (Map<String, dynamic> workingData, _) =>
                                    workingData[xAxis],
                            yValueMapper:
                                (Map<String, dynamic> workingData, _) =>
                                    num.tryParse(workingData[yAxis]),
                            dataLabelMapper: (Map<String, dynamic> workingData,
                                    _) =>
                                '${workingData[xAxis]}, ${workingData[yAxis].toString()}',
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
                          series: PyramidSeries<Map<String, dynamic>, String>(
                            dataSource: workingData,
                            xValueMapper:
                                (Map<String, dynamic> workingData, _) =>
                                    workingData[xAxis],
                            yValueMapper:
                                (Map<String, dynamic> workingData, _) =>
                                    num.tryParse(workingData[yAxis]),
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          )),
                    ),
                  if (_chartType == 'funnel')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfFunnelChart(
                          title: const ChartTitle(text: 'Sales distribution'),
                          series: FunnelSeries<Map<String, dynamic>, String>(
                            dataSource: workingData,
                            xValueMapper:
                                (Map<String, dynamic> workingData, _) =>
                                    workingData[xAxis],
                            yValueMapper:
                                (Map<String, dynamic> workingData, _) =>
                                    num.tryParse(workingData[yAxis]),
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          )),
                    ),
                  if (_chartType == 'spark')
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.8,
                      child: SfSparkLineChart(
                          data: workingData
                              .map((e) => num.parse(e[yAxis]))
                              .toList(),
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
                          data: workingData
                              .map((e) => num.parse(e[yAxis]))
                              .toList(),
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
                          data: workingData
                              .map((e) => num.parse(e[yAxis]))
                              .toList(),
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
                        data: workingData
                            .map((e) => num.parse(e[yAxis]))
                            .toList(),
                      ),
                    ),
                  DropdownMenu<String>(
                    label: const Text('Select X Axis'),
                    onSelected: (String? value) {
                      setState(() {
                        xAxis = value!;
                      });
                    },
                    dropdownMenuEntries: [
                      for (var key in workingData[0].keys)
                        // if (num.tryParse(workingData[0][key]) == null)
                          DropdownMenuEntry<String>(
                            value: key,
                            label: key.capitalize(),
                          )
                    ],
                  ),
                  DropdownMenu<String>(
                    label: const Text('Select Y Axis'),
                    onSelected: (String? value) {
                      setState(() {
                        yAxis = value!;
                      });
                    },
                    dropdownMenuEntries: [
                      for (var key in workingData[0].keys)
                        if (num.tryParse(workingData[0][key]) != null)
                          DropdownMenuEntry<String>(
                            value: key,
                            label: key.capitalize(),
                          )
                    ],
                  ),
                  DropdownMenu<String>(
                    label: const Text('Select Number Modifier'),
                    onSelected: (String? value) {
                      setState(() {
                        numberModifier = value!;
                        debugPrint('Number Modifier: $numberModifier');
                      });
                    },
                    dropdownMenuEntries: const [
                      DropdownMenuEntry<String>(
                        value: 'none',
                        label: 'None',
                      ),
                      DropdownMenuEntry(
                        value: 'sum',
                        label: 'Sum',
                      ),
                      DropdownMenuEntry(
                        value: 'average',
                        label: 'Average',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  AppBar graphBar() {
    return AppBar(
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
    );
  }

  /*
  Needs to return in the same format as the original data which is a list of a map
  Loop through the working data and sum the values of the yAxis for each unique value of the xAxis
  */
  List<Map<String, dynamic>> getSumByXAxis() {
    List<Map<String, dynamic>> sumByCategory = [];

    for (var item in workingData) {
      if (sumByCategory.isEmpty) {
        sumByCategory.add(item);
      } else {
        for (var sumItem in sumByCategory) {
          if (sumItem[xAxis] == item[xAxis]) {
            sumItem[yAxis] =
                (num.parse(item[yAxis]) + num.parse(sumItem[yAxis])).toString();
          } else {
            //sumByCategory.add(item);
          }
        }
      }
    }
    debugPrint('Sum by Category: $sumByCategory');
    return sumByCategory;
  }

  void getUserCloudData() async {
    List<_CloudData> cloudData = [];
    var headers = {
      'Content-Type': 'application/json',
      'email': email,
    };

    var response =
        await http.get(Uri.parse('$basePath/data'), headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> body = Map.castFrom(json.decode(response.body));
      for (var data in body['Items']) {
        debugPrint('Data: ${data['content']['data']}');
        List<Map<String, dynamic>> jsonData = [];
        for (var item in data['content']['data']) {
          jsonData.add(Map.castFrom(item));
        }
        debugPrint('Json Data: $jsonData');
        cloudData.add(_CloudData(data['content']['title'], jsonData));
      }
      debugPrint('Cloud Data: $cloudData');
      setState(() {
        userData = cloudData;
      });
    } else {
      debugPrint('Error: ${response.body}');
    }
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}

class _CloudData {
  _CloudData(this.title, this.jsonData);

  final String title;
  final List<Map<String, dynamic>> jsonData;
}
