import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../superadminprovider/marquee/marquee_provider.dart';

class MarqueeTextManagementScreen extends StatefulWidget {
  const MarqueeTextManagementScreen({super.key});

  @override
  State<MarqueeTextManagementScreen> createState() => _MarqueeTextManagementScreenState();
}

class _MarqueeTextManagementScreenState extends State<MarqueeTextManagementScreen> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MarqueeProvider>(context, listen: false);
      _textController.text = provider.marqueeText;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _updateMarqueeText() async {
    final currentLocale = _getCurrentLocale(context);
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<MarqueeProvider>(context, listen: false);
      final success = await provider.updateMarqueeText(_textController.text.trim());

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.mainColor,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  AppStrings.getString('marqueeTextUpdated', currentLocale),
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back after a short delay
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('manageMarqueeText', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Consumer<MarqueeProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Preview Section
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.mainColor, Color(0xFF004D26)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.getString('livePreview', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 10),
                        Container(
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Marquee(
                            text: provider.marqueeText,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            velocity: 40.0,
                            blankSpace: 100.0,
                            pauseAfterRound: Duration(seconds: 1),
                            startPadding: 10.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 30),

                // Edit Section
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.getString('editMarqueeText', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: _textController,
                        maxLines: 3,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: AppStrings.getString('marqueeText', currentLocale),
                          hintText: AppStrings.getString('enterMarqueeText', currentLocale),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.mainColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.mainColor, width: 2),
                          ),
                          labelStyle: GoogleFonts.poppins(color: AppColors.mainColor),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                        ),
                        style: GoogleFonts.poppins(fontSize: 16),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.getString('pleaseEnterMarqueeText', currentLocale);
                          }
                          if (value.trim().length < 5) {
                            return AppStrings.getString('textTooShort', currentLocale);
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${_textController.text.length}/100 ${AppStrings.getString('characters', currentLocale)}',
                        style: GoogleFonts.poppins(
                          color: _textController.text.length > 100
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Spacer(),

                // Update Button
                Container(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : _updateMarqueeText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: provider.isLoading
                        ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      AppStrings.getString('updateMarqueeText', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                if (provider.error != null) ...[
                  SizedBox(height: 10),
                  Text(
                    provider.error!,
                    style: GoogleFonts.poppins(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}