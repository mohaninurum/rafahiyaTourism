

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../const/color.dart';
import '../../../provider/wallet_doc_provider.dart';
import '../../../provider/add_umrah_packages_provider.dart';
import '../../../utils/model/add_umrah_packages_model.dart';
import '../models/wallet_doc_model.dart';
import 'full_screen_image_view.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:flutter/material.dart';

class CreateUserWallet extends StatefulWidget {
  final String userId;
  final String userName;
  final String image;
  final String email;
  final String userPhone;
  final String userCity;

  const CreateUserWallet({
    super.key,
    required this.userId,
    required this.userName,
    required this.image,
    required this.email,
    required this.userCity,
    required this.userPhone,
  });

  @override
  State<CreateUserWallet> createState() => _CreateUserWalletState();
}

class _CreateUserWalletState extends State<CreateUserWallet> {
  bool _isUploading = false;
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _personNameController = TextEditingController();
  final TextEditingController _documentNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentScheduleController = TextEditingController();
  final TextEditingController _paymentDetailsController = TextEditingController();

  String _selectedStatus = 'Pending';
  String _selectedDocumentType = 'Passport';
  String _selectedIssuingCountry = 'India';
  AddUmrahPackage? _selectedPackage;
  File? _selectedFile;

  // Add locale getter method
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  // Localized document types
  List<String> _getDocumentTypes(String currentLocale) {
    return [
      AppStrings.getString('passport', currentLocale),
      AppStrings.getString('idCard', currentLocale),
      AppStrings.getString('driverLicense', currentLocale),
      AppStrings.getString('panCard', currentLocale),
      AppStrings.getString('aadhaarCard', currentLocale),
      AppStrings.getString('voterID', currentLocale),
      AppStrings.getString('quotation', currentLocale),
      AppStrings.getString('purchaseOrder', currentLocale),
      AppStrings.getString('paymentRequest', currentLocale),
      AppStrings.getString('other', currentLocale),
    ];
  }

  // Localized status types
  List<String> _getStatusTypes(String currentLocale) {
    return [
      AppStrings.getString('pending', currentLocale),
      AppStrings.getString('received', currentLocale),
    ];
  }

  final List<String> _issuingCountries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Japan',
    'Singapore',
    'United Arab Emirates',
    'Saudi Arabia',
    'Qatar',
    'Bangladesh',
    'Sri Lanka',
    'Nepal',
    'Bhutan',
    'Maldives',
    'China',
    'Russia',
    'Brazil',
  ];

  @override
  void initState() {
    super.initState();
    _personNameController.text = widget.userName;
    _loadUserDocument();
    _loadPackages();
  }

  Future<void> _loadUserDocument() async {
    final provider = Provider.of<WalletDocumentProvider>(
      context,
      listen: false,
    );
    await provider.loadDocumentsForUser(widget.userId);
  }

  Future<void> _loadPackages() async {
    final provider = Provider.of<AddUmrahPackageProvider>(
      context,
      listen: false,
    );
    await provider.fetchPackages();
  }

  @override
  void dispose() {
    _personNameController.dispose();
    _documentNumberController.dispose();
    _expiryDateController.dispose();
    _issueDateController.dispose();
    _dobController.dispose();
    _amountController.dispose();
    _paymentScheduleController.dispose();
    _paymentDetailsController.dispose();
    super.dispose();
  }

  Future<void> _showAddDocumentDialog() async {
    final currentLocale = _getCurrentLocale(context);

    _personNameController.text = widget.userName;
    _documentNumberController.clear();
    _expiryDateController.clear();
    _issueDateController.clear();
    _dobController.clear();
    _amountController.clear();
    _paymentScheduleController.clear();
    _paymentDetailsController.clear();

    _selectedStatus = AppStrings.getString('pending', currentLocale);
    _selectedDocumentType = AppStrings.getString('passport', currentLocale);
    _selectedIssuingCountry = 'India';
    _selectedPackage = null;
    _selectedFile = null;

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AddDocumentBottomSheet(
        formKey: _formKey,
        personNameController: _personNameController,
        documentNumberController: _documentNumberController,
        expiryDateController: _expiryDateController,
        issueDateController: _issueDateController,
        dobController: _dobController,
        amountController: _amountController,
        paymentScheduleController: _paymentScheduleController,
        paymentDetailsController: _paymentDetailsController,
        selectedStatus: _selectedStatus,
        selectedDocumentType: _selectedDocumentType,
        selectedIssuingCountry: _selectedIssuingCountry,
        documentTypes: _getDocumentTypes(currentLocale),
        issuingCountries: _issuingCountries,
        selectedPackage: _selectedPackage,
        onPackageSelected: (package) {
          setState(() {
            _selectedPackage = package;
          });
        },
        userId: widget.userId,
        onDocumentTypeChanged: (value) => setState(() => _selectedDocumentType = value),
        onIssuingCountryChanged: (value) => setState(() => _selectedIssuingCountry = value),
        onFileSelected: (file) => setState(() => _selectedFile = file),
        onDateSelected: _selectDate,
        onStatusChanged: (value) => setState(() => _selectedStatus = value),
        onUploadPressed: _handleFileUpload,
        isLoading: _isUploading,
        currentLocale: currentLocale,
      ),
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _handleFileUpload() async {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<WalletDocumentProvider>(context, listen: false);

    if (_formKey.currentState!.validate() && _selectedFile != null) {
      try {
        final documentData = {
          'documentNumber': _documentNumberController.text,
          'issueDate': _issueDateController.text,
          'expiryDate': _expiryDateController.text,
          'dob': _dobController.text,
          'issuingCountry': _selectedIssuingCountry,
          'amount': _amountController.text.isNotEmpty ? _amountController.text : null,
          'paymentSchedule': _paymentScheduleController.text.isNotEmpty
              ? _paymentScheduleController.text
              : null,
          'paymentDetails': _paymentDetailsController.text.isNotEmpty
              ? _paymentDetailsController.text
              : null,
          'paymentStatus': _selectedDocumentType == AppStrings.getString('paymentRequest', currentLocale)
              ? _selectedStatus
              : null,
          'uploadDate': DateTime.now().toString(),
        };

        await provider.addOrUpdateDocument(
          userId: widget.userId,
          userName: _personNameController.text,
          documentType: _selectedDocumentType,
          documentData: documentData,
          file: _selectedFile!,
          dob: _dobController.text.isNotEmpty ? _dobController.text : null,
          issuingCountry: _selectedIssuingCountry,
          packageId: _selectedPackage?.id,
          packageName: _selectedPackage?.title,
        );

        _clearControllers(currentLocale);
        Navigator.pop(context);
        _showSnackBar(AppStrings.getString('documentUploadedSuccessfully', currentLocale));
      } catch (e) {
        _showSnackBar('${AppStrings.getString('errorUploadingDocument', currentLocale)}: ${e.toString()}');
      }
    } else if (_selectedFile == null) {
      _showSnackBar(AppStrings.getString('pleaseSelectFile', currentLocale));
    }
  }

  void _clearControllers(String currentLocale) {
    _documentNumberController.clear();
    _expiryDateController.clear();
    _issueDateController.clear();
    _dobController.clear();
    _amountController.clear();
    _paymentScheduleController.clear();
    _paymentDetailsController.clear();
    _selectedStatus = AppStrings.getString('pending', currentLocale);
    _selectedFile = null;
  }

  Future<void> _showEditDialog(
      String documentType,
      Map<String, dynamic> documentData,
      ) async {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<WalletDocumentProvider>(context, listen: false);
    final userDoc = provider.getUserDocument(widget.userId);

    _personNameController.text = widget.userName;
    _documentNumberController.text = documentData['documentNumber'] ?? '';
    _issueDateController.text = documentData['issueDate'] ?? '';
    _expiryDateController.text = documentData['expiryDate'] ?? '';
    _dobController.text = documentData['dob'] ?? '';
    _amountController.text = documentData['amount'] ?? '';
    _paymentScheduleController.text = documentData['paymentSchedule'] ?? '';
    _paymentDetailsController.text = documentData['paymentDetails'] ?? '';
    _selectedStatus = documentData['paymentStatus'] ?? AppStrings.getString('pending', currentLocale);
    _selectedDocumentType = documentType;
    _selectedIssuingCountry = documentData['issuingCountry'] ?? 'India';
    _selectedFile = null;

    if (userDoc?.packageId != null) {
      final package = provider.getPackageById(userDoc!.packageId);
      _selectedPackage = package;
    }

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EditDocumentBottomSheet(
        formKey: _formKey,
        documentType: documentType,
        documentData: documentData,
        personNameController: _personNameController,
        documentNumberController: _documentNumberController,
        expiryDateController: _expiryDateController,
        issueDateController: _issueDateController,
        dobController: _dobController,
        amountController: _amountController,
        paymentScheduleController: _paymentScheduleController,
        paymentDetailsController: _paymentDetailsController,
        selectedStatus: _selectedStatus,
        selectedDocumentType: _selectedDocumentType,
        selectedIssuingCountry: _selectedIssuingCountry,
        selectedPackage: _selectedPackage,
        documentTypes: _getDocumentTypes(currentLocale),
        issuingCountries: _issuingCountries,
        selectedFile: _selectedFile,
        onDocumentTypeChanged: (value) => _selectedDocumentType = value,
        onIssuingCountryChanged: (value) => _selectedIssuingCountry = value,
        onPackageSelected: (package) {
          setState(() {
            _selectedPackage = package;
          });
        },
        onFileSelected: (file) => _selectedFile = file,
        onDateSelected: _selectDate,
        onStatusChanged: (value) => setState(() => _selectedStatus = value),
        onSavePressed: () async {
          if (_formKey.currentState!.validate()) {
            try {
              final updatedData = {
                'documentNumber': _documentNumberController.text,
                'issueDate': _issueDateController.text,
                'expiryDate': _expiryDateController.text,
                'dob': _dobController.text,
                'issuingCountry': _selectedIssuingCountry,
                'amount': _amountController.text.isNotEmpty ? _amountController.text : null,
                'paymentSchedule': _paymentScheduleController.text.isNotEmpty
                    ? _paymentScheduleController.text
                    : null,
                'paymentDetails': _paymentDetailsController.text.isNotEmpty
                    ? _paymentDetailsController.text
                    : null,
                'paymentStatus': _selectedDocumentType == AppStrings.getString('paymentRequest', currentLocale)
                    ? _selectedStatus
                    : null,
              };

              await provider.updatePackageAssignment(
                widget.userId,
                packageId: _selectedPackage?.id,
                packageName: _selectedPackage?.title,
              );

              _showSnackBar(AppStrings.getString('documentUpdatedSuccessfully', currentLocale));
              Navigator.pop(context);
            } catch (e) {
              _showSnackBar('${AppStrings.getString('errorUpdatingDocument', currentLocale)}: ${e.toString()}');
            }
          }
        },
        onRemovePressed: () async {
          try {
            await Provider.of<WalletDocumentProvider>(
              context,
              listen: false,
            ).removeDocumentType(widget.userId, documentType);
            Navigator.pop(context);
            _showSnackBar(AppStrings.getString('documentRemovedSuccessfully', currentLocale));
          } catch (e) {
            _showSnackBar('${AppStrings.getString('errorRemovingDocument', currentLocale)}: ${e.toString()}');
          }
        },
        currentLocale: currentLocale,
      ),
    );
  }

  Future<void> _showPackageManagementDialog() async {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<WalletDocumentProvider>(context, listen: false);
    final userDoc = provider.getUserDocument(widget.userId);
    final currentPackage = userDoc?.packageId != null ? provider.getPackageById(userDoc!.packageId) : null;

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PackageManagementBottomSheet(
        userId: widget.userId,
        currentPackage: currentPackage,
        onPackageSelected: (package) async {
          try {
            await provider.updatePackageAssignment(
              widget.userId,
              packageId: package?.id,
              packageName: package?.title,
            );
            Navigator.pop(context);
            _showSnackBar(
              package != null
                  ? AppStrings.getString('packageAssignedSuccessfully', currentLocale)
                  : AppStrings.getString('packageRemovedSuccessfully', currentLocale),
            );
          } catch (e) {
            _showSnackBar('${AppStrings.getString('errorUpdatingPackage', currentLocale)}: ${e.toString()}');
          }
        },
        onPackageRemoved: () async {
          try {
            await provider.updatePackageAssignment(
              widget.userId,
              packageId: '',
              packageName: '',
            );
            Navigator.pop(context);
            _showSnackBar(AppStrings.getString('packageRemovedSuccessfully', currentLocale));
          } catch (e) {
            _showSnackBar('${AppStrings.getString('errorRemovingPackage', currentLocale)}: ${e.toString()}');
          }
        },
        currentLocale: currentLocale,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        backgroundColor: AppColors.mainColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon:  Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.whiteColor,
              backgroundImage: widget.image.isNotEmpty ? NetworkImage(widget.image) : null,
              child: widget.image.isEmpty
                  ? Text(
                widget.userName.isNotEmpty ? widget.userName[0] : '?',
                style: GoogleFonts.poppins(
                  color: AppColors.mainColor,
                  fontSize: 20,
                ),
              )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              widget.userName,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<WalletDocumentProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.userName}\'s ${AppStrings.getString('userDetails', currentLocale)}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildUserDetailRow(
                      icon: Icons.email_outlined,
                      value: widget.email,
                      iconColor: Colors.blue,
                      currentLocale: currentLocale,
                    ),
                    const SizedBox(height: 12),
                    _buildUserDetailRow(
                      icon: Icons.phone_iphone_outlined,
                      value: widget.userPhone,
                      iconColor: Colors.green,
                      currentLocale: currentLocale,
                    ),
                    const SizedBox(height: 12),
                    _buildUserDetailRow(
                      icon: Icons.location_on_outlined,
                      value: widget.userCity,
                      iconColor: Colors.orange,
                      currentLocale: currentLocale,
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.userName}\'s ${AppStrings.getString('documents', currentLocale)}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings, color: AppColors.mainColor),
                      onPressed: _showPackageManagementDialog,
                      tooltip: AppStrings.getString('managePackage', currentLocale),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.getString('uploadAndManageDocuments', currentLocale),
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: Consumer<WalletDocumentProvider>(
                    builder: (context, provider, child) {
                      final userDoc = provider.getUserDocument(widget.userId);

                      if (userDoc == null || userDoc.documents.isEmpty) {
                        return _buildEmptyState(currentLocale);
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: userDoc.documents.length,
                        itemBuilder: (context, index) {
                          final documentType = userDoc.documents.keys.elementAt(index);
                          final documentData = userDoc.documents[documentType]!;
                          return _buildDocumentCard(
                            documentType,
                            documentData,
                            userDoc,
                            currentLocale,
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: provider.isLoading ? null : _showAddDocumentDialog,
                  child: provider.isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.getString('addDocument', currentLocale),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserDetailRow({
    required IconData icon,
    required String value,
    required Color iconColor,
    required String currentLocale,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : AppStrings.getString('notProvided', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: value.isNotEmpty ? Colors.grey[700] : Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(
      String documentType,
      Map<String, dynamic> documentData,
      Document userDoc,
      String currentLocale,
      ) {
    return GestureDetector(
      onTap: () => _showEditDialog(documentType, documentData),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Center(
                        child: Icon(
                          _getDocumentIcon(documentType, currentLocale),
                          size: 48,
                          color: AppColors.mainColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    userDoc.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (userDoc.packageName != null && userDoc.packageName!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        userDoc.packageName!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: AppColors.mainColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],

                  const SizedBox(height: 4),
                  Text(
                    documentType,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),

                  if (documentData['amount'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '₹${documentData['amount']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  if (documentData['paymentStatus'] != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: documentData['paymentStatus'] == AppStrings.getString('received', currentLocale)
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        documentData['paymentStatus'],
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: documentData['paymentStatus'] == AppStrings.getString('received', currentLocale)
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: PopupMenuButton(
              color: Colors.white,
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: Text(AppStrings.getString('view', currentLocale), style: GoogleFonts.poppins()),
                  onTap: () => Future.delayed(
                    Duration.zero,
                        () => _showDocumentDetails(documentType, documentData, userDoc, currentLocale),
                  ),
                ),
                PopupMenuItem(
                  child: Text(AppStrings.getString('edit', currentLocale), style: GoogleFonts.poppins()),
                  onTap: () => Future.delayed(
                    Duration.zero,
                        () => _showEditDialog(documentType, documentData),
                  ),
                ),
                PopupMenuItem(
                  child: Text(AppStrings.getString('remove', currentLocale), style: GoogleFonts.poppins()),
                  onTap: () => Future.delayed(Duration.zero, () async {
                    try {
                      await Provider.of<WalletDocumentProvider>(
                        context,
                        listen: false,
                      ).removeDocumentType(widget.userId, documentType);
                      _showSnackBar(AppStrings.getString('documentRemoved', currentLocale));
                    } catch (e) {
                      _showSnackBar('${AppStrings.getString('errorRemovingDocument', currentLocale)}: ${e.toString()}');
                    }
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getDocumentIcon(String documentType, String currentLocale) {
    if (documentType == AppStrings.getString('passport', currentLocale)) return Icons.airplane_ticket;
    if (documentType == AppStrings.getString('idCard', currentLocale)) return Icons.badge;
    if (documentType == AppStrings.getString('driverLicense', currentLocale)) return Icons.directions_car;
    if (documentType == AppStrings.getString('panCard', currentLocale)) return Icons.credit_card;
    if (documentType == AppStrings.getString('aadhaarCard', currentLocale)) return Icons.contact_page;
    if (documentType == AppStrings.getString('voterID', currentLocale)) return Icons.how_to_vote;
    if (documentType == AppStrings.getString('quotation', currentLocale)) return Icons.description;
    if (documentType == AppStrings.getString('purchaseOrder', currentLocale)) return Icons.shopping_cart;
    if (documentType == AppStrings.getString('paymentRequest', currentLocale)) return Icons.payment;
    return Icons.description;
  }

  Widget _buildEmptyState(String currentLocale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.mainColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 48,
              color: AppColors.mainColor,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.getString('noDocumentsAdded', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.getString('tapToAddFirstDocument', currentLocale),
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _showDocumentDetails(
      String documentType,
      Map<String, dynamic> documentData,
      Document userDoc,
      String currentLocale,
      ) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DocumentDetailsBottomSheet(
        documentType: documentType,
        documentData: documentData,
        userDocument: userDoc,
        currentLocale: currentLocale,
      ),
    );
  }
}

class AddDocumentBottomSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController personNameController;
  final TextEditingController documentNumberController;
  final TextEditingController expiryDateController;
  final TextEditingController issueDateController;
  final TextEditingController dobController;
  final TextEditingController amountController;
  final TextEditingController paymentScheduleController;
  final TextEditingController paymentDetailsController;
  final String selectedStatus;
  final String selectedDocumentType;
  final String selectedIssuingCountry;
  final AddUmrahPackage? selectedPackage;
  final ValueChanged<AddUmrahPackage?> onPackageSelected;
  final List<String> documentTypes;
  final List<String> issuingCountries;
  final String userId;
  final ValueChanged<String> onDocumentTypeChanged;
  final ValueChanged<String> onIssuingCountryChanged;
  final ValueChanged<File?> onFileSelected;
  final Function(TextEditingController) onDateSelected;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onUploadPressed;
  final bool isLoading;
  final String currentLocale;

  const AddDocumentBottomSheet({
    super.key,
    required this.formKey,
    required this.personNameController,
    required this.documentNumberController,
    required this.expiryDateController,
    required this.issueDateController,
    required this.dobController,
    required this.amountController,
    required this.paymentScheduleController,
    required this.paymentDetailsController,
    required this.selectedStatus,
    required this.selectedDocumentType,
    required this.selectedIssuingCountry,
    required this.selectedPackage,
    required this.documentTypes,
    required this.issuingCountries,
    required this.userId,
    required this.onDocumentTypeChanged,
    required this.onIssuingCountryChanged,
    required this.onPackageSelected,
    required this.onFileSelected,
    required this.onDateSelected,
    required this.onStatusChanged,
    required this.onUploadPressed,
    required this.isLoading,
    required this.currentLocale,
  });

  @override
  State<AddDocumentBottomSheet> createState() => _AddDocumentBottomSheetState();
}

class _AddDocumentBottomSheetState extends State<AddDocumentBottomSheet> {
  AddUmrahPackage? _localSelectedPackage;
  File? _selectedFile;

  String get _documentNumberLabel {
    if (widget.selectedDocumentType == AppStrings.getString('passport', widget.currentLocale)) {
      return AppStrings.getString('passportNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('idCard', widget.currentLocale)) {
      return AppStrings.getString('idNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('driverLicense', widget.currentLocale)) {
      return AppStrings.getString('licenseNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('panCard', widget.currentLocale)) {
      return AppStrings.getString('panNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('aadhaarCard', widget.currentLocale)) {
      return AppStrings.getString('aadhaarNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('voterID', widget.currentLocale)) {
      return AppStrings.getString('voterIDNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('quotation', widget.currentLocale)) {
      return AppStrings.getString('quotationNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('purchaseOrder', widget.currentLocale)) {
      return AppStrings.getString('poNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('paymentRequest', widget.currentLocale)) {
      return AppStrings.getString('paymentReference', widget.currentLocale);
    } else {
      return AppStrings.getString('documentNumber', widget.currentLocale);
    }
  }

  String get _documentNumberHint {
    if (widget.selectedDocumentType == AppStrings.getString('passport', widget.currentLocale)) {
      return AppStrings.getString('enterPassportNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('idCard', widget.currentLocale)) {
      return AppStrings.getString('enterIDNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('driverLicense', widget.currentLocale)) {
      return AppStrings.getString('enterLicenseNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('panCard', widget.currentLocale)) {
      return AppStrings.getString('enterPANNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('aadhaarCard', widget.currentLocale)) {
      return AppStrings.getString('enterAadhaarNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('voterID', widget.currentLocale)) {
      return AppStrings.getString('enterVoterIDNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('quotation', widget.currentLocale)) {
      return AppStrings.getString('enterQuotationNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('purchaseOrder', widget.currentLocale)) {
      return AppStrings.getString('enterPONumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('paymentRequest', widget.currentLocale)) {
      return AppStrings.getString('enterPaymentReference', widget.currentLocale);
    } else {
      return AppStrings.getString('enterDocumentNumber', widget.currentLocale);
    }
  }

  @override
  void initState() {
    super.initState();
    _localSelectedPackage = widget.selectedPackage;
  }

  void _updateSelectedPackage(AddUmrahPackage? package) {
    setState(() {
      _localSelectedPackage = package;
    });
    widget.onPackageSelected(package);
  }

  Future<void> _showPackageSelection(List<AddUmrahPackage> packages) async {
    final result = await showModalBottomSheet<AddUmrahPackage?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PackageSelectionBottomSheet(
        packages: packages,
        selectedPackage: _localSelectedPackage,
        onPackageSelected: (package) => package,
        userId: widget.userId,
        currentLocale: widget.currentLocale,
      ),
    );

    if (result != null) {
      _updateSelectedPackage(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.getString('addNewDocument', widget.currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: widget.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: widget.personNameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('personName', widget.currentLocale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppStrings.getString('pleaseEnterPersonName', widget.currentLocale)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: widget.dobController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('dateOfBirth', widget.currentLocale),
                        hintText: 'DD-MM-YYYY',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                      onTap: () => widget.onDateSelected(widget.dobController),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: widget.selectedDocumentType,
                      items: widget.documentTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (value) {
                        widget.onDocumentTypeChanged(value!);
                        widget.documentNumberController.text = '';
                        widget.documentNumberController.selection = TextSelection.collapsed(
                          offset: widget.documentNumberController.text.length,
                        );
                      },
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('documentType', widget.currentLocale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: widget.documentNumberController,
                      decoration: InputDecoration(
                        labelText: _documentNumberLabel,
                        hintText: _documentNumberHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? '${AppStrings.getString('pleaseEnter', widget.currentLocale)} ${_documentNumberLabel.toLowerCase()}'
                          : null,
                    ),

                    if ([
                      AppStrings.getString('quotation', widget.currentLocale),
                      AppStrings.getString('purchaseOrder', widget.currentLocale),
                      AppStrings.getString('paymentRequest', widget.currentLocale),
                    ].contains(widget.selectedDocumentType))
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: widget.amountController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('amount', widget.currentLocale),
                              prefixText: '₹ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? AppStrings.getString('pleaseEnterAmount', widget.currentLocale)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: widget.paymentScheduleController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('paymentSchedule', widget.currentLocale),
                              hintText: AppStrings.getString('paymentScheduleExample', widget.currentLocale),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? AppStrings.getString('pleaseEnterPaymentSchedule', widget.currentLocale)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: widget.paymentDetailsController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('paymentDetails', widget.currentLocale),
                              hintText: AppStrings.getString('paymentDetailsExample', widget.currentLocale),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            maxLines: 3,
                            validator: (value) => value == null || value.isEmpty
                                ? AppStrings.getString('pleaseEnterPaymentDetails', widget.currentLocale)
                                : null,
                          ),
                          if (widget.selectedDocumentType == AppStrings.getString('paymentRequest', widget.currentLocale))
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: widget.selectedStatus,
                                  items: [
                                    AppStrings.getString('pending', widget.currentLocale),
                                    AppStrings.getString('received', widget.currentLocale),
                                  ].map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  )).toList(),
                                  onChanged: (value) => widget.onStatusChanged(value!),
                                  decoration: InputDecoration(
                                    labelText: AppStrings.getString('paymentStatus', widget.currentLocale),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.mainColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.issueDateController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('issueDate', widget.currentLocale),
                              hintText: 'DD-MM-YYYY',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            onTap: () => widget.onDateSelected(widget.issueDateController),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: widget.expiryDateController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('expiryDate', widget.currentLocale),
                              hintText: 'DD-MM-YYYY',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            onTap: () => widget.onDateSelected(widget.expiryDateController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: widget.selectedIssuingCountry,
                      items: widget.issuingCountries.map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      )).toList(),
                      onChanged: (value) => widget.onIssuingCountryChanged(value!),
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('issuingCountry', widget.currentLocale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppStrings.getString('pleaseEnterIssuingAuthority', widget.currentLocale)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Consumer<AddUmrahPackageProvider>(
                      builder: (context, packageProvider, child) {
                        if (packageProvider.packages.isEmpty)
                          return const SizedBox();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.getString('selectPackage', widget.currentLocale),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showPackageSelection(packageProvider.packages),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[300]!, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _localSelectedPackage?.title ?? AppStrings.getString('tapToSelectPackage', widget.currentLocale),
                                        style: GoogleFonts.poppins(
                                          color: _localSelectedPackage != null ? Colors.black : Colors.grey[500],
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_drop_down,
                                      color: Colors.grey[500],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            if (_localSelectedPackage != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.mainColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: AppColors.mainColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          AppStrings.getString('selectedPackage', widget.currentLocale),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.mainColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _localSelectedPackage!.title,
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                                    ),
                                    if (_localSelectedPackage!.price.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'INR ${_localSelectedPackage!.price}',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.mainColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildFileSelector(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildUploadButton(),
              const SizedBox(height: 8),
              Text(
                AppStrings.getString('supportedFormats', widget.currentLocale),
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('documentImage', widget.currentLocale), // Changed from 'documentFile'
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        // Only show image preview since we only accept images now
        if (_selectedFile != null)
          Column(
            children: [
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedFile!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.error, color: Colors.red, size: 48),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.image, color: AppColors.mainColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFile!.path.split('/').last,
                        style: GoogleFonts.poppins(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: _removeSelectedFile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),

        GestureDetector(
          onTap: _selectFile,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate, color: AppColors.mainColor),
                const SizedBox(width: 8),
                Text(
                  AppStrings.getString('selectImage', widget.currentLocale), // Changed from 'selectFile'
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  bool _isImageFile(String path) {
    return path.toLowerCase().endsWith('.jpg') ||
        path.toLowerCase().endsWith('.jpeg') ||
        path.toLowerCase().endsWith('.png');
  }

  bool _isPdfFile(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  void _removeSelectedFile() {
    setState(() {
      _selectedFile = null;
      widget.onFileSelected(null);
    });
  }

  Future<void> _selectFile() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => UploadOptionsBottomSheet(currentLocale: widget.currentLocale),
    );
    if (result == null) return;

    final ImagePicker imagePicker = ImagePicker();

    switch (result) {
      case 1: // Camera
        final image = await imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (image != null) _setSelectedFile(File(image.path));
        break;
      case 2: // Gallery
        final image = await imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) _setSelectedFile(File(image.path));
        break;
    }
  }

  void _setSelectedFile(File file) {
    setState(() {
      _selectedFile = file;
      widget.onFileSelected(file);
    });
  }

  Widget _buildUploadButton() {
    return Consumer<WalletDocumentProvider>(
      builder: (context, provider, child) {
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: provider.isLoading ? null : widget.onUploadPressed,
            child: provider.isLoading
                ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_upload, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  AppStrings.getString('uploadFile', widget.currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
class PackageSelectionBottomSheet extends StatefulWidget {
  final String userId;
  final List<AddUmrahPackage> packages;
  final AddUmrahPackage? selectedPackage;
  final ValueChanged<AddUmrahPackage?> onPackageSelected;
  final String currentLocale;

  const PackageSelectionBottomSheet({
    super.key,
    required this.userId,
    required this.packages,
    required this.selectedPackage,
    required this.onPackageSelected,
    required this.currentLocale,
  });

  @override
  State<PackageSelectionBottomSheet> createState() =>
      _PackageSelectionBottomSheetState();
}

class _PackageSelectionBottomSheetState
    extends State<PackageSelectionBottomSheet> {
  AddUmrahPackage? _tempSelectedPackage;

  @override
  void initState() {
    super.initState();
    _tempSelectedPackage = widget.selectedPackage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.getString('selectPackage', widget.currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.packages.length,
              itemBuilder: (context, index) {
                final package = widget.packages[index];
                return _buildPackageListItem(package);
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                if (_tempSelectedPackage != null)
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          final provider = Provider.of<WalletDocumentProvider>(
                            context,
                            listen: false,
                          );
                          await provider.updatePackageAssignment(
                            widget.userId,
                            packageId: '',
                            packageName: '',
                          );
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppStrings.getString('packageRemovedSuccessfully', widget.currentLocale),
                              ),
                            ),
                          );
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${AppStrings.getString('errorRemovingPackage', widget.currentLocale)}: $e',
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        AppStrings.getString('removePackage', widget.currentLocale).toUpperCase(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (_tempSelectedPackage != null) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context, _tempSelectedPackage);
                    },
                    child: Text(
                      _tempSelectedPackage != null
                          ? AppStrings.getString('confirm', widget.currentLocale).toUpperCase()
                          : AppStrings.getString('cancel', widget.currentLocale).toUpperCase(),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageListItem(AddUmrahPackage package) {
    final isSelected = _tempSelectedPackage?.id == package.id;
    final bool isNetworkImage = package.imageUrl.startsWith('http');

    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSelectedPackage = isSelected ? null : package;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mainColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mainColor : Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (package.imageUrl.isNotEmpty)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: isNetworkImage
                      ? DecorationImage(
                    image: NetworkImage(package.imageUrl),
                    fit: BoxFit.cover,
                  )
                      : DecorationImage(
                    image: FileImage(File(package.imageUrl)),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.photo, color: Colors.grey[500]),
              ),

            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  if (package.price.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'INR ${package.price}',
                      style: GoogleFonts.poppins(
                        color: AppColors.mainColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (package.durationString.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${AppStrings.getString('duration', widget.currentLocale)}: ${package.durationString}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.mainColor),
            if (!isSelected && _tempSelectedPackage == null)
              Icon(Icons.radio_button_unchecked, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}


class EditDocumentBottomSheet extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final String documentType;
  final Map<String, dynamic> documentData;
  final TextEditingController personNameController;
  final TextEditingController documentNumberController;
  final TextEditingController expiryDateController;
  final TextEditingController issueDateController;
  final TextEditingController dobController;
  final TextEditingController amountController;
  final TextEditingController paymentScheduleController;
  final TextEditingController paymentDetailsController;
  final String selectedStatus;
  final String selectedDocumentType;
  final String selectedIssuingCountry;
  final AddUmrahPackage? selectedPackage;
  final List<String> documentTypes;
  final List<String> issuingCountries;
  final File? selectedFile;
  final ValueChanged<String> onDocumentTypeChanged;
  final ValueChanged<String> onIssuingCountryChanged;
  final ValueChanged<AddUmrahPackage?> onPackageSelected;
  final ValueChanged<File?> onFileSelected;
  final Function(TextEditingController) onDateSelected;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onSavePressed;
  final VoidCallback onRemovePressed;
  final String currentLocale;

  const EditDocumentBottomSheet({
    super.key,
    required this.formKey,
    required this.documentType,
    required this.documentData,
    required this.personNameController,
    required this.documentNumberController,
    required this.expiryDateController,
    required this.issueDateController,
    required this.dobController,
    required this.amountController,
    required this.paymentScheduleController,
    required this.paymentDetailsController,
    required this.selectedStatus,
    required this.selectedDocumentType,
    required this.selectedIssuingCountry,
    required this.selectedPackage,
    required this.documentTypes,
    required this.issuingCountries,
    required this.selectedFile,
    required this.onDocumentTypeChanged,
    required this.onIssuingCountryChanged,
    required this.onPackageSelected,
    required this.onFileSelected,
    required this.onDateSelected,
    required this.onStatusChanged,
    required this.onSavePressed,
    required this.onRemovePressed,
    required this.currentLocale,
  });

  @override
  State<EditDocumentBottomSheet> createState() =>
      _EditDocumentBottomSheetState();
}

class _EditDocumentBottomSheetState extends State<EditDocumentBottomSheet> {
  String get _documentNumberLabel {
    if (widget.selectedDocumentType == AppStrings.getString('passport', widget.currentLocale)) {
      return AppStrings.getString('passportNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('idCard', widget.currentLocale)) {
      return AppStrings.getString('idNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('driverLicense', widget.currentLocale)) {
      return AppStrings.getString('licenseNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('panCard', widget.currentLocale)) {
      return AppStrings.getString('panNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('aadhaarCard', widget.currentLocale)) {
      return AppStrings.getString('aadhaarNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('voterID', widget.currentLocale)) {
      return AppStrings.getString('voterIDNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('quotation', widget.currentLocale)) {
      return AppStrings.getString('quotationNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('purchaseOrder', widget.currentLocale)) {
      return AppStrings.getString('poNumber', widget.currentLocale);
    } else if (widget.selectedDocumentType == AppStrings.getString('paymentRequest', widget.currentLocale)) {
      return AppStrings.getString('paymentReference', widget.currentLocale);
    } else {
      return AppStrings.getString('documentNumber', widget.currentLocale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${AppStrings.getString('edit', widget.currentLocale)} ${widget.documentType}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: widget.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: widget.personNameController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('personName', widget.currentLocale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? AppStrings.getString('pleaseEnterPersonName', widget.currentLocale)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: widget.dobController,
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('dateOfBirth', widget.currentLocale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                      onTap: () => widget.onDateSelected(widget.dobController),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: widget.selectedDocumentType,
                      items: widget.documentTypes.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      )).toList(),
                      onChanged: (value) => widget.onDocumentTypeChanged(value!),
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('documentType', widget.currentLocale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: widget.documentNumberController,
                      decoration: InputDecoration(
                        labelText: _documentNumberLabel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? '${AppStrings.getString('pleaseEnter', widget.currentLocale)} ${_documentNumberLabel.toLowerCase()}'
                          : null,
                    ),

                    if ([
                      AppStrings.getString('quotation', widget.currentLocale),
                      AppStrings.getString('purchaseOrder', widget.currentLocale),
                      AppStrings.getString('paymentRequest', widget.currentLocale),
                    ].contains(widget.selectedDocumentType))
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: widget.amountController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('amount', widget.currentLocale),
                              prefixText: '₹ ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) => value == null || value.isEmpty
                                ? AppStrings.getString('pleaseEnterAmount', widget.currentLocale)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: widget.paymentScheduleController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('paymentSchedule', widget.currentLocale),
                              hintText: AppStrings.getString('paymentScheduleExample', widget.currentLocale),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            validator: (value) => value == null || value.isEmpty
                                ? AppStrings.getString('pleaseEnterPaymentSchedule', widget.currentLocale)
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: widget.paymentDetailsController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('paymentDetails', widget.currentLocale),
                              hintText: AppStrings.getString('paymentDetailsExample', widget.currentLocale),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            maxLines: 3,
                            validator: (value) => value == null || value.isEmpty
                                ? AppStrings.getString('pleaseEnterPaymentDetails', widget.currentLocale)
                                : null,
                          ),
                          if (widget.selectedDocumentType == AppStrings.getString('paymentRequest', widget.currentLocale))
                            Column(
                              children: [
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: widget.selectedStatus,
                                  items: [
                                    AppStrings.getString('pending', widget.currentLocale),
                                    AppStrings.getString('received', widget.currentLocale),
                                  ].map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status),
                                  )).toList(),
                                  onChanged: (value) => widget.onStatusChanged(value!),
                                  decoration: InputDecoration(
                                    labelText: AppStrings.getString('paymentStatus', widget.currentLocale),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: AppColors.mainColor),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.issueDateController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('issueDate', widget.currentLocale),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            onTap: () => widget.onDateSelected(widget.issueDateController),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: widget.expiryDateController,
                            decoration: InputDecoration(
                              labelText: AppStrings.getString('expiryDate', widget.currentLocale),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: AppColors.mainColor),
                              ),
                            ),
                            onTap: () => widget.onDateSelected(widget.expiryDateController),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: widget.selectedIssuingCountry,
                      items: widget.issuingCountries.map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      )).toList(),
                      onChanged: (value) => widget.onIssuingCountryChanged(value!),
                      decoration: InputDecoration(
                        labelText: AppStrings.getString('issuingCountry', widget.currentLocale),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.mainColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFileSelector(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppStrings.getString('cancel', widget.currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: widget.onRemovePressed,
                      child: Text(
                        AppStrings.getString('remove', widget.currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
                        elevation: 0,
                      ),
                      onPressed: widget.onSavePressed,
                      child: Text(
                        AppStrings.getString('save', widget.currentLocale),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('replaceDocumentImage', widget.currentLocale), // Changed
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectFile,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.add_photo_alternate, color: AppColors.mainColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.selectedFile != null
                        ? widget.selectedFile!.path.split('/').last
                        : AppStrings.getString('currentImageAttached', widget.currentLocale), // Changed
                    style: GoogleFonts.poppins(
                      color: widget.selectedFile != null ? Colors.black : Colors.grey[500],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.selectedFile != null)
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: _removeSelectedFile,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _removeSelectedFile() {
    widget.onFileSelected(null);
    setState(() {});
  }

  Future<void> _selectFile() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => UploadOptionsBottomSheet(currentLocale: widget.currentLocale),
    );
    if (result == null) return;

    final ImagePicker imagePicker = ImagePicker();

    switch (result) {
      case 1: // Camera
        final image = await imagePicker.pickImage(
          source: ImageSource.camera,
          imageQuality: 80,
        );
        if (image != null) _setSelectedFile(File(image.path));
        break;
      case 2: // Gallery
        final image = await imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (image != null) _setSelectedFile(File(image.path));
        break;
    }
  }

  void _setSelectedFile(File file) {
    widget.onFileSelected(file);
    setState(() {});
  }
}

class DocumentDetailsBottomSheet extends StatelessWidget {
  final String documentType;
  final Map<String, dynamic> documentData;
  final Document userDocument;
  final String currentLocale;

  const DocumentDetailsBottomSheet({
    super.key,
    required this.documentType,
    required this.documentData,
    required this.userDocument,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    final String? fileUrl = documentData['fileUrl'];
    final bool isImage = fileUrl != null &&
        (fileUrl.toLowerCase().endsWith('.jpg') ||
            fileUrl.toLowerCase().endsWith('.jpeg') ||
            fileUrl.toLowerCase().endsWith('.png'));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                userDocument.name,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 8),
              if (userDocument.packageName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    userDocument.packageName!,
                    style: GoogleFonts.poppins(
                      color: AppColors.mainColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                documentType,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 24),
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
              const SizedBox(height: 24),
              _buildDetailRow(
                AppStrings.getString('documentNumberLabel', currentLocale),
                documentData['documentNumber'] ?? AppStrings.getString('notSpecified', currentLocale),
              ),
              _buildDetailRow(
                AppStrings.getString('dateOfBirthLabel', currentLocale),
                documentData['dob'] ?? AppStrings.getString('notSpecified', currentLocale),
              ),
              _buildDetailRow(
                AppStrings.getString('issueDateLabel', currentLocale),
                documentData['issueDate'] ?? AppStrings.getString('notSpecified', currentLocale),
              ),
              _buildDetailRow(
                AppStrings.getString('expiryDateLabel', currentLocale),
                documentData['expiryDate'] ?? AppStrings.getString('notSpecified', currentLocale),
              ),
              _buildDetailRow(
                AppStrings.getString('issuingCountryLabel', currentLocale),
                documentData['issuingCountry'] ?? AppStrings.getString('notSpecified', currentLocale),
              ),

              if ([
                AppStrings.getString('quotation', currentLocale),
                AppStrings.getString('purchaseOrder', currentLocale),
                AppStrings.getString('paymentRequest', currentLocale),
              ].contains(documentType))
                Column(
                  children: [
                    if (documentData['amount'] != null)
                      _buildDetailRow(
                        AppStrings.getString('amount', currentLocale),
                        documentData['amount'] ?? AppStrings.getString('notSpecified', currentLocale),
                      ),
                    if (documentData['paymentSchedule'] != null)
                      _buildDetailRow(
                        AppStrings.getString('paymentSchedule', currentLocale),
                        documentData['paymentSchedule'] ?? AppStrings.getString('notSpecified', currentLocale),
                      ),
                    if (documentData['paymentDetails'] != null)
                      _buildDetailRow(
                        AppStrings.getString('paymentDetails', currentLocale),
                        documentData['paymentDetails'] ?? AppStrings.getString('notSpecified', currentLocale),
                      ),
                    if (documentType == AppStrings.getString('paymentRequest', currentLocale) && documentData['paymentStatus'] != null)
                      _buildDetailRow(
                        AppStrings.getString('paymentStatus', currentLocale),
                        documentData['paymentStatus'] ?? AppStrings.getString('notSpecified', currentLocale),
                      ),
                  ],
                ),

              if (userDocument.packageName != null)
                _buildDetailRow(
                  AppStrings.getString('associatedPackage', currentLocale),
                  userDocument.packageName!,
                ),
              _buildDetailRow(
                AppStrings.getString('uploadedOn', currentLocale),
                documentData['uploadDate'] != null
                    ? DateFormat('dd MMM yyyy').format(DateTime.parse(documentData['uploadDate']))
                    : AppStrings.getString('notSpecified', currentLocale),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppStrings.getString('close', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
}

class PackageManagementBottomSheet extends StatefulWidget {
  final String userId;
  final AddUmrahPackage? currentPackage;
  final ValueChanged<AddUmrahPackage?> onPackageSelected;
  final VoidCallback onPackageRemoved;
  final String currentLocale;

  const PackageManagementBottomSheet({
    super.key,
    required this.userId,
    required this.currentPackage,
    required this.onPackageSelected,
    required this.onPackageRemoved,
    required this.currentLocale,
  });

  @override
  State<PackageManagementBottomSheet> createState() =>
      _PackageManagementBottomSheetState();
}

class _PackageManagementBottomSheetState
    extends State<PackageManagementBottomSheet> {
  AddUmrahPackage? _selectedPackage;

  @override
  void initState() {
    super.initState();
    _selectedPackage = widget.currentPackage;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.getString('managePackage', widget.currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            if (widget.currentPackage != null)
              Column(
                children: [
                  Text(
                    '${AppStrings.getString('currentPackage', widget.currentLocale)}:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.mainColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.currentPackage!.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (widget.currentPackage!.price.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${AppStrings.getString('price', widget.currentLocale)}: INR ${widget.currentPackage!.price}',
                            style: GoogleFonts.poppins(
                              color: AppColors.mainColor,
                            ),
                          ),
                        ],
                        if (widget.currentPackage!.durationString.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${AppStrings.getString('duration', widget.currentLocale)}: ${widget.currentPackage!.durationString}',
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () async {
                final packages = Provider.of<AddUmrahPackageProvider>(
                  context,
                  listen: false,
                ).packages;
                final result = await showModalBottomSheet<AddUmrahPackage?>(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => PackageSelectionBottomSheet(
                    packages: packages,
                    selectedPackage: _selectedPackage,
                    onPackageSelected: (package) => package,
                    userId: widget.userId,
                    currentLocale: widget.currentLocale,
                  ),
                );
                if (result != null) {
                  setState(() => _selectedPackage = result);
                }
              },
              child: Text(
                _selectedPackage != null
                    ? AppStrings.getString('changePackage', widget.currentLocale)
                    : AppStrings.getString('selectPackage', widget.currentLocale),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            if (widget.currentPackage != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  widget.onPackageRemoved();
                  Navigator.pop(context);
                },
                child: Text(
                  AppStrings.getString('removePackage', widget.currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            if (_selectedPackage != null && _selectedPackage != widget.currentPackage) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  widget.onPackageSelected(_selectedPackage);
                  Navigator.pop(context);
                },
                child: Text(
                  AppStrings.getString('confirmNewPackage', widget.currentLocale),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppStrings.getString('cancel', widget.currentLocale),
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class UploadOptionsBottomSheet extends StatelessWidget {
  final String currentLocale;

  const UploadOptionsBottomSheet({
    super.key,
    required this.currentLocale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.getString('selectUploadMethod', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),

            // Only Camera and Gallery options
            Row(
              children: [
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.photo_camera,
                    label: AppStrings.getString('camera', currentLocale),
                    onTap: () => Navigator.pop(context, 1),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOptionButton(
                    icon: Icons.photo_library,
                    label: AppStrings.getString('gallery', currentLocale),
                    onTap: () => Navigator.pop(context, 2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[50],
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Column(
          children: [
            Icon(icon, color: AppColors.mainColor, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
