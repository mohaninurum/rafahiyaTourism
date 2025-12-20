import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../provider/locale_provider.dart';
import '../../../../utils/language/app_strings.dart';
import '../../data/models/announcement_model.dart';
import '../widgets/delete_announcement_dialog.dart';
import '../widgets/edit_announcement_dialog.dart';

class AnnouncementTile extends StatelessWidget {
  final Announcement announcement;
  final String docId;

  const AnnouncementTile({
    super.key,
    required this.announcement,
    required this.docId,
  });

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final hasValidImage =
        announcement.imageUrl != null &&
            announcement.imageUrl!.isNotEmpty &&
            Uri.tryParse(announcement.imageUrl!)?.isAbsolute == true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: announcement.highlight ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image/Icon
          if (hasValidImage)
            SizedBox(
              width: 48,
              height: 48,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/images/placeholder.jpg',
                  image: announcement.imageUrl!,
                  fit: BoxFit.cover,
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.broken_image,
                      size: 48,
                      color: Colors.grey.shade400,
                    );
                  },
                ),
              ),
            )
          else
            Icon(announcement.icon, color: announcement.iconColor, size: 36),

          const SizedBox(width: 12),

          // Title + Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  announcement.description,
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Text(
                  announcement.time,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Action Icons
          Column(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.edit_note,
                  color: Colors.indigo,
                  size: 26,
                ),
                tooltip: AppStrings.getString('edit', currentLocale),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (_) => EditAnnouncementDialog(
                      docId: announcement.id,
                      announcement: announcement,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_forever_rounded,
                  color: Colors.redAccent,
                  size: 26,
                ),
                tooltip: AppStrings.getString('delete', currentLocale),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteConfirmationDialog(docId: announcement.id),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}