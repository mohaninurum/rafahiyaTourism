import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../superadminprovider/app_setting_provider.dart';

class IntroEditScreen extends StatefulWidget {
  const IntroEditScreen({super.key});

  @override
  State<IntroEditScreen> createState() => _IntroEditScreenState();
}

class _IntroEditScreenState extends State<IntroEditScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppSettingsProvider>(context, listen: false);
    provider.initializeControllers();
  }

  Future<void> _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final provider = Provider.of<AppSettingsProvider>(context, listen: false);
    final success = await provider.updateIntroContent();

    setState(() => _isLoading = false);

    final currentLocale = _getCurrentLocale(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getString('contentUpdated', currentLocale))),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getString('failedToUpdate', currentLocale))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final isMediumScreen = screenWidth >= 400 && screenWidth < 600;
    final isLargeScreen = screenWidth >= 600 && screenWidth < 900;
    final isExtraLargeScreen = screenWidth >= 900;

    return WillPopScope(
      onWillPop: () async {
        if (_isLoading) return false;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.getString('editIntroContent', currentLocale),
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.mainColor,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios_sharp, color: Colors.white)
          ),
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : isMediumScreen ? 24 : 32,
                    vertical: isSmallScreen ? 8 : 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Form(
                      key: _formKey,
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                Image.asset(
                                  'assets/images/white_logo.png',
                                  height: isExtraLargeScreen
                                      ? 240
                                      : isLargeScreen
                                      ? 200
                                      : isMediumScreen
                                      ? 180
                                      : screenHeight * 0.16,
                                ),
                                const SizedBox(height: 16),
                                Consumer<AppSettingsProvider>(
                                  builder: (context, provider, child) {
                                    return TextFormField(
                                      controller: provider.titleController,
                                      style: GoogleFonts.poppins(
                                        fontSize: isExtraLargeScreen
                                            ? 42
                                            : isLargeScreen
                                            ? 36
                                            : isMediumScreen
                                            ? 28
                                            : 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: AppStrings.getString('enterTitle', currentLocale),
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: isExtraLargeScreen
                                              ? 42
                                              : isLargeScreen
                                              ? 36
                                              : isMediumScreen
                                              ? 28
                                              : 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '${AppStrings.getString('enterTitle', currentLocale)}';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),
                                Consumer<AppSettingsProvider>(
                                  builder: (context, provider, child) {
                                    return TextFormField(
                                      controller: provider.taglineController,
                                      style: GoogleFonts.poppins(
                                        fontSize: isExtraLargeScreen
                                            ? 24
                                            : isLargeScreen
                                            ? 20
                                            : isMediumScreen
                                            ? 18
                                            : 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: AppStrings.getString('enterTagline', currentLocale),
                                        hintStyle: GoogleFonts.poppins(
                                          fontSize: isExtraLargeScreen
                                              ? 24
                                              : isLargeScreen
                                              ? 20
                                              : isMediumScreen
                                              ? 18
                                              : 16,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                        contentPadding: const EdgeInsets.only(right: 8.0),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return '${AppStrings.getString('enterTagline', currentLocale)}';
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Consumer<AppSettingsProvider>(
                              builder: (context, provider, child) {
                                return TextFormField(
                                  controller: provider.descriptionController,
                                  style: GoogleFonts.poppins(
                                    fontSize: isExtraLargeScreen
                                        ? 22
                                        : isLargeScreen
                                        ? 20
                                        : isMediumScreen
                                        ? 18
                                        : 16,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFFFCE4D0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 4,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppStrings.getString('enterDescription', currentLocale),
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: isExtraLargeScreen
                                          ? 22
                                          : isLargeScreen
                                          ? 20
                                          : isMediumScreen
                                          ? 18
                                          : 16,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFFFCE4D0).withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '${AppStrings.getString('enterDescription', currentLocale)}';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Consumer<AppSettingsProvider>(
                              builder: (context, provider, child) {
                                return TextFormField(
                                  controller: provider.secondaryDescriptionController,
                                  style: GoogleFonts.poppins(
                                    fontSize: isExtraLargeScreen
                                        ? 22
                                        : isLargeScreen
                                        ? 20
                                        : isMediumScreen
                                        ? 18
                                        : 16,
                                    fontStyle: FontStyle.italic,
                                    color: const Color(0xFFFCE4D0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 5,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: AppStrings.getString('enterSecondaryDescription', currentLocale),
                                    hintStyle: GoogleFonts.poppins(
                                      fontSize: isExtraLargeScreen
                                          ? 22
                                          : isLargeScreen
                                          ? 20
                                          : isMediumScreen
                                          ? 18
                                          : 16,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFFFCE4D0).withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '${AppStrings.getString('enterSecondaryDescription', currentLocale)}';
                                    }
                                    return null;
                                  },
                                );
                              },
                            ),
                            const Spacer(),
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: isSmallScreen ? 30 : 40,
                                top: isSmallScreen ? 30 : 40,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                                  : InkWell(
                                onTap: () => _saveChanges(context),
                                child: Container(
                                  height: isExtraLargeScreen
                                      ? 70
                                      : isLargeScreen
                                      ? 60
                                      : isMediumScreen
                                      ? 50
                                      : 48,
                                  width: screenWidth * 0.8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      AppStrings.getString('saveChanges', currentLocale),
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFFF32020),
                                        fontWeight: FontWeight.bold,
                                        fontSize: isExtraLargeScreen
                                            ? 26
                                            : isLargeScreen
                                            ? 22
                                            : isMediumScreen
                                            ? 20
                                            : 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}