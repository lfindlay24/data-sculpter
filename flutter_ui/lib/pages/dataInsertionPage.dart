import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/main.dart';
import 'package:http/http.dart' as http;

String basePath =
    'https://gaz1vaikk5.execute-api.us-east-2.amazonaws.com/Stage';

class DataInsertionPage extends StatefulWidget {
  @override
  _DataInsertionPageState createState() => _DataInsertionPageState();
}

class _DataInsertionPageState extends State<DataInsertionPage> {
  String? pageData;
  List<String>? columnNames;
  List<List<String>>? rowData;
  // Define your variables here

  @override
  Widget build(BuildContext context) {
    if (pageData != null) {
      columnNames = pageData!.split('\n')[0].split(',');
      rowData = pageData!
          .split('\n')
          .sublist(1)
          .map((e) => e.split(','))
          .where((element) => element[0].isNotEmpty)
          .toList();
      debugPrint(rowData.toString());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Insertion Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add your form fields here

                const SizedBox(height: 16.0),

                TextButton(
                  onPressed: () async {
                    String data = await parseCsvData();
                    debugPrint('data ${data}');
                    if (data != '') {
                      setState(() {
                        pageData = data;
                      });
                    }
                  },
                  child: const Text('Select A File'),
                ),
                if (pageData != null)
                  TextButton(
                    onPressed: () {
                      workingData = [];
                      for (int i = 0; i < rowData!.length; i++) {
                        Map<String, String> rowMap = {};
                        for (int j = 0; j < rowData![i].length; j++) {
                          rowMap[columnNames![j].trim()] = rowData![i][j];
                        }
                        workingData.add(rowMap);
                      }
                      debugPrint('workingData: $workingData');
                      if (email != '') {
                        _saveToCloud(workingData);
                      }
                    },
                    child: const Text('Save Data'),
                  ),
                if (pageData != null) ...[
                  DataTable(
                    columns: <DataColumn>[
                      for (int i = 0; i < columnNames!.length; i++)
                        DataColumn(
                          label: Text(
                            columnNames![i].capitalize(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                    rows: <DataRow>[
                      for (int i = 0; i < rowData!.length; i++)
                        DataRow(
                          cells: <DataCell>[
                            for (int j = 0; j < rowData![i].length; j++)
                              DataCell(Text(rowData![i][j])),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _saveToCloud(List<Map<String, dynamic>> workingData) async {
  http.post(
    Uri.parse('$basePath/data'),
    body: {
      'content': workingData.toString(),
      'email': email,
    },
  );
}

Future<String> getFilePath() async {
  FilePickerResult? result = await FilePicker.platform
      .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
  if (result != null && result.files.isNotEmpty) {
    debugPrint('File path: ${result.files.first.path!}');
    debugPrint('File bytes: ${result.files.first.bytes}');
    return result.files.first.path!;
  }
  debugPrint('No file selected');
  return '';
}

Future<String> parseCsvData() async {
  String filePath = await getFilePath();
  File file = File(filePath);
  if (filePath != '') {
    return file.readAsString();
  }
  return '';
}

extension StringExtensions on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
