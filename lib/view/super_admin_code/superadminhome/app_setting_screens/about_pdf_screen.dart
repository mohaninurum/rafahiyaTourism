import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/app_setting_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../../../const/color.dart';
import '../../../home/about_pdf_viewer.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class ManageAboutPdfScreen extends StatefulWidget {
  const ManageAboutPdfScreen({super.key});

  @override
  State<ManageAboutPdfScreen> createState() => _ManageAboutPdfScreenState();
}

class _ManageAboutPdfScreenState extends State<ManageAboutPdfScreen> {
  bool _isUploading = false;
  String? _currentPdfUrl;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPdf();
    });
  }

  Future<void> _loadCurrentPdf() async {
    await Provider.of<AppSettingsProvider>(context, listen: false)
        .fetchAboutPdfUrl();
    setState(() {
      _currentPdfUrl = Provider.of<AppSettingsProvider>(context, listen: false)
          .aboutPdfUrl;
    });
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isRestricted) {
        // On some devices, storage permission is restricted
        return true;
      }

      final status = await Permission.storage.status;
      if (status.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return status.isGranted;
    }
    return true;
  }

  Future<void> _uploadPdf() async {
    final currentLocale = _getCurrentLocale(context);
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('storagePermissionRequired', currentLocale)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      PlatformFile file = result.files.first;

      // Optional: Add file type validation if needed
      List<String> allowedExtensions = ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'];
      if (file.extension != null &&
          !allowedExtensions.contains(file.extension!.toLowerCase())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('selectValidDocument', currentLocale)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (file.size > 10 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('fileSizeLimit', currentLocale)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isUploading = true;
      });

      File docFile = File(file.path!);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('about_docs')
          .child('about_${DateTime.now().millisecondsSinceEpoch}.${file.extension}');

      final uploadTask = storageRef.putFile(docFile);
      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      final success = await Provider.of<AppSettingsProvider>(context, listen: false)
          .updateAboutPdf(downloadUrl);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('documentUpdated', currentLocale)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _currentPdfUrl = downloadUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('failedToUpdateDocument', currentLocale)),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('errorUploading', currentLocale)} $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _viewCurrentPdf() async {
    final currentLocale = _getCurrentLocale(context);
    if (_currentPdfUrl == null || _currentPdfUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('noPdfAvailable', currentLocale)),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfUrl: _currentPdfUrl!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.getString('manageAboutPdf', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getString('aboutPdfManagement', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getString('uploadNewPdf', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Current PDF Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.getString('currentPdfStatus', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          _currentPdfUrl != null && _currentPdfUrl!.isNotEmpty
                              ? Icons.check_circle
                              : Icons.error,
                          color: _currentPdfUrl != null && _currentPdfUrl!.isNotEmpty
                              ? Colors.green
                              : Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentPdfUrl != null && _currentPdfUrl!.isNotEmpty
                                ? AppStrings.getString('pdfAvailable', currentLocale)
                                : AppStrings.getString('noPdfUploaded', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_currentPdfUrl != null && _currentPdfUrl!.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            'PDF URL: ${_currentPdfUrl!.substring(0, 50)}...',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            if (_isUploading)
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      color: AppColors.mainColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Uploading PDF...',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _uploadPdf,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload_file, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.getString('uploadNewPdfButton', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _viewCurrentPdf,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppColors.mainColor),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.visibility, color: AppColors.mainColor),
                          const SizedBox(width: 8),
                          Text(
                            AppStrings.getString('viewCurrentPdf', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mainColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),

            // Instructions
            Text(
              AppStrings.getString('instructions', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• ${AppStrings.getString('instructionsPdfOnly', currentLocale)}\n'
                  '• ${AppStrings.getString('instructionsFileSize', currentLocale)}\n'
                  '• ${AppStrings.getString('instructionsContentUpdated', currentLocale)}\n'
                  '• ${AppStrings.getString('instructionsPreview', currentLocale)}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}