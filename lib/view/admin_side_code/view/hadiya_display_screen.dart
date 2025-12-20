

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../const/color.dart';
import '../admin_bottom_navigationbar.dart';
import '../data/models/hadiya_model.dart';
import '../data/subAdminProvider/add_hadiya_maulana_provider.dart';
import '../data/utils/circular_indicator_spinkit.dart';
import '../../../provider/locale_provider.dart';
import '../../../utils/language/app_strings.dart';

class HadiyaDetailScreen extends StatelessWidget {
  final HadiyaModel hadiya;

  const HadiyaDetailScreen({super.key, required this.hadiya});

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: AppColors.featherGrey,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('bankDetails', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios_new_outlined,color: AppColors.whiteColor,)),
        backgroundColor: AppColors.mainColor,
        foregroundColor: AppColors.whiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Information Box
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.getString('accountInformation', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  // FIX 1: Use accountHolderName instead of type
                  _infoRow(AppStrings.getString('accountHolder', currentLocale), hadiya.accountHolderName ?? hadiya.type, currentLocale),
                  _infoRow(AppStrings.getString('accountNumber', currentLocale), hadiya.accountNumber, currentLocale),
                  _infoRow(AppStrings.getString('ifscCode', currentLocale), hadiya.ifscCode, currentLocale),
                  _infoRow(AppStrings.getString('bankName', currentLocale), hadiya.bankDetails, currentLocale),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // QR Code
            Center(
              child: Column(
                children: [
                  Text(
                    AppStrings.getString('scanToPay', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  hadiya.qrCodeUrl != null && hadiya.qrCodeUrl!.isNotEmpty
                      ? Image.network(hadiya.qrCodeUrl!, height: 120)
                      : const Icon(
                    Icons.qr_code,
                    size: 120,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    AppStrings.getString('scanQrCodeMessage', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Request Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  _showUpdateDialog(context, hadiya);
                },
                child: Text(
                  AppStrings.getString('change', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Delete Button
            MaterialButton(
              color: Colors.red,
              minWidth: double.infinity,
              height: 50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                _showDeleteDialog(context, hadiya);
              },
              child: Consumer<HadiyaProvider>(
                builder: (context, provider, child) {
                  return provider.isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    AppStrings.getString('delete', currentLocale),
                    style: GoogleFonts.poppins(
                      color: AppColors.whiteColor,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, HadiyaModel hadiya) {
    final currentLocale = _getCurrentLocale(context);

    // FIX 1: Use accountHolderName instead of type
    final accountHolderController = TextEditingController(text: hadiya.accountHolderName ?? hadiya.type);
    final typeController = TextEditingController(text: hadiya.type);
    final bankController = TextEditingController(text: hadiya.bankDetails);
    final accountController = TextEditingController(text: hadiya.accountNumber);
    final ifscController = TextEditingController(text: hadiya.ifscCode);
    final paymentLinkController = TextEditingController(
      text: hadiya.paymentLink ?? "",
    );

    XFile? pickedImage; // For QR image
    bool keepExistingQR = true; // FIX 2: Flag to track QR code preservation

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.whiteColor,
              title: Text(
                AppStrings.getString('requestToUpdateHadiya', currentLocale),
                style: GoogleFonts.poppins(
                  color: AppColors.mainColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FIX 1: Add Account Holder Name field
                    TextField(
                      controller: accountHolderController,
                      decoration: InputDecoration(labelText: AppStrings.getString('accountHolderName', currentLocale)),
                    ),
                    TextField(
                      controller: typeController,
                      decoration: InputDecoration(labelText: AppStrings.getString('type', currentLocale)),
                    ),
                    TextField(
                      controller: bankController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('bankDetails', currentLocale),
                      ),
                    ),
                    TextField(
                      controller: accountController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('accountNumber', currentLocale),
                      ),
                    ),
                    TextField(
                      controller: ifscController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('ifscCode', currentLocale),
                      ),
                    ),
                    TextField(
                      controller: paymentLinkController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('paymentLink', currentLocale),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // FIX 2: Add option to keep existing QR code
                    Row(
                      children: [
                        Checkbox(
                          value: keepExistingQR,
                          onChanged: (value) {
                            setState(() {
                              keepExistingQR = value ?? true;
                              if (keepExistingQR) {
                                pickedImage = null;
                              }
                            });
                          },
                        ),
                        Text(
                          AppStrings.getString('keepExistingQrCode', currentLocale),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ],
                    ),

                    Center(
                      child: Text(
                        AppStrings.getString('addQrCode', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Center(
                      child: InkWell(
                        onTap: keepExistingQR ? null : () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            setState(() {
                              pickedImage = image;
                            });
                          }
                        },
                        child: Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: keepExistingQR
                              ? hadiya.qrCodeUrl != null && hadiya.qrCodeUrl!.isNotEmpty
                              ? Image.network(hadiya.qrCodeUrl!)
                              : Icon(Icons.lock, color: Colors.grey)
                              : pickedImage != null
                              ? Image.file(File(pickedImage!.path))
                              : Icon(
                            Icons.add_a_photo,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    if (keepExistingQR)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          AppStrings.getString('existingQrCodePreserved', currentLocale),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppStrings.getString('cancel', currentLocale),
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Consumer<HadiyaProvider>(
                  builder: (context, provider, child) {
                    return MaterialButton(
                      color: AppColors.mainColor,
                      onPressed:
                      provider.isLoading
                          ? null
                          : () async {
                        // FIX 1: Include accountHolderName in update data
                        final updateData = {
                          "accountHolderName": accountHolderController.text.trim(),
                          "type": typeController.text.trim(),
                          "bankDetails": bankController.text.trim(),
                          "accountNumber": accountController.text.trim(),
                          "ifscCode": ifscController.text.trim(),
                          "paymentLink": paymentLinkController.text.trim(),
                          "allowed": false,
                          'createdAt': FieldValue.serverTimestamp(),
                          "subAdminId": hadiya.subAdminId
                        };

                        // FIX 2: Preserve existing QR code if keepExistingQR is true
                        if (keepExistingQR && hadiya.qrCodeUrl != null) {
                          updateData['qrCodeUrl'] = hadiya.qrCodeUrl!;
                        }

                        // Remove empty fields but preserve important ones
                        updateData.removeWhere(
                              (key, value) => value == null || (value is String && value.isEmpty && key != 'paymentLink'),
                        );

                        await provider.updateHadiya(
                          subAdminId: hadiya.subAdminId,
                          documentId: hadiya.id,
                          updateData: updateData,
                          qrFile: keepExistingQR ? null : pickedImage, // FIX 2: Only pass new image if not keeping existing
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.getString('updatedWaitingApproval', currentLocale),
                            ),
                          ),
                        );
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminBottomNavigationBar()));
                      },
                      child:
                      provider.isLoading
                          ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CustomCircularProgressIndicator(
                          size: 20,
                          color: AppColors.backgroundColor1,
                          spinKitType: SpinKitType.chasingDots,
                        ),
                      )
                          : Text(
                        AppStrings.getString('requestToUpdate', currentLocale),
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, HadiyaModel hadiya) {
    final currentLocale = _getCurrentLocale(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(
            AppStrings.getString('confirmDelete', currentLocale),
            style: GoogleFonts.poppins(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            AppStrings.getString('confirmDeleteMessage', currentLocale),
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.red,
              onPressed: () async {
                final provider = Provider.of<HadiyaProvider>(
                  context,
                  listen: false,
                );

                await provider.deleteHadiya(
                  subAdminId: hadiya.subAdminId,
                  documentId: hadiya.id,
                  qrCodeUrl: hadiya.qrCodeUrl,
                );

                Navigator.of(context).pop();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(AppStrings.getString('deletedSuccessfully', currentLocale))));
              },
              child: Text(
                AppStrings.getString('delete', currentLocale),
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}