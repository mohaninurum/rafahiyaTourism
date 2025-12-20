
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../const/color.dart';
import '../super_admin_code/models/community_service/community_service_model.dart';
import '../super_admin_code/superadminprovider/super_admin_community_service/super_admin_community_service_provider.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class CommunityServicesScreen extends StatefulWidget {
  const CommunityServicesScreen({super.key});

  @override
  State<CommunityServicesScreen> createState() =>
      _CommunityServicesScreenState();
}

class _CommunityServicesScreenState extends State<CommunityServicesScreen> {
  bool _isLoading = true;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityServiceProvider>(
        context,
        listen: false,
      ).fetchServices().then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final servicesProvider = Provider.of<CommunityServiceProvider>(context);
    final services = servicesProvider.services;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        title: Text(
          AppStrings.getString('communityServices', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                    _isLoading
                        ? _buildLoadingIndicator(currentLocale)
                        : services.isEmpty
                        ? _buildEmptyState(currentLocale)
                        : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: services.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                        height: 1,
                        color: Colors.transparent,
                      ),
                      itemBuilder: (context, index) {
                        return _buildServiceItem(services[index], currentLocale);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mainColor,
        onPressed: () {
          _showDisclaimerDialog(context);
        },
        child: const Icon(Icons.info_outline, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _buildLoadingIndicator(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.mainColor),
          const SizedBox(height: 20),
          Text(
            AppStrings.getString('loadingServices', currentLocale),
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.getString('noServicesAvailable', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getString('checkBackLaterServices', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(SuperAdminCommunityServiceModel service, String currentLocale) {
    final locations = service.locationContacts.keys.toList();
    final contacts = service.locationContacts.values.toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                _getServiceIcon(service.icon),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    service.title,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          children: List.generate(service.locationContacts.length, (index) {
            final description =
            index < service.descriptions.length
                ? service.descriptions[index]
                : service.descriptions.isNotEmpty
                ? service.descriptions.last
                : '';
            final contact = contacts[index];
            final location = locations[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description.isNotEmpty)
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  if (description.isNotEmpty) const SizedBox(height: 8),
                  if (description.isNotEmpty)
                    Divider(thickness: 0.5, color: AppColors.mainColor),
                  if (description.isNotEmpty) const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.getString('location', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        AppStrings.getString('contactNo', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(thickness: 0.5, color: AppColors.mainColor),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          location,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          contact,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showDisclaimerDialog(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Center(
          child: Text(
              AppStrings.getString('disclaimer', currentLocale),
              style: GoogleFonts.poppins()
          ),
        ),
        content: Text(
          AppStrings.getString('disclaimerText', currentLocale),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.getString('ok', currentLocale),
              style: GoogleFonts.poppins(
                color: AppColors.mainColor,
                fontSize: 17,
              ),
            ),
          ),
        ],
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
      case 'favorite':
        icon = Icons.favorite;
        break;
      case 'attach_money':
        icon = Icons.attach_money;
        break;
      case 'spa':
        icon = Icons.spa;
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


}