import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminhome/add_community_service/widget/dialogue_form.dart';

import '../../../../const/color.dart';
import '../../models/community_service/community_service_model.dart';
import '../../superadminprovider/super_admin_community_service/super_admin_community_service_provider.dart';

class SuperAdminCommunityServicesScreen extends StatefulWidget {
  const SuperAdminCommunityServicesScreen({super.key});

  @override
  State<SuperAdminCommunityServicesScreen> createState() => _SuperAdminCommunityServicesScreenState();
}

class _SuperAdminCommunityServicesScreenState extends State<SuperAdminCommunityServicesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SuperAdminCommunityServiceModel> _filteredServices = [];
  bool _isLoading = true;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<CommunityServiceProvider>(context, listen: false);

    provider.addListener(_updateServices);

    provider.fetchServices().then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _filteredServices = provider.services;
        });
      }
    });
  }

  void _updateServices() {
    if (mounted) {
      setState(() {
        _filteredServices = Provider.of<CommunityServiceProvider>(context, listen: false).services;
        // Re-apply search filter if needed
        if (_searchController.text.isNotEmpty) {
          _filterServices(_searchController.text);
        }
      });
    }
  }

  @override
  void dispose() {
    Provider.of<CommunityServiceProvider>(context, listen: false)
        .removeListener(_updateServices);
    _searchController.dispose();
    super.dispose();
  }
  void _filterServices(String query) {
    final provider = Provider.of<CommunityServiceProvider>(context, listen: false);
    if (query.isEmpty) {
      setState(() {
        _filteredServices = provider.services;
      });
    } else {
      setState(() {
        _filteredServices = provider.services
            .where((service) =>
            service.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        title: Text(
          AppStrings.getString('manageServices', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddServiceDialog(context, currentLocale),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE8EAF6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildSearchBar(currentLocale),
              const SizedBox(height: 16),
              Consumer<CommunityServiceProvider>(
                builder: (context, provider, child) {
                  final services = provider.services;
                  final filteredServices = _searchController.text.isEmpty
                      ? services
                      : services.where((service) =>
                      service.title.toLowerCase().contains(_searchController.text.toLowerCase()))
                      .toList();

                  return Expanded(
                    child: _isLoading
                        ? _buildLoadingIndicator(currentLocale)
                        : filteredServices.isEmpty
                        ? _buildEmptyState(currentLocale)
                        : ListView.builder(
                      itemCount: filteredServices.length,
                      itemBuilder: (context, index) {
                        return _buildServiceCard(filteredServices[index], context, currentLocale);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitChasingDots(
            color: AppColors.mainColor,
            size: 50.0,
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.getString('loadingServices', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String currentLocale) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: AppStrings.getString('searchServicesByName', currentLocale),
          hintStyle: GoogleFonts.poppins(),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: _filterServices,
      ),
    );
  }

  Widget _buildEmptyState(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.getString('noServicesAddedYet', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.getString('clickToAddFirstService', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(SuperAdminCommunityServiceModel service, BuildContext context, String currentLocale) {
    return Card(
      color: Colors.white,
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getServiceIcon(service.icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    service.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainColor,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  color: Colors.white,
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditServiceDialog(context, service, currentLocale);
                    } else if (value == 'delete') {
                      _deleteService(context, service.id!, currentLocale);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text(AppStrings.getString('edit', currentLocale)),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(AppStrings.getString('delete', currentLocale)),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...service.descriptions.map((desc) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '• $desc',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            )),
            const SizedBox(height: 12),
            ...service.locationContacts.entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        entry.key,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.phone, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        entry.value,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _getServiceIcon(String iconName) {
    IconData icon;
    Color color = AppColors.mainColor;

    switch (iconName) {
      case 'directions_car_filled':
        icon = Icons.directions_car_filled;
        break;
      case 'store_mall_directory':
        icon = Icons.store_mall_directory;
        break;
      case 'restaurant':
        icon = Icons.restaurant;
        break;
      case 'language':
        icon = Icons.language;
        break;
      case 'mosque':
        icon = Icons.mosque;
        break;
      case 'menu_book':
        icon = Icons.menu_book;
        break;
      default:
        icon = Icons.add_home_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  void _showAddServiceDialog(BuildContext context, String currentLocale) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        currentLocale: currentLocale,
        onSave: (service) async {
          await Provider.of<CommunityServiceProvider>(context, listen: false)
              .addService(service);
        },
      ),
    );
  }

  void _showEditServiceDialog(BuildContext context, SuperAdminCommunityServiceModel service, String currentLocale) {
    showDialog(
      context: context,
      builder: (context) => ServiceFormDialog(
        currentLocale: currentLocale,
        service: service,
        onSave: (updatedService) async {
          await Provider.of<CommunityServiceProvider>(context, listen: false)
              .updateService(updatedService);
        },
      ),
    );
  }

  Future<void> _deleteService(BuildContext context, String id, String currentLocale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.getString('deleteService', currentLocale)),
        content: Text(AppStrings.getString('deleteServiceConfirmation', currentLocale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppStrings.getString('cancel', currentLocale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
                AppStrings.getString('delete', currentLocale),
                style: const TextStyle(color: Colors.red)
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<CommunityServiceProvider>(context, listen: false)
            .deleteService(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.getString('serviceDeletedSuccess', currentLocale))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.getString('failedToDeleteService', currentLocale)}: $e')),
        );
      }
    }
  }
}