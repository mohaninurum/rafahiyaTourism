import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

import '../../../const/color.dart';
import 'admin_detail_screen.dart';
import '../models/sub_admin_model/sub_admin_model.dart';
import '../superadminprovider/sub_admin_detail_provider/sub_admin_provider.dart';

class AllAdminsScreen extends StatefulWidget {
  final String? initialPincode;

  const AllAdminsScreen({super.key, this.initialPincode});

  @override
  State<AllAdminsScreen> createState() => _AllAdminsScreenState();
}

class _AllAdminsScreenState extends State<AllAdminsScreen> {
  late TextEditingController _searchController;
  List<Admin> _filteredAdmins = [];

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAdmins();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAdmins() async {
    await context.read<SubAdminDetailProvider>().loadAdmins();
    _filterAdmins('');

    // Load hadiya details for each admin
    final provider = context.read<SubAdminDetailProvider>();
    for (final admin in provider.admins) {
      provider.loadHadiyaDetail(admin.id);
    }
  }

  void _filterAdmins(String query) {
    final provider = context.read<SubAdminDetailProvider>();
    final allAdmins = provider.admins;

    setState(() {
      _filteredAdmins = allAdmins.where((admin) {
        final matchesPincode = widget.initialPincode == null ||
            admin.pincode == widget.initialPincode;

        final matchesSearch = query.isEmpty ||
            admin.name.toLowerCase().contains(query.toLowerCase()) ||
            admin.masjidName.toLowerCase().contains(query.toLowerCase()) ||
            admin.pincode.toLowerCase().contains(query.toLowerCase());

        return matchesPincode && matchesSearch;
      }).toList();
    });
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
          widget.initialPincode != null
              ? '${AppStrings.getString('adminsInPincode', currentLocale)} ${widget.initialPincode}'
              : AppStrings.getString('allAdmins', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SubAdminDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.admins.isEmpty) {
            return Center(child: SpinKitChasingDots(
              color: AppColors.mainColor,
            ));
          }

          if (provider.error != null) {
            return Center(child: Text(provider.error!));
          }

          return Column(
            children: [
              _buildSearchBar(currentLocale),
              if (widget.initialPincode != null) _buildPincodeHeader(currentLocale),
              Expanded(
                child: _filteredAdmins.isEmpty
                    ? _buildEmptyState(currentLocale)
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 16),
                  itemCount: _filteredAdmins.length,
                  itemBuilder: (context, index) {
                    return _buildAdminCard(_filteredAdmins[index], currentLocale);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(String currentLocale) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _filterAdmins,
          decoration: InputDecoration(
            hintText: AppStrings.getString('searchByNameMasjidPincode', currentLocale),
            hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
            prefixIcon: Icon(Icons.search, color: AppColors.mainColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _buildPincodeHeader(String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${AppStrings.getString('pincode', currentLocale)}: ${widget.initialPincode}',
              style: GoogleFonts.poppins(
                color: AppColors.mainColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${_filteredAdmins.length} ${_filteredAdmins.length == 1 ? AppStrings.getString('adminFound', currentLocale) : AppStrings.getString('adminsFound', currentLocale)}',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(Admin admin, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDetailScreen(admin: admin),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainColor.withOpacity(0.1),
                  ),
                  child: Icon(Icons.person, color: AppColors.mainColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        admin.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        admin.masjidName,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            admin.pincode,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Consumer<SubAdminDetailProvider>(
                            builder: (context, provider, _) {
                              final hadiyaDetail = provider.getHadiyaDetail(admin.id);
                              if (hadiyaDetail != null) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: hadiyaDetail.allowed
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    hadiyaDetail.allowed
                                        ? AppStrings.getString('approved', currentLocale)
                                        : AppStrings.getString('pending', currentLocale),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: hadiyaDetail.allowed ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  AppStrings.getString('noHadiya', currentLocale),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.mainColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            widget.initialPincode != null
                ? '${AppStrings.getString('noAdminsFoundInPincode', currentLocale)} ${widget.initialPincode}'
                : AppStrings.getString('noAdminsFound', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.initialPincode != null
                ? AppStrings.getString('canApproveNewAdmin', currentLocale)
                : AppStrings.getString('tryDifferentSearch', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}