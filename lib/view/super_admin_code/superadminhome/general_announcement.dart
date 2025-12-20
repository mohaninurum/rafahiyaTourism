import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/const/color.dart';
import '../models/general_annoucement/general_annoucement_model.dart';
import '../superadminprovider/general_annoucement/general_annoucement_form_provider.dart';
import '../superadminprovider/general_annoucement/super_admin_general_annoucement.dart';

class GeneralAnnouncementScreen extends StatelessWidget {
  const GeneralAnnouncementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GeneralAnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => GeneralAnnouncementFormProvider()),
      ],
      child: const _GeneralAnnouncementScreenContent(),
    );
  }
}

class _GeneralAnnouncementScreenContent extends StatefulWidget {
  const _GeneralAnnouncementScreenContent({super.key});

  @override
  State<_GeneralAnnouncementScreenContent> createState() => _GeneralAnnouncementScreenContentState();
}

class _GeneralAnnouncementScreenContentState extends State<_GeneralAnnouncementScreenContent> {
  bool _showAddForm = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GeneralAnnouncementProvider>(context, listen: false).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          AppStrings.getString('generalAnnouncements', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(_showAddForm ? Icons.close : Icons.add, color: Colors.white),
            onPressed: () {
              setState(() {
                _showAddForm = !_showAddForm;
                if (!_showAddForm) {
                  Provider.of<GeneralAnnouncementFormProvider>(context, listen: false).resetForm();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showAddForm)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: _AddGeneralAnnouncementForm(currentLocale: currentLocale),
              ),
            ),
          Expanded(child: _AnnouncementsList(currentLocale: currentLocale)),
        ],
      ),
    );
  }
}

class _AddGeneralAnnouncementForm extends StatelessWidget {
  final String currentLocale;

  const _AddGeneralAnnouncementForm({super.key, required this.currentLocale});


  Future<void> _submitAnnouncement(BuildContext context) async {
    final formProvider = Provider.of<GeneralAnnouncementFormProvider>(context, listen: false);
    final announcementProvider = Provider.of<GeneralAnnouncementProvider>(context, listen: false);

    if (!formProvider.isFormReady) return;

    formProvider.setSubmitting(true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Get FCM token
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken == null) {
        throw Exception("Unable to retrieve FCM token");
      }

      final announcement = GeneralAnnouncement(
        country: formProvider.selectedCountry!,
        city: formProvider.selectedCity!,
        message: formProvider.messageController.text,
        uid: user.uid,
        fcmToken: fcmToken,
        title: "New Update",
        createdAt: DateTime.now(),
      );

      await announcementProvider.addAnnouncement(announcement);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getString('announcementPublishedSuccess', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      formProvider.resetForm();
    } catch (e) {
      formProvider.setSubmitting(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.getString('failedToPublishAnnouncement', currentLocale)}: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    final formProvider = Provider.of<GeneralAnnouncementFormProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.announcement, color: AppColors.mainColor),
                const SizedBox(width: 10),
                Text(
                  AppStrings.getString('newAnnouncement', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mainColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Country Selection
            _buildDropdownField(
              context,
              label: AppStrings.getString('country', currentLocale),
              value: formProvider.selectedCountry,
              items: formProvider.countryCities.keys.toList(),
              onChanged: formProvider.setCountry,
              icon: Icons.location_on,
              currentLocale: currentLocale,
            ),

            const SizedBox(height: 20),

            // City Selection (only shown when country is selected)
            if (formProvider.selectedCountry != null)
              _buildDropdownField(
                context,
                label: AppStrings.getString('city', currentLocale),
                value: formProvider.selectedCity,
                items: formProvider.countryCities[formProvider.selectedCountry]!,
                onChanged: formProvider.setCity,
                icon: Icons.location_city,
                currentLocale: currentLocale,
              ),

            if (formProvider.selectedCountry != null) const SizedBox(height: 20),

            // Message Field
            TextFormField(
              controller: formProvider.messageController,
              maxLines: 4,
              enabled: formProvider.isFormReady,
              decoration: InputDecoration(
                labelText: AppStrings.getString('announcementMessage', currentLocale),
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.mainColor, width: 1.5),
                ),
                labelStyle: GoogleFonts.poppins(
                  color: Colors.grey[700],
                ),
                floatingLabelStyle: GoogleFonts.poppins(
                  color: AppColors.mainColor,
                ),
                hintText: formProvider.isFormReady
                    ? AppStrings.getString('enterAnnouncementHint', currentLocale)
                    : AppStrings.getString('selectCountryCityFirst', currentLocale),
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                ),
                prefixIcon: Icon(Icons.message, color: AppColors.mainColor),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              style: GoogleFonts.poppins(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.getString('pleaseEnterAnnouncement', currentLocale);
                }
                return null;
              },
            ),
            const SizedBox(height: 25),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formProvider.isSubmitting || !formProvider.isFormReady
                    ? null
                    : () => _submitAnnouncement(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: formProvider.isFormReady
                      ? AppColors.mainColor
                      : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: formProvider.isSubmitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      AppStrings.getString('publishAnnouncement', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
      BuildContext context, {
        required String label,
        required String? value,
        required List<String> items,
        required Function(String?) onChanged,
        required IconData icon,
        required String currentLocale,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(icon, color: AppColors.mainColor),
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  '${AppStrings.getString('selectA', currentLocale)} $label',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ...items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
            ],
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return '${AppStrings.getString('pleaseSelectA', currentLocale)} $label';
              }
              return null;
            },
            icon: Icon(Icons.arrow_drop_down, color: AppColors.mainColor),
            isExpanded: true,
            style: GoogleFonts.poppins(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 300,
          ),
        ),
      ],
    );
  }
}

class _AnnouncementsList extends StatelessWidget {
  final String currentLocale;

  const _AnnouncementsList({super.key, required this.currentLocale});

  Future<void> _deleteAnnouncement(BuildContext context, String id) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.getString('confirmDelete', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Text(
          AppStrings.getString('deleteAnnouncementConfirmation', currentLocale),
          style: GoogleFonts.poppins(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppStrings.getString('cancel', currentLocale),
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppStrings.getString('delete', currentLocale),
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmDelete != true) return;

    try {
      await Provider.of<GeneralAnnouncementProvider>(context, listen: false)
          .deleteAnnouncement(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getString('announcementDeletedSuccess', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.getString('failedToDeleteAnnouncement', currentLocale)}: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _showEditDialog(BuildContext context, GeneralAnnouncement announcement) async {
    final formProvider = Provider.of<GeneralAnnouncementFormProvider>(context, listen: false);
    final announcementProvider = Provider.of<GeneralAnnouncementProvider>(context, listen: false);

    // Initialize form with existing values
    formProvider.setCountry(announcement.country);
    formProvider.setCity(announcement.city);
    formProvider.messageController.text = announcement.message;

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, color: AppColors.mainColor, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.getString('editAnnouncement', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Country Selection
                  _buildDropdownField(
                    context,
                    label: AppStrings.getString('country', currentLocale),
                    value: formProvider.selectedCountry,
                    items: formProvider.countryCities.keys.toList(),
                    onChanged: formProvider.setCountry,
                    icon: Icons.location_on,
                    currentLocale: currentLocale,
                  ),

                  const SizedBox(height: 20),

                  // City Selection
                  if (formProvider.selectedCountry != null)
                    _buildDropdownField(
                      context,
                      label: AppStrings.getString('city', currentLocale),
                      value: formProvider.selectedCity,
                      items: formProvider.countryCities[formProvider.selectedCountry]!,
                      onChanged: formProvider.setCity,
                      icon: Icons.location_city,
                      currentLocale: currentLocale,
                    ),

                  if (formProvider.selectedCountry != null) const SizedBox(height: 20),

                  // Message Field
                  TextFormField(
                    controller: formProvider.messageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: AppStrings.getString('announcementMessage', currentLocale),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mainColor, width: 1.5),
                      ),
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.grey[700],
                      ),
                      floatingLabelStyle: GoogleFonts.poppins(
                        color: AppColors.mainColor,
                      ),
                      prefixIcon: Icon(Icons.message, color: AppColors.mainColor),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 25),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          formProvider.resetForm();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppStrings.getString('cancel', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            final updatedAnnouncement = GeneralAnnouncement(
                              id: announcement.id,
                              country: formProvider.selectedCountry!,
                              city: formProvider.selectedCity!,
                              message: formProvider.messageController.text,
                              title: "New Update",
                              createdAt: announcement.createdAt,
                              uid: FirebaseAuth.instance.currentUser!.uid,
                            );

                            await announcementProvider.updateAnnouncement(updatedAnnouncement);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppStrings.getString('announcementUpdatedSuccess', currentLocale),
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );

                            Navigator.pop(context);
                            formProvider.resetForm();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${AppStrings.getString('failedToUpdateAnnouncement', currentLocale)}: ${e.toString()}',
                                  style: GoogleFonts.poppins(),
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppStrings.getString('saveChanges', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownField(
      BuildContext context, {
        required String label,
        required String? value,
        required List<String> items,
        required Function(String?) onChanged,
        required IconData icon,
        required String currentLocale,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[300]!),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: value,
            decoration: InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              prefixIcon: Icon(icon, color: AppColors.mainColor),
            ),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(
                  '${AppStrings.getString('selectA', currentLocale)} $label',
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ),
              ...items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(),
                  ),
                );
              }).toList(),
            ],
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return '${AppStrings.getString('pleaseSelectA', currentLocale)} $label';
              }
              return null;
            },
            icon: Icon(Icons.arrow_drop_down, color: AppColors.mainColor),
            isExpanded: true,
            style: GoogleFonts.poppins(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
            menuMaxHeight: 300,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final announcements = Provider.of<GeneralAnnouncementProvider>(context).announcements;
    final announcementProvider = Provider.of<GeneralAnnouncementProvider>(context);
    final isLoading = announcementProvider.isLoading;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitChasingDots(
              color: AppColors.mainColor,
              size: 50.0,
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.getString('loadingAnnouncements', currentLocale),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    if (announcements.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/images/no_announcements.svg',
            width: 200,
            height: 200,
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.getString('noAnnouncementsYet', currentLocale),
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.getString('clickToAddFirstAnnouncement', currentLocale),
            style: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: announcements.length,
      itemBuilder: (context, index) {
        final announcement = announcements[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Material(
              color: Colors.white,
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.mainColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.announcement,
                              color: AppColors.mainColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${announcement.country}, ${announcement.city}',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy - hh:mm a').format(announcement.createdAt!),
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton(
                            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: AppColors.mainColor, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.getString('edit', currentLocale),
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ],
                                ),
                                onTap: () => Future.delayed(
                                  Duration.zero,
                                      () => _showEditDialog(context, announcement),
                                ),
                              ),
                              PopupMenuItem(
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppStrings.getString('delete', currentLocale),
                                      style: GoogleFonts.poppins(),
                                    ),
                                  ],
                                ),
                                onTap: () => Future.delayed(
                                  Duration.zero,
                                      () => _deleteAnnouncement(context, announcement.id!),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          announcement.message,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${AppStrings.getString('posted', currentLocale)} ${DateFormat('MMM dd').format(announcement.createdAt!)}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[500],
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}