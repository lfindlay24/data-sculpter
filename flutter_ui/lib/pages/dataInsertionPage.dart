import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DataInsertionPage extends StatefulWidget {
  @override
  _DataInsertionPageState createState() => _DataInsertionPageState();
}

class _DataInsertionPageState extends State<DataInsertionPage> {
  String? pageData;
  // Define your variables here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Insertion Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add your form fields here

            const SizedBox(height: 16.0),

            TextButton(
              onPressed: () async {
                String data = await parseCsvData();
                debugPrint('data ${data}');
                setState(() {
                  pageData = data;
                });
              },
              child: const Text('Select A File'),
            ),
            if (pageData != null) Text(pageData!),
          ],
        ),
      ),
    );
  }
}

Future<String> getFilePath() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
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