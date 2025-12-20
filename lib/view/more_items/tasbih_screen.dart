import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/tasbih_provider.dart';
import 'package:rafahiyatourism/view/more_items/tasbih_history.dart';
import '../admin_side_code/data/models/dikhr_model.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class TasbiScreen extends StatefulWidget {
  const TasbiScreen({super.key});

  @override
  State<TasbiScreen> createState() => _TasbiScreenState();
}

class _TasbiScreenState extends State<TasbiScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      final provider = Provider.of<TasbihProvider>(context, listen: false);
      provider.saveIncrementalProgress();
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = TasbihProvider();
        provider.initialize();
        // Reset the counter when screen is created
        provider.resetCounter();
        return provider;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(color: AppColors.whiteColor),
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
                child: const _TasbihBody(),
              ),
            ),
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomDikhrSelector(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasbihBody extends StatefulWidget {
  const _TasbihBody();

  @override
  State<_TasbihBody> createState() => _TasbihBodyState();
}

class _TasbihBodyState extends State<_TasbihBody> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void dispose() {
    // Save current session when screen is disposed
    final provider = Provider.of<TasbihProvider>(context, listen: false);
    provider.saveIncrementalProgress();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        children: [
          _buildAppBar(context, currentLocale),
          const SizedBox(height: 10),
          _buildCounterDisplay(context, currentLocale),
          const SizedBox(height: 20),
          _buildTasbihBeads(context),
          const SizedBox(height: 20),
          _buildCountButton(context, currentLocale),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(CupertinoIcons.back, color: AppColors.blackColor),
          ),
          Text(
            AppStrings.getString('digitalTasbih', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
          Row(
            children: [
              InkWell(
                onTap: () {
                  Provider.of<TasbihProvider>(
                    context,
                    listen: false,
                  ).resetCounter();
                },
                child: Icon(Icons.refresh, color: AppColors.mainColor),
              ),
              const SizedBox(width: 7),
              InkWell(
                onTap: () => Provider.of<TasbihProvider>(context, listen: false).toggleMute(),
                child: Icon(
                  Provider.of<TasbihProvider>(context).isMuted
                      ? Icons.volume_off
                      : Icons.volume_up,
                  color: AppColors.mainColor,
                ),
              ),
              const SizedBox(width: 7),
              InkWell(
                onTap: () async {
                  final sessionData = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TasbihHistoryScreen())
                  );

                  if (sessionData != null) {
                    final provider = Provider.of<TasbihProvider>(context, listen: false);
                    provider.loadSessionFromHistory(sessionData);
                  }
                },
                child: Icon(Icons.history, color: AppColors.mainColor),
              ),
              const SizedBox(width: 7),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterDisplay(BuildContext context, String currentLocale) {
    final provider = Provider.of<TasbihProvider>(context);
    final loops = provider.counter ~/ TasbihProvider.LOOP_SIZE; // Calculate completed loops
    final isEnglishDisplay = provider.selectedDikhr.arabic == provider.selectedDikhr.name.toUpperCase();

    return Column(
      children: [
        if (loops > 0) ...[
          const SizedBox(height: 8),
          Text(
            "${AppStrings.getString('loops', currentLocale)}: $loops",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.blackColor,
            ),
          ),
        ],
        Text(
          "${provider.counter}",
          style: GoogleFonts.poppins(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            color: AppColors.mainColor,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "/ ${provider.maxCount}",
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: Colors.grey.shade600,
              ),
            ),
            IconButton(
              onPressed: () => _showMaxEditDialog(context, currentLocale),
              icon: Icon(
                Icons.edit,
                size: 20,
                color: AppColors.mainColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        if (isEnglishDisplay)
          Text(
            provider.selectedDikhr.arabic,
            style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.mainColor
            ),
          )
        else
          Text(
            provider.selectedDikhr.arabic,
            style: GoogleFonts.amiri(fontSize: 28, color: AppColors.mainColor),
            textDirection: TextDirection.rtl,
          ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            provider.selectedDikhr.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasbihBeads(BuildContext context) {
    final provider = Provider.of<TasbihProvider>(context);

    return SizedBox(
      height: 100,
      width: double.infinity,
      child: Transform(
        transform: Matrix4.identity()..rotateZ(35 / 180),
        alignment: Alignment.center,
        child: CustomPaint(
          painter: TasbihPainter(
            total: provider.maxCount,
            count: provider.counter,
            color: AppColors.mainColor,
          ),
          child: Container(),
        ),
      ),
    );
  }

  Widget _buildCountButton(BuildContext context, String currentLocale) {
    final player = AudioPlayer();

    return SizedBox(
      width: 150,
      height: 150,
      child: ElevatedButton(
        onPressed: () {
          Provider.of<TasbihProvider>(context, listen: false).incrementCounter(context);
          _playTickSound(context, player);
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: AppColors.mainColor,
          elevation: 8,
          padding: const EdgeInsets.all(24),
          foregroundColor: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.touch_app, size: 32),
            const SizedBox(height: 8),
            Text(
              AppStrings.getString('count', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaxEditDialog(BuildContext context, String currentLocale) {
    final provider = Provider.of<TasbihProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController(
      text: provider.maxCount.toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.getString('setTargetCount', currentLocale), style: GoogleFonts.poppins()),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: AppStrings.getString('enterTargetCount', currentLocale),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getString('cancel', currentLocale)),
          ),
          TextButton(
            onPressed: () {
              int? newVal = int.tryParse(controller.text);
              if (newVal != null && newVal > 0) {
                provider.setMaxCount(newVal);
              }
              Navigator.pop(context);
            },
            child: Text(AppStrings.getString('save', currentLocale)),
          ),
        ],
      ),
    );
  }

  Future<void> _playTickSound(BuildContext context, AudioPlayer player) async {
    final provider = Provider.of<TasbihProvider>(context, listen: false);
    if (!provider.isMuted) {
      try {
        await player.stop();
        await player.play(AssetSource('audio/tick.wav'));
      } catch (e) {
        debugPrint("Error playing sound: $e");
      }
    }
  }
}

class _BottomDikhrSelector extends StatelessWidget {
  const _BottomDikhrSelector();

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<TasbihProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => _showDikhrSelectionDialog(context, currentLocale),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.selectedDikhr.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: AppColors.mainColor,
                      ),
                    ),
                    Text(
                      provider.selectedDikhr.arabic,
                      style: GoogleFonts.amiri(
                        fontSize: 20,
                        color: AppColors.mainColor,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.mainColor),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showAddDikhrDialog(context, currentLocale),
            icon: const Icon(Icons.add, size: 20, color: Colors.white),
            label: Text(
              AppStrings.getString('addCustomDikhr', currentLocale),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDikhrDialog(BuildContext context, String currentLocale) {
    final nameController = TextEditingController();
    final arabicController = TextEditingController();
    final provider = Provider.of<TasbihProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Center(child: Text(AppStrings.getString('addCustomDikhr', currentLocale), style: GoogleFonts.poppins())),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppStrings.getString('nameEnglishUrdu', currentLocale),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: arabicController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: AppStrings.getString('nameArabicOptional', currentLocale),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppStrings.getString('cancel', currentLocale),
                  style: GoogleFonts.poppins(
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    provider.addCustomDikhr(
                      Dikhr(
                        name: nameController.text,
                        arabic: arabicController.text.isNotEmpty
                            ? arabicController.text
                            : nameController.text.toUpperCase(),
                        isCustom: true,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  AppStrings.getString('add', currentLocale),
                  style: GoogleFonts.poppins(
                    color: AppColors.mainColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDikhrSelectionDialog(BuildContext context, String currentLocale) {
    final provider = Provider.of<TasbihProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    AppStrings.getString('selectDikhr', currentLocale),
                    style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: provider.allDikhrs.length,
                      itemBuilder: (context, index) {
                        final dikhr = provider.allDikhrs[index];
                        return ListTile(
                          onTap: () {
                            provider.setSelectedDikhr(dikhr);
                            Navigator.pop(context);
                          },
                          onLongPress: dikhr.isCustom
                              ? () => _showDeleteDikhrDialog(context, dikhr, currentLocale)
                              : null,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dikhr.name,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500
                                ),
                              ),
                              Text(
                                dikhr.arabic,
                                style: GoogleFonts.amiri(
                                    fontSize: 20,
                                    color: AppColors.mainColor
                                ),
                              ),
                            ],
                          ),
                          trailing: provider.selectedDikhr == dikhr
                              ? Icon(Icons.check, color: AppColors.mainColor)
                              : dikhr.isCustom
                              ? IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDikhrDialog(context, dikhr, currentLocale);
                            },
                          )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteDikhrDialog(BuildContext context, Dikhr dikhr, String currentLocale) {
    final provider = Provider.of<TasbihProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppStrings.getString('deleteDikhr', currentLocale)),
        content: Text(AppStrings.getString('deleteDikhrConfirmation', currentLocale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.getString('cancel', currentLocale)),
          ),
          TextButton(
            onPressed: () {
              provider.removeCustomDikhr(dikhr);
              Navigator.pop(context);
              Navigator.pop(context); // Also close the bottom sheet
            },
            child: Text(AppStrings.getString('delete', currentLocale), style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class TasbihPainter extends CustomPainter {
  final int total;
  final int count;
  final Color color;

  TasbihPainter({
    required this.total,
    required this.count,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int leftBeads = 6;
    const int rightBeads = 6;
    const int totalBeads = leftBeads + rightBeads;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double smallBeadRadius = 12;
    final double largeBeadRadius = 16;
    final double gap = 2;

    List<Offset> beadPositions = [];

    double startLeftX = centerX - (smallBeadRadius * 3 + gap) * (leftBeads - 1);
    for (int i = 0; i < leftBeads; i++) {
      double x = startLeftX + i * (smallBeadRadius * 2 + gap);
      beadPositions.add(Offset(x, centerY));
    }

    double startRightX = centerX + largeBeadRadius * 2 + gap;
    for (int i = 0; i < rightBeads; i++) {
      double x = startRightX + i * (largeBeadRadius * 2 + gap);
      beadPositions.add(Offset(x, centerY));
    }

    final ropePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final ropePath = Path();
    ropePath.moveTo(beadPositions[leftBeads - 1].dx + smallBeadRadius, centerY);
    ropePath.lineTo(beadPositions[leftBeads].dx - largeBeadRadius, centerY);
    canvas.drawPath(ropePath, ropePaint);

    for (int i = 0; i < totalBeads; i++) {
      bool isActive = i < (count % totalBeads == 0 && count != 0 ? totalBeads : count % totalBeads);
      double radius = i < leftBeads ? smallBeadRadius : largeBeadRadius;
      final beadPaint = Paint()
        ..color = isActive ? color : color.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      if (isActive) {
        canvas.drawShadow(
          Path()..addOval(
            Rect.fromCircle(center: beadPositions[i], radius: radius),
          ),
          color.withOpacity(0.5),
          3,
          true,
        );
      }

      canvas.drawCircle(beadPositions[i], radius, beadPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}