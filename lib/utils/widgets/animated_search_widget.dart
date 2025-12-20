import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
class AnimatedSearchText extends StatefulWidget {
  final TextEditingController controller;

  const AnimatedSearchText({super.key, required this.controller});

  @override
  State<AnimatedSearchText> createState() => _AnimatedSearchTextState();
}

class _AnimatedSearchTextState extends State<AnimatedSearchText> {
  final List<String> _searchOptions = [
    'name',
    'masjid',
    'pincode'
  ];

  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
    widget.controller.addListener(_stopAnimationOnTextEntry);
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.controller.removeListener(_stopAnimationOnTextEntry);
    super.dispose();
  }

  void _startAnimation() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (widget.controller.text.isEmpty) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _searchOptions.length;
        });
      }
    });
  }

  void _stopAnimationOnTextEntry() {
    if (widget.controller.text.isNotEmpty && _timer.isActive) {
      _timer.cancel();
    } else if (widget.controller.text.isEmpty && !_timer.isActive) {
      _startAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        hintText: 'Search by ${_searchOptions[_currentIndex]}',
        hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      style: GoogleFonts.poppins(),
    );
  }
}