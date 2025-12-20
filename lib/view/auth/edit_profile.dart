import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/user_profile_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/utils/widgets/textformfield.dart';

import '../../provider/locale_provider.dart';
import '../../utils/model/auth/auth_user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  late TextEditingController _pinCodeController;

  bool isSaving = false;
  String? _selectedCountry;

  final List<String> _countries = [
    'Saudi Arabia',
    'United Arab Emirates',
    'Qatar',
    'Kuwait',
    'Oman',
    'Bahrain',
    'Egypt',
    'Jordan',
    'Palestine',
    'Germany',
    'Morocco',
    'Turkey',
    'Indonesia',
    'Malaysia',
    'Pakistan',
    'India',
    'Bangladesh',
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProfileProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.mobileNumber ?? '');
    _cityController = TextEditingController(text: user?.city ?? '');
    _pinCodeController = TextEditingController(text: user?.pinCode ?? '');

    // Set the selected country to user's current country
    _selectedCountry = user?.country;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final profileProvider = Provider.of<UserProfileProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        title: Text(
          AppStrings.getString('editProfile', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: isTablet ? 24 : 20,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                color: Colors.white,
                Icons.save,
                size: isTablet ? 30 : 24,
              ),
              onPressed: isSaving ? null : _saveProfile,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 40 : 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: isTablet ? 70 : 60,
                    backgroundImage: profileProvider.pickedImage != null
                        ? FileImage(profileProvider.pickedImage!)
                        : (profileProvider.user?.profileImage != null &&
                        profileProvider.user!.profileImage!.isNotEmpty)
                        ? NetworkImage(profileProvider.user!.profileImage!)
                        : AssetImage("assets/images/user.png") as ImageProvider,
                  ),
                  Positioned(
                    bottom: -10,
                    right: -10,
                    child: InkWell(
                      onTap: () {
                        Provider.of<UserProfileProvider>(
                          context,
                          listen: false,
                        ).showImagePickerBottomSheet(context);
                      },
                      child: Container(
                        height: isTablet ? 50 : 40,
                        width: isTablet ? 50 : 40,
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: isTablet ? 30 : 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            CustomTextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              labelText: AppStrings.getString('fullName', currentLocale),
              prefixIcon: Icon(
                Icons.person,
                color: AppColors.mainColor,
                size: isTablet ? 28 : 24,
              ),
            ),

            SizedBox(height: 15),

            CustomTextFormField(
              controller: _phoneController,
              textInputAction: TextInputAction.next,
              labelText: AppStrings.getString('mobileNumber', currentLocale),
              prefixIcon: Icon(
                Icons.phone,
                color: AppColors.mainColor,
                size: isTablet ? 28 : 24,
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 15),

            CustomTextFormField(
              controller: _cityController,
              textInputAction: TextInputAction.next,
              labelText: AppStrings.getString('city', currentLocale),
              prefixIcon: Icon(
                Icons.location_city,
                color: AppColors.mainColor,
                size: isTablet ? 28 : 24,
              ),
            ),

            SizedBox(height: 15),

            // Country Dropdown - REPLACED TEXTFORMFIELD
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.getString('country', currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCountry,
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
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: isTablet ? 18 : 16,
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCountry = newValue;
                        });
                      }
                    },
                    items: _countries.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 18 : 16,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            SizedBox(height: 15),

            CustomTextFormField(
              controller: _pinCodeController,
              textInputAction: TextInputAction.done,
              labelText: AppStrings.getString('pincode', currentLocale),
              prefixIcon: Icon(
                Icons.pin_drop,
                color: AppColors.mainColor,
                size: isTablet ? 28 : 24,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 30),

            Container(
              width: isTablet ? screenWidth * 0.4 : screenWidth * 0.6,
              height: isTablet ? 60 : 50,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: isSaving ? null : _saveProfile,
                child: isSaving
                    ? const SpinKitChasingDots(
                  color: Colors.white,
                  size: 25,
                )
                    : Text(
                  AppStrings.getString('saveChanges', currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: isTablet ? 20 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      isSaving = true;
    });

    final profileProvider = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    );

    // Validate country selection
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select a country',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() {
          isSaving = false;
        });
      }
      return;
    }

    // Upload the new image if one was picked
    String? imageUrl;
    if (profileProvider.pickedImage != null) {
      imageUrl = await profileProvider.uploadProfileImage();
    }

    final updatedUser = AuthUserModel(
      id: profileProvider.user?.id,
      fullName: _nameController.text,
      email: _emailController.text,
      mobileNumber: _phoneController.text,
      city: _cityController.text,
      country: _selectedCountry!,
      profileImage: imageUrl ?? profileProvider.user?.profileImage,
      pinCode: _pinCodeController.text,
      createdAt: profileProvider.user?.createdAt,
    );

    try {
      await profileProvider.updateProfile(updatedUser);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update profile: $e',
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
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _pinCodeController.dispose();
    super.dispose();
  }
}