import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/app_state_proivder.dart';
import 'package:rafahiyatourism/view/home/notification_setting_screen.dart';
import '../../provider/home_masjid_data_provider.dart';
import '../../provider/notification_provider.dart';
import '../../provider/multi_mosque_provider.dart';
import 'mosque_search_dropdown.dart';

class MasjidSettingsScreen extends StatefulWidget {
  final int tabIndex;

  const MasjidSettingsScreen({super.key, required this.tabIndex});

  @override
  State<MasjidSettingsScreen> createState() => _MasjidSettingsScreenState();
}

class _MasjidSettingsScreenState extends State<MasjidSettingsScreen> {
  late TextEditingController mosqueNameController;
  late TextEditingController addressController;
  late MultiMosqueProvider multiMosqueProvider;

  // Define the desired order of prayer names
  final List<String> prayerOrder = [
    'Fajr',
    'Dhuhr',
    'Asr',
    'Maghrib',
    'Isha',
    'Jumuah',
    'Hadiyah',
    'Announcement',
    'Sehri/Iftari',
  ];

  @override
  void initState() {
    super.initState();
    mosqueNameController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    multiMosqueProvider = Provider.of<MultiMosqueProvider>(context);

    // Update controllers with current provider values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateControllers();
    });

    // Add listener to update controllers when provider changes
    multiMosqueProvider.addListener(_updateControllers);
  }

  void _updateControllers() {
    if (mounted) {
      setState(() {
        final mosqueData = multiMosqueProvider.getMosqueData(widget.tabIndex);

        mosqueNameController.text = mosqueData?['name'] ?? '';

        addressController.text = mosqueData?['address'] ?? '';

      });
    }
  }

  @override
  void dispose() {
    mosqueNameController.dispose();
    addressController.dispose();
    multiMosqueProvider.removeListener(_updateControllers);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Back',
                  style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            Consumer<MultiMosqueProvider>(
              builder: (context, provider, child) {
                final mosqueData = provider.getMosqueData(widget.tabIndex);
                final mosqueUid = mosqueData?['uid'];
              print("ID:: ${mosqueUid}");
              print("ID:: ${widget.tabIndex}");
                return TextButton(
                  onPressed: () async {
                    if (mosqueUid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a mosque first')),
                      );
                      return;
                    }

                    await provider.saveToFirestore();

                    final homeDataProvider = Provider.of<HomeMasjidDataProvider>(context, listen: false);
                    homeDataProvider.fetchMosqueData(widget.tabIndex, mosqueUid);

                    final appState = Provider.of<AppStateProvider>(context, listen: false);
                    appState.setShowRestartDialog(true);
                    print("Should show restart dialog!");

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Settings saved successfully'),
                        duration: Duration(seconds: 2, milliseconds: 300),
                      ),
                    );

                    // Give time for snackbar + state propagation
                    await Future.delayed(const Duration(milliseconds: 2500));
                    if (mounted) {
                      Navigator.pop(context);
                      // Navigator.of(context).pop();
                    }
                  },
                  child: Text('Save',
                      style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MosqueSearchDropdown(
                controller: mosqueNameController,
                tabIndex: widget.tabIndex,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: () async {
                  final mosqueData = multiMosqueProvider.getMosqueData(widget.tabIndex);
                  if (mosqueData?['uid'] == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please select a mosque first')),
                    );
                    return;
                  }

                  final notificationProvider = Provider.of<NotificationSettingsProvider>(context, listen: false);
                  notificationProvider.setSelectedDays(multiMosqueProvider.getSelectedDays(widget.tabIndex));

                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationSettingsScreen(),
                    ),
                  );

                  if (result != null && result is List<String>) {
                    multiMosqueProvider.setSelectedDays(widget.tabIndex, result);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Notification Settings',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Consumer<MultiMosqueProvider>(
                        builder: (context, provider, child) {
                          final selectedDays = provider.getSelectedDays(widget.tabIndex);
                          return Text(
                            selectedDays.isEmpty
                                ? 'Select Days'
                                : selectedDays.length == 7
                                ? 'All Days'
                                : '${selectedDays.length} Days',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Consumer<MultiMosqueProvider>(
                builder: (context, provider, child) {
                  final selectedDays = provider.getSelectedDays(widget.tabIndex);
                  if (selectedDays.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Selected days: ${selectedDays.join(', ')}',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Notification Preferences',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 80),
                  Text('Azan',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 40),
                  Text('Jamat',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const SizedBox(width: 30),
                  Text('Audio', style: GoogleFonts.poppins()),
                  Text('Text', style: GoogleFonts.poppins()),
                  Text('Audio', style: GoogleFonts.poppins()),
                  Text('Text', style: GoogleFonts.poppins()),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<MultiMosqueProvider>(
                builder: (context, provider, child) {
                  final notificationSettings = provider.getNotificationSettings(widget.tabIndex);

                  // Initialize default settings if empty
                  if (notificationSettings.isEmpty) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      provider.initializeDefaultSettings(widget.tabIndex);
                    });
                    return const CircularProgressIndicator();
                  }

                  // Get keys in the desired order, filtering only those that exist in the settings
                  final orderedKeys = prayerOrder.where((key) => notificationSettings.containsKey(key)).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: orderedKeys.length,
                    itemBuilder: (context, index) {
                      String key = orderedKeys[index];
                      bool hasAnyEnabled = notificationSettings[key]?.values.any((val) => val == true) ?? false;
                      bool isAnnouncement = key == 'Announcement';
                      bool isHadiyah = key == 'Hadiyah';
                      bool isSehriIftari = key == 'Sehri/Iftari';

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(key,
                                  style: GoogleFonts.poppins(
                                    color: hasAnyEnabled ? Colors.black : Colors.grey,
                                    fontWeight: hasAnyEnabled ? FontWeight.bold : FontWeight.normal,
                                  )),
                            ),
                            if (!isAnnouncement && !isHadiyah && !isSehriIftari) ...[
                              Checkbox(
                                activeColor: AppColors.mainColor,
                                value: notificationSettings[key]?['AzanAudio'] ?? false,
                                onChanged: (val) {
                                  provider.updateNotificationSetting(widget.tabIndex, key, 'AzanAudio', val!);
                                },
                              ),
                              Checkbox(
                                activeColor: AppColors.mainColor,
                                value: notificationSettings[key]?['AzanText'] ?? false,
                                onChanged: (val) {
                                  provider.updateNotificationSetting(widget.tabIndex, key, 'AzanText', val!);
                                },
                              ),
                            ] else ...[
                              const SizedBox(width: 24),
                              const SizedBox(width: 24),
                            ],
                            Checkbox(
                              activeColor: AppColors.mainColor,
                              value: notificationSettings[key]?['JamatAudio'] ?? false,
                              onChanged: (val) {
                                provider.updateNotificationSetting(widget.tabIndex, key, 'JamatAudio', val!);
                              },
                            ),
                            Checkbox(
                              activeColor: AppColors.mainColor,
                              value: notificationSettings[key]?['JamatText'] ?? false,
                              onChanged: (val) {
                                provider.updateNotificationSetting(widget.tabIndex, key, 'JamatText', val!);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}