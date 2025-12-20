import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import '../../../const/color.dart';
import '../superadminprovider/super_admin_salah_provider/super_admin_salah_provider.dart';

class SalahClockScreen extends StatefulWidget {
  final String? initialMasjidId;
  final String? initialMasjidName;

  const SalahClockScreen({super.key, this.initialMasjidId, this.initialMasjidName});

  @override
  State<SalahClockScreen> createState() => _SalahClockScreenState();
}

class _SalahClockScreenState extends State<SalahClockScreen> {
  late final SuperAdminSalahProvider _mosqueProvider;
  String? _currentMasjidId;
  String? _currentMasjidName;
  Map<String, dynamic>? _currentMasjidData;
  Map<String, Map<String, String>> _prayerTimes = {};
  Map<String, String> _eidFitrTimes = {};
  Map<String, String> _eidAdhaTimes = {};

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _prayerTimesSubscription;
  StreamSubscription? _eidFitrSubscription;
  StreamSubscription? _eidAdhaSubscription;

  String hijriDate = '15 Ramadan 1444';
  String gregorianDate = 'April 6, 2023';

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _mosqueProvider = Provider.of<SuperAdminSalahProvider>(
      context,
      listen: false,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mosqueProvider.startListening();
    });

    _currentMasjidId = widget.initialMasjidId;
    _currentMasjidName = widget.initialMasjidName;
  }

  void _selectMosque(Map<String, dynamic> mosque) {
    setState(() {
      _currentMasjidId = mosque['id'];
      _currentMasjidName = mosque['name'];
      _currentMasjidData = mosque['data'];
      _prayerTimes = {};
      _eidFitrTimes = {};
      _eidAdhaTimes = {};
    });

    _prayerTimesSubscription?.cancel();
    _eidFitrSubscription?.cancel();
    _eidAdhaSubscription?.cancel();

    if (_currentMasjidId != null) {
      print('Listening for prayer times for mosque: $_currentMasjidId');

      _prayerTimesSubscription = _firestore
          .collection('mosques')
          .doc(_currentMasjidId)
          .collection('namazTimings')
          .snapshots()
          .listen((snapshot) {
        final Map<String, Map<String, String>> updatedTimes = {};
        print('Received ${snapshot.docs.length} prayer time documents');

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final prayerName = data['namazName'] ?? doc.id;
          print('Prayer: $prayerName, Data: $data');

          updatedTimes[prayerName] = {
            'azaan': data['azaanTime'] ?? '',
            'jammat': data['jammatTime'] ?? '',
            'awwal': data['awwalTime'] ?? '',
            'akhir': data['akhirTime'] ?? '',
          };
        }

        print('Updated prayer times: $updatedTimes');

        if (mounted) {
          setState(() {
            _prayerTimes = updatedTimes;
          });
        }
      }, onError: (error) {
        print('Error listening to prayer times: $error');
      });

      _eidFitrSubscription = _firestore
          .collection('mosques')
          .doc(_currentMasjidId)
          .collection('specialTimings')
          .doc('eidulfitr')
          .snapshots()
          .listen((snapshot) {
        print('Eid ul-Fitr snapshot: ${snapshot.exists}');
        if (snapshot.exists) {
          final data = snapshot.data()!;
          print('Eid ul-Fitr data: $data');
          if (mounted) {
            setState(() {
              _eidFitrTimes = {
                'Jamat 1': data['jammat1'] ?? '',
                'Jamat 2': data['jammat2'] ?? '',
              };
            });
          }
        }
      }, onError: (error) {
        print('Error listening to Eid ul-Fitr times: $error');
      });

      _eidAdhaSubscription = _firestore
          .collection('mosques')
          .doc(_currentMasjidId)
          .collection('specialTimings')
          .doc('eidulazha')
          .snapshots()
          .listen((snapshot) {
        print('Eid ul-Adha snapshot: ${snapshot.exists}');
        if (snapshot.exists) {
          final data = snapshot.data()!;
          print('Eid ul-Adha data: $data');
          if (mounted) {
            setState(() {
              _eidAdhaTimes = {
                'Jamat 1': data['jammat1'] ?? '',
                'Jamat 2': data['jammat2'] ?? '',
              };
            });
          }
        }
      }, onError: (error) {
        print('Error listening to Eid ul-Adha times: $error');
      });
    }
  }

  @override
  void dispose() {
    _mosqueProvider.stopListening();
    _prayerTimesSubscription?.cancel();
    _eidFitrSubscription?.cancel();
    _eidAdhaSubscription?.cancel();
    super.dispose();
  }

  void _showMasjidSelectionDialog() {
    final currentLocale = _getCurrentLocale(context);

    showDialog(
      context: context,
      builder: (context) => Consumer<SuperAdminSalahProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.mosques.isEmpty) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Center(
                child: Text(
                  AppStrings.getString('noMosquesAvailable', currentLocale),
                  style: GoogleFonts.poppins(

                  ),
                ),
              ),
              content: Text(
                AppStrings.getString('contactAdmin', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.getString('ok', currentLocale),
                    style: GoogleFonts.poppins(color: AppColors.mainColor),
                  ),
                ),
              ],
            );
          }

          return AlertDialog(
            backgroundColor: Colors.white,
            title: Center(
              child: Text(
                  AppStrings.getString('selectMasjid', currentLocale),
                  style: GoogleFonts.poppins()
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.mosques.length,
                itemBuilder: (context, index) {
                  final mosque = provider.mosques[index];
                  return ListTile(
                    title: Text(mosque['name'], style: GoogleFonts.poppins()),
                    leading: Icon(Icons.mosque, color: AppColors.mainColor),
                    onTap: () {
                      _selectMosque(mosque);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            actions: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Text(
                  AppStrings.getString('cancel', currentLocale),
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: InkWell(
          onTap: _showMasjidSelectionDialog,
          child: Text(
            _currentMasjidName ?? AppStrings.getString('selectMasjid', currentLocale),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppStrings.getString('prayerTimesUpdated', currentLocale),
                    style: GoogleFonts.poppins(),
                  ),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<SuperAdminSalahProvider>(
        builder: (context, provider, child) {
          if (_currentMasjidId == null && provider.mosques.isNotEmpty && !provider.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _selectMosque(provider.mosques.first);
            });
          }

          // Handle loading state
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle no mosques available
          if (provider.mosques.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.mosque_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('noMosquesAvailable', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('contactAdmin', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Handle no mosque selected but mosques are available
          if (_currentMasjidId == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMosqueClock(currentLocale),
                const SizedBox(height: 24),
                _buildDateDisplay(currentLocale),
                const SizedBox(height: 24),
                _buildPrayerTimesList(currentLocale),
                const SizedBox(height: 24),
                _buildEidPrayerSection(currentLocale),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMosqueClock(String currentLocale) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.2,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: _showMasjidSelectionDialog,
            child: Text(
              _currentMasjidName ?? AppStrings.getString('selectMasjid', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.whiteBackground,
              ),
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              return Text(
                _formatTime(DateTime.now()),
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.whiteBackground,
                ),
              );
            },
          ),
          Text(
            _formatDate(DateTime.now()),
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildDateDisplay(String currentLocale) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.mainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            hijriDate,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.mainColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            gregorianDate,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesList(String currentLocale) {
    print('Building prayer times list with data: $_prayerTimes');

    // Define all possible prayer names
    final defaultPrayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha', 'Jumuah'];

    // Get all prayer names that actually exist in the data
    final existingPrayerNames = _prayerTimes.keys.toList();

    // Use existing prayers if available, otherwise use default order
    final prayersToDisplay = existingPrayerNames.isNotEmpty ? existingPrayerNames : defaultPrayerOrder;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppStrings.getString('dailyPrayerTimes', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
            ),
          ),
          if (prayersToDisplay.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                AppStrings.getString('noPrayerTimesSet', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey),
              ),
            )
          else
            ...prayersToDisplay.map((prayerName) {
              final times = _prayerTimes[prayerName] ?? {
                'azaan': AppStrings.getString('notSet', currentLocale),
                'jammat': AppStrings.getString('notSet', currentLocale),
                'awwal': AppStrings.getString('notSet', currentLocale),
                'akhir': AppStrings.getString('notSet', currentLocale),
              };
              return _buildPrayerTimeItem(prayerName, times, currentLocale);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeItem(String name, Map<String, String> times, String currentLocale) {
    final hasData = times['azaan'] != AppStrings.getString('notSet', currentLocale) ||
        times['jammat'] != AppStrings.getString('notSet', currentLocale) ||
        (times['awwal'] != null && times['awwal']!.isNotEmpty && times['awwal'] != AppStrings.getString('notSet', currentLocale)) ||
        (times['akhir'] != null && times['akhir']!.isNotEmpty && times['akhir'] != AppStrings.getString('notSet', currentLocale));

    return ExpansionTile(
      title: Text(
        _formatPrayerName(name, currentLocale),
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: hasData ? Colors.black : Colors.grey,
        ),
      ),
      children: [
        _buildTimeFieldItem(
            AppStrings.getString('azaan', currentLocale),
            times['azaan'] ?? AppStrings.getString('notSet', currentLocale),
            name,
            'azaan',
            hasData,
            currentLocale
        ),
        _buildTimeFieldItem(
            AppStrings.getString('jammat', currentLocale),
            times['jammat'] ?? AppStrings.getString('notSet', currentLocale),
            name,
            'jammat',
            hasData,
            currentLocale
        ),
        if (times['awwal'] != null && times['awwal']!.isNotEmpty && times['awwal'] != AppStrings.getString('notSet', currentLocale))
          _buildTimeFieldItem(
              AppStrings.getString('awwal', currentLocale),
              times['awwal']!,
              name,
              'awwal',
              hasData,
              currentLocale
          ),
        if (times['akhir'] != null && times['akhir']!.isNotEmpty && times['akhir'] != AppStrings.getString('notSet', currentLocale))
          _buildTimeFieldItem(
              AppStrings.getString('akhir', currentLocale),
              times['akhir']!,
              name,
              'akhir',
              hasData,
              currentLocale
          ),
      ],
    );
  }

  String _formatPrayerName(String name, String currentLocale) {
    // Format prayer names for display
    final nameMap = {
      'jammat 1': AppStrings.getString('jumuahJamat1', currentLocale),
      'jammat 2': AppStrings.getString('jumuahJamat2', currentLocale),
      'jammat1': AppStrings.getString('jumuahJamat1', currentLocale),
      'jammat2': AppStrings.getString('jumuahJamat2', currentLocale),
      'fajr': AppStrings.getString('fajr', currentLocale),
      'sunrise': AppStrings.getString('sunrise', currentLocale),
      'dhuhr': AppStrings.getString('dhuhr', currentLocale),
      'asr': AppStrings.getString('asr', currentLocale),
      'maghrib': AppStrings.getString('maghrib', currentLocale),
      'isha': AppStrings.getString('isha', currentLocale),
      'jumuah': AppStrings.getString('jumuah', currentLocale),
    };

    // Convert to lowercase first, then check the map, then capitalize properly
    final lowerName = name.toLowerCase();
    if (nameMap.containsKey(lowerName)) {
      return nameMap[lowerName]!;
    }

    return name[0].toUpperCase() + name.substring(1).toLowerCase();
  }

  Widget _buildTimeFieldItem(String fieldName, String time, String prayerName, String fieldType, bool hasData, String currentLocale) {
    return ListTile(
      title: Text(
        fieldName,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: hasData ? Colors.black : Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time.isEmpty ? AppStrings.getString('notSet', currentLocale) : time,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: time.isEmpty ? Colors.grey : Colors.grey[800],
            ),
          ),
          const SizedBox(width: 8),
          if (hasData) // Only show edit button if data exists
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.mainColor, size: 18),
              onPressed: () => _editTime(prayerName, fieldType, time, currentLocale),
            ),
        ],
      ),
    );
  }

  Future<void> _editTime(String prayerName, String fieldType, String currentTime, String currentLocale) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 12, minute: 0);

    if (currentTime.isNotEmpty && currentTime != AppStrings.getString('notSet', currentLocale)) {
      final timeParts = currentTime.split(' ');
      if (timeParts.length == 2) {
        final hourMinute = timeParts[0].split(':');
        final period = timeParts[1];

        try {
          initialTime = TimeOfDay(
            hour: period == 'PM'
                ? (int.parse(hourMinute[0]) % 12) + 12
                : int.parse(hourMinute[0]) % 12,
            minute: int.parse(hourMinute[1]),
          );
        } catch (e) {
          // If parsing fails, use default time
          initialTime = const TimeOfDay(hour: 12, minute: 0);
        }
      }
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && _currentMasjidId != null) {
      final formattedTime = _formatTimeOfDay(pickedTime);
      await _mosqueProvider.updatePrayerTime(
          _currentMasjidId!,
          prayerName,
          '${fieldType}Time',
          formattedTime
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_formatPrayerName(prayerName, currentLocale)} $fieldType ${AppStrings.getString('timeUpdatedTo', currentLocale)} $formattedTime',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Widget _buildEidPrayerSection(String currentLocale) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              AppStrings.getString('eidPrayerTimes', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                AppStrings.getString('eidAlFitr', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          _buildEidPrayerTimeItem('Eid al-Fitr', 'Jamat 1', _eidFitrTimes['Jamat 1'] ?? '', currentLocale),
          _buildEidPrayerTimeItem('Eid al-Fitr', 'Jamat 2', _eidFitrTimes['Jamat 2'] ?? '', currentLocale),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                AppStrings.getString('eidAlAdha', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          _buildEidPrayerTimeItem('Eid al-Adha', 'Jamat 1', _eidAdhaTimes['Jamat 1'] ?? '', currentLocale),
          _buildEidPrayerTimeItem('Eid al-Adha', 'Jamat 2', _eidAdhaTimes['Jamat 2'] ?? '', currentLocale),
        ],
      ),
    );
  }

  Widget _buildEidPrayerTimeItem(String eidType, String jamatName, String time, String currentLocale) {
    final hasData = time.isNotEmpty && time != AppStrings.getString('notSet', currentLocale);

    return ListTile(
      title: Text(
        jamatName,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          color: hasData ? Colors.black : Colors.grey,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            time.isEmpty ? AppStrings.getString('notSet', currentLocale) : time,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: time.isEmpty ? Colors.grey : Colors.grey[800],
            ),
          ),
          const SizedBox(width: 8),
          if (hasData) // Only show edit button if data exists
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.mainColor, size: 20),
              onPressed: () => _editEidTime(eidType, jamatName, time, currentLocale),
            ),
        ],
      ),
    );
  }

  Future<void> _editEidTime(String eidType, String jamatName, String currentTime, String currentLocale) async {
    TimeOfDay initialTime = const TimeOfDay(hour: 12, minute: 0);

    if (currentTime.isNotEmpty && currentTime != AppStrings.getString('notSet', currentLocale)) {
      final timeParts = currentTime.split(' ');
      if (timeParts.length == 2) {
        final hourMinute = timeParts[0].split(':');
        final period = timeParts[1];

        try {
          initialTime = TimeOfDay(
            hour: period == 'PM'
                ? (int.parse(hourMinute[0]) % 12) + 12
                : int.parse(hourMinute[0]) % 12,
            minute: int.parse(hourMinute[1]),
          );
        } catch (e) {
          // If parsing fails, use default time
          initialTime = const TimeOfDay(hour: 12, minute: 0);
        }
      }
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && _currentMasjidId != null) {
      final formattedTime = _formatTimeOfDay(pickedTime);
      await _mosqueProvider.updateEidPrayerTime(
          _currentMasjidId!,
          eidType,
          jamatName,
          formattedTime
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$eidType $jamatName ${AppStrings.getString('timeUpdatedTo', currentLocale)} $formattedTime',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime time) {
    return '${time.day} ${_getMonthName(time.month)} ${time.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}