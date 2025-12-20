import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';
import 'package:rafahiyatourism/view/super_admin_code/models/community_service/community_service_model.dart';
import '../../../../../const/color.dart';

class ServiceFormDialog extends StatefulWidget {
  final SuperAdminCommunityServiceModel? service;
  final Function(SuperAdminCommunityServiceModel) onSave;
  final String currentLocale;

  const ServiceFormDialog({
    super.key,
    this.service,
    required this.onSave,
    required this.currentLocale
  });

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late List<String> _descriptions;
  late Map<String, String> _locationContacts;
  late String _selectedIcon;
  late TextEditingController _customServiceController;
  bool _showCustomServiceField = false;

  final List<Map<String, dynamic>> _iconOptions = [
    {
      'icon': Icons.directions_car_filled,
      'label': 'Cab/Rental',
      'iconName': 'directions_car_filled',
    },
    {
      'icon': Icons.store_mall_directory,
      'label': 'Store',
      'iconName': 'store_mall_directory',
    },
    {'icon': Icons.restaurant, 'label': 'Food', 'iconName': 'restaurant'},
    {'icon': Icons.language, 'label': 'Language', 'iconName': 'language'},
    {'icon': Icons.mosque, 'label': 'Hajj/Umrah', 'iconName': 'mosque'},
    {'icon': Icons.menu_book, 'label': 'Quran', 'iconName': 'menu_book'},
    {'icon': Icons.add_home_rounded, 'label': 'Other', 'iconName': 'help_outline'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.service?.title ?? '');
    _descriptions = List.from(widget.service?.descriptions ?? []);
    _locationContacts = Map.from(widget.service?.locationContacts ?? {});
    _selectedIcon = widget.service?.icon ?? 'help_outline';
    _customServiceController = TextEditingController();

    if (widget.service != null &&
        !_iconOptions.any((icon) => icon['iconName'] == widget.service?.icon)) {
      _showCustomServiceField = true;
      _selectedIcon = 'help_outline';
      _customServiceController.text = widget.service?.icon ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customServiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.whiteColor,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  widget.service == null
                      ? AppStrings.getString('addNewService', widget.currentLocale)
                      : AppStrings.getString('editService', widget.currentLocale),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mainColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppStrings.getString('companyName', widget.currentLocale),
                  labelStyle: GoogleFonts.poppins(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.getString('pleaseEnterName', widget.currentLocale);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.getString('selectCategory', widget.currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                _iconOptions.map((iconData) {
                  final isSelected = _selectedIcon == iconData['iconName'];
                  return ChoiceChip(
                    backgroundColor: Colors.white,
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(iconData['icon'], size: 18),
                        const SizedBox(width: 4),
                        Text(iconData['label']),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (iconData['iconName'] == 'help_outline') {
                          _showCustomServiceField = true;
                          _selectedIcon = 'help_outline';
                        } else {
                          _showCustomServiceField = false;
                          _selectedIcon = iconData['iconName'];
                        }
                      });
                    },
                    selectedColor: AppColors.mainColor.withOpacity(0.2),
                    labelStyle: GoogleFonts.poppins(
                      color:
                      isSelected ? AppColors.mainColor : Colors.black,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color:
                        isSelected
                            ? AppColors.mainColor
                            : Colors.grey.shade300,
                      ),
                    ),
                  );
                }).toList(),
              ),
              // Show custom service field only when "Other" is selected
              if (_showCustomServiceField) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customServiceController,
                  decoration: InputDecoration(
                    labelText: AppStrings.getString('enterServiceCategory', widget.currentLocale),
                    labelStyle: GoogleFonts.poppins(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: AppStrings.getString('serviceCategoryHint', widget.currentLocale),
                  ),
                  validator: (value) {
                    if (_showCustomServiceField &&
                        (value == null || value.isEmpty)) {
                      return AppStrings.getString('pleaseEnterServiceCategory', widget.currentLocale);
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedIcon = value;
                    });
                  },
                ),
              ],
              const SizedBox(height: 16),
              Text(
                AppStrings.getString('detailInfo', widget.currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ..._descriptions.asMap().entries.map((entry) {
                final idx = entry.key;
                final desc = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(child: Text(desc, style: GoogleFonts.poppins())),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        onPressed: () => _editDescription(idx),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _descriptions.removeAt(idx);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              OutlinedButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: Text(
                    AppStrings.getString('addInfo', widget.currentLocale),
                    style: GoogleFonts.poppins()
                ),
                onPressed: _addDescription,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.getString('locationsContacts', widget.currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              ..._locationContacts.entries
                  .map(
                    (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _editLocationContact(entry.key),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _locationContacts.remove(entry.key);
                              });
                            },
                          ),
                        ],
                      ),
                      Text(
                        entry.value,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(
                  Icons.add_location,
                  size: 18,
                  color: AppColors.whiteBorderColor,
                ),
                label: Text(
                  AppStrings.getString('addLocationContact', widget.currentLocale),
                  style: GoogleFonts.poppins(color: AppColors.whiteColor),
                ),
                onPressed: _addLocationWithContact,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.greyColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        AppStrings.getString('cancel', widget.currentLocale),
                        style: GoogleFonts.poppins(color: AppColors.whiteColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveService,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      widget.service == null
                          ? AppStrings.getString('save', widget.currentLocale)
                          : AppStrings.getString('update', widget.currentLocale),
                      style: GoogleFonts.poppins(color: Colors.white),
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

  Future<void> _addDescription() async {
    final description = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(AppStrings.getString('addDescription', widget.currentLocale)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppStrings.getString('enterDescription', widget.currentLocale),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getString('cancel', widget.currentLocale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppStrings.getString('add', widget.currentLocale)),
            ),
          ],
        );
      },
    );

    if (description != null && description.isNotEmpty) {
      setState(() {
        _descriptions.add(description);
      });
    }
  }

  Future<void> _editDescription(int index) async {
    final description = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: _descriptions[index]);
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(AppStrings.getString('editDescription', widget.currentLocale)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: AppStrings.getString('editDescription', widget.currentLocale),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getString('cancel', widget.currentLocale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppStrings.getString('save', widget.currentLocale)),
            ),
          ],
        );
      },
    );

    if (description != null && description.isNotEmpty) {
      setState(() {
        _descriptions[index] = description;
      });
    }
  }

  Future<void> _addLocationWithContact() async {
    final location = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(AppStrings.getString('addLocation', widget.currentLocale)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppStrings.getString('enterLocation', widget.currentLocale),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getString('cancel', widget.currentLocale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppStrings.getString('next', widget.currentLocale)),
            ),
          ],
        );
      },
    );

    if (location == null || location.isEmpty) return;

    final contact = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(AppStrings.getString('addContactNumber', widget.currentLocale)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: AppStrings.getString('enterContactNumber', widget.currentLocale),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getString('cancel', widget.currentLocale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppStrings.getString('add', widget.currentLocale)),
            ),
          ],
        );
      },
    );

    if (contact != null && contact.isNotEmpty) {
      setState(() {
        _locationContacts[location] = contact;
      });
    }
  }

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final service = SuperAdminCommunityServiceModel(
        id: widget.service?.id,
        title: _titleController.text,
        icon:
        _showCustomServiceField
            ? _customServiceController.text
            : _selectedIcon,
        descriptions: _descriptions,
        locationContacts: _locationContacts,
      );
      widget.onSave(service);
      Navigator.pop(context);
    }
  }

  Future<void> _editLocationContact(String currentLocation) async {
    final currentContact = _locationContacts[currentLocation] ?? '';

    final location = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentLocation);
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(AppStrings.getString('editLocation', widget.currentLocale)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: AppStrings.getString('editLocation', widget.currentLocale),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getString('cancel', widget.currentLocale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppStrings.getString('next', widget.currentLocale)),
            ),
          ],
        );
      },
    );

    if (location == null || location.isEmpty) return;

    final contact = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentContact);
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Text(AppStrings.getString('editContactNumber', widget.currentLocale)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: AppStrings.getString('editContactNumber', widget.currentLocale),
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppStrings.getString('cancel', widget.currentLocale)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(AppStrings.getString('save', widget.currentLocale)),
            ),
          ],
        );
      },
    );

    if (contact != null && contact.isNotEmpty) {
      setState(() {
        // Remove old entry and add new one
        _locationContacts.remove(currentLocation);
        _locationContacts[location] = contact;
      });
    }
  }
}