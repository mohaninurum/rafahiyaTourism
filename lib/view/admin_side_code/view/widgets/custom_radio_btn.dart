import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../const/color.dart';



class CustomRadioButton extends StatelessWidget {
  final String title;
  final String value;
  final String? groupValue;
  final Function(String) onChanged;
  final bool isDisabled; // ✅ new

  const CustomRadioButton({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.isDisabled = false, // ✅ default false
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: isDisabled ? null : () => onChanged(value), // ✅ disable tap
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.mainColor
              : Colors.transparent,
          border: Border.all(
            color: isDisabled
                ? Colors.grey // ✅ grey border if disabled
                : AppColors.mainColor,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDisabled
                ? Colors.grey // ✅ grey text if disabled
                : (isSelected ? Colors.white : AppColors.blackBackground),
          ),
        ),
      ),
    );
  }
}
