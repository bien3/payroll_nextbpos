import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegularOT extends StatefulWidget {
  const RegularOT({Key? key}) : super(key: key);

  @override
  State<RegularOT> createState() => _RegularOTState();
}

class _RegularOTState extends State<RegularOT> {
  late List<String> _selectedOvertimeTypes;

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regular Overtime'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Overtime').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available yet'));
          } else {
            List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Time In')),
                  DataColumn(label: Text('Time Out')),
                  DataColumn(label: Text('Overtime Hours')),
                  DataColumn(label: Text('Overtime Minute')),
                  DataColumn(label: Text('Overtime Pay')),
                  DataColumn(label: Text('Overtime Type')),
                ],
                rows: List.generate(overtimeDocs.length, (index) {
                  DocumentSnapshot overtimeDoc = overtimeDocs[index];
                  Map<String, dynamic> overtimeData =
                      overtimeDoc.data() as Map<String, dynamic>;
                  _selectedOvertimeTypes.add('Regular');
                  return DataRow(cells: [
                    DataCell(Text(overtimeDoc.id)),
                    DataCell(
                      Text(overtimeData['userName'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['department'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text((_formatTimestamp(overtimeData['timeIn']))),
                    ),
                    DataCell(
                      Text((_formatTimestamp(overtimeData['timeOut']))),
                    ),
                    DataCell(
                      Text(overtimeData['hours_overtime']?.toString() ??
                          'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['minute_overtime']?.toString() ??
                          'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['overtimePay']?.toString() ??
                          'Not Available Yet'),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: _selectedOvertimeTypes[index],
                        items: <String>[
                          'Regular',
                          'Special Holiday OT',
                          'Regular Holiday OT',
                          'Rest day OT'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          if (newValue == 'Special Holiday OT') {
                            await moveRecordToSpecialHolidayOT(overtimeDoc);
                            await deleteRecordFromOvertime(overtimeDoc);
                          }
                          setState(() {
                            _selectedOvertimeTypes[index] = newValue!;
                          });
                          if (newValue == 'Regular Holiday OT') {
                            await moveRecordToRegularHolidayOT(overtimeDoc);
                            await deleteRecordFromOvertime(overtimeDoc);
                          }
                          setState(() {
                            _selectedOvertimeTypes[index] = newValue!;
                          });
                          if (newValue == 'Rest day OT') {
                            await moveRecordToRestdayOT(overtimeDoc);
                            await deleteRecordFromOvertime(overtimeDoc);
                          }
                          setState(() {
                            _selectedOvertimeTypes[index] = newValue!;
                          });
                        },
                      ),
                    ),
                  ]);
                }),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> moveRecordToSpecialHolidayOT(
      DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.95;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> moveRecordToRegularHolidayOT(
      DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 2.6;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> moveRecordToRestdayOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.69;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('RestdayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> deleteRecordFromOvertime(DocumentSnapshot overtimeDoc) async {
    try {
      await overtimeDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }
}
