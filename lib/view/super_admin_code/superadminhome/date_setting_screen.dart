import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/super_admin_home.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../const/color.dart';
import '../super_admin_navbar.dart';
import '../superadminprovider/hijri_date_provider/hijri_date_provider.dart';

class DateSettingsScreen extends StatefulWidget {
  const DateSettingsScreen({super.key});

  @override
  State<DateSettingsScreen> createState() => _DateSettingsScreenState();
}

class _DateSettingsScreenState extends State<DateSettingsScreen> {
  bool _isLoading = false;
  bool _isLoadingCountries = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final provider = Provider.of<HijriDateProvider>(context, listen: false);
    setState(() {
      _isLoadingCountries = true;
    });

    try {
      await provider.loadCountriesFromSubAdmins();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load countries: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCountries = false;
        });
      }
    }
  }

  void _openHijriCalendar(BuildContext context, HijriDateProvider provider) {
    final currentLocale = _getCurrentLocale(context);

    DateTime focusedDay = provider.selectedDate;
    CalendarFormat calendarFormat = CalendarFormat.month;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppStrings.getString('selectDate', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TableCalendar(
                    firstDay: DateTime(1900),
                    lastDay: DateTime(2100),
                    focusedDay: focusedDay,
                    calendarFormat: calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(provider.selectedDate, day),
                    onDaySelected: (selectedDay, newFocusedDay) {
                      provider.setDate(selectedDay);
                      Navigator.of(context).pop();
                    },
                    onFormatChanged: (format) {
                      setModalState(() {
                        calendarFormat = format;
                      });
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) {
                        final hijri = HijriCalendar.fromDate(day);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${day.day}'),
                            Flexible(
                              child: Text(
                                '${hijri.hDay} ${hijri.getLongMonthName()}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        );
                      },
                      selectedBuilder: (context, day, _) {
                        final hijri = HijriCalendar.fromDate(day);
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.mainColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              Flexible(
                                child: Text(
                                  '${hijri.hDay} ${hijri.getLongMonthName()}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveDateSettings(HijriDateProvider provider) async {
    final currentLocale = _getCurrentLocale(context);

    setState(() {
      _isLoading = true;
    });

    try {
      await provider.saveDateSettings();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.getString('hijriDateUpdatedFor', currentLocale)} ${provider.selectedCountry}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SuperAdminBottomNavigationBar()),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.getString('error', currentLocale)}: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HijriDateProvider>(context);
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('hijriDateSettings', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_isLoadingCountries)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getString('setHijriDateForCountries', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getString('selectCountrySetHijriDate', currentLocale),
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getString('selectCountry', currentLocale),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _isLoadingCountries
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : DropdownButton<String>(
                        isExpanded: true,
                        value: provider.selectedCountry,
                        hint: Text(
                          AppStrings.getString('chooseCountry', currentLocale),
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.mainColor,
                        ),
                        iconSize: 24,
                        elevation: 16,
                        underline: const SizedBox(),
                        style: GoogleFonts.poppins(color: Colors.black87),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            provider.setCountry(newValue);
                            provider.loadDateSettings(newValue);
                          }
                        },
                        items: provider.availableCountries.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    if (provider.availableCountries.isEmpty && !_isLoadingCountries)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'No countries found from sub-admins',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getString('currentHijriDate', currentLocale),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              provider.toHijri(provider.selectedDate),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mainColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onPressed: () => _openHijriCalendar(context, provider),
                          child: Text(
                            AppStrings.getString('selectDate', currentLocale),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.getString('dateConvertedToHijri', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (provider.selectedCountry != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : () => _saveDateSettings(provider),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    AppStrings.getString('saveDateSettings', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 40,
                    color: AppColors.mainColor,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('needHelp', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('contactSupportDateSettings', currentLocale),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}