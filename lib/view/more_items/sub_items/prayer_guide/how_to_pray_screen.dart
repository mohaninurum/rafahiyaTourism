import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class HowToPrayScreen extends StatelessWidget {
  HowToPrayScreen({super.key});

  final List<Map<String, dynamic>> salahSteps = const [
    {
      'titleKey': 'preparationTitle',
      'descriptionKey': 'preparationDesc',
      'image': 'assets/images/wudu.jpg',
      'icon': Icons.clean_hands,
    },
    {
      'titleKey': 'intentionTitle',
      'descriptionKey': 'intentionDesc',
      'image': 'assets/images/standing.png',
      'icon': Icons.psychology,
    },
    {
      'titleKey': 'takbirTitle',
      'descriptionKey': 'takbirDesc',
      'image': 'assets/images/takbir.jpeg',
      'icon': Icons.arrow_upward,
    },
    {
      'titleKey': 'qiyamTitle',
      'descriptionKey': 'qiyamDesc',
      'image': 'assets/images/qayam.jpeg',
      'icon': Icons.accessibility,
    },
    {
      'titleKey': 'rukuTitle',
      'descriptionKey': 'rukuDesc',
      'image': 'assets/images/ruku1.png',
      'icon': Icons.downhill_skiing,
    },
    {
      'titleKey': 'standingStraightTitle',
      'descriptionKey': 'standingStraightDesc',
      'image': 'assets/images/standing.png',
      'icon': Icons.arrow_upward,
    },
    {
      'titleKey': 'sujoodTitle',
      'descriptionKey': 'sujoodDesc',
      'image': 'assets/images/sujood.jpeg',
      'icon': Icons.volunteer_activism,
    },
    {
      'titleKey': 'sittingBetweenTitle',
      'descriptionKey': 'sittingBetweenDesc',
      'image': 'assets/images/sitting.jpeg',
      'icon': Icons.chair,
    },
    {
      'titleKey': 'secondSujoodTitle',
      'descriptionKey': 'secondSujoodDesc',
      'image': 'assets/images/sujood.jpeg',
      'icon': Icons.volunteer_activism,
    },
    {
      'titleKey': 'tashahhudTitle',
      'descriptionKey': 'tashahhudDesc',
      'image': 'assets/images/sitting.jpeg',
      'icon': Icons.handshake,
    },
    {
      'titleKey': 'salatNabiTitle',
      'descriptionKey': 'salatNabiDesc',
      'image': 'assets/images/nabi.jpeg',
      'icon': Icons.emoji_people,
    },
    {
      'titleKey': 'daroodTitle',
      'descriptionKey': 'daroodDesc',
      'image': 'assets/images/sitting.jpeg',
      'icon': Icons.handshake,
    },
    {
      'titleKey': 'finalDuaTitle',
      'descriptionKey': 'finalDuaDesc',
      'image': 'assets/images/sitting.jpeg',
      'icon': Icons.handshake,
    },
    {
      'titleKey': 'tasleemTitle',
      'descriptionKey': 'tasleemDesc',
      'image': 'assets/images/salam.jpeg',
      'icon': Icons.exit_to_app,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppStrings.getString('howToPrayTitle', currentLocale),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.mainColor, AppColors.mainColor],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                AppStrings.getString('stepByStepGuide', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mainColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                AppStrings.getString('followSteps', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final step = salahSteps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: _buildStepCard(step, index, context, currentLocale),
              )
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .slideY(
                begin: 0.1,
                end: 0,
                curve: Curves.easeOut,
                duration: 300.ms,
              );
            }, childCount: salahSteps.length),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(
      Map<String, dynamic> step,
      int index,
      BuildContext context,
      String currentLocale,
      ) {
    final title = AppStrings.getString(step['titleKey'], currentLocale);
    final description = AppStrings.getString(step['descriptionKey'], currentLocale);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      shadowColor: Colors.grey.withOpacity(0.3),
      child: InkWell(
        onTap: () {
          _showStepDetail(context, step, currentLocale);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(step['image']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 160,
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          step['icon'],
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${AppStrings.getString('step', currentLocale)} ${index + 1} ${AppStrings.getString('of', currentLocale)} ${salahSteps.length}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStepDetail(BuildContext context, Map<String, dynamic> step, String currentLocale) {
    final title = AppStrings.getString(step['titleKey'], currentLocale);
    final description = AppStrings.getString(step['descriptionKey'], currentLocale);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(top: 16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(step['image']),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(step['icon'], color: AppColors.mainColor),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.mainColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              description,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[800],
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 24),

                            // Custom notes for each step
                            if (step['titleKey'] == 'preparationTitle')
                              _buildImportantNote(
                                AppStrings.getString('wuduSteps', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'intentionTitle')
                              _buildImportantNote(
                                AppStrings.getString('intentionNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'takbirTitle')
                              _buildImportantNote(
                                AppStrings.getString('takbirNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'qiyamTitle')
                              _buildImportantNote(
                                AppStrings.getString('qiyamNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'rukuTitle')
                              _buildImportantNote(
                                AppStrings.getString('rukuNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'standingStraightTitle')
                              _buildImportantNote(
                                AppStrings.getString('standingNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'sujoodTitle')
                              _buildImportantNote(
                                AppStrings.getString('sujoodNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'sittingBetweenTitle')
                              _buildImportantNote(
                                AppStrings.getString('sittingNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'tashahhudTitle')
                              _buildImportantNote(
                                AppStrings.getString('tashahhudNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'salatNabiTitle')
                              _buildImportantNote(
                                AppStrings.getString('salatNabiNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'daroodTitle')
                              _buildImportantNote(
                                AppStrings.getString('daroodNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'finalDuaTitle')
                              _buildImportantNote(
                                AppStrings.getString('finalDuaNote', currentLocale),
                                currentLocale,
                              ),

                            if (step['titleKey'] == 'tasleemTitle')
                              _buildImportantNote(
                                AppStrings.getString('tasleemNote', currentLocale),
                                currentLocale,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    AppStrings.getString('close', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImportantNote(String text, String currentLocale) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mainColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: Colors.white),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}