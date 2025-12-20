

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/hadiya_display_screen.dart';
import 'package:rafahiyatourism/view/super_admin_code/createuserwallet/full_screen_image_view.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/super_admin_home.dart';
import '../../../const/color.dart';
import '../../admin_side_code/data/models/hadiya_model.dart';
import '../models/sub_admin_model/sub_admin_model.dart';
import '../superadminprovider/sub_admin_detail_provider/sub_admin_provider.dart';
import 'hadiyah/handiyah_request_detail_screen.dart';

class AdminDetailScreen extends StatefulWidget {
  final Admin admin;

  const AdminDetailScreen({super.key, required this.admin});

  @override
  State<AdminDetailScreen> createState() => _AdminDetailScreenState();
}

class _AdminDetailScreenState extends State<AdminDetailScreen> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubAdminDetailProvider>().loadAllHadiyaDetails(widget.admin.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('adminDetails', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<SubAdminDetailProvider>().loadAdmins();
              context.read<SubAdminDetailProvider>().loadAllHadiyaDetails(widget.admin.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(currentLocale),
            const SizedBox(height: 32),
            _buildDetailCard(currentLocale),
            const SizedBox(height: 32),
            _buildHadiyaSection(context, currentLocale),
            const SizedBox(height: 32),
            _buildActionButtons(context, currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildHadiyaSection(BuildContext context, String currentLocale) {
    return Consumer<SubAdminDetailProvider>(
      builder: (context, provider, _) {
        final hadiyaLoading = provider.isHadiyaLoading(widget.admin.id);
        final hadiyaError = provider.getHadiyaError(widget.admin.id);
        final allHadiyaDetails = provider.getAllHadiyaDetails(widget.admin.id);

        if (hadiyaLoading) {
          return _buildLoadingCard(currentLocale);
        }

        if (hadiyaError != null) {
          return _buildErrorCard(hadiyaError, currentLocale, provider);
        }

        return _buildHadiyaCards(allHadiyaDetails, currentLocale, provider);
      },
    );
  }

  Widget _buildLoadingCard(String currentLocale) {
    return Card(
      color: AppColors.whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppColors.mainColor),
              const SizedBox(height: 16),
              Text(
                AppStrings.getString('loadingHadiyaDetails', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String error, String currentLocale, SubAdminDetailProvider provider) {
    final isIndexError = error.contains('index');
    final errorMessage = isIndexError
        ? AppStrings.getString('noHadiyaDetailAvailable', currentLocale)
        : AppStrings.getString('errorLoadingHadiya', currentLocale);

    return Card(
      color: AppColors.whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              isIndexError ? CupertinoIcons.archivebox : Icons.error_outline,
              color: isIndexError ? AppColors.mainColor : Colors.red,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isIndexError ? AppColors.mainColor : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isIndexError) ...[
              const SizedBox(height: 8),
              Text(
                AppStrings.getString('oneTimeSetupProcess', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.loadAllHadiyaDetails(widget.admin.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: isIndexError ? AppColors.mainColor : Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppStrings.getString('retry', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadiyaCards(List<HadiyaModel> hadiyaDetails, String currentLocale, SubAdminDetailProvider provider) {
    if (hadiyaDetails.isEmpty) {
      return _buildNoHadiyaCard(currentLocale, provider);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('hadiyaDetails', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        ...hadiyaDetails.map((hadiya) => _buildHadiyaCard(hadiya, currentLocale)).toList(),
      ],
    );
  }

  Widget _buildHadiyaCard(HadiyaModel hadiya, String currentLocale) {
    final isMasjid = hadiya.type == 'Masjid';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with type and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isMasjid ? Colors.blue.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isMasjid ? Icons.mosque : Icons.person,
                  color: isMasjid ? Colors.blue : Colors.green,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMasjid
                            ? AppStrings.getString('masjidHadiya', currentLocale)
                            : AppStrings.getString('maulanaHadiya', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isMasjid ? Colors.blue : Colors.green,
                        ),
                      ),
                      Text(
                        hadiya.accountHolderName ?? AppStrings.getString('notProvided', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hadiya.allowed
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hadiya.allowed
                        ? AppStrings.getString('approved', currentLocale)
                        : AppStrings.getString('pending', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: hadiya.allowed ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHadiyaDetailRow(
                  AppStrings.getString('accountNumber', currentLocale),
                  hadiya.accountNumber,
                  currentLocale,
                ),
                const SizedBox(height: 8),
                _buildHadiyaDetailRow(
                  AppStrings.getString('bankDetails', currentLocale),
                  hadiya.bankDetails,
                  currentLocale,
                ),
                const SizedBox(height: 8),
                if (hadiya.ifscCode != null && hadiya.ifscCode!.isNotEmpty)
                  _buildHadiyaDetailRow(
                    AppStrings.getString('ifscCode', currentLocale),
                    hadiya.ifscCode!,
                    currentLocale,
                  ),

                // QR Code if available
                if (hadiya.qrCodeUrl != null && hadiya.qrCodeUrl!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          AppStrings.getString('qrCode', currentLocale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> FullScreenImageViewer(imageUrl: hadiya.qrCodeUrl!)));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                hadiya.qrCodeUrl!,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 80,
                                    width: 80,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.qr_code, color: Colors.grey[400]),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Buttons
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HadiyaRequestDetailScreen(
                                request: hadiya,
                              ),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.mainColor),
                        ),
                        child: Text(
                          AppStrings.getString('viewDetails', currentLocale),
                          style: GoogleFonts.poppins(
                            color: AppColors.mainColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _approveHadiya(context, hadiya, currentLocale),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hadiya.allowed ? Colors.grey : AppColors.mainColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          hadiya.allowed
                              ? AppStrings.getString('approved', currentLocale)
                              : AppStrings.getString('approve', currentLocale),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoHadiyaCard(String currentLocale, SubAdminDetailProvider provider) {
    return Card(
      color: AppColors.whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet, size: 40, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                AppStrings.getString('noHadiyaDetailsFound', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.getString('adminNotSubmittedHadiya', currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.loadAllHadiyaDetails(widget.admin.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  AppStrings.getString('checkAgain', currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHadiyaDetailRow(String label, String value, String currentLocale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value.isNotEmpty ? value : AppStrings.getString('notProvided', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _approveHadiya(BuildContext context, HadiyaModel hadiya, String currentLocale) async {
    if (hadiya.allowed) return; // Already approved

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            AppStrings.getString('approveHadiya', currentLocale),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)
        ),
        content: Text(
            "${AppStrings.getString('approveHadiyaConfirmation', currentLocale)} ${hadiya.type}."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey[600])
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
                AppStrings.getString('approve', currentLocale),
                style: GoogleFonts.poppins(color: Colors.green, fontWeight: FontWeight.w600)
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final provider = context.read<SubAdminDetailProvider>();
        await provider.toggleHadiyaStatus(hadiya.subAdminId, hadiya.id, true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.getString('hadiyaApprovedSuccess', currentLocale))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.getString('failedToApproveHadiya', currentLocale)}: $e')),
        );
      }
    }
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
              border: Border.all(
                color: AppColors.mainColor,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 60,
              color: AppColors.mainColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.admin.name,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.admin.successfullyRegistered
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.admin.successfullyRegistered
                  ? AppStrings.getString('active', currentLocale)
                  : AppStrings.getString('inactive', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: widget.admin.successfullyRegistered ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String currentLocale) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.email, AppStrings.getString('email', currentLocale), widget.admin.email, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.phone, AppStrings.getString('phone', currentLocale), widget.admin.phone, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.mosque, AppStrings.getString('masjid', currentLocale), widget.admin.masjidName, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.location_on, AppStrings.getString('pincode', currentLocale), widget.admin.pincode, currentLocale),
            const Divider(height: 24),
            _buildDetailRow(Icons.house, AppStrings.getString('address', currentLocale), widget.admin.address, currentLocale),
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

  Widget _buildActionButtons(BuildContext context, String currentLocale) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: widget.admin.successfullyRegistered ? Colors.grey : Colors.green,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => _toggleAdminStatus(context, currentLocale),
            child: Text(
              widget.admin.successfullyRegistered
                  ? AppStrings.getString('deactivate', currentLocale)
                  : AppStrings.getString('activate', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: widget.admin.successfullyRegistered ? Colors.grey : Colors.green,
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
            onPressed: () => _confirmDelete(context, currentLocale),
            child: Text(
              AppStrings.getString('removeAdmin', currentLocale),
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

  Future<void> _toggleAdminStatus(BuildContext context, String currentLocale) async {
    final provider = context.read<SubAdminDetailProvider>();
    final newStatus = !widget.admin.successfullyRegistered;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newStatus
              ? AppStrings.getString('activateAdmin', currentLocale)
              : AppStrings.getString('deactivateAdmin', currentLocale),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          newStatus
              ? "${AppStrings.getString('activateAdminConfirmation', currentLocale)} ${widget.admin.name} ${AppStrings.getString('accessAdminFeatures', currentLocale)}"
              : "${AppStrings.getString('deactivateAdminConfirmation', currentLocale)} ${widget.admin.name} ${AppStrings.getString('accessAdminFeatures', currentLocale)}",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey[600])
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              newStatus
                  ? AppStrings.getString('activate', currentLocale)
                  : AppStrings.getString('deactivate', currentLocale),
              style: GoogleFonts.poppins(
                color: newStatus ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.toggleAdminStatus(widget.admin.id, newStatus);

        Fluttertoast.showToast(
          msg: newStatus
              ? AppStrings.getString('adminActivatedSuccess', currentLocale)
              : AppStrings.getString('adminDeactivatedSuccess', currentLocale),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SuperAdminHome()),
              (route) => false,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: '${AppStrings.getString('failedToUpdateAdmin', currentLocale)}: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, String currentLocale) async {
    final provider = context.read<SubAdminDetailProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.getString('removeAdmin', currentLocale),
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "${AppStrings.getString('removeAdminConfirmation', currentLocale)} ${widget.admin.name} ${AppStrings.getString('asAdmin', currentLocale)}",
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
                AppStrings.getString('cancel', currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey[600])
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppStrings.getString('remove', currentLocale),
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.deleteAdmin(widget.admin.id);

        Fluttertoast.showToast(
          msg: AppStrings.getString('adminRemovedSuccess', currentLocale),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black87,
          textColor: Colors.white,
        );

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const SuperAdminHome()),
              (route) => false,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: '${AppStrings.getString('failedToRemoveAdmin', currentLocale)}: $e',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

}