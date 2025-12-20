import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../data/models/announcement_model.dart';
import '../../data/subAdminProvider/bayan_provider.dart';

class EditAnnouncementDialog extends StatefulWidget {
  final String docId;
  final Announcement announcement;

  const EditAnnouncementDialog({
    super.key,
    required this.docId,
    required this.announcement,
  });

  @override
  State<EditAnnouncementDialog> createState() => _EditAnnouncementDialogState();
}

class _EditAnnouncementDialogState extends State<EditAnnouncementDialog> {
  late TextEditingController titleController;
  late TextEditingController videoController;
  File? _newImage;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.announcement.title);
    videoController = TextEditingController(
      text: widget.announcement.description.contains("http")
          ? widget.announcement.description.replaceFirst("Watch video: ", "")
          : "",
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImage = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Dialog(
      backgroundColor: AppColors.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.getString('editAnnouncement', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blackColor,
                ),
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: _newImage != null
                          ? FileImage(_newImage!)
                          : (widget.announcement.imageUrl != null &&
                          widget.announcement.imageUrl!.isNotEmpty)
                          ? NetworkImage(widget.announcement.imageUrl!)
                      as ImageProvider
                          : const AssetImage("assets/images/no_image.jpg"),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: AppColors.mainColor,
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: AppStrings.getString('title', currentLocale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: videoController,
                decoration: InputDecoration(
                  labelText: AppStrings.getString('videoLink', currentLocale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text(
                      AppStrings.getString('cancel', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackColor,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                    ),
                    icon: Icon(
                      Icons.update,
                      size: 18,
                      color: AppColors.whiteColor,
                    ),
                    label: Text(
                      AppStrings.getString('update', currentLocale),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    onPressed: () async {
                      await Provider.of<BayanProvider>(
                        context,
                        listen: false,
                      ).updateBayan(
                        widget.docId,
                        titleController.text,
                        videoController.text,
                        imageFile: _newImage, // pass image if picked
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}