import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late MeetingDataSource _dataSource;

  @override
  void initState() {
    _dataSource = MeetingDataSource();
    _loadMeetingsFromFirestore(); // Load meetings from Firestore
    super.initState();
  }
  
  TextEditingController eventNameController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();
  TextEditingController endTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Syncfusion Calendar'),
      ),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: _dataSource,
        monthViewSettings: MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        onTap: (calendarTapDetails) {
          if (calendarTapDetails.targetElement ==
              CalendarElement.calendarCell) {
            _showAddAppointmentDialog(calendarTapDetails.date!);
          } else if (calendarTapDetails.targetElement ==
              CalendarElement.appointment) {
            final Meeting meeting =
                calendarTapDetails.appointments![0] as Meeting;
            _showEditAppointmentDialog(meeting);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAppointmentDialog(DateTime.now());
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _loadMeetingsFromFirestore() async {
    // Retrieve meetings from Firestore
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('meetings').get();

    List<Meeting> meetings = snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data()!;
      return Meeting(
        data['eventName'],
        (data['from'] as Timestamp).toDate(),
        (data['to'] as Timestamp).toDate(),
        Color(data['background']),
        data['isAllDay'],
      );
    }).toList();

    setState(() {
      _dataSource = MeetingDataSource(meetings);
    });
  }

  void _showAddAppointmentDialog(DateTime selectedDate) {
    eventNameController.text = '';
    startTimeController.text = selectedDate.toString();
    endTimeController.text = selectedDate.add(Duration(hours: 1)).toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAppointmentDialog(null);
      },
    );
  }

  void _showEditAppointmentDialog(Meeting meeting) {
    eventNameController.text = meeting.eventName;
    startTimeController.text = meeting.from.toString();
    endTimeController.text = meeting.to.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _buildAppointmentDialog(meeting);
      },
    );
  }

  void _showAppointmentDetailsDialog(Meeting meeting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event Name: ${meeting.eventName}'),
              Text('Start Time: ${meeting.from}'),
              Text('End Time: ${meeting.to}'),
              Text('All-Day: ${meeting.isAllDay ? 'Yes' : 'No'}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentDialog(Meeting? meeting) {
    return AlertDialog(
      title: Text(meeting != null ? 'Edit Appointment' : 'Add Appointment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: eventNameController,
            decoration: InputDecoration(labelText: 'Event Name'),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => _selectDate(startTimeController),
                child: Text('Select Start Time'),
              ),
              ElevatedButton(
                onPressed: () => _selectDate(endTimeController),
                child: Text('Select End Time'),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        if (meeting != null) // Only show delete button if editing
          TextButton(
            onPressed: () {
              _dataSource.deleteMeeting(meeting);
              _deleteMeetingFromFirestore(
                  meeting); // Call function to delete from Firestore
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
        TextButton(
          onPressed: () {
            if (eventNameController.text.isEmpty) {
              // Show error message if event name is empty
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Event name cannot be empty'),
                  duration: Duration(seconds: 2),
                ),
              );
              return; // Return without adding or updating the meeting
            }

            final newMeeting = Meeting(
              eventNameController.text,
              DateTime.parse(startTimeController.text),
              DateTime.parse(endTimeController.text),
              meeting != null
                  ? meeting.background
                  : Colors
                      .blue, // Use existing color if editing, otherwise default to blue
              false,
            );

            if (meeting != null) {
              // If editing, update the existing meeting
              _dataSource.updateMeeting(meeting, newMeeting);
            } else {
              // If adding, add a new meeting
              _dataSource.addMeeting(newMeeting);
            }

            // Add or update meeting in Firestore
            if (meeting != null) {
              _updateMeetingInFirestore(meeting, newMeeting);
            } else {
              _saveMeetingToFirestore(newMeeting);
            }

            Navigator.of(context).pop();
          },
          child: Text(meeting != null ? 'Update' : 'Add'),
        ),
        if (meeting != null)
        TextButton(
          onPressed: () => _showAppointmentDetailsDialog(meeting),
          child: const Text("View"),
        )
      ],
    );
  }

  void _selectDate(TextEditingController controller) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != controller.text) {
      setState(() {
        controller.text = pickedDate.toString();
      });
    }
  }
  
  void _saveMeetingToFirestore(Meeting meeting) {
    FirebaseFirestore.instance.collection('meetings').add({
      'eventName': meeting.eventName,
      'from': meeting.from,
      'to': meeting.to,
      'background': meeting.background.value,
      'isAllDay': meeting.isAllDay,
    });
  }

  void _updateMeetingInFirestore(Meeting oldMeeting, Meeting newMeeting) {
    FirebaseFirestore.instance
        .collection('meetings')
        .where('eventName', isEqualTo: oldMeeting.eventName)
        .where('from', isEqualTo: oldMeeting.from)
        .where('to', isEqualTo: oldMeeting.to)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        FirebaseFirestore.instance.collection('meetings').doc(doc.id).update({
          'eventName': newMeeting.eventName,
          'from': newMeeting.from,
          'to': newMeeting.to,
          'background': newMeeting.background.value,
          'isAllDay': newMeeting.isAllDay,
        });
      }
    });
  }

  void _deleteMeetingFromFirestore(Meeting meeting) {
    FirebaseFirestore.instance
        .collection('meetings')
        .where('eventName', isEqualTo: meeting.eventName)
        .where('from', isEqualTo: meeting.from)
        .where('to', isEqualTo: meeting.to)
        .get()
        .then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        FirebaseFirestore.instance.collection('meetings').doc(doc.id).delete();
      }
    });
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource([List<Meeting>? source]) {
    appointments = source ?? <Meeting>[];
  }

  void addMeeting(Meeting meeting) {
    appointments!.add(meeting);
    notifyListeners(CalendarDataSourceAction.add, <Meeting>[meeting]);
  }

  void deleteMeeting(Meeting meeting) {
    appointments!.remove(meeting);
    notifyListeners(CalendarDataSourceAction.remove, <Meeting>[meeting]);
  }

  void updateMeeting(Meeting oldMeeting, Meeting newMeeting) {
    final index = appointments!.indexOf(oldMeeting);
    appointments![index] = newMeeting;
    notifyListeners(CalendarDataSourceAction.remove, <Meeting>[oldMeeting]);
    notifyListeners(CalendarDataSourceAction.add, <Meeting>[newMeeting]);
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }
}

class Meeting {
  Meeting(
    this.eventName,
    this.from,
    this.to,
    this.background,
    this.isAllDay,
  );

  String eventName;
  DateTime from;
  DateTime to;
  Color background;
  bool isAllDay;
}