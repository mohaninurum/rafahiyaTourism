import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/widgets/textformfield.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/auth/subadmin_login_screen.dart';

import '../../../../utils/language/app_strings.dart';
import '../../data/subAdminProvider/admin_register_provider.dart';
import '../../data/utils/circular_indicator_spinkit.dart';
import '../../data/utils/location_handler.dart';
import '../home/map_search_screen.dart';

class AdminRegisterScreenTwo extends StatefulWidget {
  const AdminRegisterScreenTwo({super.key});

  @override
  State<AdminRegisterScreenTwo> createState() => _AdminRegisterScreenTwoState();
}

class _AdminRegisterScreenTwoState extends State<AdminRegisterScreenTwo> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminRegisterProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';

    return Scaffold(
      body: Stack(
        children: [

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),


          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/container_image.png"),
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),

          Column(
            children: [

              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/container_image.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, top: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: Colors.white54,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Icon(
                                CupertinoIcons.back,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 50),
                          Text(
                            AppStrings.getString('signUp', currentLocale),
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Text(
                              AppStrings.getString('masjidDetails', currentLocale),
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                SizedBox(height: 15),
                                CustomTextFormField(
                                  controller: provider.masjidNameController,
                                  textInputAction: TextInputAction.next,
                                  labelText: AppStrings.getString('masjidName', currentLocale),
                                  prefixIcon: Icon(
                                    Icons.mosque,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                SizedBox(height: 15),


                                Row(
                                  children: [
                                    CountryCodePicker(
                                      onChanged: (countryCode) {
                                        provider.masjidSelectedCountryCode = countryCode.dialCode ?? "+91";
                                      },
                                      initialSelection: 'IN',
                                      favorite: ['+91', 'IN'],
                                      showCountryOnly: false,
                                      showOnlyCountryWhenClosed: false,
                                      alignLeft: false,
                                    ),
                                    Expanded(
                                      child: CustomTextFormField(
                                        controller: provider.masjidPhoneNumberController,
                                        textInputAction: TextInputAction.next,
                                        labelText: AppStrings.getString('masjidPhoneNumber', currentLocale),
                                        prefixIcon: Icon(
                                          Icons.phone,
                                          color: AppColors.mainColor,
                                        ),
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15),

                                CustomTextFormField(
                                  controller: provider.pinCodeController,
                                  textInputAction: TextInputAction.next,
                                  labelText: AppStrings.getString('pincode', currentLocale),
                                  prefixIcon: Icon(
                                    Icons.numbers,
                                    color: AppColors.mainColor,
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(height: 25),

                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    AppStrings.getString('selectLocation', currentLocale),
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Consumer<AdminRegisterProvider>(
                                  builder: (context, provider, child) {
                                    return Column(
                                      children: [

                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(Icons.location_on, color: AppColors.mainColor),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  provider.addressController.text.isEmpty
                                                      ? AppStrings.getString('selectLocation', currentLocale)
                                                      : provider.addressController.text,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: provider.addressController.text.isEmpty
                                                        ? Colors.grey
                                                        : Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 15),

                                        Container(
                                          height: 140,
                                          width: MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            color: AppColors.mainColor.withOpacity(0.4),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            children: [
                                              InkWell(
                                                onTap: () async {
                                                  final selectedLocation = await Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => const MapSearchScreen(),
                                                    ),
                                                  );

                                                  if (selectedLocation != null) {
                                                    if (selectedLocation is Map) {
                                                      provider.addressController.text = selectedLocation['address'] ?? '';
                                                      provider.selectedLatitude = selectedLocation['latitude']?.toDouble();
                                                      provider.selectedLongitude = selectedLocation['longitude']?.toDouble();

                                                      final extractedCountry = provider.extractCountryFromAddress(selectedLocation['address'] ?? '');
                                                      if (extractedCountry != null && provider.countries.contains(extractedCountry)) {
                                                        provider.selectedCountry = extractedCountry;
                                                      }
                                                    } else if (selectedLocation is String) {
                                                      provider.addressController.text = selectedLocation;

                                                      final extractedCountry = provider.extractCountryFromAddress(selectedLocation);
                                                      if (extractedCountry != null && provider.countries.contains(extractedCountry)) {
                                                        provider.selectedCountry = extractedCountry;
                                                      }
                                                    }
                                                    provider.notifyListeners();
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  margin: const EdgeInsets.only(top: 15),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.add, color: AppColors.blackColor),
                                                      const SizedBox(width: 20),
                                                      Text(
                                                        AppStrings.getString('addAddressFromMap', currentLocale),
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: AppColors.blackColor,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                                child: Divider(thickness: 1, color: AppColors.blackColor),
                                              ),

                                              provider.isLoadingLocation
                                                  ? const Padding(
                                                padding: EdgeInsets.only(top: 15),
                                                child: CustomCircularProgressIndicator(
                                                  size: 50.0,
                                                  color: AppColors.mainColor,
                                                  spinKitType: SpinKitType.chasingDots,
                                                ),
                                              )
                                                  : InkWell(
                                                onTap: () async {
                                                  provider.setLoadingLocation(true);
                                                  try {
                                                    provider.currentPosition = await LocationHandler.getCurrentPosition();
                                                    final address = await LocationHandler.getAddressFromLatLng(provider.currentPosition!);

                                                    if (address != null) {
                                                      provider.addressController.text = address;
                                                      provider.selectedLatitude = provider.currentPosition!.latitude;
                                                      provider.selectedLongitude = provider.currentPosition!.longitude;


                                                      final extractedCountry = provider.extractCountryFromAddress(address);
                                                      if (extractedCountry != null && provider.countries.contains(extractedCountry)) {
                                                        provider.selectedCountry = extractedCountry;
                                                      }
                                                    }
                                                  } catch (e) {
                                                    debugPrint("Location error: $e");
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(content: Text("Failed to get location: $e")),
                                                    );
                                                  } finally {
                                                    provider.setLoadingLocation(false);
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  margin: const EdgeInsets.only(top: 15),
                                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.location_on_outlined, color: AppColors.blackColor),
                                                      const SizedBox(width: 20),
                                                      Text(
                                                        AppStrings.getString('useCurrentLocation', currentLocale),
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: AppColors.blackColor,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),

                                SizedBox(height: 15),


                                Consumer<AdminRegisterProvider>(
                                  builder: (context, provider, child) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          AppStrings.getString('country', currentLocale),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: DropdownButton<String>(
                                            value: provider.selectedCountry,
                                            isExpanded: true,
                                            underline: SizedBox(),
                                            hint: Text(
                                              AppStrings.getString('selectCountry', currentLocale),
                                              style: GoogleFonts.poppins(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            items: provider.countries.map((String country) {
                                              return DropdownMenuItem<String>(
                                                value: country,
                                                child: Text(
                                                  country,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              provider.selectedCountry = newValue;
                                            },
                                          ),
                                        ),
                                        if (provider.selectedCountry == null &&
                                            provider.addressController.text.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 8),
                                            child: Text(
                                              "Country not detected in address. Please select from dropdown.",
                                              style: GoogleFonts.poppins(
                                                color: Colors.orange,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    );
                                  },
                                ),

                                SizedBox(height: 25),

                                Consumer<AdminRegisterProvider>(
                                  builder: (context, provider, _) {
                                    return InkWell(
                                      onTap: provider.isUploading ? null : () async {
                                        await provider.registerSubAdmin(context);
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(right: 10),
                                        height: 52,
                                        width: MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: AppColors.mainColor,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                        child: Center(
                                          child: provider.isUploading
                                              ? CustomCircularProgressIndicator(
                                            size: 30.0,
                                            color: AppColors.whiteColor,
                                            spinKitType: SpinKitType.chasingDots,
                                          )
                                              : Text(
                                            AppStrings.getString('signUp', currentLocale),
                                            style: GoogleFonts.poppins(
                                              color: AppColors.whiteBackground,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      AppStrings.getString('alreadyHaveAccount', currentLocale),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SubAdminLoginScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.getString('signInHere', currentLocale),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.mainColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}