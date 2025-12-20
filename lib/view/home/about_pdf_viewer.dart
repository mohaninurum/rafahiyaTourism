import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/app_setting_provider.dart';

import '../../provider/locale_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final String? pdfUrl;

  const PdfViewerScreen({super.key, this.pdfUrl});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isError = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  File? _localPdfFile;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      // If PDF URL is provided (from Firebase), download it
      if (widget.pdfUrl != null && widget.pdfUrl!.isNotEmpty) {
        await _downloadPdfFromUrl(widget.pdfUrl!);
      } else {
        // Fallback to local asset
        await _loadLocalAssetPdf();
      }

      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadPdfFromUrl(String pdfUrl) async {
    try {
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        Directory appDocDir = await getApplicationDocumentsDirectory();
        String localPath = '${appDocDir.path}/about_firebase.pdf';
        File file = File(localPath);

        await file.writeAsBytes(bytes);
        _localPdfFile = file;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      // If Firebase download fails, try local asset
      print('Firebase PDF download failed: $e');
      await _loadLocalAssetPdf();
    }
  }

  Future<void> _loadLocalAssetPdf() async {
    try {
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String localPath = '${appDocDir.path}/about.pdf';
      File file = File(localPath);

      if (await file.exists()) {
        _localPdfFile = file;
      } else {
        try {
          // Try to load from assets
          final ByteData data = await rootBundle.load('assets/pdfs/about.pdf');
          final List<int> bytes = data.buffer.asUint8List();
          await file.writeAsBytes(bytes);
          _localPdfFile = file;
        } catch (e) {
          throw Exception('Failed to load PDF from assets: $e');
        }
      }
    } catch (e) {
      throw Exception('Failed to load local PDF: $e');
    }
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          AppStrings.getString('about', currentLocale),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? _buildShimmerLoader()
          : _isError
          ? Center(
        child: Text(
          AppStrings.getString('failedToLoadPDF', currentLocale),
          style: TextStyle(color: Colors.red),
        ),
      )
          : FadeTransition(
        opacity: _fadeAnimation,
        child: SfPdfViewer.file(_localPdfFile!),
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        itemCount: 6,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
      ),
    );
  }
}