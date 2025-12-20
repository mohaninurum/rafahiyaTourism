

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/const/color.dart';

import '../superadminprovider/sub_admin_detail_provider/sub_admin_provider.dart';
import 'bayan_detail_card.dart';

class SuperAdminBayanManagementScreen extends StatefulWidget {
  const SuperAdminBayanManagementScreen({super.key});

  @override
  State<SuperAdminBayanManagementScreen> createState() => _SuperAdminBayanManagementScreenState();
}

class _SuperAdminBayanManagementScreenState extends State<SuperAdminBayanManagementScreen> {
  List<Map<String, dynamic>> _allBayans = [];
  bool _isLoading = true;
  String _searchQuery = '';

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _loadAllBayans();
  }

  Future<void> _loadAllBayans() async {
    setState(() {
      _isLoading = true;
    });

    final bayans = await context.read<SubAdminDetailProvider>().fetchAllBayansForSuperAdmin();

    setState(() {
      _allBayans = bayans;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredBayans {
    if (_searchQuery.isEmpty) return _allBayans;

    return _allBayans.where((bayan) {
      final title = bayan['title']?.toString().toLowerCase() ?? '';
      final mosqueName = bayan['mosqueName']?.toString().toLowerCase() ?? '';
      final authorEmail = bayan['authorEmail']?.toString().toLowerCase() ?? '';
      final authorName = bayan['authorName']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return title.contains(query) ||
          mosqueName.contains(query) ||
          authorEmail.contains(query) ||
          authorName.contains(query);
    }).toList();
  }

  Future<void> _deleteBayan(Map<String, dynamic> bayan, String currentLocale) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('deleteBayan', currentLocale)),
        content: Text('${AppStrings.getString('deleteBayanConfirmation', currentLocale)} "${bayan['title']}" ${AppStrings.getString('from', currentLocale)} ${bayan['mosqueName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.getString('cancel', currentLocale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
                AppStrings.getString('delete', currentLocale),
                style: GoogleFonts.poppins(color: Colors.red)
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await context.read<SubAdminDetailProvider>().deleteBayanAsSuperAdmin(
          bayan['subAdminId'], // Use subAdminId instead of mosqueId
          bayan['id'],
        );

        // Remove from local list
        setState(() {
          _allBayans.removeWhere((b) => b['id'] == bayan['id'] && b['subAdminId'] == bayan['subAdminId']);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('bayanDeletedSuccess', currentLocale)),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.getString('errorDeletingBayan', currentLocale)}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBayanDetails(Map<String, dynamic> bayan, String currentLocale) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _BayanDetailsSheet(bayan: bayan, currentLocale: currentLocale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(
                Icons.arrow_back_ios_new_outlined,
                color: AppColors.whiteColor
            )
        ),
        title: Text(
          AppStrings.getString('bayanList', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.whiteColor,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadAllBayans,
            icon: Icon(Icons.refresh, color: AppColors.whiteColor),
            tooltip: AppStrings.getString('refresh', currentLocale),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppStrings.getString('searchBayansHint', currentLocale),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Statistics
          if (!_isLoading) _buildStatistics(currentLocale),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBayans.isEmpty
                ? _buildEmptyState(currentLocale)
                : _buildBayanList(currentLocale),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(String currentLocale) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              AppStrings.getString('totalBayans', currentLocale),
              _allBayans.length.toString(),
              Icons.announcement,
              Colors.white,
              currentLocale
          ),
          _buildStatItem(
              AppStrings.getString('subadmins', currentLocale),
              _allBayans.map((b) => b['subAdminId']).toSet().length.toString(),
              Icons.person,
              Colors.white,
              currentLocale
          ),
          _buildStatItem(
              AppStrings.getString('today', currentLocale),
              _getTodayBayans().toString(),
              Icons.today,
              Colors.white,
              currentLocale
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color, String currentLocale) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.whiteColor),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),
        ),
      ],
    );
  }

  int _getTodayBayans() {
    final now = DateTime.now();
    return _allBayans.where((bayan) {
      final bayanDate = (bayan['createdAt'] as Timestamp).toDate();
      return bayanDate.year == now.year &&
          bayanDate.month == now.month &&
          bayanDate.day == now.day;
    }).length;
  }

  Widget _buildEmptyState(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.announcement, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? AppStrings.getString('noBayansAvailable', currentLocale)
                : AppStrings.getString('noBayansFound', currentLocale),
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
          ),
          if (_searchQuery.isEmpty)
            TextButton(
              onPressed: _loadAllBayans,
              child: Text(AppStrings.getString('refresh', currentLocale)),
            ),
        ],
      ),
    );
  }

  Widget _buildBayanList(String currentLocale) {
    return RefreshIndicator(
      onRefresh: _loadAllBayans,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filteredBayans.length,
        itemBuilder: (context, index) {
          final bayan = _filteredBayans[index];
          return SuperAdminBayanCard(
            bayan: bayan,
            onDelete: () => _deleteBayan(bayan, currentLocale),
            onTap: () => _showBayanDetails(bayan, currentLocale),
          );
        },
      ),
    );
  }
}

// Bottom Sheet for Bayan Details
class _BayanDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> bayan;
  final String currentLocale;

  const _BayanDetailsSheet({required this.bayan, required this.currentLocale});

  @override
  Widget build(BuildContext context) {
    final date = (bayan['createdAt'] as Timestamp).toDate();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Text(
            bayan['title'] ?? AppStrings.getString('noTitle', currentLocale),
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          _buildDetailRow(
              AppStrings.getString('mosque', currentLocale),
              bayan['mosqueName'] ?? AppStrings.getString('unknown', currentLocale),
              currentLocale
          ),
          _buildDetailRow(
              AppStrings.getString('author', currentLocale),
              '${bayan['authorName'] ?? AppStrings.getString('unknown', currentLocale)} (${bayan['authorEmail'] ?? AppStrings.getString('unknown', currentLocale)})',
              currentLocale
          ),
          _buildDetailRow(
              AppStrings.getString('date', currentLocale),
              '${date.toLocal()}',
              currentLocale
          ),

          if ((bayan['videoLink'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildDetailRow(
                AppStrings.getString('videoLink', currentLocale),
                bayan['videoLink'],
                currentLocale
            ),
          ],

          if ((bayan['imageUrl'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            Text(
                '${AppStrings.getString('image', currentLocale)}:',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(bayan['imageUrl']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}





// AIzaSyD4ZqIfKBHWMLEcM8o2rdjwQzxqfA5YXDw
