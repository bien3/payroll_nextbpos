import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class SpecialHolidayOTPage extends StatefulWidget {
  const SpecialHolidayOTPage({Key? key}) : super(key: key);

  @override
  State<SpecialHolidayOTPage> createState() => _SpecialHolidayOTPage();
}

class _SpecialHolidayOTPage extends State<SpecialHolidayOTPage> {
  late List<String> _selectedOvertimeTypes;

  TextEditingController _searchController = TextEditingController();
  int _itemsPerPage = 5;
  int _currentPage = 0;
  int indexRow = 0;

  DateTime? fromDate;
  DateTime? toDate;
  bool _sortAscending = false;

  bool sortPay = false;
  bool table = false;

  String selectedDepartment = 'All';
  bool endPicked = false;
  bool startPicked = false;
  bool filter = false;
  late String _role = 'Guest';

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [
      'Special Holiday',
      'Regular',
    ];
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        final role = docSnapshot['role'];
        _role = role != null
            ? role
            : 'Guest'; // Default to 'Guest' if role is not specified
      });
    }
  }

  String? getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    var styleFrom = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(5),
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
                    margin: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                    padding: const EdgeInsets.all(10),
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
                              padding: EdgeInsets.all(10.0),
                              child: Text(
                                "Special Holiday Overtime",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        dateFilterSearchRow(context, styleFrom),
                        const Divider(),
                        _buildTable(),
                        const SizedBox(height: 10),
                        const Divider(),
                        const SizedBox(height: 5),
                        pagination(),
                        const SizedBox(height: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
                              const Text('Show entries: '),
                              Container(
                                width: 70,
                                height: 30,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade200)),
                                child: DropdownButton<int>(
                                  padding: const EdgeInsets.all(5),
                                  underline: const SizedBox(),
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
                            padding: const EdgeInsets.all(5),
                            underline: const SizedBox(),
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
                          child: ElevatedButton(
                            onPressed: () async {
                              await _computeAndAddToOvertimePay();
                            },
                            child: Text('Compute and Add to Overtime Pay'),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 400
                                : 100,
                            height: 30,
                            margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
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
                        Flexible(
                          child: Container(
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
                                  setState(() {
                                    filter = !filter;
                                  });
                                  filtermodal(
                                    context,
                                    styleFrom,
                                  );
                                },
                                child: MediaQuery.of(context).size.width > 800
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
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1,
                                                color: Colors.white),
                                          ),
                                        ],
                                      )
                                    : const Icon(
                                        Icons.filter_alt_outlined,
                                        color: Colors.white,
                                      ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
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
                    const SizedBox(
                      height: 130,
                    ),
                    AlertDialog(
                      surfaceTintColor: Colors.white,
                      content: SizedBox(
                        height: 200,
                        width: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
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
                            const Text('From :'),
                            _fromDate(context, styleFrom),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('To :'),
                            _toDate(context, styleFrom),
                            const SizedBox(
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
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, padding: const EdgeInsets.all(3)),
        onPressed: () {
          setState(() {
            toDate = null;
            fromDate = null;
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

  Flexible _toDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 150 : 50,
        padding: const EdgeInsets.all(2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        toDate != null
                            ? DateFormat('yyyy-MM-dd').format(toDate!)
                            : 'Select',
                        style: TextStyle(
                          color: endPicked == !true
                              ? Colors.black
                              : Colors.teal.shade800,
                        ),
                      )
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
            )),
      ),
    );
  }

  Flexible _fromDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 230 : 80,
        padding: const EdgeInsets.all(2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        fromDate != null
                            ? DateFormat('yyyy-MM-dd').format(fromDate!)
                            : 'Select',
                        style: TextStyle(
                          color: startPicked == !true
                              ? Colors.black
                              : Colors.teal.shade800,
                        ),
                      )
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
            )),
      ),
    );
  }

  Row pagination() {
    int pageNum = _currentPage + 1;
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Previous', style: TextStyle(color: Colors.teal[900])),
      ),
      const SizedBox(width: 10),
      Container(
          height: 35,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200)),
          child: Text('$pageNum')),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Next', style: TextStyle(color: Colors.teal[900])),
      ),
    ]);
  }

  Widget _buildDateFilter() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _selectDate2(context, true),
          child: Text(fromDate != null
              ? DateFormat('yyyy-MM-dd').format(fromDate!)
              : 'From'),
        ),
        ElevatedButton(
          onPressed: () => _selectDate2(context, false),
          child: Text(
              toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : 'To'),
        ),
        ElevatedButton(
          onPressed: () => setState(() {
            fromDate = null;
            toDate = null;
          }),
          child: Text('Show All'),
        ),
      ],
    );
  }

  Widget _buildTable() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('SpecialHolidayOT').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return _buildShimmerLoading();
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> overtimeDocs = _role == 'Employee'
              ? snapshot.data!.docs
                  .where((doc) => doc['userId'] == getCurrentUserId())
                  .toList()
              : snapshot.data!.docs;

          overtimeDocs = overtimeDocs.where((doc) {
            DateTime timeIn = doc['timeIn'].toDate();
            DateTime timeOut = doc['timeOut'].toDate();
            if (fromDate != null && toDate != null) {
              return timeIn.isAfter(fromDate!) &&
                  timeOut.isBefore(toDate!.add(const Duration(
                      days: 1))); // Adjusted toDate to include end of the day
            } else if (fromDate != null) {
              return timeIn.isAfter(fromDate!);
            } else if (toDate != null) {
              return timeOut.isBefore(toDate!.add(const Duration(
                  days: 1))); // Adjusted toDate to include end of the day
            }
            return true;
          }).toList();
          if (_searchController.text.isNotEmpty) {
            String searchText = _searchController.text.toLowerCase();
            overtimeDocs = overtimeDocs.where((doc) {
              String employeeId = doc['employeeId'].toString().toLowerCase();
              String userName = doc['userName'].toString().toLowerCase();
              return employeeId.contains(searchText) ||
                  userName.contains(searchText);
            }).toList();
          }
          _sortAscending
              ? overtimeDocs.sort((a, b) {
                  double overtimePayA = a['overtimePay'] ?? 0.0;
                  double overtimePayB = b['overtimePay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                })
              : overtimeDocs.sort((b, a) {
                  double overtimePayA = a['overtimePay'] ?? 0.0;
                  double overtimePayB = b['overtimePay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                });

          List<DocumentSnapshot> filteredDocuments = overtimeDocs;
          if (selectedDepartment != 'All') {
            filteredDocuments = overtimeDocs
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
            filteredDocuments.sort((a, b) {
              Timestamp aTimestamp = a['timeIn'];
              Timestamp bTimestamp = b['timeIn'];
              return bTimestamp.compareTo(aTimestamp);
            });
          }
          const textStyle = TextStyle(fontWeight: FontWeight.bold);

          var dataTable = DataTable(
            columns: [
              const DataColumn(
                  label: Flexible(child: Text('#', style: textStyle))),
              const DataColumn(
                  label: Flexible(
                child: Text('ID', style: textStyle),
              )),
              const DataColumn(
                  label: Flexible(child: Text('Name', style: textStyle))),
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
              const DataColumn(
                  label: Flexible(child: Text('Date', style: textStyle))),
              const DataColumn(
                  label: Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Overtime Hours',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
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
                          const Text('Overtime Pay',
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
              const DataColumn(
                  label: Flexible(
                child: Text('Overtime Type', style: textStyle),
              )),
              const DataColumn(
                  label: Flexible(
                child: Text('Action', style: textStyle),
              )),
            ],
            rows: List.generate(filteredDocuments.length, (index) {
              DocumentSnapshot overtimeDoc = filteredDocuments[index];
              Map<String, dynamic> overtimeData =
                  overtimeDoc.data() as Map<String, dynamic>;
              _selectedOvertimeTypes.add('Regular');
              FutureBuilder<double>(
                future: calculateSpecialHolidayOT(
                  overtimeData['userId'],
                  Duration(
                    hours: overtimeData['hours_overtime'],
                    minutes: overtimeData['minute_overtime'],
                  ),
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text(
                        'Calculating...'); // Or any loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    double overtimePay = snapshot.data ??
                        0; // Use snapshot.data, default to 0 if null
                    return Text(overtimePay.toStringAsFixed(2));
                  }
                },
              );
              Color? rowColor = indexRow % 2 == 0
                  ? Colors.white
                  : Colors.grey[200]; // Alternating row colors
              indexRow++; //

              // Extract timestamps for timeIn and timeOut
              Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
              Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

              // Calculate the duration between timeIn and timeOut
              Duration totalDuration = const Duration();
              if (timeInTimestamp != null && timeOutTimestamp != null) {
                DateTime timeIn = timeInTimestamp.toDate();
                DateTime timeOut = timeOutTimestamp.toDate();
                totalDuration = timeOut.difference(timeIn);
              }
              // Format the duration to display total hours
              String totalHoursAndMinutes =
                  '${totalDuration.inHours} hrs, ${totalDuration.inMinutes.remainder(60)} mins';

              return DataRow(
                  color: MaterialStateColor.resolveWith((states) => rowColor!),
                  cells: [
                    DataCell(Text((index + 1).toString())),
                    DataCell(Text(overtimeData['employeeId'])),
                    DataCell(
                      Text(overtimeData['userName'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['department'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(_formatDate(
                          overtimeData['timeIn'] ?? 'Not Available Yet')),
                    ),
                    DataCell(
                      Container(
                        width: 100,
                        padding: const EdgeInsets.fromLTRB(5, 2, 2, 5),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          border: Border.all(color: Colors.indigo.shade900),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(totalHoursAndMinutes),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        NumberFormat.currency(
                                locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                            .format(overtimeData['overtimePay'] ?? 0.0),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    _role == 'Employee'
                        ? DataCell(Text('Special Holiday OT'))
                        : DataCell(
                            DropdownButton<String>(
                              value: _selectedOvertimeTypes[0],
                              items: <String>[
                                'Special Holiday',
                                'Regular',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) async {
                                if (newValue == 'Regular') {
                                  await _showConfirmationDialog(overtimeDoc);
                                }
                                setState(() {
                                  _selectedOvertimeTypes[index] = newValue!;
                                });
                              },
                            ),
                          ),
                    DataCell(
                      Container(
                        width: 100,
                        padding: const EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _showConfirmationDialog4(overtimeDoc);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(5),
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
                                'View',
                                style: TextStyle(color: Colors.blue),
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

  Future<double> calculateSpecialHolidayOT(
    String userId,
    Duration duration,
  ) async {
    final daysInMonth = 22;
    final overTimeRate = 1.95;

    final daysWorked = duration.inDays;
    final overtimeHours = duration.inMinutes - 1 - (daysWorked * 8);

    try {
      var userData =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();
      double? monthlySalary = userData.data()?['monthly_salary'];

      if (monthlySalary == null) {
        // Return 0 if monthlySalary is null
        return 0;
      }

      double specialHolidayOTPay = 0;

      if (duration.inMinutes > 1) {
        specialHolidayOTPay =
            (monthlySalary / daysInMonth / 8 * overtimeHours * overTimeRate);
      }

      return specialHolidayOTPay;
    } catch (error) {
      print('Error retrieving monthly salary: $error');
      return 0;
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

  Future<void> deleteRecordFromSpecialOT(DocumentSnapshot overtimeDoc) async {
    try {
      await overtimeDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
  }

  Future<void> moveRecordToRegularOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.25;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance.collection('Overtime').add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> _showConfirmationDialog4(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('SpecialHolidayOT')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    int totalDays = 0;
    double totalHours = 0.0;
    double totalPays = 0.0;

    // Calculate total days, hours, and pays
    for (var overtimeDoc in userOvertimeDocs) {
      Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
      Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

      if (timeInTimestamp != null && timeOutTimestamp != null) {
        DateTime timeIn = timeInTimestamp.toDate();
        DateTime timeOut = timeOutTimestamp.toDate();
        Duration totalDuration = timeOut.difference(timeIn);

        totalDays++;
        totalHours += totalDuration.inHours + totalDuration.inMinutes / 60;
        totalPays += (overtimeDoc['overtimePay'] ?? 0.0);
      }
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Special Holiday Overtime Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 15,
                  )),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Employee ID',
                            overtimeDoc['employeeId'] ?? 'Not Available'),
                        _buildInfoRow2('Name           ',
                            overtimeDoc['userName'] ?? 'Not Available'),
                        _buildInfoRow('Department ',
                            overtimeDoc['department'] ?? 'Not Available'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildInfoRow3('# of Days', totalDays.toString()),
                        _buildInfoRow3(
                            'Total Hours', totalHours.toStringAsFixed(2)),
                        _buildInfoRow2(
                          'Total Pays',
                          NumberFormat.currency(
                                  locale: 'en_PH',
                                  symbol: '₱ ',
                                  decimalDigits: 2)
                              .format(totalPays ?? 0.0),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                _buildOvertimeTable(userOvertimeDocs),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Total Overtime Pay'),
              onPressed: () async {
                try {
                  // Show a loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  // Delay Firestore operations by a very short duration
                  await Future.delayed(Duration(milliseconds: 10));

                  // Calculate total overtime pay
                  double totalSHOTPay = 0;
                  for (var overtimeDoc in userOvertimeDocs) {
                    if (overtimeDoc['overtimePay'] != null) {
                      totalSHOTPay += overtimeDoc['overtimePay'];
                    }
                  }

                  // Update total_overtimePay in the Overtime collection
                  // Update total_overtimePay in the Overtime collection
                  DocumentReference userOvertimeDocRef = FirebaseFirestore
                      .instance
                      .collection('SpecialHolidayOTPay')
                      .doc(userId);

// Get user details
                  final userDoc = await FirebaseFirestore.instance
                      .collection('User')
                      .doc(userId)
                      .get();
                  final userData = userDoc.data() as Map<String, dynamic>;

// Check if the document exists
                  var docSnapshot = await userOvertimeDocRef.get();
                  if (docSnapshot.exists) {
                    // If the document exists, update it
                    await userOvertimeDocRef.update({
                      'total_specialOTPay': totalSHOTPay,
                      'employeeId': userData['employeeId'],
                      'userName':
                          '${userData['fname']} ${userData['mname']} ${userData['lname']}',
                      'department': userData['department'],
                    });
                  } else {
                    // If the document doesn't exist, create a new one
                    await userOvertimeDocRef.set({
                      'total_specialOTPay': totalSHOTPay,
                      'userId': userId,
                      'employeeId': userData['employeeId'],
                      'userName':
                          '${userData['fname']} ${userData['mname']} ${userData['lname']}',
                      'department': userData['department'],
                    });
                  }

                  // Dismiss the loading indicator
                  Navigator.of(context).pop();

                  // Dismiss the dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle any errors
                  print('Error updating total overtime pay: $e');
                  // Dismiss the loading indicator
                  Navigator.of(context).pop();
                  // Show an error message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: const Text(
                            'Failed to update total overtime pay. Please try again.'),
                        actions: [
                          TextButton(
                            child: const Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
            width: 100,
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Text(value)),
      ],
    );
  }

  Widget _buildInfoRow3(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
            width: 70,
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  Widget _buildInfoRow2(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        IntrinsicWidth(
          child: Container(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Text(value)),
        ),
      ],
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
      height: 300,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(
                label:
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Time In',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Time Out',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Total Hours (h:m)',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
              label: Text('Overtime Pay',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          rows: overtimeDocs.map((overtimeDoc) {
            Color? rowColor = index % 2 == 0
                ? Colors.grey[200]
                : Colors.transparent; // Alternating row colors
            index++;
            Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
            Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

            // Calculate the duration between timeIn and timeOut
            Duration totalDuration = Duration();
            if (timeInTimestamp != null && timeOutTimestamp != null) {
              DateTime timeIn = timeInTimestamp.toDate();
              DateTime timeOut = timeOutTimestamp.toDate();
              totalDuration = timeOut.difference(timeIn);
            }

            // Format the duration to display total hours
            String totalHoursAndMinutes =
                '${totalDuration.inHours} hrs, ${totalDuration.inMinutes.remainder(60)} mins';

            return DataRow(
                color: MaterialStateColor.resolveWith((states) => rowColor!),
                cells: [
                  DataCell(Text('$index')),
                  DataCell(Text(_formatDate(overtimeDoc['timeIn']))),
                  DataCell(Text(_formatTime(overtimeDoc['timeIn']))),
                  DataCell(Text(_formatTime(overtimeDoc['timeOut']))),
                  DataCell(
                    Container(
                        padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                        decoration: BoxDecoration(
                            color: Colors.teal[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade900)),
                        child: Text(totalHoursAndMinutes)),
                  ),
                  DataCell(
                    Text(
                      NumberFormat.currency(
                              locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                          .format(overtimeDoc['overtimePay'] ?? 0.0),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]);
          }).toList(),
        ),
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

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
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

  Future<void> _showConfirmationDialog(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
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
                await moveRecordToRegularOT(overtimeDoc);
                await deleteRecordFromSpecialOT(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _computeAndAddToOvertimePay() async {
    try {
      // Fetch all documents from RegularHolidayOT collection
      QuerySnapshot overtimeSnapshot =
          await FirebaseFirestore.instance.collection('SpecialHolidayOT').get();

      // Loop through each overtime document
      for (var overtimeDoc in overtimeSnapshot.docs) {
        String userId = overtimeDoc['userId'];

        // Fetch all overtime records for the current user
        QuerySnapshot userOvertimeSnapshot = await FirebaseFirestore.instance
            .collection('SpecialHolidayOT')
            .where('userId', isEqualTo: userId)
            .get();

        // Calculate total overtime pay for the current user
        double totalHOTPay = 0;
        for (var userOvertimeDoc in userOvertimeSnapshot.docs) {
          if (userOvertimeDoc['overtimePay'] != null) {
            totalHOTPay += userOvertimeDoc['overtimePay'];
          }
        }

        // Get user details
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();

        // Check if the user exists
        if (userSnapshot.exists) {
          final userData = userSnapshot.data() as Map<String, dynamic>;

          // Update total_overtimePay in the OvertimePay collection
          DocumentReference userOvertimeDocRef = FirebaseFirestore.instance
              .collection('SpecialHolidayOTPay')
              .doc(userId);

          // Update or create the document in RegularHolidayOTPay collection
          await userOvertimeDocRef.set({
            'total_specialHOTPay': totalHOTPay,
            'userId': userId,
            'employeeId': userData['employeeId'],
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department': userData['department'],
          });
        }
      }
      // Show a success message
      print('Total overtime pay computed and added to OvertimePay collection');
    } catch (e) {
      // Handle any errors
      print('Error computing and adding to OvertimePay collection: $e');
    }
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
