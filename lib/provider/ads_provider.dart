


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../const/color.dart';
import '../utils/language/app_strings.dart';
import '../view/super_admin_code/models/country_cities_list.dart';
import '../view/super_admin_code/models/global_ads_model/global_ad.dart';
import 'locale_provider.dart';

class AdsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  List<GlobalAdModel> _ads = [];
  bool _isLoading = false;
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  File? _selectedImage;
  bool _isActive = true;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedCountry;
  String? _selectedCity;
  List<String> _availableCities = [];
  String? _lastSelectedCountry;
  String? _lastSelectedCity;

  final Map<String, List<String>> _countryCities = CitiesData.countryCities;


  // final Map<String, List<String>> _countryCities = {
  //   'Saudi Arabia': ['Makkah', 'Madinah', 'Riyadh', 'Jeddah'],
  //   'India': ['Mumbai', 'Delhi', 'Hyderabad', 'Chennai'],
  //   'Germany': ['Berlin', 'Munich', 'Frankfurt', 'Hamburg'],
  //   'All Countries': ['All Cities'],
  // };

  String? get selectedCountry => _selectedCountry;
  String? get selectedCity => _selectedCity;
  List<GlobalAdModel> get ads => _ads;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    await _loadAds();
  }

  Future<void> _loadAds() async {
    try {
      _setLoading(true);
      final snapshot = await _firestore.collection('global_ads').get();
      print('Fetched ${snapshot.docs.length} ads');
      _ads = snapshot.docs.map((doc) => GlobalAdModel.fromMap(doc.data())).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading ads: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void showCountrySelectionDialog(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            AppStrings.getString('selectCountry', currentLocale),
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _countryCities.keys.length,
              itemBuilder: (context, index) {
                final country = _countryCities.keys.elementAt(index);
                return ListTile(
                  title: Text(country, style: GoogleFonts.poppins()),
                  onTap: () {
                    _selectedCountry = country;
                    _availableCities = _countryCities[country]!;
                    _selectedCity = null;
                    Navigator.pop(context);
                    showCitySelectionDialog(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showCitySelectionDialog(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    if (_selectedCountry == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${AppStrings.getString('selectCityFor', currentLocale)} $_selectedCountry',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _availableCities.length,
              itemBuilder: (context, index) {
                final city = _availableCities[index];
                return ListTile(
                  title: Text(city, style: GoogleFonts.poppins()),
                  onTap: () {
                    _selectedCity = city;
                    _lastSelectedCountry = _selectedCountry;
                    _lastSelectedCity = _selectedCity;
                    Navigator.pop(context);
                    notifyListeners();
                    showAddAdBottomSheet(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void showAddAdBottomSheet(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    _resetFormState(keepLocation: true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBottomSheetHandle(),
                      Center(
                        child: Text(
                          AppStrings.getString('createNewGlobalAd', currentLocale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        child: Column(
                          children: [
                            _buildImagePicker(setState, null, currentLocale),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _titleController,
                              decoration: _buildInputDecoration(
                                  AppStrings.getString('adTitle', currentLocale),
                                  currentLocale
                              ),
                              style: GoogleFonts.poppins(),
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterAdTitle', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descController,
                              decoration: _buildInputDecoration(
                                  AppStrings.getString('description', currentLocale),
                                  currentLocale
                              ),
                              style: GoogleFonts.poppins(),
                              maxLines: 3,
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterDescription', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _linkController,
                              decoration: _buildInputDecoration(
                                  AppStrings.getString('linkOptional', currentLocale),
                                  currentLocale
                              ),
                              style: GoogleFonts.poppins(),
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!Uri.tryParse(value)!.hasAbsolutePath) {
                                    return AppStrings.getString('pleaseEnterValidUrl', currentLocale);
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ElevatedButton(
                                onPressed: () => showCountrySelectionDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mainColor,
                                  foregroundColor: AppColors.whiteColor,
                                ),
                                child: Text(
                                    AppStrings.getString('selectNewLocation', currentLocale),
                                    style: GoogleFonts.poppins()
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (_selectedCountry != null || _selectedCity != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  children: [
                                    if (_selectedCountry != null)
                                      _buildLocationChip(
                                          '${AppStrings.getString('country', currentLocale)}: $_selectedCountry',
                                          currentLocale
                                      ),
                                    if (_selectedCity != null) ...[
                                      const SizedBox(width: 8),
                                      _buildLocationChip(
                                          '${AppStrings.getString('city', currentLocale)}: $_selectedCity',
                                          currentLocale
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _startDateController,
                              readOnly: true,
                              onTap: () => _selectDate(context, true, setState),
                              decoration: _buildInputDecoration(
                                AppStrings.getString('startDate', currentLocale),
                                currentLocale,
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              style: GoogleFonts.poppins(),
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterStartDate', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _endDateController,
                              readOnly: true,
                              onTap: () => _selectDate(context, false, setState),
                              decoration: _buildInputDecoration(
                                AppStrings.getString('endDate', currentLocale),
                                currentLocale,
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              style: GoogleFonts.poppins(),
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterEndDate', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  '${AppStrings.getString('active', currentLocale)}:',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: _isActive,
                                  onChanged: (value) => setState(() => _isActive = value),
                                  activeColor: AppColors.mainColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildActionButtons(context, false, null, currentLocale),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLocationChip(String text, String currentLocale) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  void showEditAdBottomSheet(BuildContext context, GlobalAdModel ad) {
    final currentLocale = _getCurrentLocale(context);

    _titleController.text = ad.title;
    _descController.text = ad.description;
    _startDateController.text = ad.startDate;
    _endDateController.text = ad.endDate;
    _linkController.text = ad.link ?? '';
    _isActive = ad.isActive;
    _selectedCountry = ad.country;
    _selectedCity = ad.city;
    _availableCities = _countryCities[ad.country] ?? [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBottomSheetHandle(),
                      Center(
                        child: Text(
                          AppStrings.getString('editGlobalAd', currentLocale),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Form(
                        child: Column(
                          children: [
                            _buildImagePicker(setState, ad, currentLocale),
                            const SizedBox(height: 24),
                            TextFormField(
                              controller: _titleController,
                              decoration: _buildInputDecoration(
                                  AppStrings.getString('adTitle', currentLocale),
                                  currentLocale
                              ),
                              style: GoogleFonts.poppins(),
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterAdTitle', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descController,
                              decoration: _buildInputDecoration(
                                  AppStrings.getString('description', currentLocale),
                                  currentLocale
                              ),
                              style: GoogleFonts.poppins(),
                              maxLines: 3,
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterDescription', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _linkController,
                              decoration: _buildInputDecoration(
                                  AppStrings.getString('linkOptional', currentLocale),
                                  currentLocale
                              ),
                              style: GoogleFonts.poppins(),
                              keyboardType: TextInputType.url,
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  if (!Uri.tryParse(value)!.hasAbsolutePath) {
                                    return AppStrings.getString('pleaseEnterValidUrl', currentLocale);
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _startDateController,
                              readOnly: true,
                              onTap: () => _selectDate(context, true, setState),
                              decoration: _buildInputDecoration(
                                AppStrings.getString('startDate', currentLocale),
                                currentLocale,
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              style: GoogleFonts.poppins(),
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterStartDate', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _endDateController,
                              readOnly: true,
                              onTap: () => _selectDate(context, false, setState),
                              decoration: _buildInputDecoration(
                                AppStrings.getString('endDate', currentLocale),
                                currentLocale,
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                              style: GoogleFonts.poppins(),
                              validator: (value) => value?.isEmpty ?? true
                                  ? AppStrings.getString('pleaseEnterEndDate', currentLocale)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Text(
                                  '${AppStrings.getString('active', currentLocale)}:',
                                  style: GoogleFonts.poppins(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: _isActive,
                                  onChanged: (value) => setState(() => _isActive = value),
                                  activeColor: AppColors.mainColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildActionButtons(context, true, ad, currentLocale),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildImagePicker(void Function(void Function()) setState, GlobalAdModel? ad, String currentLocale) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 130,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: _selectedImage != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(_selectedImage!, fit: BoxFit.cover),
          )
              : (ad != null && ad.imageUrl != null && ad.imageUrl!.isNotEmpty)
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(ad.imageUrl!, fit: BoxFit.cover),
          )
              : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.image, size: 40, color: Colors.grey),
                Text(
                  AppStrings.getString('selectAdImage', currentLocale),
                  style: GoogleFonts.poppins(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          onPressed: () async {
            await pickImage();
            setState(() {});
          },
          child: Text(
              AppStrings.getString('chooseImage', currentLocale),
              style: GoogleFonts.poppins()
          ),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label, String currentLocale, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isEdit, GlobalAdModel? ad, String currentLocale) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: Text(
              AppStrings.getString('cancel', currentLocale).toUpperCase(),
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // First validate all fields
              if (_titleController.text.isEmpty ||
                  _descController.text.isEmpty ||
                  _startDateController.text.isEmpty ||
                  _endDateController.text.isEmpty) {
                Fluttertoast.showToast(
                  msg: AppStrings.getString('pleaseFillAllFields', currentLocale),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                return;
              }

              if (_selectedCountry == null || _selectedCity == null) {
                Fluttertoast.showToast(
                  msg: AppStrings.getString('pleaseSelectCountryCity', currentLocale),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
                return;
              }

              if (_selectedStartDate != null && _selectedEndDate != null) {
                if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
                  Fluttertoast.showToast(
                    msg: AppStrings.getString('endDateAfterStartDate', currentLocale),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                  return;
                }
              }

              Navigator.pop(context);

              try {
                if (isEdit && ad != null) {
                  await updateAd(
                    ad.id,
                    GlobalAdModel(
                      id: ad.id,
                      title: _titleController.text,
                      description: _descController.text,
                      imageUrl: ad.imageUrl,
                      startDate: _startDateController.text,
                      endDate: _endDateController.text,
                      isActive: _isActive,
                      country: _selectedCountry!,
                      city: _selectedCity!,
                      link: _linkController.text.isNotEmpty ? _linkController.text : null,
                    ),
                  );
                } else {
                  await addAd(
                    GlobalAdModel(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: _titleController.text,
                      description: _descController.text,
                      imageUrl: null,
                      startDate: _startDateController.text,
                      endDate: _endDateController.text,
                      isActive: _isActive,
                      country: _selectedCountry!,
                      city: _selectedCity!,
                      link: _linkController.text.isNotEmpty ? _linkController.text : null,
                    ),
                  );
                }

                Fluttertoast.showToast(
                  msg: isEdit
                      ? AppStrings.getString('adUpdatedSuccess', currentLocale)
                      : AppStrings.getString('globalAdAddedSuccess', currentLocale),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );

                await _loadAds();
              } catch (e) {
                Fluttertoast.showToast(
                  msg: '${AppStrings.getString('error', currentLocale)}: ${e.toString()}',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mainColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              isEdit
                  ? AppStrings.getString('update', currentLocale).toUpperCase()
                  : AppStrings.getString('create', currentLocale).toUpperCase(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  Future<void> _selectDate(
      BuildContext context,
      bool isStartDate,
      void Function(void Function()) setState,
      ) async
  {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _selectedStartDate ?? DateTime.now()
          : _selectedEndDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
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
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
          _startDateController.text = picked.toIso8601String().split('T')[0];
        } else {
          _selectedEndDate = picked;
          _endDateController.text = picked.toIso8601String().split('T')[0];
        }
      });
    }
  }

  Future<void> addAd(GlobalAdModel newAd) async {
    try {
      _setLoading(true);

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }

      final adWithLink = newAd.copyWith(
        imageUrl: imageUrl,
      );

      await _firestore
          .collection('global_ads')
          .doc(adWithLink.id)
          .set(adWithLink.toMap());
      _ads.add(adWithLink);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAd(String id, GlobalAdModel updatedAd) async {
    try {
      _setLoading(true);

      String? imageUrl = updatedAd.imageUrl;
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);
      }

      final adWithLink = updatedAd.copyWith(
        imageUrl: imageUrl,
      );

      await _firestore
          .collection('global_ads')
          .doc(id)
          .update(adWithLink.toMap());
      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index >= 0) {
        _ads[index] = adWithLink;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAd(String id) async {
    try {
      _setLoading(true);
      await _firestore.collection('global_ads').doc(id).delete();
      _ads.removeWhere((ad) => ad.id == id);
      notifyListeners();
    } catch (e) {
      ScaffoldMessenger.of(globalContext!).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to delete ad: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleAdStatus(String id) async {
    try {
      _setLoading(true);
      final index = _ads.indexWhere((ad) => ad.id == id);
      if (index >= 0) {
        _ads[index].isActive = !_ads[index].isActive;
        await _firestore.collection('global_ads').doc(id).update({
          'isActive': _ads[index].isActive,
        });
        notifyListeners();
      }
    } catch (e) {
      ScaffoldMessenger.of(globalContext!).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to toggle ad status: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final ref = _storage.ref().child(
        'global_ads/${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      rethrow;
    }
  }

  void confirmDeleteAd(BuildContext context, String id) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBottomSheetHandle(),
              Center(
                child: Text(
                  'Delete Ad?',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Are you sure you want to delete this ad?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        'CANCEL',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await deleteAd(id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'DELETE',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _resetFormState({bool keepLocation = false}) {
    _titleController.clear();
    _descController.clear();
    _startDateController.clear();
    _linkController.clear();
    _endDateController.clear();
    _selectedImage = null;
    _isActive = true;
    _selectedStartDate = null;
    _selectedEndDate = null;

    if (!keepLocation) {
      _selectedCountry = null;
      _selectedCity = null;
      _availableCities = [];
    } else if (_lastSelectedCountry != null) {
      _selectedCountry = _lastSelectedCountry;
      _selectedCity = _lastSelectedCity;
      _availableCities = _countryCities[_selectedCountry] ?? [];
    }
  }

  static BuildContext? globalContext;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startDateController.dispose();
    _linkController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}