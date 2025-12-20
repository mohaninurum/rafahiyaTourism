import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:google_fonts/google_fonts.dart';

class HijriDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDatePicked;

  const HijriDatePicker({
    super.key,
    required this.initialDate,
    required this.onDatePicked,
  });

  @override
  _HijriDatePickerState createState() => _HijriDatePickerState();
}

class _HijriDatePickerState extends State<HijriDatePicker> {
  late HijriCalendar _selectedHijriDate;

  @override
  void initState() {
    super.initState();
    _selectedHijriDate = HijriCalendar.fromDate(widget.initialDate);
  }

  void _goToPreviousMonth() {
    setState(() {
      if (_selectedHijriDate.hMonth == 1) {
        _selectedHijriDate.hMonth = 12;
        _selectedHijriDate.hYear -= 1;
      } else {
        _selectedHijriDate.hMonth -= 1;
      }
      _selectedHijriDate = HijriCalendar()
        ..hYear = _selectedHijriDate.hYear
        ..hMonth = _selectedHijriDate.hMonth
        ..hDay = 1;
    });
  }

  void _goToNextMonth() {
    setState(() {
      if (_selectedHijriDate.hMonth == 12) {
        _selectedHijriDate.hMonth = 1;
        _selectedHijriDate.hYear += 1;
      } else {
        _selectedHijriDate.hMonth += 1;
      }
      _selectedHijriDate = HijriCalendar()
        ..hYear = _selectedHijriDate.hYear
        ..hMonth = _selectedHijriDate.hMonth
        ..hDay = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Hijri Date', style: GoogleFonts.poppins()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select a Hijri date', style: GoogleFonts.poppins()),
          const SizedBox(height: 10),
          Text(
            '${_selectedHijriDate.hDay} ${_selectedHijriDate.longMonthName} ${_selectedHijriDate.hYear} AH',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goToPreviousMonth,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: _goToNextMonth,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onDatePicked(_selectedHijriDate as DateTime);
            Navigator.pop(context);
          },
          child: Text('Select', style: GoogleFonts.poppins()),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel', style: GoogleFonts.poppins()),
        ),
      ],
    );
  }
}
