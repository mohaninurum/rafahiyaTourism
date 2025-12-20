import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/const/color.dart';

import '../../../provider/add_umrah_packages_provider.dart';
import '../../../utils/model/add_umrah_packages_model.dart';

class AddPackagesScreen extends StatefulWidget {
  const AddPackagesScreen({super.key});

  @override
  State<AddPackagesScreen> createState() => _AddPackagesScreenState();
}

class _AddPackagesScreenState extends State<AddPackagesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescController = TextEditingController();

  String? _imagePath;
  bool _isEditing = false;
  String? _editingPackageId;
  List<PackageService> _services = [];
  List<ItineraryDay> _itinerary = [];
  List<TextEditingController> _itineraryControllers = [];
  bool _isLoading = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      await context.read<AddUmrahPackageProvider>().fetchPackages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.getString('errorInitializingFirebase', _getCurrentLocale(context))}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _serviceNameController.dispose();
    _serviceDescController.dispose();
    for (var controller in _itineraryControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _priceController.clear();
    _noteController.clear();
    _serviceNameController.clear();
    _serviceDescController.clear();
    setState(() {
      _imagePath = null;
      _isEditing = false;
      _editingPackageId = null;
      _services = [];
      _itinerary = [];
      _isLoading = false;
    });
    for (var controller in _itineraryControllers) {
      controller.dispose();
    }
    _itineraryControllers = [];
  }

  void _addService(String currentLocale) {
    if (_serviceNameController.text.isEmpty || _serviceDescController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getString('pleaseEnterServiceDetails', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _services.add(
        PackageService(
          name: _serviceNameController.text,
          description: _serviceDescController.text,
        ),
      );
    });
    _serviceNameController.clear();
    _serviceDescController.clear();
  }

  void _removeService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  void _editPackage(AddUmrahPackage package) {
    _titleController.text = package.title;
    _priceController.text = package.price;
    _noteController.text = package.note;
    setState(() {
      _imagePath = package.imageUrl;
      _isEditing = true;
      _editingPackageId = package.id;
      _services = [...package.services];
      _itinerary = [...package.itinerary];
    });

    for (var controller in _itineraryControllers) {
      controller.dispose();
    }
    _itineraryControllers = [];

    for (var day in package.itinerary) {
      final controller = TextEditingController(text: day.activities);
      _itineraryControllers.add(controller);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final currentLocale = _getCurrentLocale(context);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      currentDate: DateTime.now(),
      saveText: AppStrings.getString('select', currentLocale).toUpperCase(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      for (var controller in _itineraryControllers) {
        controller.dispose();
      }
      _itineraryControllers = [];

      final dates = context.read<AddUmrahPackageProvider>().generateDateRange(
        picked.start,
        picked.end,
      );

      setState(() {
        _itinerary = dates.map((date) => ItineraryDay(date: date, activities: '')).toList();
        _itineraryControllers = List.generate(_itinerary.length, (index) => TextEditingController());
      });
    }
  }

  void _submitForm() async {
    final currentLocale = _getCurrentLocale(context);

    if (!_formKey.currentState!.validate()) return;
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.getString('pleaseSelectImage', currentLocale), style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_itinerary.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.getString('pleaseSelectDateRange', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (int i = 0; i < _itineraryControllers.length; i++) {
      if (_itineraryControllers[i].text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppStrings.getString('pleaseEnterActivitiesFor', currentLocale)} ${AppStrings.getString('day', currentLocale)} ${i + 1}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final updatedItinerary = <ItineraryDay>[];
    for (int i = 0; i < _itinerary.length; i++) {
      updatedItinerary.add(
        ItineraryDay(
          date: _itinerary[i].date,
          activities: _itineraryControllers[i].text,
        ),
      );
    }

    setState(() {
      _isLoading = true;
    });

    try {
      File? imageFile;
      if (_imagePath != null && !_imagePath!.startsWith('http')) {
        imageFile = File(_imagePath!);
      }

      final newPackage = AddUmrahPackage(
        id: _isEditing ? _editingPackageId! : DateTime.now().toString(),
        title: _titleController.text,
        price: _priceController.text,
        startDate: _itinerary.first.date,
        endDate: _itinerary.last.date,
        note: _noteController.text,
        imageUrl: _imagePath!, // This will be updated after upload
        itinerary: updatedItinerary,
        services: _services,
      );

      if (_isEditing) {
        await context.read<AddUmrahPackageProvider>().updatePackage(
            newPackage,
            imageFile: imageFile
        );
      } else {
        await context.read<AddUmrahPackageProvider>().addPackage(
            newPackage,
            imageFile: imageFile
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? AppStrings.getString('packageUpdated', currentLocale)
                : AppStrings.getString('packageAdded', currentLocale),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.mainColor,
        ),
      );

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.getString('error', currentLocale)}: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    final provider = context.watch<AddUmrahPackageProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(CupertinoIcons.back, color: Colors.white),
        ),
        title: Text(
          _isEditing
              ? AppStrings.getString('editPackage', currentLocale)
              : AppStrings.getString('addNewPackage', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.mainColor),
        ),
      )
          : SingleChildScrollView(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: isSmallScreen ? 150 : 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: _imagePath == null
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppStrings.getString('tapToAddPackageImage', currentLocale),
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _imagePath!.startsWith('http')
                            ? Image.network(
                          _imagePath!,
                          fit: BoxFit.cover,
                        )
                            : Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: AppStrings.getString('packageTitle', currentLocale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mainColor),
                      ),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    style: GoogleFonts.poppins(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.getString('pleaseEnterTitle', currentLocale);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDateRange(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _itinerary.isEmpty
                                ? AppStrings.getString('selectDates', currentLocale)
                                : '${_itinerary.first.date.day}/${_itinerary.first.date.month}/${_itinerary.first.date.year} - '
                                '${_itinerary.last.date.day}/${_itinerary.last.date.month}/${_itinerary.last.date.year}',
                            style: GoogleFonts.poppins(),
                          ),
                          Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: '${AppStrings.getString('price', currentLocale)} (INR)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.mainColor,
                        ),
                      ),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    style: GoogleFonts.poppins(),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppStrings.getString('pleaseEnterPrice', currentLocale);
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: AppStrings.getString('specialNote', currentLocale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.mainColor),
                      ),
                      labelStyle: GoogleFonts.poppins(),
                    ),
                    style: GoogleFonts.poppins(),
                  ),
                  const SizedBox(height: 16),
                  if (_itinerary.isNotEmpty) ...[
                    Text(
                      '${AppStrings.getString('itineraryDetails', currentLocale)} (${_itinerary.length} ${AppStrings.getString('days', currentLocale)})',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _itinerary.length,
                      itemBuilder: (context, index) {
                        return _buildItineraryDayField(index, isSmallScreen, currentLocale);
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('packageServices', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.getString('selectPackageServices', currentLocale),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: predefinedServices.length,
                    itemBuilder: (context, index) {
                      final service = predefinedServices[index];
                      final isSelected = _services.any((s) => s.name == service.name);

                      return CheckboxListTile(
                        value: isSelected,
                        title: Text(
                          service.description,
                          style: GoogleFonts.poppins(),
                        ),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _services.add(service);
                            } else {
                              _services.removeWhere((s) => s.name == service.name);
                            }
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  if (_services.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppStrings.getString('addedServices', currentLocale)}:',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _services.length,
                          itemBuilder: (context, index) {
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  _services[index].name,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  _services[index].description,
                                  style: GoogleFonts.poppins(),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _removeService(index),
                                ),
                              ),
                            );

                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isEditing
                            ? AppStrings.getString('updatePackage', currentLocale).toUpperCase()
                            : AppStrings.getString('addPackage', currentLocale).toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: _resetForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppStrings.getString('cancel', currentLocale).toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              AppStrings.getString('existingPackages', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            if (provider.packages.isEmpty)
              Column(
                children: [
                  Icon(Icons.inbox, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.getString('noPackagesAdded', currentLocale),
                    style: GoogleFonts.poppins(color: Colors.grey[500]),
                  ),
                ],
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.packages.length,
                itemBuilder: (context, index) {
                  final package = provider.packages[index];
                  return _buildPackageCard(package, provider, isSmallScreen, currentLocale);
                },
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryDayField(int index, bool isSmallScreen, String currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppStrings.getString('day', currentLocale)} ${index + 1} - ${_itinerary[index].date.toLocal().toString().split(' ')[0]}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _itineraryControllers[index],
          decoration: InputDecoration(
            labelText: AppStrings.getString('activities', currentLocale),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.mainColor),
            ),
            labelStyle: GoogleFonts.poppins(),
          ),
          style: GoogleFonts.poppins(),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPackageCard(
      AddUmrahPackage package,
      AddUmrahPackageProvider provider,
      bool isSmallScreen,
      String currentLocale,
      ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: package.imageUrl.startsWith('http')
                      ? Image.network(
                    package.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                      : Image.file(
                    File(package.imageUrl),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (package.startDate != null && package.endDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${package.startDate!.day}/${package.startDate!.month}/${package.startDate!.year} - '
                              '${package.endDate!.day}/${package.endDate!.month}/${package.endDate!.year}',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppStrings.getString('duration', currentLocale)}: ${package.durationString}',
                          style: GoogleFonts.poppins(
                            color: AppColors.mainColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'INR ${package.price}',
                        style: GoogleFonts.poppins(
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text(AppStrings.getString('edit', currentLocale), style: GoogleFonts.poppins()),
                      onTap: () => _editPackage(package),
                    ),
                    PopupMenuItem(
                      child: Text(
                        AppStrings.getString('delete', currentLocale),
                        style: GoogleFonts.poppins(color: Colors.red),
                      ),
                      onTap: () {
                        provider.removePackage(package.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppStrings.getString('packageDeleted', currentLocale),
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (package.services.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                '${AppStrings.getString('servicesIncluded', currentLocale)}:',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: package.services
                    .map(
                      (service) => Chip(
                    label: Text(service.name),
                    backgroundColor: Colors.grey[100],
                  ),
                )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
  final predefinedServices = [
    PackageService(name: 'Meals', description: 'Meals included'),
    PackageService(name: 'Flight', description: 'Flight tickets'),
    PackageService(name: 'Hotel Accommodation', description: 'Stay in hotel'),
    PackageService(name: 'Umrah Kit', description: 'Ihram, prayer mat, etc.'),
    PackageService(name: 'Zam Zam Water', description: '5L Zam Zam water per pilgrim'),
    PackageService(name: 'Umrah Visa', description: 'Visa for Umrah'),
    PackageService(name: 'Tour Guide', description: 'Religious guide'),
    PackageService(name: 'Laundry Service', description: 'Laundry included'),
    PackageService(name: 'Local Transport', description: 'Transfers between airport, Makkah, Madinah'),
  ];
}