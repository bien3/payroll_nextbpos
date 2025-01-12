import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:project_payroll_nextbpo/frontend/payslip/contribution.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:universal_html/html.dart' as html;

import 'package:project_payroll_nextbpo/frontend/modal.dart';

class PayslipData {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dateGenerated;

  PayslipData({
    required this.startDate,
    required this.endDate,
    required this.dateGenerated,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate':
          Timestamp.fromDate(startDate), // Convert DateTime to Timestamp
      'endDate': Timestamp.fromDate(endDate), // Convert DateTime to Timestamp
      'dateGenerated':
          Timestamp.fromDate(dateGenerated), // Convert DateTime to Timestamp
    };
  }
}

class PayslipPage extends StatefulWidget {
  const PayslipPage({Key? key}) : super(key: key);

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

TextEditingController _searchController = TextEditingController();

class _PayslipPageState extends State<PayslipPage> {
  bool viewTable = true;
  String selectedDepartment = 'All';
  DateTime? fromDate;
  DateTime? toDate;
  List<PayslipData> payrollData = [];
  double totalGrossPay = 0.0;
  double totalNetPay = 0.0;
  double totalDeductions = 0.0;
  final _firestore = FirebaseFirestore.instance;
  bool showButtons = true;

  late Stream<QuerySnapshot> _userRecordsStream;
  // Variable to store generated payroll data
  // Variable to store generated payroll data
  // Declare a variable to hold the future result of fetchTotal()
  late Future<void> _fetchTotalFuture;
  late Future<void> _fetchTotalFuture2;
  late Future<void> _fetchTotalFuture3;
  bool _isLoading = false;
  bool filter = false;
  DateTime? _startDate;
  DateTime? _endDate;

  bool endPicked = false;
  bool startPicked = false;

  @override
  void initState() {
    super.initState();
    // Call fetchTotal only once during initialization
    _fetchUserRecords();
    _fetchTotalFuture = fetchTotal();
    _fetchTotalFuture2 = fetchTotal();
    _fetchTotalFuture3 = fetchTotal();
  }

  void _fetchUserRecords() {
    _userRecordsStream =
        FirebaseFirestore.instance.collection('User').snapshots();
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
      body: Container(
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      viewTable
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        viewTable = true;
                                      });
                                    },
                                    child: Text(
                                      "Generate Payroll",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        showGeneratePayrollDialog(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 68, 166, 100),
                                        padding: const EdgeInsets.all(8.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: const Flexible(
                                        child: Text(
                                          "+ Add new",
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 130,
                                      height: 30,
                                      padding: EdgeInsets.all(0),
                                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                      decoration: BoxDecoration(
                                        color: Colors.teal,
                                        border: Border.all(
                                          color: Colors.teal.shade900
                                              .withOpacity(0.5),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          padding: EdgeInsets.only(left: 5),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            filter = !filter;
                                          });
                                          filtermodal(context, styleFrom);
                                        },
                                        child: MediaQuery.of(context)
                                                    .size
                                                    .width >
                                                800
                                            ? const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.filter_alt_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    'Filter Date',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      letterSpacing: 1,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : Icon(
                                                Icons.filter_alt_outlined,
                                                color: Colors.white,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        viewTable = true;
                                      });
                                    },
                                    child: Text(
                                      "Generate Payroll >",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      viewTable = false;
                                    });
                                  },
                                  child: const Text(
                                    "Payroll",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      viewTable ? timesheet(context) : _buildDataTable(),
                      const Divider(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox timesheet(BuildContext context) {
    return SizedBox(
      height: 600,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('PayslipDepartment')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final dataTable = DataTable(
            columns: const [
              DataColumn(
                label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Date Start',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Date End',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Date Generated',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Action',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: List<DataRow>.generate(documents.length, (index) {
              final doc = documents[index];
              Map<String, dynamic>? data =
                  doc.data() as Map<String, dynamic>?; // Make data nullable
              if (data == null) return DataRow(cells: []); // Skip null data

              DateFormat dateFormatter = DateFormat('MM/dd/yyyy');
              bool isDone = data['status'] == 'Done';
              String documentId = doc.id;
              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(dateFormatter.format(
                      data['startDate']?.toDate() ??
                          DateTime.now()))), // Provide default value if null
                  DataCell(Text(dateFormatter.format(
                      data['endDate']?.toDate() ??
                          DateTime.now()))), // Provide default value if null
                  DataCell(Text(dateFormatter.format(
                      data['dateGenerated']?.toDate() ??
                          DateTime.now()))), // Provide default value if null
                  DataCell(
                    isDone
                        ? Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  bool verificationSuccess =
                                      await commitPayslip(context);
                                  if (verificationSuccess) {
                                    setState(() {
                                      viewTable =
                                          false; // Set viewTable to true after verification
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Commit'),
                              ),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  bool? confirmed =
                                      await showMarkAsDoneConfirmation(context);
                                  if (confirmed ?? false) {
                                    setState(() {
                                      markAsDone(documentId);
                                      setState(() {
                                        showButtons = false;
                                      });
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Mark as Done'),
                              ),
                            ],
                          ),
                  ),
                ],
              );
            }).toList(),
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
        },
      ),
    );
  }

  Future<void> markAsDone(String documentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('PayslipDepartment')
          .doc(documentId)
          .update({'status': 'Done'});
    } catch (e) {
      print('Error updating document: $e');
    }
  }

  Future<dynamic> filtermodal(BuildContext context, ButtonStyle styleFrom) {
    return showDialog(
        context: context,
        builder: (_) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 130,
                    ),
                    AlertDialog(
                      surfaceTintColor: Colors.white,
                      content: Container(
                        height: 200,
                        width: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Filter Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.close)),
                              ],
                            ),
                            Text('From :'),
                            _fromDate(context, styleFrom),
                            SizedBox(
                              width: 5,
                            ),
                            Text('To :'),
                            _toDate(context, styleFrom),
                            SizedBox(
                              height: 5,
                            ),
                            clearDate(context, styleFrom),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }

  Container clearDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      height: 30,
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, padding: EdgeInsets.all(3)),
        onPressed: () {
          setState(() {
            _startDate = null;
            _endDate = null;
            filter = false;
          });
          Navigator.of(context).pop();
        },
        child: const Text(
          'Reset Date',
          style: TextStyle(
              fontWeight: FontWeight.w400, letterSpacing: 1, color: Colors.red),
        ),
      ),
    );
  }

  Container _toDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: 150, // or use MediaQuery.of(context).size.width > 600 ? 150 : 80
      padding: EdgeInsets.all(2),
      child: ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? DateTime.now(),
              firstDate: DateTime(2015, 8),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != _endDate) {
              setState(() {
                _endDate = picked;
                endPicked = true;
              });
              Navigator.of(context).pop();
            }
          },
          style: styleFrom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _endDate != null
                        ? DateFormat('yyyy-MM-dd').format(_endDate!)
                        : 'Select Date',
                    style: TextStyle(
                        color: endPicked == !true
                            ? Colors.black
                            : Colors.teal.shade800),
                  )
                ],
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.calendar_month,
                color: Colors.black,
                size: 20,
              ),
            ],
          )),
    );
  }

  Container _fromDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: 150, // or use MediaQuery.of(context).size.width > 600 ? 150 : 80
      padding: EdgeInsets.all(2),
      child: ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: DateTime(2015, 8),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != _startDate) {
              setState(() {
                _startDate = picked;
                startPicked = true;
              });
            }
          },
          style: styleFrom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _startDate != null
                        ? DateFormat('yyyy-MM-dd').format(_startDate!)
                        : 'Select Date',
                    style: TextStyle(
                        color: startPicked == !true
                            ? Colors.black
                            : Colors.teal.shade800),
                  )
                ],
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.calendar_month,
                color: Colors.black,
                size: 20,
              ),
            ],
          )),
    );
  }

  Future<void> generatePayroll() async {
    List<PayslipData> generatedData = [];
    {
      // Generate a PayslipData instance for each day
      PayslipData payslip = PayslipData(
        startDate: fromDate!,
        endDate: toDate!,
        dateGenerated: DateTime.now(),
      );
      generatedData.add(payslip);
    }
    await saveToFirestore(generatedData);
  }

  Future<void> saveToFirestore(List<PayslipData> generatedData) async {
    CollectionReference payslipCollection =
        FirebaseFirestore.instance.collection('PayslipDepartment');

    // Use batch writes for efficient write operations
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Iterate over the generated payslip data
    for (var payslip in generatedData) {
      // Create a new document reference for each payslip
      DocumentReference documentRef = payslipCollection.doc();

      // Set the document data
      batch.set(documentRef,
          payslip.toMap()); // Assuming toMap() converts PayslipData to a map
    }

    try {
      // Commit the batch
      await batch.commit();

      // Optionally, you can perform additional actions after batch commit
      // For example, updating UI or triggering other tasks
    } catch (e) {
      // Handle errors
      print("Error saving to Firestore: $e");
      // You can add additional error handling here
    }
  }

  Widget departmentDropdown(
    Function(String?) onChanged,
    String userDepartment,
  ) {
    List<String> departments = ['IT', 'HR', 'ACCOUNTING', 'SERVICING'];

    // Check if the user's department is included in the departments list
    if (!departments.contains(userDepartment)) {
      // If not included, add it to the departments list
      departments.insert(1, userDepartment);
    }

    return DropdownButton<String>(
      value: userDepartment,
      onChanged: (newValue) {
        // Update selectedDepartment only if newValue is not null
        if (newValue != null) {
          // Update selectedDepartment only if it's a valid department
          if (departments.contains(newValue)) {
            // Call the provided onChanged function
            onChanged(newValue);
          }
        }
      },
      items: departments.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void showGeneratePayrollDialog(BuildContext context) async {
    DateTime? fromDateLocal = fromDate;
    DateTime? toDateLocal = toDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Generate Payroll'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Date Range:'),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? initialStartDate = fromDateLocal;
                      DateTime? initialEndDate = toDateLocal;

                      DateTimeRange? picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 5),
                        lastDate: DateTime(DateTime.now().year + 5),
                        initialDateRange: DateTimeRange(
                          end: initialEndDate ??
                              DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day + 13),
                          start: initialStartDate ?? DateTime.now(),
                        ),
                        builder: (context, child) {
                          return Column(
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: 400.0,
                                ),
                                child: child!,
                              )
                            ],
                          );
                        },
                      );

                      if (picked != null) {
                        setState(() {
                          fromDateLocal = picked.start;
                          toDateLocal = picked.end;
                        });
                      }
                    },
                    child: Center(
                      child: Text(
                        '${fromDateLocal != null ? DateFormat('MM/dd/yyyy').format(fromDateLocal!) : 'Start'} - ${toDateLocal != null ? DateFormat('MM/dd/yyyy').format(toDateLocal!) : 'End'}',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      fromDate = fromDateLocal;
                      toDate = toDateLocal;
                    });
                    generatePayroll(); // Call your generatePayroll function here without passing any department
                    Navigator.pop(context);
                  },
                  child: Text('Generate'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double calculateNetPay(double grossPay, double totalDeductions) {
    return grossPay - totalDeductions;
  }

  Widget _buildDataTable() {
    return StreamBuilder(
      stream: _userRecordsStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> payrollDocs = snapshot.data!.docs;

          // Filter payrollDocs based on search text
          List<DocumentSnapshot> filteredPayrollDocs = _searchController
                  .text.isNotEmpty
              ? payrollDocs.where((doc) {
                  final Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return (data['employeeId'] != null &&
                          data['employeeId'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase())) ||
                      (data['fname'] != null &&
                          data['fname'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase())) ||
                      (data['mname'] != null &&
                          data['mname'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase())) ||
                      (data['lname'] != null &&
                          data['lname']
                              .toString()
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()));
                }).toList()
              : List.from(
                  payrollDocs); // Copying the list if no search text to maintain original data

          if (selectedDepartment != 'All') {
            filteredPayrollDocs = filteredPayrollDocs
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
          }

          return SizedBox(
            height: 700,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Container(
                                  width: MediaQuery.of(context).size.width > 600
                                      ? 400
                                      : 100,
                                  height: 30,
                                  margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                  padding:
                                      const EdgeInsets.fromLTRB(3, 0, 0, 0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5)),
                                  ),
                                  child: TextField(
                                    controller: _searchController,
                                    textAlign: TextAlign.start,
                                    decoration: const InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 15),
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
                              Container(
                                width: 130,
                                height: 30,
                                padding: const EdgeInsets.all(0),
                                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                decoration: BoxDecoration(
                                    color: Colors.teal,
                                    border: Border.all(
                                        color: Colors.teal.shade900
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: const EdgeInsets.only(left: 5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'Reset Data',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 1,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      // Reset the status to default in each document
                                      for (var payrollDoc
                                          in filteredPayrollDocs) {
                                        payrollDoc.reference
                                            .update({'status': 'Not Done'});
                                      }
                                    });
                                  },
                                ),
                              ),
                              Container(
                                width: 130,
                                height: 30,
                                padding: const EdgeInsets.all(0),
                                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                decoration: BoxDecoration(
                                    color: Colors.teal,
                                    border: Border.all(
                                        color: Colors.teal.shade900
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    padding: const EdgeInsets.only(left: 5),
                                  ),
                                  onPressed: () {
                                    calculatePayslipTotals();
                                  },
                                  child: Text(
                                    'Calculate Totals',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DataTable(
                                columns: [
                                  const DataColumn(
                                      label: Text('#',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  const DataColumn(
                                      label: Text('Employee Id',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  const DataColumn(
                                      label: Text('Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                    label: PopupMenuButton<String>(
                                      child: const Row(
                                        children: [
                                          Text(
                                            'Department',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
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
                                  DataColumn(
                                      label: Text('Status',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Action',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                ],
                                rows: List.generate(filteredPayrollDocs.length,
                                    (index) {
                                  DocumentSnapshot payrollDoc =
                                      filteredPayrollDocs[index];
                                  Map<String, dynamic> payrollData =
                                      payrollDoc.data() as Map<String, dynamic>;
                                  final fullname =
                                      '${payrollData['fname']} ${payrollData['mname']} ${payrollData['lname']}';

                                  // Checking if the employeeId exists in _generateClickedList to highlight the row

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(
                                        Text(payrollData['employeeId'] ??
                                            'Not Available Yet'),
                                      ),
                                      DataCell(
                                        Text(fullname ?? 'Not Available Yet'),
                                      ),
                                      DataCell(
                                        Text(payrollData['department'] ??
                                            'Not Available Yet'),
                                      ),
                                      DataCell(
                                        Text(payrollData['status'] ??
                                            'Not Done'),
                                      ),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: Colors.blue),
                                            onPressed: () {
                                              _showPayslipDialog2(
                                                  context, payrollData);
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.payment,
                                                color: Colors.blue),
                                            onPressed: () {
                                              // Show circular progress indicator
                                              showDialog(
                                                context: context,
                                                barrierDismissible:
                                                    false, // Prevent dialog dismissal
                                                builder:
                                                    (BuildContext context) {
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  );
                                                },
                                              );

                                              // Simulate data fetching delay
                                              Future.delayed(
                                                  Duration(seconds: 3), () {
                                                // Once data is fetched, close the circular progress indicator
                                                Navigator.of(context,
                                                        rootNavigator: true)
                                                    .pop();

                                                // Delay before showing the payslip dialog
                                                Future.delayed(
                                                    Duration(seconds: -1), () {
                                                  // Show payslip dialog
                                                  _showPayslipDialog(
                                                      context, payrollData);
                                                });
                                              });
                                            },
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 10),
                            const Text(
                              'OVERALL SUMMARY',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Gross Pay',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 50,
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                              decoration: BoxDecoration(
                                color: Colors.blue[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('TotalPayslip')
                                        .doc('totals')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        // Show a loading indicator or placeholder while fetching data
                                        return CircularProgressIndicator();
                                      } else {
                                        // Data has been successfully fetched, display it
                                        final data = snapshot.data!.data()
                                            as Map<String, dynamic>;

                                        final totalGrossPay =
                                            data['totalGrossPay'] ?? 0.0;

                                        return Column(
                                          children: [
                                            Text(
                                              NumberFormat.currency(
                                                      locale: 'en_PH',
                                                      symbol: '₱ ',
                                                      decimalDigits: 2)
                                                  .format(totalGrossPay ?? 0.0),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Deductions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 50,
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                              decoration: BoxDecoration(
                                color: Colors.red[200],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('TotalPayslip')
                                        .doc('totals')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        // Show a loading indicator or placeholder while fetching data
                                        return CircularProgressIndicator();
                                      } else {
                                        // Data has been successfully fetched, display it
                                        final data = snapshot.data!.data()
                                            as Map<String, dynamic>;

                                        final totalDeductions =
                                            data['totalDeductions'] ?? 0.0;

                                        return Column(
                                          children: [
                                            Text(
                                              NumberFormat.currency(
                                                      locale: 'en_PH',
                                                      symbol: '₱ ',
                                                      decimalDigits: 2)
                                                  .format(
                                                      totalDeductions ?? 0.0),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'NETPAY',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Container(
                              height: 50,
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                              decoration: BoxDecoration(
                                color: Colors.green[200],
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: Colors.green.shade200),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('TotalPayslip')
                                        .doc('totals')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        // Show a loading indicator or placeholder while fetching data
                                        return CircularProgressIndicator();
                                      } else {
                                        // Data has been successfully fetched, display it
                                        final data = snapshot.data!.data()
                                            as Map<String, dynamic>;

                                        final totalNetPay =
                                            data['totalNetPay'] ?? 0.0;

                                        return Column(
                                          children: [
                                            Text(
                                              NumberFormat.currency(
                                                      locale: 'en_PH',
                                                      symbol: '₱ ',
                                                      decimalDigits: 2)
                                                  .format(totalNetPay ?? 0.0),
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          ],
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

// Define _generateClickedList to store employeeIds that have generated payslip
  List<String> _generateClickedList = [];

  Future<void> _showPayslipDialog(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      var employeeId = data['employeeId'];
      var overtimeQuerySnapshot = await FirebaseFirestore.instance
          .collection('Overtime')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot2 = await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot3 = await FirebaseFirestore.instance
          .collection('RestdayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot4 = await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot5 = await FirebaseFirestore.instance
          .collection('SpecialHoliday')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot6 = await FirebaseFirestore.instance
          .collection('Holiday')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      // Query the User collection to get the user's document
      var userDocSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      if (userDocSnapshot.docs.isNotEmpty) {
        var userData = userDocSnapshot.docs.first.data();
        var monthlySalary = userData['monthly_salary'] ?? 0;
        var regularOTDataQuery = await FirebaseFirestore.instance
            .collection('OvertimePay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var specialHOTDataQuery = await FirebaseFirestore.instance
            .collection('SpecialHolidayOTPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var regularHOTDataQuery = await FirebaseFirestore.instance
            .collection('RegularHolidayOTPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var restdayOTDataQuery = await FirebaseFirestore.instance
            .collection('RestdayOTPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var holidayPayDataQuery = await FirebaseFirestore.instance
            .collection('HolidayPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var specialHPayDataQuery = await FirebaseFirestore.instance
            .collection('SpecialHolidayPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var regularOTPay = regularOTDataQuery.docs.isNotEmpty
            ? regularOTDataQuery.docs.first.data()['total_overtimePay'] ?? 0
            : 0;

        var specialHOTPay = specialHOTDataQuery.docs.isNotEmpty
            ? specialHOTDataQuery.docs.first.data()['total_specialOTPay'] ?? 0
            : 0;

        var regularHOTPay = regularHOTDataQuery.docs.isNotEmpty
            ? regularHOTDataQuery.docs.first.data()['total_regularHOTPay'] ?? 0
            : 0;

        var restdayOTPay = restdayOTDataQuery.docs.isNotEmpty
            ? restdayOTDataQuery.docs.first.data()['total_restDayOTPay'] ?? 0
            : 0;

        var holidayPay = holidayPayDataQuery.docs.isNotEmpty
            ? holidayPayDataQuery.docs.first.data()['total_holidayPay'] ?? 0
            : 0;

        var specialHPay = specialHPayDataQuery.docs.isNotEmpty
            ? specialHPayDataQuery.docs.first
                    .data()['total_specialHolidayPay'] ??
                0
            : 0;

        final TextEditingController nightDifferentialController =
            TextEditingController();
        final TextEditingController advancesAmescoController =
            TextEditingController();

        final TextEditingController standyAllowanceController =
            TextEditingController();
        final TextEditingController otherPremiumPayController =
            TextEditingController();
        final TextEditingController allowanceController =
            TextEditingController();
        final TextEditingController salaryAdjustmentController =
            TextEditingController();
        final TextEditingController otAdjustmentController =
            TextEditingController();
        final TextEditingController referralBonusController =
            TextEditingController();
        final TextEditingController signingBonusController =
            TextEditingController();
        final TextEditingController sssContributionController =
            TextEditingController();
        final TextEditingController pagibigContributionController =
            TextEditingController();
        final TextEditingController phicContributionController =
            TextEditingController();
        final TextEditingController witholdingTaxController =
            TextEditingController();
        final TextEditingController sssLoanController = TextEditingController();
        final TextEditingController pagibigLoanController =
            TextEditingController();
        final TextEditingController advancesEyeCrafterController =
            TextEditingController();

        final TextEditingController advancesInsularController =
            TextEditingController();
        final TextEditingController vitalabBMCDCController =
            TextEditingController();
        final TextEditingController otherAdvanceController =
            TextEditingController();

        //get Contribution
        sssContributionController.text =
            sssContribution(monthlySalary).toString();
        phicContributionController.text =
            phicContribution(monthlySalary).toString();
        pagibigContributionController.text = pagibigContribution().toString();
        witholdingTaxController.text =
            calculateWithholdingTax(monthlySalary).toString();

        double calculateGrossPay() {
          double nightDifferential =
              double.tryParse(nightDifferentialController.text) ?? 0.0;
          double standyAllowanace =
              double.tryParse(standyAllowanceController.text) ?? 0.0;
          double otherPremiumPay =
              double.tryParse(otherPremiumPayController.text) ?? 0.0;
          double allowance = double.tryParse(allowanceController.text) ?? 0.0;
          double salaryAdjustment =
              double.tryParse(salaryAdjustmentController.text) ?? 0.0;
          double otAdjustment =
              double.tryParse(otAdjustmentController.text) ?? 0.0;
          double referralBonus =
              double.tryParse(referralBonusController.text) ?? 0.0;
          double signingBonus =
              double.tryParse(signingBonusController.text) ?? 0.0;

          return restdayOTPay +
              regularHOTPay +
              specialHOTPay +
              regularOTPay +
              holidayPay +
              specialHPay +
              monthlySalary +
              nightDifferential +
              standyAllowanace +
              otherPremiumPay +
              allowance +
              salaryAdjustment +
              otAdjustment +
              referralBonus +
              signingBonus;
        }

        double calculateDeductions() {
          double sssContribution =
              double.tryParse(sssContributionController.text) ?? 0.0;
          double pagibigContribution =
              double.tryParse(pagibigContributionController.text) ?? 0.0;
          double phicContribution =
              double.tryParse(phicContributionController.text) ?? 0.0;
          double withholdingTax =
              double.tryParse(witholdingTaxController.text) ?? 0.0;
          double sssLoan = double.tryParse(sssLoanController.text) ?? 0.0;
          double pagibigLoan =
              double.tryParse(pagibigLoanController.text) ?? 0.0;
          double advancesEyeCrafter =
              double.tryParse(advancesEyeCrafterController.text) ?? 0.0;
          double advancesAmesco =
              double.tryParse(advancesAmescoController.text) ?? 0.0;
          double advancesInsular =
              double.tryParse(advancesInsularController.text) ?? 0.0;
          double vitalabBMCDC =
              double.tryParse(vitalabBMCDCController.text) ?? 0.0;
          double otherAdvances =
              double.tryParse(otherAdvanceController.text) ?? 0.0;

          return sssContribution +
              pagibigContribution +
              phicContribution +
              withholdingTax +
              sssLoan +
              pagibigLoan +
              advancesEyeCrafter +
              advancesInsular +
              advancesAmesco +
              vitalabBMCDC +
              otherAdvances;
        }

        double overallOTPay = regularHOTPay + specialHOTPay + regularOTPay;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (BuildContext context, setState) {
              double grossPay = calculateGrossPay();
              double totalDeduction = calculateDeductions();
              double netPay = calculateNetPay(grossPay, totalDeduction);
              return AlertDialog(
                surfaceTintColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payslip Details'),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: data['role'] == 'Admin'
                                ? const AssetImage('assets/images/Admin.jpg')
                                : data['role'] == 'Superadmin'
                                    ? const AssetImage(
                                        'assets/images/SAdmin.jpg')
                                    : const AssetImage(
                                        'assets/images/Employee.jpg'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(data['employeeId'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(data['fname'] +
                                  " " +
                                  data['mname'] +
                                  " " +
                                  data['lname']),
                              Row(
                                children: [
                                  Container(
                                      color: Colors.blue[300],
                                      child: Text(data['department'])),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                      color: Colors.amber[200],
                                      child: Text(data['typeEmployee'])),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                      color: Colors.lime[300],
                                      child: Text(data['role'])),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 400,
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                    label: Text('EARNINGS',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1))),
                                DataColumn(label: Text('Hours')),
                                DataColumn(label: Text('Amount')),
                              ],
                              rows: [
                                DataRow(
                                  cells: [
                                    DataCell(Text('Basic Salary')),
                                    DataCell(Text('')),
                                    DataCell(Text(monthlySalary.toString())),
                                  ],
                                ),
                                DataRow(
                                  cells: [
                                    DataCell(Text('Night Differential')),
                                    DataCell(Text('0')),
                                    DataCell(
                                      TextField(
                                        style: TextStyle(fontSize: 14),
                                        controller: nightDifferentialController,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(11),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            grossPay = calculateGrossPay();
                                            // Recalculate
                                            //the gross pay whenever night differential changes
                                          });
                                        },
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: '0'),
                                      ),
                                    ),
                                  ],
                                ),
                                DataRow(cells: [
                                  DataCell(Text('Overtime')),
                                  DataCell(Text('')),
                                  DataCell(Text(overallOTPay.toString())),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('RDOT')),
                                  DataCell(Text('')),
                                  DataCell(Text(restdayOTPay.toString())),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Regular Holiday')),
                                  DataCell(Text('')),
                                  DataCell(Text(holidayPay.toString())),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Special Holiday')),
                                  DataCell(Text('')),
                                  DataCell(Text(specialHPay.toString())),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Standy Allowance')),
                                  DataCell(Text('-')),
                                  DataCell(TextField(
                                    controller: standyAllowanceController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        grossPay = calculateGrossPay();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0'),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Other Premium Pay')),
                                  DataCell(Text('-')),
                                  DataCell(TextField(
                                    controller: otherPremiumPayController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        grossPay = calculateGrossPay();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0'),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Allowance')),
                                  DataCell(Text('-')),
                                  DataCell(TextField(
                                    controller: allowanceController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        grossPay = calculateGrossPay();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0'),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Salary Adjustment')),
                                  DataCell(Text('-')),
                                  DataCell(TextField(
                                    controller: salaryAdjustmentController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        grossPay = calculateGrossPay();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0'),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('OT Adjustment')),
                                  DataCell(Text('-')),
                                  DataCell(TextField(
                                    controller: otAdjustmentController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        grossPay = calculateGrossPay();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0'),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Referral Bonus')),
                                  DataCell(Text('-')),
                                  DataCell(TextField(
                                    controller: referralBonusController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        grossPay = calculateGrossPay();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0'),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Signing Bonus')),
                                  DataCell(Text('-')),
                                  DataCell(TextField(
                                    controller: signingBonusController,
                                    onChanged: (value) {
                                      setState(() {
                                        grossPay = calculateGrossPay();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: '0'),
                                  )),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text(
                                    'GROSS PAY',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  DataCell(Text('')),
                                  DataCell(Text(
                                    grossPay.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                ]),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 700,
                            width: 1, // Adjust the width as needed
                            color: Colors.black,
                          ),
                          Container(
                            width: 400,
                            child: DataTable(columns: const [
                              DataColumn(
                                  label: Text('DEDUCTIONS',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1))),
                              DataColumn(label: Text('Amount')),
                            ], rows: [
                              DataRow(cells: [
                                DataCell(Text('LWOP/ Tardiness')),
                                DataCell(Text('0')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('SSS Contribution')),
                                DataCell(TextField(
                                  controller: sssContributionController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Pag-ibig Contribution')),
                                DataCell(TextField(
                                  controller: pagibigContributionController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('PHIC Contribution')),
                                DataCell(TextField(
                                  controller: phicContributionController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Witholding Tax')),
                                DataCell(TextField(
                                  controller: witholdingTaxController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('SSS Loan')),
                                DataCell(TextField(
                                  controller: sssLoanController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Pag-ibig Loan')),
                                DataCell(TextField(
                                  controller: pagibigLoanController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Advances: Eye Crafter')),
                                DataCell(TextField(
                                  controller: advancesEyeCrafterController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Advances: Amesco')),
                                DataCell(TextField(
                                  controller: advancesAmescoController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Advances: Insular')),
                                DataCell(TextField(
                                  controller: advancesInsularController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Vitalab/ BMCDC')),
                                DataCell(TextField(
                                    controller: vitalabBMCDCController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(11),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        totalDeduction = calculateDeductions();
                                      });
                                    },
                                    style: TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '0',
                                    ))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Other Advances')),
                                DataCell(TextField(
                                  controller: otherAdvanceController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      totalDeduction = calculateDeductions();
                                    });
                                  },
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                  ),
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text(
                                  'TOTAL DEDUCTIONS',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataCell(Text(
                                  totalDeduction.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                              ]),
                            ]),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 700,
                            width: 1, // Adjust the width as needed
                            color: Colors.black,
                          ),
                          Container(
                            width: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SUMMARY',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1)),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gross Pay: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      grossPay.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Deductions: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      totalDeduction.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'NET PAY: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                    Text(
                                      netPay.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    bool confirmGenerate = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                              title: Text('Confirmation'),
                                              content: Text(
                                                  'Are you sure you want to generate the payslip?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(true);
                                                  },
                                                  child: Text('Yes'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(false);
                                                  },
                                                  child: Text('No'),
                                                ),
                                              ]);
                                        });

                                    if (confirmGenerate == true) {
                                      final String nightDifferentialText =
                                          nightDifferentialController.text;

                                      final String advancesAmescoText =
                                          advancesAmescoController.text;

                                      final String standyAllowanceText =
                                          standyAllowanceController.text;

                                      final String otherPremiumText =
                                          otherPremiumPayController.text;

                                      final String allowanceText =
                                          allowanceController.text;

                                      final String salaryAdjustmentText =
                                          salaryAdjustmentController.text;

                                      final String otAdjustmentText =
                                          otAdjustmentController.text;

                                      final String referralBonusText =
                                          referralBonusController.text;

                                      final String signingBonusText =
                                          signingBonusController.text;

                                      final String sssContributionText =
                                          sssContributionController.text;

                                      final String pagibigContributionText =
                                          pagibigContributionController.text;

                                      final String phicContributionText =
                                          phicContributionController.text;

                                      final String withholdingTaxText =
                                          witholdingTaxController.text;

                                      final String sssLoanText =
                                          sssLoanController.text;

                                      final String pagibigLoanText =
                                          pagibigLoanController.text;

                                      final String advancesEyeCrafterText =
                                          advancesEyeCrafterController.text;

                                      final String advancesInsularText =
                                          advancesInsularController.text;

                                      final String vitalabBMCDCText =
                                          vitalabBMCDCController.text;
                                      final String otherAdvancesText =
                                          otherAdvanceController.text;

                                      try {
                                        final double advanceAmesco =
                                            advancesAmescoText.isNotEmpty
                                                ? double.tryParse(
                                                        advancesAmescoText) ??
                                                    0
                                                : 0;
                                        final double nightDifferential =
                                            double.tryParse(
                                                    nightDifferentialText) ??
                                                0.0;

                                        final double standyAllowance =
                                            double.tryParse(
                                                    standyAllowanceText) ??
                                                0.0;
                                        final double otherPremiumPay =
                                            double.tryParse(otherPremiumText) ??
                                                0.0;
                                        final double allowance =
                                            double.tryParse(allowanceText) ??
                                                0.0;
                                        final double salaryAdjustment =
                                            double.tryParse(
                                                    salaryAdjustmentText) ??
                                                0.0;
                                        final double otAdjustment =
                                            double.tryParse(otAdjustmentText) ??
                                                0.0;
                                        final double referralBonus =
                                            double.tryParse(
                                                    referralBonusText) ??
                                                0.0;
                                        final double signingBonus =
                                            double.tryParse(signingBonusText) ??
                                                0.0;
                                        final double sssContribution =
                                            double.tryParse(
                                                    sssContributionText) ??
                                                0.0;
                                        final double pagibigContribution =
                                            double.tryParse(
                                                    pagibigContributionText) ??
                                                0.0;
                                        final double phicContribution =
                                            double.tryParse(
                                                    phicContributionText) ??
                                                0.0;
                                        final double withholdingTax =
                                            double.tryParse(
                                                    withholdingTaxText) ??
                                                0.0;
                                        final double sssLoan =
                                            double.tryParse(sssLoanText) ?? 0.0;
                                        final double pagibigLoan =
                                            double.tryParse(pagibigLoanText) ??
                                                0.0;
                                        final double advancesEyeCrafter =
                                            double.tryParse(
                                                    advancesEyeCrafterText) ??
                                                0.0;
                                        final double advancesInsular =
                                            double.tryParse(
                                                    advancesInsularText) ??
                                                0.0;
                                        final double vitalabBMCDC =
                                            double.tryParse(vitalabBMCDCText) ??
                                                0.0;
                                        final double otherAdvances =
                                            double.tryParse(
                                                    otherAdvancesText) ??
                                                0.0;
                                        double grossPay = calculateGrossPay();
                                        double totalDeduction =
                                            calculateDeductions();
                                        double netPay = calculateNetPay(
                                            grossPay, totalDeduction);

                                        var userData =
                                            userDocSnapshot.docs.first.data();
                                        var monthlySalary =
                                            userData['monthly_salary'] ?? 0;
                                        final holidayPay =
                                            holidayPayDataQuery.docs.isNotEmpty
                                                ? holidayPayDataQuery.docs.first
                                                            .data()[
                                                        'total_holidayPay'] ??
                                                    0
                                                : 0;
                                        var specialHPay = specialHPayDataQuery
                                                .docs.isNotEmpty
                                            ? specialHPayDataQuery.docs.first
                                                        .data()[
                                                    'total_specialHolidayPay'] ??
                                                0
                                            : 0;
                                        var restdayOTPay =
                                            restdayOTDataQuery.docs.isNotEmpty
                                                ? restdayOTDataQuery.docs.first
                                                            .data()[
                                                        'total_restDayOTPay'] ??
                                                    0
                                                : 0;
                                        // Assuming employeeId is accessible from the user object
                                        final String employeeId = userData[
                                            'employeeId']; // Adjust this line according to your actual user object structure
                                        final String fullName =
                                            '${userData['fname']} ${userData['mname']} ${userData['lname']}';
                                        final String department =
                                            userData['department'];
                                        final double monthly_salary =
                                            userData['monthly_salary'];
                                        // User is authenticated, proceed with adding payslip
                                        await addPayslip(
                                          monthly_salary: monthly_salary,
                                          department: department,
                                          fullName: fullName,
                                          advances_amesco: advanceAmesco,
                                          employeeId: employeeId,
                                          night_differential: nightDifferential,
                                          advances_eyecrafter:
                                              advancesEyeCrafter,
                                          advances_insular: advancesInsular,
                                          allowance: allowance,
                                          ot_adjustment: otAdjustment,
                                          other_advances: otherAdvances,
                                          other_prem_pay: otherPremiumPay,
                                          overAllOTPay: overallOTPay,
                                          pagibig_contribution:
                                              pagibigContribution,
                                          pagibig_loan: pagibigLoan,
                                          phic_contribution: phicContribution,
                                          signing_bonus: signingBonus,
                                          salary_adjustment: salaryAdjustment,
                                          referral_bonus: referralBonus,
                                          sss_contribution: sssContribution,
                                          sss_loan: sssLoan,
                                          standy_allowance: standyAllowance,
                                          vitalab_bmcdc: vitalabBMCDC,
                                          witholding_tax: withholdingTax,
                                          total_deduction: totalDeduction,
                                          grossPay: grossPay,
                                          netPay: netPay,
                                          salary: monthlySalary,
                                          holidayPay: holidayPay,
                                          specialHOTPay: specialHOTPay,
                                          specialHPay: specialHPay,
                                          regularHOTPay: regularHOTPay,
                                          regularOTPay: regularOTPay,
                                          restdayOTPay: restdayOTPay,

                                          // Pass employeeId instead of userId
                                        );

                                        // Update status to "Done" in Firestore document
                                        await userDocSnapshot
                                            .docs.first.reference
                                            .update({
                                          'status': 'Done',
                                        });

                                        // Add employeeId to _generateClickedList
                                        _generateClickedList.add(employeeId);
                                        double makeitzero = 0;
                                        final lastRecordSnapshot =
                                            await _firestore
                                                .collection('OvertimePay')
                                                .where('employeeId',
                                                    isEqualTo: employeeId)
                                                .get();

                                        final lastRecordSnapshot2 =
                                            await _firestore
                                                .collection('HolidayPay')
                                                .where('employeeId',
                                                    isEqualTo: employeeId)
                                                .get();

                                        final lastRecordSnapshot3 =
                                            await _firestore
                                                .collection('RestdayOTPay')
                                                .where('employeeId',
                                                    isEqualTo: employeeId)
                                                .get();

                                        final lastRecordSnapshot4 =
                                            await _firestore
                                                .collection('SpecialHolidayPay')
                                                .where('employeeId',
                                                    isEqualTo: employeeId)
                                                .get();

                                        final lastRecordSnapshot5 =
                                            await _firestore
                                                .collection(
                                                    'RegularHolidayOTPay')
                                                .where('employeeId',
                                                    isEqualTo: employeeId)
                                                .get();

                                        final lastRecordSnapshot6 =
                                            await _firestore
                                                .collection(
                                                    'SpecialHolidayOTPay')
                                                .where('employeeId',
                                                    isEqualTo: employeeId)
                                                .get();
                                        if (lastRecordSnapshot
                                            .docs.isNotEmpty) {
                                          final recordId =
                                              lastRecordSnapshot.docs.first.id;
                                          await _firestore
                                              .collection('OvertimePay')
                                              .doc(recordId)
                                              .update({
                                            'total_overtimePay': makeitzero,
                                          });
                                        }

                                        if (lastRecordSnapshot2
                                            .docs.isNotEmpty) {
                                          final recordId =
                                              lastRecordSnapshot2.docs.first.id;
                                          await _firestore
                                              .collection('HolidayPay')
                                              .doc(recordId)
                                              .update({
                                            'total_holidayPay': makeitzero,
                                          });
                                        }

                                        if (lastRecordSnapshot3
                                            .docs.isNotEmpty) {
                                          final recordId =
                                              lastRecordSnapshot3.docs.first.id;
                                          await _firestore
                                              .collection('RestdayOTPay')
                                              .doc(recordId)
                                              .update({
                                            'total_restDayOTPay': makeitzero,
                                          });
                                        }

                                        if (lastRecordSnapshot4
                                            .docs.isNotEmpty) {
                                          final recordId =
                                              lastRecordSnapshot4.docs.first.id;
                                          await _firestore
                                              .collection('SpecialHolidayPay')
                                              .doc(recordId)
                                              .update({
                                            'total_specialHolidayPay':
                                                makeitzero,
                                          });
                                        }

                                        if (lastRecordSnapshot5
                                            .docs.isNotEmpty) {
                                          final recordId =
                                              lastRecordSnapshot5.docs.first.id;
                                          await _firestore
                                              .collection('RegularHolidayOTPay')
                                              .doc(recordId)
                                              .update({
                                            'total_regularHOTPay': makeitzero,
                                          });
                                        }

                                        if (lastRecordSnapshot6
                                            .docs.isNotEmpty) {
                                          final recordId =
                                              lastRecordSnapshot6.docs.first.id;
                                          await _firestore
                                              .collection('SpecialHolidayOTPay')
                                              .doc(recordId)
                                              .update({
                                            'total_specialOTPay': makeitzero,
                                          });
                                        }

                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        print('Error generating payslip: $e');
                                      }
                                      for (var overtimeDoc
                                          in overtimeQuerySnapshot.docs) {
                                        await moveToArchiveOT(overtimeDoc);
                                      }
                                      for (var overtimeDoc
                                          in overtimeQuerySnapshot2.docs) {
                                        await moveToSpecialHOT(overtimeDoc);
                                      }
                                      for (var overtimeDoc
                                          in overtimeQuerySnapshot3.docs) {
                                        await moveToRestdayOT(overtimeDoc);
                                      }

                                      for (var overtimeDoc
                                          in overtimeQuerySnapshot4.docs) {
                                        await moveToRegularHOT(overtimeDoc);
                                      }

                                      for (var overtimeDoc
                                          in overtimeQuerySnapshot5.docs) {
                                        await moveToSpecialH(overtimeDoc);
                                      }

                                      for (var overtimeDoc
                                          in overtimeQuerySnapshot6.docs) {
                                        await moveToRegularH(overtimeDoc);
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal[300],
                                    padding: const EdgeInsets.all(18.0),
                                    minimumSize: const Size(300, 50),
                                    maximumSize: const Size(300, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "Generate Payslip",
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Change the text color to white
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          },
        );
      }
    } catch (e) {
      print('Error showing payslip dialog: $e');
    }
  }

// Utility function to build info row in the dialog
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

// Placeholder function, replace this with actual implementation
  Future<void> addPayslip({
    required double monthly_salary,
    required String department,
    required String fullName,
    required double advances_amesco,
    required String employeeId,
    required double night_differential,
    required double advances_eyecrafter,
    required double advances_insular,
    required double allowance,
    required double ot_adjustment,
    required double other_advances,
    required double other_prem_pay,
    required double overAllOTPay,
    required double pagibig_contribution,
    required double pagibig_loan,
    required double phic_contribution,
    required double signing_bonus,
    required double salary_adjustment,
    required double referral_bonus,
    required double sss_contribution,
    required double sss_loan,
    required double standy_allowance,
    required double vitalab_bmcdc,
    required double witholding_tax,
    required double total_deduction,
    required double grossPay,
    required double netPay,
    required double salary,
    required double holidayPay,
    required double specialHPay,
    required double restdayOTPay,
    required double regularHOTPay,
    required double specialHOTPay,
    required double regularOTPay,
  }) async {
    try {
      final json = {
        'monthly_salary': monthly_salary,
        'department': department,
        'fullname': fullName,
        'employeeId': employeeId,
        'advances_amesco': advances_amesco,
        'advances_eyecrafter': advances_eyecrafter,
        'advances_insular': advances_insular,
        'allowance': allowance,
        'holidayPay': holidayPay,
        'specialHPay': specialHPay,
        'restdayOTPay': restdayOTPay,
        'salary': salary,
        'grossPay': grossPay,
        'netPay': netPay,
        'night_differential': night_differential,
        'ot_adjustment': ot_adjustment,
        'other_advances': other_advances,
        'other_prem_pay': other_prem_pay,
        'overAllOTPay': overAllOTPay,
        'pagibig_contribution': pagibig_contribution,
        'pagibig_loan': pagibig_loan,
        'phic_contribution': phic_contribution,
        'referral_bonus': referral_bonus,
        'signing_bonus': signing_bonus,
        'salary_adjustment': salary_adjustment,
        'sss_contribution': sss_contribution,
        'sss_loan': sss_loan,
        'standy_allowance': standy_allowance,
        'vitalab_bmcdc': vitalab_bmcdc,
        'witholding_tax': witholding_tax,
        'total_deduction': total_deduction,
        'specialHOTPay': specialHOTPay,
        'regularHOTPay': regularHOTPay,
        'regularOTPay': regularOTPay,

        // Using employeeId as the document ID when adding to the Payslip collection
      };

      // Using employeeId as the document ID when adding to the Payslip collection
      await FirebaseFirestore.instance
          .collection('Payslip')
          .doc(employeeId)
          .set(json);
      await FirebaseFirestore.instance
          .collection('ArchivesPayslip')
          .doc()
          .set(json);

      print('Payslip added successfully for employee $employeeId');
    } catch (e) {
      print('Error adding payslip data: $e');
    }
  }

  Future<void> moveToArchiveOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('Overtime')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesOvertime')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> _showPayslipDialog2(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      var employeeId = data['employeeId'];
      var userDocSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('employeeId', isEqualTo: employeeId)
          .get();
      var userData = userDocSnapshot.docs.first.data();
      var monthlySalary = userData['monthly_salary'] ?? 0;

      var paySlipDataQuery = await FirebaseFirestore.instance
          .collection('Payslip')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var nightDifferential = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['night_differential'] ?? 0
          : 0;

      var overallOTPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['overAllOTPay'] ?? 0
          : 0;

      var restdayOTPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['restdayOTPay'] ?? 0
          : 0;

      var holidayPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['holidayPay'] ?? 0
          : 0;

      var specialHPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['specialHPay'] ?? 0
          : 0;

      var standyAllowance = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['standy_allowance'] ?? 0
          : 0;

      var otherPremiumPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['other_prem_pay'] ?? 0
          : 0;

      var allowance = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['allowance'] ?? 0
          : 0;
      var salaryAdjustment = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['salary_adjustment'] ?? 0
          : 0;

      var otAdjustment = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['ot_adjustment'] ?? 0
          : 0;

      var referralBonus = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['referral_bonus'] ?? 0
          : 0;

      var signingBonus = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['signing_bonus'] ?? 0
          : 0;

      var grossPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['grossPay'] ?? 0
          : 0;

      var sssContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['sss_contribution'] ?? 0
          : 0;

      var pagibigContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['pagibig_contribution'] ?? 0
          : 0;
      var phicContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['phic_contribution'] ?? 0
          : 0;
      var withHoldingTax = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['witholding_tax'] ?? 0
          : 0;

      var sssLoan = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['sss_loan'] ?? 0
          : 0;

      var pagibigLoan = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['pagibig_loan'] ?? 0
          : 0;

      var advancesEyeCrafter = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_eyecrafter'] ?? 0
          : 0;

      var advancesAmesco = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_amesco'] ?? 0
          : 0;

      var advancesInsular = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_insular'] ?? 0
          : 0;
      var vitalabBMCDC = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['vitalab_bmcdc'] ?? 0
          : 0;

      var otherAdvances = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['other_advances'] ?? 0
          : 0;

      var totalDeduction = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['total_deduction'] ?? 0
          : 0;

      var netPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['netPay'] ?? 0
          : 0;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (BuildContext context, setSTate) {
              return AlertDialog(
                surfaceTintColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payslip Details'),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: data['role'] == 'Admin'
                                ? const AssetImage('assets/images/Admin.jpg')
                                : data['role'] == 'Superadmin'
                                    ? const AssetImage(
                                        'assets/images/SAdmin.jpg')
                                    : const AssetImage(
                                        'assets/images/Employee.jpg'),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(data['employeeId'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(data['fname'] +
                                  " " +
                                  data['mname'] +
                                  " " +
                                  data['lname']),
                              Row(
                                children: [
                                  Container(
                                      color: Colors.blue[300],
                                      child: Text(data['department'])),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                      color: Colors.amber[200],
                                      child: Text(data['typeEmployee'])),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                      color: Colors.lime[300],
                                      child: Text(data['role'])),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 400,
                            child: DataTable(
                              columns: const [
                                DataColumn(
                                    label: Text('EARNINGS',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1))),
                                DataColumn(label: Text('Hours')),
                                DataColumn(label: Text('Amount')),
                              ],
                              rows: [
                                DataRow(cells: [
                                  DataCell(Text('Basic Salary')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(monthlySalary.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Night Differential')),
                                  DataCell(Text('')),
                                  DataCell(Text(
                                      nightDifferential.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Overtime')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(overallOTPay.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('RDOT')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(restdayOTPay.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Regular Holiday')),
                                  DataCell(Text('')),
                                  DataCell(Text(holidayPay.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Special Holiday')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(specialHPay.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Standy Allowance')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(standyAllowance.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Other Premium Pay')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(otherPremiumPay.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Allowance  ')),
                                  DataCell(Text('')),
                                  DataCell(Text(allowance.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Salary Adjustment  ')),
                                  DataCell(Text('')),
                                  DataCell(Text(
                                      salaryAdjustment.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('OT Adjustment')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(otAdjustment.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Referral Bonus')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(referralBonus.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text('Signing Bonus')),
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(signingBonus.toStringAsFixed(2))),
                                ]),
                                DataRow(cells: [
                                  DataCell(Text(
                                    'GROSS PAY',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                                  DataCell(Text('')),
                                  DataCell(Text(grossPay.toStringAsFixed(2))),
                                ]),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 700,
                            width: 1, // Adjust the width as needed
                            color: Colors.black,
                          ),
                          Container(
                            width: 400,
                            child: DataTable(columns: const [
                              DataColumn(
                                label: Text(
                                  'DEDUCTIONS',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1),
                                ),
                              ),
                              DataColumn(
                                label: Text('Amount'),
                              ),
                            ], rows: [
                              DataRow(cells: [
                                DataCell(Text('LWOP/ Tardiness')),
                                DataCell(Text('0')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('SSS Contribution')),
                                DataCell(
                                    Text(sssContribution.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Pag-ibig Contribution')),
                                DataCell(Text(pagibigContribution.toString())),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('PHIC Contribution')),
                                DataCell(
                                    Text(phicContribution.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Witholding Tax')),
                                DataCell(
                                    Text(withHoldingTax.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('SSS Loan')),
                                DataCell(Text(sssLoan.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Pag-ibig Loan')),
                                DataCell(Text(pagibigLoan.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Advances: Eye Crafter')),
                                DataCell(Text(
                                    advancesEyeCrafter.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Advances: Amesco')),
                                DataCell(
                                    Text(advancesAmesco.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Advances: Insular')),
                                DataCell(
                                    Text(advancesInsular.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Vitalab / BMCDC')),
                                DataCell(Text(vitalabBMCDC.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('Other Advances')),
                                DataCell(
                                    Text(otherAdvances.toStringAsFixed(2))),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('')),
                                DataCell(Text('')),
                              ]),
                              DataRow(cells: [
                                DataCell(Text('TOTAL DEDUCTIONS',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))),
                                DataCell(
                                    Text(totalDeduction.toStringAsFixed(2))),
                              ]),
                            ]),
                          ),
                          Container(
                            margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            height: 700,
                            width: 1, // Adjust the width as needed
                            color: Colors.black,
                          ),
                          Container(
                            width: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 20,
                                ),
                                Text('SUMMARY',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    )),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Gross Pay: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                              locale: 'en_PH',
                                              symbol: '₱ ',
                                              decimalDigits: 2)
                                          .format(grossPay ?? 0.0),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total Deductions: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                              locale: 'en_PH',
                                              symbol: '₱ ',
                                              decimalDigits: 2)
                                          .format(totalDeduction ?? 0.0),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'NET PAY: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      NumberFormat.currency(
                                              locale: 'en_PH',
                                              symbol: '₱ ',
                                              decimalDigits: 2)
                                          .format(netPay ?? 0.0),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    // Call function to export PDF
                                    _exportPdf(context, data);
                                  },
                                  child: Text('Export PDF'),
                                ),
                                SizedBox(height: 580),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          });
    } catch (e) {}
  }

  Future<void> _exportPdf(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      var employeeId = data['employeeId'];
      var userDocSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('employeeId', isEqualTo: employeeId)
          .get();
      var userData = userDocSnapshot.docs.first.data();
      var monthlySalary = userData['monthly_salary'] ?? 0;

      var paySlipDataQuery = await FirebaseFirestore.instance
          .collection('Payslip')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var nightDifferential = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['night_differential'] ?? 0
          : 0;

      var overallOTPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['overAllOTPay'] ?? 0
          : 0;

      var restdayOTPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['restdayOTPay'] ?? 0
          : 0;

      var holidayPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['holidayPay'] ?? 0
          : 0;

      var specialHPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['specialHPay'] ?? 0
          : 0;

      var standyAllowance = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['standy_allowance'] ?? 0
          : 0;

      var otherPremiumPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['other_prem_pay'] ?? 0
          : 0;

      var allowance = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['allowance'] ?? 0
          : 0;
      var salaryAdjustment = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['salary_adjustment'] ?? 0
          : 0;

      var otAdjustment = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['ot_adjustment'] ?? 0
          : 0;

      var referralBonus = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['referral_bonus'] ?? 0
          : 0;

      var signingBonus = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['signing_bonus'] ?? 0
          : 0;

      var grossPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['grossPay'] ?? 0
          : 0;

      var sssContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['sss_contribution'] ?? 0
          : 0;

      var pagibigContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['pagibig_contribution'] ?? 0
          : 0;
      var phicContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['phic_contribution'] ?? 0
          : 0;
      var withHoldingTax = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['witholding_tax'] ?? 0
          : 0;

      var sssLoan = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['sss_loan'] ?? 0
          : 0;

      var pagibigLoan = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['pagibig_loan'] ?? 0
          : 0;

      var advancesEyeCrafter = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_eyecrafter'] ?? 0
          : 0;

      var advancesAmesco = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_amesco'] ?? 0
          : 0;

      var advancesInsular = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_insular'] ?? 0
          : 0;
      var vitalabBMCDC = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['vitalab_bmcdc'] ?? 0
          : 0;

      var otherAdvances = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['other_advances'] ?? 0
          : 0;

      var totalDeduction = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['total_deduction'] ?? 0
          : 0;

      var netPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['netPay'] ?? 0
          : 0;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            var currencyFormatter = NumberFormat.currency(
              locale: 'en_PH',
              symbol: 'PHP ',
              decimalDigits: 2,
            );
            pw.Row createRow(String description, String amount) {
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(description),
                  pw.Text(amount),
                ],
              );
            }

            pw.Row createRowSum(String description, String amount) {
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(description),
                  pw.Text(amount,
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              );
            }

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Payslip Details',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                createRow('Employee ID: ', '${data['employeeId']}'),
                createRow('Name:',
                    ' ${data['fname']} ${data['mname']} ${data['lname']}'),
                createRow('Department: ', '${data['department']}'),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('EARNINGS',
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          createRow('Basic Salary:', ' $monthlySalary'),
                          createRow(
                              'Night Differential:', ' $nightDifferential'),
                          createRow('Overall OT Pay:', ' $overallOTPay'),
                          createRow('Restday OT Pay: ', '$restdayOTPay'),
                          createRow('Holiday Pay: ', '$holidayPay'),
                          createRow('Special Holiday Pay: ', '$specialHPay'),
                          createRow('Standy Allowance: ', '$standyAllowance'),
                          createRow('Other Premium Pay:', ' $otherPremiumPay'),
                          createRow('Allowance:', ' $allowance'),
                          createRow('Salary Adjustment:', ' $salaryAdjustment'),
                          createRow('OT Adjustment: ', '$otAdjustment'),
                          createRow('Referral Bonus: ', '$referralBonus'),
                          createRow('Signing Bonus: ', '$signingBonus'),
                          pw.Divider(),
                          createRow('Gross Pay: ', '$grossPay'),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 10),
                    // pw.Container(height: 280, width: 1, color: PdfColors.black),
                    pw.SizedBox(width: 10),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('DEDUCTIONS',
                              style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 10),
                          createRow('SSS Contribution:', ' $sssContribution'),
                          createRow('Pag-ibig Contribution: ',
                              '$pagibigContribution'),
                          createRow('PHIC Contribution: ', '$phicContribution'),
                          createRow('Withholding Tax:', ' $withHoldingTax'),
                          createRow('SSS Loan: ', ' $sssLoan'),
                          createRow('Pag-ibig Loan:', ' $pagibigLoan'),
                          createRow(
                              'Advances Eye Crafter:', ' $advancesEyeCrafter'),
                          createRow('Advances Amesco: ', '$advancesAmesco'),
                          createRow('Advances Insular:', ' $advancesInsular'),
                          createRow('Vitalab / BMCDC:', ' $vitalabBMCDC'),
                          createRow('Other Advances: ', '$otherAdvances'),
                          pw.Text(
                            'S',
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                          pw.Text(
                            'S',
                            style: pw.TextStyle(color: PdfColors.white),
                          ),
                          pw.Divider(),
                          createRow('Total Deductions:', ' $totalDeduction'),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('SUMMARY',
                    style: pw.TextStyle(
                        fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                createRowSum('Gross Pay:',
                    ' ${currencyFormatter.format(grossPay ?? 0.0)}'),
                createRowSum('Total Deductions: ',
                    '${currencyFormatter.format(totalDeduction ?? 0.0)}'),
                pw.Divider(),
                createRowSum(
                    'Net Pay:', ' ${currencyFormatter.format(netPay ?? 0.0)}'),
                       pw.Container(
                margin: pw.EdgeInsets.only(top: 100),
                child: pw.Text(
                  'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10),
                ),
              ),
              ],
            );
          },
        ),
      );

      final pdfBytes = await pdf.save();

      if (kIsWeb) {
        final pdfBlob = html.Blob([Uint8List.fromList(pdfBytes)]);
        final pdfUrl = html.Url.createObjectUrlFromBlob(pdfBlob);
        html.AnchorElement(href: pdfUrl)
          ..setAttribute("download", "Payslip_Report.pdf")
          ..click();
        html.Url.revokeObjectUrl(pdfUrl);
      } else {
        final String directoryPath =
            (await getExternalStorageDirectory())?.path ?? '';
        final String filePath = '$directoryPath/Payslip_Report.pdf';
        final File file = File(filePath);
        await file.writeAsBytes(pdfBytes);
        OpenFile.open(filePath);
      }
    } catch (e) {
      print("Error: $e");
      // Handle error appropriately
    }
  }

  Future<void> fetchTotal() async {
    DocumentSnapshot totalPayslipSnapshot = await FirebaseFirestore.instance
        .collection('TotalPayslip')
        .doc('totals')
        .get();

    setState(() {
      totalGrossPay = totalPayslipSnapshot['totalGrossPay'] ?? 0.0;
      totalDeductions = totalPayslipSnapshot['totalDeductions'] ?? 0.0;
      totalNetPay = totalPayslipSnapshot['totalNetPay'] ?? 0.0;
    });
  }

  Future<void> moveToRestdayOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesRegularHOT')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> moveToSpecialHOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesSpecialHOT')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> calculatePayslipTotals() async {
    double totalGrossPay = 0.0;
    double totalDeductions = 0.0;
    double totalNetPay = 0.0;

    QuerySnapshot payslipSnapshot =
        await FirebaseFirestore.instance.collection('Payslip').get();

    payslipSnapshot.docs.forEach((payslipDoc) {
      Map<String, dynamic> payslipData =
          payslipDoc.data() as Map<String, dynamic>;

      double grossPay = payslipData['grossPay'] ?? 0.0;
      double deductions = payslipData['total_deduction'] ?? 0.0;

      totalGrossPay += grossPay;
      totalDeductions += deductions;
      totalNetPay += (grossPay - deductions);
    });

    // Storing the calculated totals in Firestore
    await FirebaseFirestore.instance
        .collection('TotalPayslip')
        .doc('totals')
        .set({
      'totalGrossPay': totalGrossPay,
      'totalDeductions': totalDeductions,
      'totalNetPay': totalNetPay,
      'timestamp': FieldValue.serverTimestamp(), // Optional: Add a timestamp
    });
    // Optionally, you can print the totals
    print('Total Gross Pay: $totalGrossPay');
    print('Total Deductions: $totalDeductions');
    print('Total Net Pay: $totalNetPay');
  }
}

Future<void> moveToRegularHOT(DocumentSnapshot overtimeDoc) async {
  try {
    Map<String, dynamic> overtimeData =
        Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

    String employeeId = overtimeData['employeeId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('RegularHolidayOT')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    // Loop through documents and move each one to ArchivesOvertime collection
    for (DocumentSnapshot doc in userOvertimeDocs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await FirebaseFirestore.instance
            .collection('ArchivesRegularHOT')
            .add(data); // Adding document data to ArchivesOvertime collection
      }
      await doc.reference
          .delete(); // Delete the document from the original collection
    }
  } catch (e) {
    print('Error moving record to ArchivesOvertime collection: $e');
  }
}

Future<void> moveToRegularH(DocumentSnapshot overtimeDoc) async {
  try {
    Map<String, dynamic> overtimeData =
        Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

    String employeeId = overtimeData['employeeId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('Holiday')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    // Loop through documents and move each one to ArchivesOvertime collection
    for (DocumentSnapshot doc in userOvertimeDocs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await FirebaseFirestore.instance
            .collection('ArchivesRegularH')
            .add(data); // Adding document data to ArchivesOvertime collection
      }
      await doc.reference
          .delete(); // Delete the document from the original collection
    }
  } catch (e) {
    print('Error moving record to ArchivesOvertime collection: $e');
  }
}

Future<void> moveToPayslip(DocumentSnapshot overtimeDoc) async {
  try {
    Map<String, dynamic> overtimeData =
        Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

    String employeeId = overtimeData['employeeId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('Payslip')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    // Loop through documents and move each one to ArchivesOvertime collection
    for (DocumentSnapshot doc in userOvertimeDocs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await FirebaseFirestore.instance
            .collection('ArchivesPayslip')
            .add(data); // Adding document data to ArchivesOvertime collection
      }
      await doc.reference
          .delete(); // Delete the document from the original collection
    }
  } catch (e) {
    print('Error moving record to ArchivesOvertime collection: $e');
  }
}

Future<void> moveToSpecialH(DocumentSnapshot overtimeDoc) async {
  try {
    Map<String, dynamic> overtimeData =
        Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

    String employeeId = overtimeData['employeeId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('SpecialHoliday')
        .where('employeeId', isEqualTo: employeeId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    // Loop through documents and move each one to ArchivesOvertime collection
    for (DocumentSnapshot doc in userOvertimeDocs) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        await FirebaseFirestore.instance
            .collection('ArchivesSpecialH')
            .add(data); // Adding document data to ArchivesOvertime collection
      }
      await doc.reference
          .delete(); // Delete the document from the original collection
    }
  } catch (e) {
    print('Error moving record to ArchivesOvertime collection: $e');
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
            label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
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
