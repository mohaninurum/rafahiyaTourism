import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../const/color.dart';
import '../../../model/faq_model.dart';
import '../../superadminprovider/faq/faq_provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class AddEditFAQScreen extends StatefulWidget {
  final FAQ? faq;

  const AddEditFAQScreen({super.key, this.faq});

  @override
  State<AddEditFAQScreen> createState() => _AddEditFAQScreenState();
}

class _AddEditFAQScreenState extends State<AddEditFAQScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  bool _isSaving = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.faq?.question ?? '',
    );
    _answerController = TextEditingController(
      text: widget.faq?.answer ?? '',
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _saveFAQ() async {
    final currentLocale = _getCurrentLocale(context);

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      final faqProvider = Provider.of<FAQProvider>(context, listen: false);
      final isEditing = widget.faq != null;

      try {
        if (isEditing) {
          final updatedFaq = widget.faq!.copyWith(
            question: _questionController.text,
            answer: _answerController.text,
            updatedAt: DateTime.now(),
          );
          await faqProvider.updateFAQ(widget.faq!.id, updatedFaq);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.getString('faqUpdatedSuccessfully', currentLocale),
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final newFaq = FAQ(
            id: '',
            question: _questionController.text,
            answer: _answerController.text,
            createdAt: DateTime.now(),
          );
          await faqProvider.addFAQ(newFaq);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.getString('faqAddedSuccessfully', currentLocale),
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context);
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.getString('error', currentLocale)}: ${error.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final isEditing = widget.faq != null;

    return Scaffold(
      backgroundColor: AppColors.whiteBackground,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        title: Text(
          isEditing
              ? AppStrings.getString('editFaq', currentLocale)
              : AppStrings.getString('addNewFaq', currentLocale),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSaving
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
            ),
            SizedBox(height: 16),
            Text(
              isEditing
                  ? AppStrings.getString('updatingFaq', currentLocale)
                  : AppStrings.getString('addingFaq', currentLocale),
              style: GoogleFonts.poppins(
                color: AppColors.mainColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.getString('question', currentLocale),
                style: GoogleFonts.poppins(
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: AppStrings.getString('enterQuestion', currentLocale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.mainColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: GoogleFonts.poppins(),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.getString('pleaseEnterQuestion', currentLocale);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              Text(
                AppStrings.getString('answer', currentLocale),
                style: GoogleFonts.poppins(
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerController,
                decoration: InputDecoration(
                  hintText: AppStrings.getString('enterAnswer', currentLocale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.mainColor, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: GoogleFonts.poppins(),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.getString('pleaseEnterAnswer', currentLocale);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveFAQ,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    isEditing
                        ? AppStrings.getString('updateFaq', currentLocale)
                        : AppStrings.getString('addFaq', currentLocale),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}