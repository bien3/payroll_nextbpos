import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/userTimeInToday.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.teal.shade700,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: Column(
                    children: [
                      Flexible(
                        flex: MediaQuery.of(context).size.width > 800 ? 1 : 3,
                        child: MediaQuery.of(context).size.width > 800
                            ? Row(
                                children: [
                                  Expanded(
                                      child: smallContainer(
                                          '416',
                                          Icons.supervisor_account_rounded,
                                          'Total Employees')),
                                  Expanded(
                                      child: smallContainer(
                                          '360', Icons.access_time, 'On Time')),
                                  Expanded(
                                      child: smallContainer(
                                          '62',
                                          Icons.more_time_sharp,
                                          'Late Arrival')),
                                  Expanded(
                                    child: smallContainer(
                                        '360', Icons.list_alt, 'Check Out'),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: smallContainer(
                                              '416',
                                              Icons.supervisor_account_rounded,
                                              'Total Employees')),
                                      Expanded(
                                          child: smallContainer('360',
                                              Icons.access_time, 'On Time')),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: smallContainer(
                                              '62',
                                              Icons.more_time_sharp,
                                              'Late Arrival')),
                                      Expanded(
                                        child: smallContainer(
                                            '360', Icons.list_alt, 'Check Out'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                      Expanded(
                        flex: MediaQuery.of(context).size.width > 800 ? 5 : 7,
                        child: MediaQuery.of(context).size.width > 1100
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            margin: EdgeInsets.fromLTRB(
                                                10, 10, 10, 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                    child: UserTimedInToday()),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 0),
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 15, 0),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  30, 10, 20, 30),
                                              child: GestureDetector(
                                                onTap: () {
                                                  _navigateToCalendarPageWithDialog(
                                                      context);
                                                },
                                                child: CalendarPage(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                child: Column(
                                  children: [
                                    Flexible(
                                      flex: 3,
                                      child: Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(8),
                                                margin: EdgeInsets.fromLTRB(
                                                    10, 0, 10, 10),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    Expanded(
                                                        child:
                                                            UserTimedInToday()),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        margin:
                                            EdgeInsets.fromLTRB(10, 0, 10, 10),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            _navigateToCalendarPageWithDialog(
                                                context);
                                          },
                                          child:
                                              SizedBox(child: CalendarPage()),
                                        ),
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
            ],
          ),
        ),
      ),
    );
  }

  Container flexcontainer(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.blue.shade300.withOpacity(1),
          ),
          Text(
            text,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget smallContainer(String total, IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                total,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Icon(
                icon,
                size: 30,
                color: Colors.blue.shade300.withOpacity(1),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(title),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget smallContainer2(String total, IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                total,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Icon(
                icon,
                size: 30,
                color: Colors.blue.shade300.withOpacity(1),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }

  void _navigateToCalendarPageWithDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child:
              CalendarPage(), // Replace CalendarPage() with your dialog content
        );
      },
    );
  }
}
