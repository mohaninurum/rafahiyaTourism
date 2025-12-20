
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/createuserwallet/full_screen_image_view.dart';
import '../../../../const/color.dart';
import '../../../admin_side_code/data/models/hadiya_model.dart';
import '../../superadminprovider/pending_hadiyah_provider/pending_hadiyah_provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class HadiyaRequestDetailScreen extends StatelessWidget {
  final HadiyaModel request;

  const HadiyaRequestDetailScreen({super.key, required this.request});

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<PendingHadiyaProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          AppStrings.getString('hadiyaRequestDetails', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: provider.getMosqueDetails(request.subAdminId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppColors.mainColor));
          }

          final mosqueData = snapshot.data;
          final mosqueName = mosqueData?['masjidName'] ?? AppStrings.getString('unknownMosque', currentLocale);
          final imamName = mosqueData?['imamName'] ?? AppStrings.getString('unknownImam', currentLocale);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(mosqueName, imamName, currentLocale),
                const SizedBox(height: 32),
                _buildDetailCard(currentLocale,context),
                const SizedBox(height: 24),
                request.allowed != true ?
                _buildActionButtons(context, currentLocale):
                InkWell(
                  onTap: (){
                    _showDeleteConfirmationDialog(context, request, currentLocale);
                  },
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.mainColor,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_forever,color: AppColors.whiteColor,),
                          SizedBox(
                            width: 10,
                          ),
                          Text(AppStrings.getString('delete', currentLocale),style: GoogleFonts.roboto(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),),
                        ],
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

  Widget _buildProfileHeader(String mosqueName, String imamName, String currentLocale) {
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
            child: Icon(
              request.type == 'Masjid' ? Icons.mosque : Icons.person,
              size: 60,
              color: AppColors.mainColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            request.type == 'Masjid' ? mosqueName : imamName,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            request.type,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String currentLocale,BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.account_balance, AppStrings.getString('bankDetails', currentLocale), request.bankDetails, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.numbers, AppStrings.getString('accountNumber', currentLocale), request.accountNumber, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.manage_search, AppStrings.getString('ifscCode', currentLocale), request.ifscCode, currentLocale),
            const Divider(height: 24),
            if (request.qrCodeUrl != null && request.qrCodeUrl!.isNotEmpty)
              Column(
                children: [
                  _buildDetailRow(Icons.qr_code, AppStrings.getString('qrCode', currentLocale), "", currentLocale),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> FullScreenImageViewer(imageUrl: request.qrCodeUrl!)));
                    },
                    child: Center(
                      child: Image.network(
                        request.qrCodeUrl!,
                        height: 150,
                        width: 150,
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                ],
              ),
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

  void _showDeleteConfirmationDialog(BuildContext context, HadiyaModel hadiya, String currentLocale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.getString('deleteHadiya', currentLocale),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "${AppStrings.getString('confirmDeleteHadiya', currentLocale)} ${hadiya.type}?",
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
            onPressed: () async {
              try {
                final provider = Provider.of<PendingHadiyaProvider>(context, listen: false);
                await provider.deleteHadiya(hadiya.subAdminId, hadiya.id);

                Navigator.pop(context);
                Navigator.pop(context); // Go back to previous screen

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.getString('hadiyaDeletedSuccessfully', currentLocale)),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${AppStrings.getString('error', currentLocale)}: ${e.toString()}"),
                  ),
                );
              }
            },
            child: Text(
              AppStrings.getString('delete', currentLocale),
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, String currentLocale) {
    final provider = Provider.of<PendingHadiyaProvider>(context, listen: false);

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
            onPressed: () => _showConfirmationDialog(context, provider, isApproved: false, currentLocale: currentLocale),
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
            onPressed: () => _showConfirmationDialog(context, provider, isApproved: true, currentLocale: currentLocale),
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
      BuildContext context,
      PendingHadiyaProvider provider, {
        required bool isApproved,
        required String currentLocale,
      })
  {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isApproved
              ? AppStrings.getString('approveHadiya', currentLocale)
              : AppStrings.getString('rejectHadiya', currentLocale),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          isApproved
              ? AppStrings.getString('confirmApproveHadiya', currentLocale)
              : AppStrings.getString('confirmRejectHadiya', currentLocale),
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
            onPressed: () async {
              try {
                await provider.updateHadiyaStatus(
                  request.id!,
                  request.subAdminId,
                  isApproved,
                );
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isApproved
                          ? AppStrings.getString('hadiyaApprovedSuccessfully', currentLocale)
                          : AppStrings.getString('hadiyaRejectedSuccessfully', currentLocale),
                    ),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("${AppStrings.getString('error', currentLocale)}: ${e.toString()}"),
                  ),
                );
              }
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