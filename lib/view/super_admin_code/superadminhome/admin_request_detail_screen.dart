import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../const/color.dart';
import '../models/masjid_imam_adminlist.dart';
import '../superadminprovider/pending_admin_imam_list.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import 'all_admins.dart';

class AdminRequestDetailScreen extends StatelessWidget {
  final MasjidImamAdminModel request;

  const AdminRequestDetailScreen({super.key, required this.request});

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          AppStrings.getString('adminRequestDetails', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(currentLocale),
            const SizedBox(height: 32),
            _buildDetailCard(currentLocale),
            const SizedBox(height: 24),
            _buildProofDocumentSection(context, currentLocale),
            const SizedBox(height: 24),
            _buildCheckAdminsButton(context, currentLocale),
            const SizedBox(height: 24),
            _buildActionButtons(context, currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String currentLocale) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.mainColor.withOpacity(0.1),
              border: Border.all(color: AppColors.mainColor, width: 2),
            ),
            child: request.imageUrl.isNotEmpty
                ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: request.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.person, size: 60, color: AppColors.mainColor),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.mainColor,
                ),
              ),
            )
                : Icon(Icons.person, size: 60, color: AppColors.mainColor),
          ),
          const SizedBox(height: 16),
          Text(
            request.imamName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.email,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String currentLocale) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.phone, AppStrings.getString('phoneNumber', currentLocale), request.mobileNumber, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.mosque, AppStrings.getString('masjidName', currentLocale), request.masjidName, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.location_on, AppStrings.getString('pincode', currentLocale), request.pinCode, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.home, AppStrings.getString('address', currentLocale), request.address, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(
              Icons.calendar_today,
              AppStrings.getString('requestDate', currentLocale),
              request.createdAt.toString(),
              currentLocale,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProofDocumentSection(BuildContext context, String currentLocale) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified, size: 24, color: AppColors.mainColor),
                const SizedBox(width: 12),
                Text(
                  AppStrings.getString('proofOfAssociation', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (request.proofUrl.isNotEmpty)
              Column(
                children: [
                  // Proof Document Image
                  GestureDetector(
                    onTap: () => _showImageDialog(request.proofUrl, context, currentLocale),
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                        color: Colors.grey[50],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: request.proofUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mainColor,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppStrings.getString('failedToLoadImage', currentLocale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Document Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: AppColors.mainColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.getString('tapToViewFullSize', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, size: 20, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.getString('noProofDocument', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showImageDialog(String imageUrl, BuildContext context, String currentLocale) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              // Background with blur effect
              BackdropFilter(
                filter: ColorFilter.mode(
                  Colors.black.withOpacity(0.7),
                  BlendMode.darken,
                ),
                child: Container(
                  color: Colors.black54,
                ),
              ),

              // Image content
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                      ),

                      // Image with zoom capability
                      InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => Container(
                            width: 300,
                            height: 400,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.mainColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 300,
                            height: 400,
                            color: Colors.grey[200],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 50,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  AppStrings.getString('failedToLoadImage', currentLocale),
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Zoom instructions
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppStrings.getString('zoomInstructions', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, String currentLocale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: AppColors.mainColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckAdminsButton(BuildContext context, String currentLocale) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue[50],
        foregroundColor: AppColors.mainColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.mainColor.withOpacity(0.3)),
        ),
        elevation: 0,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllAdminsScreen(initialPincode: request.pinCode),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 20),
          const SizedBox(width: 8),
          Text(
            '${AppStrings.getString('checkExistingAdmins', currentLocale)} (${AppStrings.getString('pincode', currentLocale)}: ${request.pinCode})',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String currentLocale) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dialogueItemsBackgroundColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _showConfirmationDialog(context, isApproved: false, currentLocale: currentLocale),
            child: Text(
              AppStrings.getString('reject', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _showConfirmationDialog(context, isApproved: true, currentLocale: currentLocale),
            child: Text(
              AppStrings.getString('approve', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showConfirmationDialog(
      BuildContext context, {
        required bool isApproved,
        required String currentLocale,
      }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isApproved
              ? AppStrings.getString('approveAdmin', currentLocale)
              : AppStrings.getString('rejectAdmin', currentLocale),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          isApproved
              ? '${AppStrings.getString('confirmApproveAdmin', currentLocale)} ${request.imamName} ${AppStrings.getString('asAdmin', currentLocale)}'
              : '${AppStrings.getString('confirmRejectAdmin', currentLocale)} ${request.imamName}\'s ${AppStrings.getString('adminRequest', currentLocale)}',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.getString('cancel', currentLocale),
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: isApproved
                ? () {
              final provider = Provider.of<PendingAdminImamListProvider>(
                context,
                listen: false,
              );
              provider.updateRegistrationStatus(
                request.uid,
                isApproved,
              );
              Navigator.pop(context);
              Navigator.pop(context);
            }
                : () {
              Navigator.pop(context);
              Navigator.pop(context);
              print("Abak");
            },
            child: Text(
              isApproved
                  ? AppStrings.getString('approve', currentLocale)
                  : AppStrings.getString('reject', currentLocale),
              style: GoogleFonts.poppins(
                color: isApproved ? AppColors.mainColor : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}