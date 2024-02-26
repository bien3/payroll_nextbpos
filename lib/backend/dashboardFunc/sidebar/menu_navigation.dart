import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/check_in_out_logs.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_user_create.dart';
import 'package:project_payroll_nextbpo/frontend/mobileHomeScreen.dart';

class ScreensView extends StatelessWidget {
  final String menu;
  const ScreensView({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (menu) {
      case 'Dashboard':
        page = buildDashboardPage(context);
        break;
      case 'Overtime':
        page = const Center(
          child: Text(
            "Dart Page",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
        );
        break;
      case 'Regular (OT)':
        page = const Center(
          child: Text(
            "Regular OT",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
        );
        break;
      case 'Add Account':
        page = buildAddAccountPage();
        break;
      default:
        page = const Center(
          child: Text(
            "Other Page",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
        );
    }
    return page;
  }

  Widget buildDashboardPage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard Page",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  width: 20,
                ), // Add spacing between MobileHomeScreen and CalendarPage
                Expanded(
                  flex: 2, // Adjust flex factor as needed
                  child: GestureDetector(
                    onTap: () {
                      _navigateToCalendarPageWithDialog(context);
                    },
                    child: CalendarPage(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Logs(),
          ),
        ],
      ),
    );
  }

  Widget buildAddAccountPage() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Account",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: PovUser(),
          ),
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