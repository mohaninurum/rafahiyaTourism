import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/app_setting_provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  final List<TextEditingController> _headingControllers = [];
  final List<TextEditingController> _descriptionControllers = [];
  bool _isInitialized = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppSettingsProvider>(context, listen: false)
          .fetchTermsContent()
          .then((_) {
        _initializeControllers();
      });
    });
  }

  void _initializeControllers() {
    final provider = Provider.of<AppSettingsProvider>(context, listen: false);

    // Clear existing controllers
    for (var controller in _headingControllers) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    _headingControllers.clear();
    _descriptionControllers.clear();

    // Create new controllers for each section
    for (var section in provider.termsContent) {
      _headingControllers.add(TextEditingController(text: section['heading']));
      _descriptionControllers.add(TextEditingController(text: section['description']));
    }

    _isInitialized = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _headingControllers) {
      controller.dispose();
    }
    for (var controller in _descriptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.getString('termsAndConditions', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      body: Consumer<AppSettingsProvider>(
        builder: (context, provider, child) {
          // Initialize controllers only once when data is available
          if (!_isInitialized && provider.termsContent.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _initializeControllers();
            });
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: provider.termsContent.length,
                    itemBuilder: (context, index) {
                      return _buildSectionCard(context, provider, index, currentLocale);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          provider.addNewSection();
                          _headingControllers.add(TextEditingController());
                          _descriptionControllers.add(TextEditingController());
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blackColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.getString('addNewSection', currentLocale),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      for (int i = 0; i < _headingControllers.length; i++) {
                        if (i < provider.termsContent.length) {
                          provider.updateSectionHeading(i, _headingControllers[i].text);
                          provider.updateSectionDescription(i, _descriptionControllers[i].text);
                        }
                      }

                      bool success = await provider.updateTermsContent();
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.getString('termsUpdated', currentLocale)),
                            backgroundColor: AppColors.mainColor,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppStrings.getString('failedToUpdateTerms', currentLocale)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      AppStrings.getString('saveAllChanges', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, AppSettingsProvider provider, int index, String currentLocale) {
    // Ensure we have controllers for this index
    if (index >= _headingControllers.length || index >= _descriptionControllers.length) {
      return Container(); // Return empty container while controllers are being created
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '${index + 1}.',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _headingControllers[index],
                    decoration: InputDecoration(
                      hintText: AppStrings.getString('enterHeading', currentLocale),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      if (index < provider.termsContent.length) {
                        provider.updateSectionHeading(index, value);
                      }
                    },
                  ),
                ),
                if (provider.termsContent.length > 1)
                  IconButton(
                    onPressed: () {
                      provider.removeSection(index);
                      if (_headingControllers.length > index) {
                        _headingControllers[index].dispose();
                        _headingControllers.removeAt(index);
                      }
                      if (_descriptionControllers.length > index) {
                        _descriptionControllers[index].dispose();
                        _descriptionControllers.removeAt(index);
                      }
                      setState(() {});
                    },
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionControllers[index],
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.getString('enterDescriptionHere', currentLocale),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
              onChanged: (value) {
                if (index < provider.termsContent.length) {
                  provider.updateSectionDescription(index, value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}