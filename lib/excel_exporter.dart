import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_excel/excel.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'db_helper.dart';

class ExcelExporter extends StatefulWidget {
  @override
  _ExcelExporterState createState() => _ExcelExporterState();
}

class _ExcelExporterState extends State<ExcelExporter> {
  List<Map<String, dynamic>> attendees = [];

  @override
  void initState() {
    super.initState();
    _fetchAttendees();
  }

  Future<void> _fetchAttendees() async {
    attendees = await DBHelper().getAttendees();
    setState(() {}); // Refresh the UI with the fetched data
  }

  Future<void> generateCSV() async {
    StringBuffer csvData = StringBuffer();

    // Date format for DD-MM-YYYY
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

    for (var attendee in attendees) {
      String formattedDate = dateFormat.format(DateTime.parse(attendee['date']));
      csvData.write('$formattedDate,${attendee['time']},${attendee['name']}\n');
    }

    // Get the current date and time
    String formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/attendees_$formattedDateTime.csv';

    // Save the file
    File file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsStringSync(csvData.toString());

    // Share the file using XFile
    final xFile = XFile(filePath);
    await Share.shareXFiles([xFile], text: 'Here is the attendees list.');
  }

  // Future<void> generateExcel() async {
  //   var excel = Excel.createExcel();
  //   Sheet sheet = excel['Sheet1'];
  //
  //   sheet.appendRow(['Row ID', 'Student ID', 'Date', 'Time']);
  //   for (var attendee in attendees) {
  //     sheet.appendRow([attendee['id'], attendee['name'], attendee['date'], attendee['time']]);
  //   }
  //
  //   var bytes = excel.save();
  //
  //   // Get the current date and time
  //   String formattedDateTime = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  //
  //   Directory directory = await getApplicationDocumentsDirectory();
  //   String filePath = '${directory.path}/attendees_$formattedDateTime.xlsx';
  //
  //   // Save the file
  //   File file = File(filePath)
  //     ..createSync(recursive: true)
  //     ..writeAsBytesSync(bytes!);
  //
  //   // Share the file using XFile
  //   final xFile = XFile(filePath);
  //   await Share.shareXFiles([xFile], text: 'Here is the attendees list.');
  //
  //   // After successfully sharing, empty the table if needed
  //   // await DBHelper().deleteAllAttendees(); // Optional: Clear the table after export
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Export to Excel')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: attendees.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        attendees[index]['id'].toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      attendees[index]['name'],
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    subtitle: Text(
                      '${attendees[index]['date']} - ${attendees[index]['time']}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    trailing: const Icon(Icons.check_circle, color: Colors.green),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: generateCSV,
              child: const Text('Generate CSV'),
            ),
          ),
        ],
      ),
    );
  }
}
