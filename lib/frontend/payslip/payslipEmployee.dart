import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/payslip/payslip_page.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class PayslipEmployee extends StatefulWidget {
  PayslipEmployee({super.key});

  @override
  State<PayslipEmployee> createState() => _PayslipEmployeeState();
}

class _PayslipEmployeeState extends State<PayslipEmployee> {
  TextEditingController _searchController = TextEditingController();

  int _currentPage = 0;
  bool viewTable = true;
  String selectedDepartment = 'All';
  DateTime? fromDate;
  DateTime? toDate;
  List<PayslipData> payrollData = [];

  @override
  Widget build(BuildContext context) {
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
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Payslip",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        _buildDataTable(),
                        const Divider(),
                        const SizedBox(height: 5),
                        Pagination(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('ArchivesPayslip')
          .where('userId',
              isEqualTo: FirebaseAuth
                  .instance.currentUser!.uid) // Filter payslip data by user ID
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> payslipDocs = snapshot.data!.docs;

          // Filter payrollDocs based on search text
          List<DocumentSnapshot> filteredPayrollDocs = _searchController
                  .text.isNotEmpty
              ? payslipDocs.where((doc) {
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
                  payslipDocs); // Copying the list if no search text to maintain original data

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
                                  const DataColumn(
                                      label: Text('Department',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  const DataColumn(
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

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(Text(payrollData['employeeId'] ??
                                          'Not Available Yet')),
                                      DataCell(Text(payrollData['fullname'] ??
                                          'Not Available Yet')),
                                      DataCell(Text(payrollData['department'] ??
                                          'Not Available Yet')),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: Colors.blue),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Payroll Details'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                child:
                                                                    DataTable(
                                                                  columns: const [
                                                                    DataColumn(
                                                                      label:
                                                                          Text(
                                                                        'EARNINGS',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            letterSpacing: 1),
                                                                      ),
                                                                    ),
                                                                    DataColumn(
                                                                        label: Text(
                                                                            'Hours')),
                                                                    DataColumn(
                                                                        label: Text(
                                                                            'Amount')),
                                                                  ],
                                                                  rows: [
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Basic Salary')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['monthly_salary'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                          Text(
                                                                              'Night Differential'),
                                                                        ),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['night_differential'] ?? 0)
                                                                              .toString(),
                                                                        )),
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Overtime')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['overAllOTPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('RDOT')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['restdayOTPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Regular Holiday')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['holidayPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Special Holiday')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['specialHPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Standy Allowance')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['standy_allowance'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Other PRemium Pay')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['other_prem_pay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Allowance')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['allowance'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Salary Adjustment')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['salary_adjustment'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('OT Adjustment')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['ot_adjustment'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Referral Bonus')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['referral_bonus'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Signing Bonus')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['signing_bonus'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(Text(
                                                                            'GROSS PAY',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold))),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['grossPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        10,
                                                                        0),
                                                                height: 700,
                                                                width:
                                                                    1, // Adjust the width as needed
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              Container(
                                                                child:
                                                                    DataTable(
                                                                  columns: const [
                                                                    DataColumn(
                                                                        label:
                                                                            Text(
                                                                      'DEDUCTIONS',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              18,
                                                                          letterSpacing:
                                                                              1),
                                                                    )),
                                                                    DataColumn(
                                                                      label: Text(
                                                                          'Amount'),
                                                                    ),
                                                                  ],
                                                                  rows: [
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('LWOP / Tardiness')),
                                                                        DataCell(
                                                                            Text('0'))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('SSS Contribution')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['sss_contribution'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Pag-ibig Contribution')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['pagibig_contribution'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('PHIC Contribution')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['phic_contribution'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Witholding Tax')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['witholding_tax'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('SSS Loan')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['sss_loan'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Pag-ibig Loan')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['pagibig_loan'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Advances: Eyecrafter')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['advances_eyecrafter'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Advances: Amesco')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['advances_amesco'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Advances: Insular')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['advances_insular'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Vitalab / BMCDC')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['vitalab_bmcdc'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Other Advances')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['other_advanaces'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(''))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(Text(
                                                                            'TOTAL DEDUCTIONS',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold))),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['total_deduction'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        10,
                                                                        0),
                                                                height: 700,
                                                                width:
                                                                    1, // Adjust the width as needed
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              Container(
                                                                width: 250,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Text(
                                                                        'SUMMARY',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          letterSpacing:
                                                                              1,
                                                                        )),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Gross Pay: ',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Text(
                                                                          (payrollData['grossPay'] ?? 0)
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Total Deductions: ',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Text(
                                                                          (payrollData['total_deduction'] ?? 0)
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Divider(),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'NET PAY: ',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Text(
                                                                          (payrollData['netPay'] ?? 0)
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            580),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          // Add more details as needed
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Close'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
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
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Row Pagination() {
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
          child: Text(
            '$pageNum',
          )),
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
              label:
                  Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
