import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';

import '../../provider/notification_provider.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: AppColors.mainColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<NotificationSettingsProvider>(
            builder: (context, provider, child) {
              final allSelected = provider.daySelection.values.every((val) => val);
              return TextButton(
                onPressed: () {
                  provider.toggleAllDays(!allSelected);
                },
                child: Text(
                  allSelected ? 'Deselect All' : 'Select All',
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 22, right: 22, top: 10),
        child: Consumer<NotificationSettingsProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    children: provider.daySelection.keys.map((day) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              day,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            Checkbox(
                              value: provider.daySelection[day],
                              onChanged: (bool? value) {
                                provider.updateDaySelection(day, value!);
                              },
                              activeColor: AppColors.mainColor,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      final selectedDays = provider.getSelectedDays();
                      Navigator.pop(context, selectedDays);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(
                      'Save Days',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}