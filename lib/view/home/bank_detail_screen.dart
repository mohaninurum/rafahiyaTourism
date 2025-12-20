
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rafahiyatourism/view/super_admin_code/createuserwallet/full_screen_image_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';

import '../../utils/language/app_strings.dart';

class BankDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> hadiyaDetails;
  final String type;

  const BankDetailsScreen({
    super.key,
    required this.hadiyaDetails,
    required this.type,
  });

  @override
  State<BankDetailsScreen> createState() => _BankDetailsScreenState();
}

class _BankDetailsScreenState extends State<BankDetailsScreen> {
  Future<void> _launchPaymentLink() async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    final paymentLink = widget.hadiyaDetails['paymentLink'];

    if (paymentLink == null || paymentLink.toString().isEmpty) {
      _showSnackBar(AppStrings.getString('paymentLinkNotAvailableError', currentLocale));
      return;
    }

    final Uri url = Uri.parse(paymentLink.toString());

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
    } else {
      _showSnackBar(AppStrings.getString('couldNotLaunchPaymentLink', currentLocale));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    final accountHolder = widget.type == 'Masjid'
        ? AppStrings.getString('masjidBankDetails', currentLocale)
        : AppStrings.getString('maulanaBankDetails', currentLocale);
    final accountHolderName = widget.hadiyaDetails['accountHolderName'] ?? AppStrings.getString('notAvailable', currentLocale);
    final accountNumber = widget.hadiyaDetails['accountNumber'] ?? AppStrings.getString('notAvailable', currentLocale);
    final bankDetails = widget.hadiyaDetails['bankDetails'] ?? AppStrings.getString('notAvailable', currentLocale);
    final ifscCode = widget.hadiyaDetails['ifscCode'] ?? AppStrings.getString('notAvailable', currentLocale);
    final qrCodeUrl = widget.hadiyaDetails['qrCodeUrl'];
    final paymentLink = widget.hadiyaDetails['paymentLink'];
    final hasPaymentLink = paymentLink != null && paymentLink.toString().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'Masjid'
              ? AppStrings.getString('masjidBankDetails', currentLocale)
              : AppStrings.getString('maulanaBankDetails', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_new_outlined,
            color: AppColors.whiteColor,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getString('accountInformation', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mainColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(
                        "${AppStrings.getString('accountHolder', currentLocale)}:",
                        accountHolderName,
                        currentLocale
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                        "${AppStrings.getString('accountNumber', currentLocale)}:",
                        accountNumber,
                        currentLocale
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                        "${AppStrings.getString('ifscCode', currentLocale)}:",
                        ifscCode,
                        currentLocale
                    ),
                    const SizedBox(height: 15),
                    _buildDetailRow(
                        "${AppStrings.getString('bankName', currentLocale)}:",
                        bankDetails,
                        currentLocale
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Scan to Pay section
            if (qrCodeUrl != null) Center(
              child: Column(
                children: [
                  Text(
                    AppStrings.getString('scanToPay', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> FullScreenImageViewer(imageUrl: qrCodeUrl)));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: qrCodeUrl,
                        width: 150,
                        height: 150,
                        placeholder: (context, url) => SizedBox(
                          width: 150,
                          height: 150,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mainColor,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.qr_code_scanner,
                          size: 120,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.getString('scanQrCode', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Payment Link Button - Only show if payment link exists
            if (hasPaymentLink) Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _launchPaymentLink,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.getString('openPaymentLink', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Show message if no payment link available
            if (!hasPaymentLink) Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  AppStrings.getString('paymentLinkNotAvailable', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Additional information
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    AppStrings.getString('paymentNote', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (hasPaymentLink) ...[
                    const SizedBox(height: 10),
                    Text(
                      AppStrings.getString('paymentLinkNote', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String currentLocale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}