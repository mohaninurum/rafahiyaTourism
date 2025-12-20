import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/utils/model/auth/auth_user_model.dart';
import 'package:rafahiyatourism/view/super_admin_code/createuserwallet/full_screen_image_view.dart';
import '../../const/color.dart';
import '../../provider/wallet_doc_provider.dart';
import '../../utils/model/add_umrah_packages_model.dart';
import '../super_admin_code/models/wallet_doc_model.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class WalletScreen extends StatefulWidget {
  final AuthUserModel? user;
  const WalletScreen({super.key, this.user});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  DateTime _selectedDate = DateTime.now();
  final PageController _pageController = PageController(viewportFraction: 0.9);
  AddUmrahPackage? _currentPackage;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    final userId = widget.user!.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletDocumentProvider>(context, listen: false)
          .loadDocumentsForUser(userId!);
      print("userId $userId");
    });
  }

  List<DateTime> get _dates {
    if (_currentPackage == null ||
        _currentPackage!.startDate == null ||
        _currentPackage!.endDate == null) {
      return [];
    }

    List<DateTime> allDates = [];
    DateTime start = _currentPackage!.startDate!;
    DateTime end = _currentPackage!.endDate!;

    for (int i = 0; i <= end.difference(start).inDays; i++) {
      allDates.add(start.add(Duration(days: i)));
    }
    return allDates;
  }

  Map<String, dynamic>? get _currentDayDetails {
    if (_currentPackage == null) return null;

    for (var day in _currentPackage!.itinerary) {
      if (day.date.day == _selectedDate.day &&
          day.date.month == _selectedDate.month &&
          day.date.year == _selectedDate.year) {
        return {
          'title': '${AppStrings.getString('day', _getCurrentLocale(context))} ${_dates.indexOf(_selectedDate) + 1}',
          'description': day.activities,
          'icon': Icons.calendar_today,
        };
      }
    }
    return null;
  }

  void showDocumentDetail(String documentType, Map<String, dynamic> documentData, Document userDocument) {
    final currentLocale = _getCurrentLocale(context);
    // Get the file URL from the document data (new structure)
    final String? fileUrl = documentData['fileUrl'];

    final bool isImage = fileUrl != null &&
        (fileUrl.toLowerCase().endsWith('.jpg') ||
            fileUrl.toLowerCase().endsWith('.jpeg') ||
            fileUrl.toLowerCase().endsWith('.png'));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),
                if (fileUrl != null)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(imageUrl: fileUrl),
                        ),
                      );
                    },
                    child: Center(
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[50],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            fileUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error, color: Colors.red, size: 48),
                                    const SizedBox(height: 8),
                                    Text(AppStrings.getString('invalidImage', currentLocale)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(AppStrings.getString('noFileAvailable', currentLocale)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 25),
                Column(
                  children: [
                    _buildDetailRow(AppStrings.getString('documentType', currentLocale), documentType, currentLocale),
                    if (documentData['documentNumber'] != null)
                      _buildDetailRow(AppStrings.getString('documentNumber', currentLocale), documentData['documentNumber']!, currentLocale),
                    _buildDetailRow(AppStrings.getString('name', currentLocale), userDocument.name, currentLocale),
                    if (documentData['dob'] != null)
                      _buildDetailRow(AppStrings.getString('dateOfBirth', currentLocale), documentData['dob']!, currentLocale),
                    if (documentData['issueDate'] != null)
                      _buildDetailRow(AppStrings.getString('issueDate', currentLocale), documentData['issueDate']!, currentLocale),
                    if (documentData['expiryDate'] != null)
                      _buildDetailRow(AppStrings.getString('expiryDate', currentLocale), documentData['expiryDate']!, currentLocale),
                    if (documentData['issuingCountry'] != null)
                      _buildDetailRow(AppStrings.getString('issuingCountry', currentLocale), documentData['issuingCountry']!, currentLocale),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileTypeFromUrl(String url) {
    if (url.toLowerCase().endsWith('.pdf')) return 'pdf';
    if (url.toLowerCase().endsWith('.jpg') ||
        url.toLowerCase().endsWith('.jpeg') ||
        url.toLowerCase().endsWith('.png')) return 'image';
    if (url.toLowerCase().endsWith('.doc') ||
        url.toLowerCase().endsWith('.docx')) return 'doc';
    return 'file';
  }

  Widget _buildDateItem(DateTime date, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEE').format(date),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('MMM').format(date),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItineraryCard() {
    final currentLocale = _getCurrentLocale(context);

    if (_currentPackage == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.calendar_today, size: 40, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  AppStrings.getString('noPackageSelected', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.getString('selectPackageToViewItinerary', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final package = _currentPackage!;
    final dayDetails = _currentDayDetails;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: package.imageUrl.startsWith('http')
                        ? Image.network(
                      package.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      package.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          package.title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildPackageDetailChip(
                              Icons.calendar_today,
                              package.durationString,
                            ),
                            const SizedBox(width: 8),
                            _buildPackageDetailChip(
                              Icons.attach_money,
                              '₹${package.price}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPackageDetail(
                        Icons.hotel,
                        AppStrings.getString('hotel', currentLocale),
                        AppStrings.getString('fiveStarHotels', currentLocale),
                      ),
                      _buildPackageDetail(
                        Icons.directions_bus,
                        AppStrings.getString('transport', currentLocale),
                        AppStrings.getString('privateLuxuryTransport', currentLocale),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (dayDetails != null) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.getString('todaysSchedule', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDayDetailItem(
                      dayDetails['icon'],
                      dayDetails['title'],
                      dayDetails['description'],
                    ),
                  ] else if (_dates.isNotEmpty &&
                      _selectedDate.isAfter(package.startDate!.subtract(Duration(days: 1)))) ...[
                    const Divider(),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        AppStrings.getString('noScheduledActivities', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
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

  Widget _buildPackageDetailChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.whiteBackground),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.whiteBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageDetail(IconData icon, String label, String value) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.mainColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDetailItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.mainColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: AppColors.mainColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dateItemWidth = (screenWidth - 32) / 6;
    final walletProvider = Provider.of<WalletDocumentProvider>(context);
    final userDoc = walletProvider.getUserDocument(widget.user!.id!);

    // Find the first document with a packageId to set as current package
    if (_currentPackage == null && userDoc != null && userDoc.packageId != null) {
      final package = walletProvider.getPackageById(userDoc.packageId);
      if (package != null) {
        _currentPackage = package;
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.getString('myWallet', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                AppStrings.getString('yourDocuments', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            SizedBox(
              height: 160,
              child: userDoc == null || userDoc.documents.isEmpty
                  ? Center(
                child: Text(
                  AppStrings.getString('noDocumentsAddedYet', currentLocale),
                  style: GoogleFonts.poppins(color: Colors.grey[500]),
                ),
              )
                  : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: userDoc.documents.length,
                itemBuilder: (context, index) {
                  final documentType = userDoc.documents.keys.elementAt(index);
                  final documentData = userDoc.documents[documentType]!;
                  final fileUrl = documentData['fileUrl']; // Get file URL from document data

                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => showDocumentDetail(documentType, documentData, userDoc),
                      child: SizedBox(
                        width: 250,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 2,
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey[100],
                                ),
                                child: fileUrl != null
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    fileUrl,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          _getDocumentIcon(_getFileTypeFromUrl(fileUrl)),
                                          size: 60,
                                          color: AppColors.mainColor,
                                        ),
                                      );
                                    },
                                  ),
                                )
                                    : Center(
                                  child: Icon(
                                    _getDocumentIcon('doc'),
                                    size: 60,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.mainColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.white,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    documentType,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            if (_currentPackage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.getString('selectDate', currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _dates.length,
                  itemBuilder: (context, index) {
                    final date = _dates[index];
                    final isSelected = _selectedDate.day == date.day &&
                        _selectedDate.month == date.month &&
                        _selectedDate.year == date.year;
                    return SizedBox(
                      width: dateItemWidth,
                      child: _buildDateItem(date, isSelected),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                AppStrings.getString('yourItinerary', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildItineraryCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}