import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                      debugPrint('email: $email');
                      if (email != '') {
                        _dialogBuilder(context);
                        debugPrint('Saving to cloud');
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

Future<void> _dialogBuilder(BuildContext context) {
  final titleController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Please enter a title before saving to the cloud'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Title',
          ),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Submit'),
            onPressed: () {
              _saveToCloud(workingData, titleController.text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _saveToCloud(List<Map<String, dynamic>> workingData, String title) async {
  var body = {
    "content": {"data": workingData, "title": title},
    "email": email,
  };
  var response = await http.post(
    Uri.parse('$basePath/data'),
    body: json.encode(body),
  );
  debugPrint('Status: $response.statusCode');
  debugPrint('Response: ${response.body}');
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
