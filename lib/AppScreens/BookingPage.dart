import 'dart:async';

import 'package:airbnb/Models/AppConstants.dart';
import 'package:airbnb/Models/Postings.dart';
import 'package:flutter/material.dart';


class CalendarPage extends StatelessWidget {

  static final String routeName = '/calendarPageRoute';

  @override
  Widget build(BuildContext context) {
    return MyCalendarPage();
  }
}

class MyCalendarPage extends StatefulWidget {

  MyCalendarPage({Key key}) : super(key: key);

  @override
  _MyCalendarPageState createState() => _MyCalendarPageState();

}


class _MyCalendarPageState extends State<MyCalendarPage> {

  Posting posting;
  List<CalendarMonthWidget> _calendarWidgets = [];
  List<DateTime> selectedDates = [];
  List<DateTime> bookedDates = [];
  DateTime startDate;
  DateTime endDate;
  int _numCalendars = 0;

  void _setDate(DateTime dateTime) {
    if (selectedDates.contains(dateTime)) {
      selectedDates.remove(dateTime);
    } else {
      selectedDates.add(dateTime);
    }
    selectedDates.sort();
    print(selectedDates);
  }

  List<DateTime> getSelectedDates() {
    return this.selectedDates;
  }

  void _buildCalendarWidgets() {
    _calendarWidgets = [];
    selectedDates = [];
    setState(() {
      for (int i = 0; i < 13; i++) {
        _calendarWidgets.add(CalendarMonthWidget(monthIndex: i, setDate: _setDate, getSelectedDates: getSelectedDates, bookedDates: bookedDates));
      }
    });
  }

  void _loadBookedDates() {
    bookedDates = [];
    this.posting.loadBookings().whenComplete(() {
      List<DateTime> dates = [];
      this.posting.bookings.forEach((booking) {
        dates.addAll(booking.dates);
      });
      this.bookedDates = dates;
      print('booked dates: ${this.bookedDates}');

      _numCalendars = 13;
      _buildCalendarWidgets();
    });

//    bookedDates = [];
//    bookedDates.add(DateTime(2019, 8, 18));
//    bookedDates.add(DateTime(2019, 8, 19));
//    bookedDates.add(DateTime(2019, 8, 20));
//    bookedDates.add(DateTime(2019, 8, 29));
//    bookedDates.add(DateTime(2019, 8, 30));
//    print('booked dates: ${this.bookedDates}');
//    _buildCalendarWidgets();
  }

  void _makeBooking() {
    if (selectedDates.isEmpty) { return; }
    posting.makeBooking(selectedDates);
  }

  @override
  Widget build(BuildContext context) {
    if (this.posting == null) {
      this.posting = ModalRoute.of(context).settings.arguments;
      print('posting id = ${this.posting.id}');
      _loadBookedDates();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookings Page'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _buildCalendarWidgets();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.smallPadding,
          AppConstants.smallPadding,
          AppConstants.smallPadding,
          0.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: AppConstants.tinyPadding, bottom: AppConstants.tinyPadding),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Text('Sun'),
                  Text('Mon'),
                  Text('Tue'),
                  Text('Wed'),
                  Text('Thu'),
                  Text('Fri'),
                  Text('Sat'),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 1.7,
              child: PageView.builder(
                itemCount: _numCalendars,
                itemBuilder: (context, index) {
                  return _calendarWidgets[index];
                }),
            ),
            Padding(
              padding: EdgeInsets.only(top: AppConstants.mediumPadding),
              child: MaterialButton(
                onPressed: _makeBooking,
                child: Text('Book Now!'),
                minWidth: double.infinity,
                height: MediaQuery.of(context).size.height / 12,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CalendarMonthWidget extends StatefulWidget {

  final int monthIndex;
  final Function setDate;
  final Function getSelectedDates;
  final List<DateTime> bookedDates;

  CalendarMonthWidget({Key key, this.monthIndex, this.setDate, this.getSelectedDates, this.bookedDates}): super(key: key);

  @override
  _CalendarMonthWidgetState createState() => _CalendarMonthWidgetState();

}

class _CalendarMonthWidgetState extends State<CalendarMonthWidget> {

  int _currentMonthInt;
  int _currentYearInt;
  List<DateTime> selectedDates = [];
  List<MonthTile> _monthTiles = [];

  String _getMonth() {
    String monthString = _currentMonthInt.toString();
    if (monthString.length == 1) { monthString = "0" + monthString; }
    return AppConstants.months[monthString];
  }

  void _selectDayOfMonth(MonthTile monthTile) {
    setState(() {
      DateTime selectedDateTime = monthTile.date;
      if (selectedDates.contains(selectedDateTime)) {
        selectedDates.remove(selectedDateTime);
      } else {
        selectedDates.add(selectedDateTime);
      }
      widget.setDate(selectedDateTime);
    });
  }

  void _createMonthTiles() {
    setState(() {
      int daysInMonth = AppConstants.daysInMonths[_currentMonthInt];
      DateTime firstDayOfMonth = DateTime(_currentYearInt, _currentMonthInt, 1);
      int firstWeekdayOfMonth = firstDayOfMonth.weekday;
      for(int i = 0; i < firstWeekdayOfMonth; i++) {
        _monthTiles.add(MonthTile(date: null));
      }
      for(int i = 1; i <= daysInMonth; i++) {
        DateTime date = DateTime(_currentYearInt, _currentMonthInt, i);
        _monthTiles.add(MonthTile(date: date));
      }
    });
  }

  void _setInitialDateValues() {
    DateTime now = DateTime.now();
    _currentMonthInt = now.month;
    _currentMonthInt = (_currentMonthInt + widget.monthIndex) % 12;
    if (_currentMonthInt == 0) { _currentMonthInt = 12; }

    _currentYearInt = now.year;
    if (_currentMonthInt < now.month) { _currentYearInt += 1; }
  }

  void _setInitialSelectedDates() {
    setState(() {
      List<DateTime> dates = widget.getSelectedDates();
      dates.forEach((date) {
        selectedDates.add(date);
      });
    });
  }

  @override
  void initState() {
    _setInitialDateValues();
    _setInitialSelectedDates();
    _createMonthTiles();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppConstants.tinyPadding),
          child: Text(_getMonth()),
        ),
        GridView.builder(
          itemCount: _monthTiles.length,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            MonthTile monthTile = _monthTiles[index];
            if (monthTile.date == null) {
              return MaterialButton(
                onPressed: null,
                child: Text(""),
              );
            } else {
              if (widget.bookedDates.contains(monthTile.date)) {
                return MaterialButton(
                  onPressed: () {},
                  child: monthTile,
                  color: AppConstants.messageYellow,
                );
              }
              return MaterialButton(
                onPressed: () {
                  _selectDayOfMonth(_monthTiles[index]);
                },
                child: monthTile,
                color: selectedDates.contains(monthTile.date) ? AppConstants.messageBlue : Colors.white,
              );
            }
          }
        ),
      ],
    );
  }

}

class MonthTile extends StatelessWidget {

  final DateTime date;

  MonthTile({Key key, this.date}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(this.date == null ? "" : date.day.toString());
  }


}