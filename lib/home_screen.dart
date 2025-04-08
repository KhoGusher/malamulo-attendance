import 'package:flutter/material.dart';
import 'qr_scanner.dart';
import 'excel_exporter.dart';
import 'db_helper.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE d MMMM').format(DateTime.now());
    String formattedTime = DateFormat('HH:mm').format(DateTime.now());

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/Dashboard.jpg',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 50,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      formattedTime,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () async {
                          bool confirmed = await _showConfirmationDialog(context);
                          if (confirmed) {
                            await DBHelper().deleteAllRows();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('All data deleted successfully.')),
                            );
                          }
                        },
                        child: Image.asset(
                          'assets/delete_data.png', // Replace with your image path
                          fit: BoxFit.cover, // Adjust as needed
                        ),
                      ),
                      const SizedBox(height: 80),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QRScanner()),
                          );
                        },
                          child: Image.asset(
                            'assets/start_scan.png', // Replace with your image path
                            fit: BoxFit.cover, // Adjust as needed
                          ),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ExcelExporter()),
                          );
                        },
                        child: Image.asset(
                          'assets/export_data.png', // Replace with your image path
                          fit: BoxFit.cover, // Adjust as needed
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Fresh Start By Emptying Data'),
          content: const Text('Are you sure you want to delete all data? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    ) ?? false;
  }
}
