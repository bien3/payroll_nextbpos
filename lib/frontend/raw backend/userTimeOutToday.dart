import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserTimedOutToday extends StatefulWidget {
  @override
  _UserTimedOutTodayState createState() => _UserTimedOutTodayState();
}

class _UserTimedOutTodayState extends State<UserTimedOutToday> {
  late Stream<QuerySnapshot> _userRecordsStream;

  @override
  void initState() {
    super.initState();
    _fetchUserTimedOutToday();
  }

  void _fetchUserTimedOutToday() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    _userRecordsStream = FirebaseFirestore.instance
        .collection('Records')
        .where('timeOut',
            isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
        .orderBy('timeOut', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Timed Out Today'),
      ),
      body: TimeoutTable(),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> TimeoutTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userRecordsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No users timed in today.'),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        final int rowsPerPage = 10; // Number of rows per page

        return DataTable(
          columns: const [
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Time-In',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Department',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: List<DataRow>.generate(
            documents.length,
            (index) {
              final document = documents[index];
              return DataRow(
                cells: [
                  DataCell(Text(document['userName'].toString())),
                  DataCell(Text(document['timeIn'].toString())),
                  DataCell(Text(document['department'].toString())),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _UserRecordsDataSource extends DataTableSource {
  final BuildContext context;
  final List<QueryDocumentSnapshot> documents;

  _UserRecordsDataSource(this.context, this.documents);

  @override
  DataRow getRow(int index) {
    final Map<String, dynamic> data =
        documents[index].data() as Map<String, dynamic>;

    return DataRow(cells: [
      DataCell(Text(data['userName'])),
      DataCell(Text(_formatTimestamp(data['timeOut']))),
      DataCell(Text(data['department'])),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => documents.length;

  @override
  int get selectedRowCount => 0;
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
