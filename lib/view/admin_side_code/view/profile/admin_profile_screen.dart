

import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../const/color.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../../auth/intro_slider.dart';
import '../../data/subAdminProvider/admin_login_provider.dart';
import '../../data/subAdminProvider/sub_admin_profile_provider.dart';
import '../../data/utils/circular_indicator_spinkit.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _mosqueOffsetAnimation;

  late SubAdminProfileProvider _profileProvider;
  bool _isLoggingOut = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileProvider = Provider.of<SubAdminProfileProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _mosqueOffsetAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileProvider.getProfile(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _profileProvider.stopListening();
    super.dispose();
  }

  // Add this method for image picking
  void _showImageSourceDialog(BuildContext context, String currentLocale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.getString('chooseImageSource', currentLocale),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: AppColors.mainColor),
                title: Text(AppStrings.getString('camera', currentLocale)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, context, currentLocale);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppColors.mainColor),
                title: Text(AppStrings.getString('gallery', currentLocale)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, context, currentLocale);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: AppColors.mainColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source, BuildContext context, String currentLocale) async {
    try {
      final profileProvider = Provider.of<SubAdminProfileProvider>(context, listen: false);
      final uid = FirebaseAuth.instance.currentUser!.uid;

      File? imageFile;
      if (source == ImageSource.camera) {
        imageFile = await profileProvider.pickImageFromCamera();
      } else {
        imageFile = await profileProvider.pickImageFromGallery();
      }

      if (imageFile != null && mounted) {
        // Show loading indicator on the edit button instead of a dialog
        setState(() {});

        try {
          // Upload image
          await profileProvider.updateProfileImage(uid, imageFile);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.getString('profileImageUpdated', currentLocale)),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (uploadError) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${AppStrings.getString('failedToUpdateImage', currentLocale)}: $uploadError'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } finally {
          if (mounted) {
            setState(() {});
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.getString('failedToPickImage', currentLocale)}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEditFieldDialog({
    required String fieldName,
    required String currentValue,
    required String labelText,
    required String currentLocale,
  }) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            '${AppStrings.getString('update', currentLocale)} $labelText',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: '${AppStrings.getString('enterNew', currentLocale)} $labelText',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getString('cancel', currentLocale), style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  final uid = FirebaseAuth.instance.currentUser!.uid;
                  await Provider.of<SubAdminProfileProvider>(
                    context,
                    listen: false,
                  ).updateProfileField(uid, fieldName, newValue);
                  await Provider.of<SubAdminProfileProvider>(
                    context,
                    listen: false,
                  ).getProfile(uid);
                }
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
              ),
              child: Text(
                AppStrings.getString('update', currentLocale),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildSettingTile({
    required IconData leadingIcon,
    required String text,
    Widget? trailing,
    required String currentLocale,
  }) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 15),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 2,
              spreadRadius: 1,
              offset: const Offset(0, 0.2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(leadingIcon, color: AppColors.mainColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.poppins(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 24, child: trailing ?? const SizedBox()),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<SubAdminProfileProvider>(context);
    final profile = provider.profile;

    return Scaffold(
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
          ? Center(child: Text(AppStrings.getString('noProfileDataFound', currentLocale)))
          : Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/container_image.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              SlideTransition(
                position: _mosqueOffsetAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    AppStrings.getString('profile', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.blackBackground,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: profile.imageUrl.isNotEmpty
                              ? NetworkImage(profile.imageUrl) as ImageProvider
                              : const AssetImage('assets/images/map.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _showImageSourceDialog(context, currentLocale);
                        },
                        child: Container(
                          height: 24,
                          width: 24,
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.blackBackground,
                              width: 2,
                            ),
                          ),
                          child: provider.isUploadingImage
                              ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(
                            Icons.edit,
                            size: 14,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _mosqueOffsetAnimation,
                child: Center(
                  child: Text(
                    profile.imamName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackBackground,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ... rest of your existing buildSettingTile widgets remain the same
              buildSettingTile(
                leadingIcon: Icons.person,
                text: profile.imamName,
                currentLocale: currentLocale,
                trailing: IconButton(
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.mainColor,
                  ),
                  onPressed: () {
                    _showEditFieldDialog(
                      fieldName: 'imamName',
                      currentValue: profile.imamName,
                      labelText: AppStrings.getString('name', currentLocale),
                      currentLocale: currentLocale,
                    );
                  },
                ),
              ),
              buildSettingTile(
                leadingIcon: Icons.email,
                text: profile.email,
                currentLocale: currentLocale,
              ),
              buildSettingTile(
                leadingIcon: Icons.location_on,
                text: '${profile.city}, ${profile.address}',
                currentLocale: currentLocale,
              ),
              buildSettingTile(
                leadingIcon: Icons.mosque,
                text: profile.masjidName,
                currentLocale: currentLocale,

              ),
              buildSettingTile(
                leadingIcon: Icons.phone,
                text: profile.mobileNumber,
                currentLocale: currentLocale,
                trailing: InkWell(
                  onTap: () {
                    _showEditFieldDialog(
                      fieldName: 'mobileNumber',
                      currentValue: profile.mobileNumber,
                      labelText: AppStrings.getString('mobileNumber', currentLocale),
                      currentLocale: currentLocale,
                    );
                  },
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.mainColor,
                  ),
                ),
              ),
              buildSettingTile(
                leadingIcon: Icons.mosque_outlined,
                text: profile.masjidPhoneNumber,
                currentLocale: currentLocale,
                trailing: InkWell(
                  onTap: () {
                    _showEditFieldDialog(
                      fieldName: 'masjidPhone',
                      currentValue: profile.masjidPhoneNumber,
                      labelText: AppStrings.getString('masjidPhone', currentLocale),
                      currentLocale: currentLocale,
                    );
                  },
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.mainColor,
                  ),
                ),
              ),
              buildSettingTile(
                leadingIcon: Icons.numbers,
                text: profile.pinCode,
                currentLocale: currentLocale,
              ),
              InkWell(
                onTap: () {
                  _launchWhatsApp(currentLocale);
                },
                child: buildSettingTile(
                  leadingIcon: Icons.support_agent,
                  text: AppStrings.getString('support', currentLocale),
                  currentLocale: currentLocale,
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.mainColor,
                    size: 16,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _showLogoutDialog(context, currentLocale),
                child: buildSettingTile(
                  leadingIcon: Icons.logout,
                  text: AppStrings.getString('logOut', currentLocale),
                  currentLocale: currentLocale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... rest of your existing methods (_launchWhatsApp, _showLogoutDialog, _performLogout) remain the same
  Future<void> _launchWhatsApp(String currentLocale) async {
    final phoneNumber = '+919552378468';
    final url = 'https://wa.me/$phoneNumber';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw '${AppStrings.getString('couldNotLaunch', currentLocale)} $url';
      }
    } catch (e) {
      print('${AppStrings.getString('errorLaunchingWhatsApp', currentLocale)}: $e');
    }
  }

  Future<void> _showLogoutDialog(BuildContext context, String currentLocale) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppStrings.getString('logout', currentLocale),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: AppColors.mainColor,
            ),
          ),
          content: Text(
            AppStrings.getString('confirmLogoutMessage', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: AppColors.mainColor),
              ),
            ),
            TextButton(
              onPressed: _isLoggingOut
                  ? null
                  : () async {
                setState(() => _isLoggingOut = true);
                Navigator.of(context).pop(true);
                await _performLogout(context, currentLocale);
                setState(() => _isLoggingOut = false);
              },
              child: _isLoggingOut
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CustomCircularProgressIndicator(
                  size: 20.0,
                  color: AppColors.mainColor,
                ),
              )
                  : Text(
                AppStrings.getString('logout', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context, String currentLocale) async {
    try {
      final provider = Provider.of<AdminsLoginProvider>(context, listen: false);
      await provider.signOut(context);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
            (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('logoutFailed', currentLocale)}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }
}