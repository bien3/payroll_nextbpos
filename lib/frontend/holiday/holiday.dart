import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class HolidayPage extends StatefulWidget {
  const HolidayPage({Key? key}) : super(key: key);

  @override
  State<HolidayPage> createState() => _HolidayPageState();
}

class _HolidayPageState extends State<HolidayPage> {
  late List<String> _selectedOvertimeTypes;
  TextEditingController _searchController = TextEditingController();
  int _itemsPerPage = 5;
  int _currentPage = 0;
  int indexRow = 0;
  bool _sortAscending = false;

  bool sortPay = false;
  bool table = false;

  String selectedDepartment = 'All';
  DateTime? fromDate;
  DateTime? toDate;
  bool endPicked = false;
  bool startPicked = false;

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
  }

  @override
  Widget build(BuildContext context) {
    var styleFrom = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return Scaffold(
        body: Center(
      child: Container(
        color: Colors.teal.shade700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Holiday Overtime",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        dateFilterSearchRow(context, styleFrom),
                        Divider(),
                        _buildTable(),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 5),
                        pagination(),
                        SizedBox(height: 20),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Container dateFilterSearchRow(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: MediaQuery.of(context).size.width > 600
                        ? Row(
                            children: [
                              Text('Show entries: '),
                              Container(
                                width: 70,
                                height: 30,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade200)),
                                child: DropdownButton<int>(
                                  padding: EdgeInsets.all(5),
                                  underline: SizedBox(),
                                  value: _itemsPerPage,
                                  items: [5, 10, 15, 20, 25]
                                      .map<DropdownMenuItem<int>>(
                                    (int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text('$value'),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      _itemsPerPage = newValue!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          )
                        : DropdownButton<int>(
                            padding: EdgeInsets.all(5),
                            underline: SizedBox(),
                            value: _itemsPerPage,
                            items:
                                [5, 10, 15, 20, 25].map<DropdownMenuItem<int>>(
                              (int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                );
                              },
                            ).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _itemsPerPage = newValue!;
                              });
                            },
                          ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 400
                                : 100,
                            height: 30,
                            margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              textAlign: TextAlign.start,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 15),
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                hintText: 'Search',
                              ),
                              onChanged: (value) {
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 230
                                : 80,
                            padding: EdgeInsets.all(2),
                            child: ElevatedButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != fromDate) {
                                  setState(() {
                                    fromDate = picked;
                                    startPicked = true;
                                  });
                                }
                              },
                              style: styleFrom,
                              child: MediaQuery.of(context).size.width > 800
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            children: [
                                              Text(
                                                'From: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1100
                                                  ? Text(
                                                      fromDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(fromDate!)
                                                          : 'Select',
                                                      style: TextStyle(
                                                        color:
                                                            startPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    )
                                                  : Text(
                                                      fromDate != null
                                                          ? DateFormat('MM-dd')
                                                              .format(fromDate!)
                                                          : '',
                                                      style: TextStyle(
                                                        color:
                                                            startPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.calendar_month,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 150
                                : 50,
                            padding: EdgeInsets.all(2),
                            child: ElevatedButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: toDate ?? DateTime.now(),
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != toDate) {
                                  setState(() {
                                    toDate = picked;
                                    endPicked = true;
                                  });
                                }
                              },
                              style: styleFrom,
                              child: MediaQuery.of(context).size.width > 800
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            children: [
                                              Text(
                                                'To: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1100
                                                  ? Text(
                                                      toDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(toDate!)
                                                          : 'Select',
                                                      style: TextStyle(
                                                        color:
                                                            endPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    )
                                                  : Text(
                                                      toDate != null
                                                          ? DateFormat('MM-dd')
                                                              .format(toDate!)
                                                          : '',
                                                      style: TextStyle(
                                                        color:
                                                            endPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 3),
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.calendar_month,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
        ],
      ),
    );
  }

  Row pagination() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Previous'),
      ),
      SizedBox(width: 10),
      Container(
          height: 35,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200)),
          child: Text('$_currentPage')),
      SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Next'),
      ),
    ]);
  }

  Widget _buildTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Holiday').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return _buildShimmerLoading();
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;

          _sortAscending
              ? overtimeDocs.sort((a, b) {
                  double overtimePayA = a['holidayPay'] ?? 0.0;
                  double overtimePayB = b['holidayPay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                })
              : overtimeDocs.sort((b, a) {
                  double overtimePayA = a['holidayPay'] ?? 0.0;
                  double overtimePayB = b['holidayPay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                });

          overtimeDocs = overtimeDocs.where((doc) {
            DateTime timeIn = doc['timeIn'].toDate();
            DateTime timeOut = doc['timeOut'].toDate();
            if (fromDate != null && toDate != null) {
              return timeIn.isAfter(fromDate!) &&
                  timeOut.isBefore(toDate!.add(Duration(
                      days: 1))); // Adjusted toDate to include end of the day
            } else if (fromDate != null) {
              return timeIn.isAfter(fromDate!);
            } else if (toDate != null) {
              return timeOut.isBefore(toDate!.add(Duration(
                  days: 1))); // Adjusted toDate to include end of the day
            }
            return true;
          }).toList();

          List<DocumentSnapshot> filteredDocuments = overtimeDocs;
          if (selectedDepartment != 'All') {
            filteredDocuments = overtimeDocs
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
          }

          // Grouping by employee ID and calculating total hours and total holiday pay
          Map<String, Map<String, dynamic>> groupedData = {};
          for (var doc in filteredDocuments) {
            String id = doc['employeeId'];
            double holidayPay = doc['holidayPay'] ?? 0.0;
            int regularHours = doc['regular_hours'] ?? 0;
            int regularMinutes = doc['regular_minute'] ?? 0;
            double hours = regularHours + (regularMinutes / 60.0);
            DateTime date = doc['timeIn'].toDate();
            String formattedDate = DateFormat('MMMM dd').format(date);

            if (!groupedData.containsKey(id)) {
              groupedData[id] = {
                'totalHours': hours,
                'totalHolidayPay': holidayPay,
                'startDate': formattedDate,
                'endDate': formattedDate,
              };
            } else {
              groupedData[id]!['totalHours'] += hours;
              groupedData[id]!['totalHolidayPay'] += holidayPay;
              groupedData[id]!['endDate'] = formattedDate;
            }

            double totalHolidayPay = filteredDocuments.fold(
                0, (sum, doc) => sum + (doc['holidayPay'] ?? 0.0));
            double totalHours = filteredDocuments.fold(
                0,
                (sum, doc) =>
                    sum +
                    (doc['regular_hours'] + (doc['regular_minute'] / 60.0) ??
                        0.0));
          }

          // Formatting the accumulated dates
          groupedData.forEach((id, data) {
            String startDate = data['startDate'];
            String endDate = data['endDate'];
            if (startDate != endDate) {
              data['accumulatedDates'] = '$startDate - $endDate';
            } else {
              data['accumulatedDates'] = startDate;
            }
          });
          // // Sort documents by timestamp in descending order
          // overtimeDocs.sort((a, b) {
          //   Timestamp aTimestamp = a['timeIn'];
          //   Timestamp bTimestamp = b['timeIn'];
          //   return bTimestamp.compareTo(aTimestamp);
          // });
          // // Sort the documents by timestamp in descending order
          // overtimeDocs.sort((a, b) =>
          //     (b['timeIn'] as Timestamp).compareTo(a['timeIn'] as Timestamp));

          const textStyle = TextStyle(fontWeight: FontWeight.bold);
          var dataTable = DataTable(
            columns: [
              const DataColumn(label: Text('#', style: textStyle)),
              const DataColumn(
                  label:
                      Flexible(child: Text('Employee ID', style: textStyle))),
              const DataColumn(label: Text('Name', style: textStyle)),
              DataColumn(
                label: PopupMenuButton<String>(
                  child: const Row(
                    children: [
                      Text(
                        'Department',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                  onSelected: (String value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    'All', // Default option
                    'IT',
                    'HR',
                    'ACCOUNTING',
                    'SERVICING',
                  ].map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const DataColumn(label: Text('Date', style: textStyle)),
              const DataColumn(label: Text('Total Hours', style: textStyle)),
              DataColumn(
                label: Container(
                  width: 100,
                  padding: EdgeInsets.all(0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                    child: Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Holiday Pay',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                              width:
                                  4), // Add some space between the text and the icon
                          Flexible(
                            child: Icon(
                              _sortAscending
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const DataColumn(label: Text('Holiday Type', style: textStyle)),
              const DataColumn(label: Text('Action', style: textStyle)),
            ],
            rows: List.generate(groupedData.length, (index) {
              DocumentSnapshot overtimeDoc = filteredDocuments[index];
              Map<String, dynamic> overtimeData =
                  overtimeDoc.data() as Map<String, dynamic>;
              _selectedOvertimeTypes.add('Regular Holiday');
              Color? rowColor = indexRow % 2 == 0
                  ? Colors.white
                  : Colors.grey[200]; // Alternating row colors
              indexRow++; //

              return DataRow(
                  color: MaterialStateColor.resolveWith((states) => rowColor!),
                  cells: [
                    DataCell(Text((index + 1).toString())),
                    DataCell(
                      Text(overtimeData['employeeId'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                        Text(overtimeData['userName'] ?? 'Not Available Yet')),
                    DataCell(Text(
                        overtimeData['department'] ?? 'Not Available Yet')),
                    DataCell(Text(groupedData[overtimeData['employeeId']]![
                        'accumulatedDates'])),
                    DataCell(
                      Container(
                        width: 100,
                        decoration: BoxDecoration(color: Colors.amber.shade200),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  Text(
                                    (groupedData[overtimeData['employeeId']]![
                                                'totalHours'] ??
                                            0.0)
                                        .toStringAsFixed(2),
                                    style: textStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(NumberFormat.currency(
                              locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                          .format(groupedData[overtimeData['employeeId']]![
                                  'totalHolidayPay'] ??
                              0.0)),
                    ),
                    DataCell(
                      IntrinsicWidth(
                        child: DropdownButton<String>(
                          value: _selectedOvertimeTypes[index],
                          items: <String>[
                            'Regular Holiday',
                            'Special Holiday',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(fontSize: 15),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            if (newValue == 'Special Holiday') {
                              await _showConfirmationDialog(overtimeDoc);
                            }
                            setState(() {
                              _selectedOvertimeTypes[index] = newValue!;
                            });
                            if (newValue == 'Regular Holiday') {
                              await _showConfirmationDialog2(overtimeDoc);
                            }
                            setState(() {
                              _selectedOvertimeTypes[index] = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 100,
                        padding: EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _showConfirmationDialog4(overtimeDoc);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.visibility,
                                color: Colors.blue,
                                size: 15,
                              ),
                              Text(
                                'View Logs',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]);
            }),
          );
          return MediaQuery.of(context).size.width > 1500
              ? SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    child: Flexible(
                      child: dataTable,
                    ),
                  ),
                )
              : SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Flexible(
                        child: dataTable,
                      ),
                    ),
                  ),
                );
        }
      },
    );
  }

  Future<void> moveRecordToSpecialHoliday(DocumentSnapshot overtimeDoc) async {
    try {
      if (overtimeDoc.exists) {
        Map<String, dynamic> overtimeData = Map<String, dynamic>.from(
            overtimeDoc.data() as Map<String, dynamic>);

        // Check if all required fields are present
        if (overtimeData.containsKey('monthly_salary') &&
            overtimeData.containsKey('regular_minute')) {
          final monthlySalary = overtimeData['monthly_salary'];
          final overtimeMinute = overtimeData['regular_minute'];
          final overtimeRate = 1.0;
          final daysInMonth = 22;

          // Set holidayPay
          overtimeData['holidayPay'] =
              (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);

          // Add to SpecialHoliday collection
          await FirebaseFirestore.instance
              .collection('SpecialHoliday')
              .add(overtimeData);
        } else {
          print('Required fields are missing in the Firestore document');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error moving record to SpecialHoliday collection: $e');
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
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  Future<void> _showConfirmationDialog(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await moveRecordToSpecialHoliday(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateHolidayPay(DocumentSnapshot overtimeDoc) async {
    try {
      if (overtimeDoc.exists) {
        Map<String, dynamic> overtimeData = Map<String, dynamic>.from(
            overtimeDoc.data() as Map<String, dynamic>);

        // Check if all required fields are present
        if (overtimeData.containsKey('monthly_salary') &&
            overtimeData.containsKey('regular_minute')) {
          final monthlySalary = overtimeData['monthly_salary'];
          final overtimeMinute = overtimeData['regular_minute'];
          final overtimeRate = 0.3;
          final daysInMonth = 22;

          // Update holidayPay
          double holidayPay =
              (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
          await overtimeDoc.reference.update({'holidayPay': holidayPay});
        } else {
          print('Required fields are missing in the Firestore document');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error updating holidayPay: $e');
    }
  }

  Future<void> _showConfirmationDialog2(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await updateHolidayPay(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog3(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog4(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('Holiday')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Regular Holiday Logs'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Employee ID',
                    overtimeDoc['employeeId'] ?? 'Not Available Yet'),
                _buildInfoRow(
                    'Name', overtimeDoc['userName'] ?? 'Not Available'),
                _buildInfoRow(
                    'Department', overtimeDoc['department'] ?? 'Not Available'),
                SizedBox(height: 10),
                Container(
                    height: 300,
                    child: SingleChildScrollView(
                        child: _buildOvertimeTable(userOvertimeDocs))),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOvertimeTable(List<DocumentSnapshot> overtimeDocs) {
    // Sort documents by timestamp in descending order
    overtimeDocs.sort((a, b) {
      Timestamp aTimestamp = a['timeIn'];
      Timestamp bTimestamp = b['timeIn'];
      return bTimestamp.compareTo(aTimestamp);
    });
    int index = 0;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Time In',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Total Hours (h:m)',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text('Pay', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
        rows: overtimeDocs.map((overtimeDoc) {
          Color? rowColor = index % 2 == 0
              ? Colors.grey[200]
              : Colors.transparent; // Alternating row colors
          index++;
          return DataRow(
              color: MaterialStateColor.resolveWith((states) => rowColor!),
              cells: [
                DataCell(Text((index).toString())),
                DataCell(Text(_formatDate(overtimeDoc['timeIn']))),
                DataCell(Text(_formatTime(overtimeDoc['timeIn']))),
                DataCell(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                              overtimeDoc['regular_hours']?.toString() ??
                                  'Not Available Yet',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(':'),
                          Text(
                              overtimeDoc['regular_minute']?.toString() ??
                                  'Not Available Yet',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                )),
                DataCell(
                  Text(NumberFormat.currency(
                          locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                      .format(overtimeDoc['holidayPay'] ?? 0.0)),
                ),
              ]);
        }).toList(),
      ),
    );
  }

  String _formatTimestamp2(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM d, yyyy').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  Future<void> _selectDate2(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label + ':', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}

Widget _buildShimmerLoading() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ShimmerPackage.Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Employee ID',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Department',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Total Hours (h:m)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Overtime Pay',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Overtime Type',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Added column for Status
        ],
        rows: List.generate(
          10, // You can change this to the number of shimmer rows you want
          (index) => DataRow(cells: [
            DataCell(Container(width: 40, height: 16, color: Colors.white)),
            DataCell(Container(width: 60, height: 16, color: Colors.white)),
            DataCell(Container(width: 120, height: 16, color: Colors.white)),
            DataCell(Container(width: 80, height: 16, color: Colors.white)),
            DataCell(Container(width: 80, height: 16, color: Colors.white)),
            DataCell(Container(width: 100, height: 16, color: Colors.white)),
            DataCell(Container(width: 60, height: 16, color: Colors.white)),
            DataCell(Container(width: 60, height: 16, color: Colors.white)),
          ]),
        ),
      ),
    ),
  );
}
