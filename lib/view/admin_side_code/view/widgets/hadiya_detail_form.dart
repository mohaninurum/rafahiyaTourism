

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../admin_bottom_navigationbar.dart';
import '../../data/subAdminProvider/add_hadiya_maulana_provider.dart';
import '../../data/utils/circular_indicator_spinkit.dart';
import 'custom_radio_btn.dart';

class HadiyaBankDetailsForm extends StatefulWidget {
  const HadiyaBankDetailsForm({super.key});

  @override
  State<HadiyaBankDetailsForm> createState() => _HadiyaBankDetailsFormState();
}

class _HadiyaBankDetailsFormState extends State<HadiyaBankDetailsForm> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<HadiyaProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          AppStrings.getString('addBankDetails', currentLocale),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        children: [
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(provider.error!, style: const TextStyle(color: Colors.red)),
            ),

          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                AppStrings.getString('chooseHadiyaType', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackBackground,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Responsive Radio Buttons
          LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 400;
              return isSmallScreen
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer<HadiyaProvider>(
                    builder: (_, provider, __) => CustomRadioButton(
                      title: AppStrings.getString('forMasjid', currentLocale),
                      value: "Masjid",
                      groupValue: provider.selectedHadiyaTitle,
                      onChanged: provider.setHadiyaTitle,
                      isDisabled: provider.isOptionDisabled("Masjid"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Consumer<HadiyaProvider>(
                    builder: (_, provider, __) => CustomRadioButton(
                      title: AppStrings.getString('forMaulana', currentLocale),
                      value: "Maulana",
                      groupValue: provider.selectedHadiyaTitle,
                      onChanged: provider.setHadiyaTitle,
                      isDisabled: provider.isOptionDisabled("Maulana"),
                    ),
                  ),
                ],
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer<HadiyaProvider>(
                    builder: (_, provider, __) => CustomRadioButton(
                      title: AppStrings.getString('forMasjid', currentLocale),
                      value: "Masjid",
                      groupValue: provider.selectedHadiyaTitle,
                      onChanged: provider.setHadiyaTitle,
                      isDisabled: provider.isOptionDisabled("Masjid"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Consumer<HadiyaProvider>(
                    builder: (_, provider, __) => CustomRadioButton(
                      title: AppStrings.getString('forMaulana', currentLocale),
                      value: "Maulana",
                      groupValue: provider.selectedHadiyaTitle,
                      onChanged: provider.setHadiyaTitle,
                      isDisabled: provider.isOptionDisabled("Maulana"),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(thickness: 0.5, color: AppColors.greyColor),
          ),
          const SizedBox(height: 20),

          // Text Fields
          _buildResponsiveTextField(
            label: AppStrings.getString('accountHolder', currentLocale),
            controller: provider.accountHolderNameController,
            currentLocale: currentLocale,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 10),

          _buildResponsiveTextField(
            label: AppStrings.getString('bankDetails', currentLocale),
            controller: provider.bankDetailsController,
            currentLocale: currentLocale,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 10),

          _buildResponsiveTextField(
            label: AppStrings.getString('accountNumber', currentLocale),
            controller: provider.accountController,
            keyboardType: TextInputType.number,
            currentLocale: currentLocale,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 10),

          _buildResponsiveTextField(
            label: AppStrings.getString('ifscCode', currentLocale),
            controller: provider.ifscController,
            keyboardType: TextInputType.text,
            currentLocale: currentLocale,
            screenWidth: screenWidth,
          ),
          const SizedBox(height: 10),

          // Payment Link Section - Responsive
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 400;
                return isSmallScreen
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppStrings.getString('paymentLink', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.blackBackground,
                            ),
                          ),
                        ),
                        Switch(
                          value: provider.showPaymentLink,
                          activeColor: AppColors.mainColor,
                          onChanged: (val) {
                            provider.showPaymentLink = val;
                          },
                        ),
                      ],
                    ),
                    if (provider.showPaymentLink) ...[
                      const SizedBox(height: 10),
                      _buildPaymentLinkField(provider, currentLocale),
                    ],
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.getString('paymentLink', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackBackground,
                      ),
                    ),
                    Switch(
                      value: provider.showPaymentLink,
                      activeColor: AppColors.mainColor,
                      onChanged: (val) {
                        provider.showPaymentLink = val;
                      },
                    ),
                    if (provider.showPaymentLink)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: _buildPaymentLinkField(provider, currentLocale),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // QR Code Section - Responsive
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 400;
                return isSmallScreen
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getString('qrCode', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackBackground,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildQRCodeSection(provider),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.getString('qrCode', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.blackBackground,
                      ),
                    ),
                    _buildQRCodeSection(provider),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          provider.isLoading
              ? SpinKitChasingDots(
            color: AppColors.mainColor,
          ):
          Center(
            child: GestureDetector(
              onTap: provider.isSaveDisabled ? null : () async {
                final success = await provider.submitHadiyaDetails(
                  FirebaseAuth.instance.currentUser!.uid,
                );
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppStrings.getString('bankDetailsSaved', currentLocale))),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminBottomNavigationBar()),
                  );
                }
              },
              child: Container(
                height: 40,
                width: 200,
                decoration: BoxDecoration(
                  color: provider.isSaveDisabled
                      ? Colors.grey
                      : AppColors.mainColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    AppStrings.getString('save', currentLocale),
                    style: GoogleFonts.poppins(
                      color: AppColors.whiteBackground,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildResponsiveTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required String currentLocale,
    required double screenWidth,
  }) {
    final isSmallScreen = screenWidth < 400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: isSmallScreen
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.blackBackground,
            ),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 35,
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(fontSize: 12),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      )
          : Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.blackBackground,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 3,
            child: SizedBox(
              height: 35,
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                style: GoogleFonts.poppins(fontSize: 12),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLinkField(HadiyaProvider provider, String currentLocale) {
    return SizedBox(
      height: 35,
      child: TextFormField(
        controller: provider.paymentLinkController,
        style: GoogleFonts.poppins(fontSize: 12),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          hintText: AppStrings.getString('enterPaymentLink', currentLocale),
          hintStyle: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildQRCodeSection(HadiyaProvider provider) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            provider.pickQRImage();
          },
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: provider.qrImage != null
                ? Image.file(
              provider.qrImage!,
              height: 80,
              width: 80,
              fit: BoxFit.fill,
            )
                : Image.asset(
              'assets/images/user.png',
              height: 80,
              width: 80,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: InkWell(
            onTap: () {
              if (provider.qrImage != null) {
                provider.removeQRImage();
              } else {
                provider.pickQRImage();
              }
            },
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.mainColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  provider.qrImage != null ? Icons.delete : Icons.camera_alt,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}