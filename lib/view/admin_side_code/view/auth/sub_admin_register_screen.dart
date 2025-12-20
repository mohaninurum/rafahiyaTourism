import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/widgets/textformfield.dart';
import 'package:rafahiyatourism/view/admin_side_code/view/auth/sub_admin_register_screentwo.dart';

import '../../../../utils/language/app_strings.dart';
import '../../data/subAdminProvider/admin_register_provider.dart';
import '../widgets/image_picker_bottomsheet.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
  Future<String?> imagePickerBottomSheet(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => const ImagePickerBottomSheet(),
    );
  }

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

          // Main content column
          Column(
            children: [
              // Header container
              Container(
                height: 190,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/container_image.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Padding(
                        padding: const EdgeInsets.only(right: 13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppStrings.getString('signUp', currentLocale),
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Consumer<AdminRegisterProvider>(
                              builder: (context, refProvider, child) {
                                final image = refProvider.pickedImage;

                                return Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    GestureDetector(
                                      onTap: () async {
                                        final source =
                                            await imagePickerBottomSheet(
                                              context,
                                            );
                                        if (source != null) {
                                          final imageSource =
                                              source == 'camera'
                                                  ? ImageSource.camera
                                                  : ImageSource.gallery;
                                          await refProvider.pickImageFromCamera(
                                            imageSource,
                                          );
                                        }
                                      },
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                        child:
                                            image != null
                                                ? Image.file(
                                                  image,
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.fill,
                                                )
                                                : Image.asset(
                                                  'assets/images/user.png',
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.fill,
                                                ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    if (refProvider.error != null)
                                      Text(
                                        refProvider.error!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      child: InkWell(
                                        onTap: () async {
                                          final source =
                                              await imagePickerBottomSheet(
                                                context,
                                              );
                                          if (source != null) {
                                            final imageSource =
                                                source == 'camera'
                                                    ? ImageSource.camera
                                                    : ImageSource.gallery;
                                            await refProvider
                                                .pickImageFromCamera(
                                                  imageSource,
                                                );
                                          }
                                        },
                                        child: Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: AppColors.mainColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
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
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              children: [
                                SizedBox(height: 15),
                                CustomTextFormField(
                                  controller: provider.imamNameController,
                                  textInputAction: TextInputAction.next,
                                  labelText: AppStrings.getString(
                                    'imamName',
                                    currentLocale,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                SizedBox(height: 15),
                                CustomTextFormField(
                                  controller: provider.emailController,
                                  textInputAction: TextInputAction.next,
                                  labelText: AppStrings.getString(
                                    'emailId',
                                    currentLocale,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.mail,
                                    color: AppColors.mainColor,
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: 15),
                                Row(
                                  children: [
                                    CountryCodePicker(
                                      onChanged: (countryCode) {
                                        provider.selectedCountryCode =
                                            countryCode.dialCode ?? "+91";
                                      },
                                      initialSelection: 'IN',
                                      favorite: ['+91', 'IN'],
                                      showCountryOnly: false,
                                      showOnlyCountryWhenClosed: false,
                                      alignLeft: false,
                                    ),
                                    Expanded(
                                      child: CustomTextFormField(
                                        controller:
                                            provider.mobileNumberController,
                                        textInputAction: TextInputAction.next,
                                        labelText: AppStrings.getString(
                                          'phoneNumber',
                                          currentLocale,
                                        ),
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
                                  controller: provider.cityController,
                                  textInputAction: TextInputAction.next,
                                  labelText: AppStrings.getString(
                                    'city',
                                    currentLocale,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.location_city,
                                    color: AppColors.mainColor,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Consumer<AdminRegisterProvider>(
                                  builder: (context, provider, child) {
                                    return CustomTextFormField(
                                      controller: provider.passwordController,
                                      textInputAction: TextInputAction.next,
                                      labelText: AppStrings.getString(
                                        'password',
                                        currentLocale,
                                      ),
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: AppColors.mainColor,
                                      ),
                                      isPassword: provider.isPasswordObscure,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          provider.isPasswordObscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          provider.togglePasswordVisibility();
                                        },
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 15),
                                Consumer<AdminRegisterProvider>(
                                  builder: (context, provider, child) {
                                    return CustomTextFormField(
                                      prefixIcon: Icon(
                                        Icons.password,
                                        color: AppColors.mainColor,
                                      ),
                                      controller:
                                          provider.confirmPasswordController,
                                      textInputAction: TextInputAction.next,
                                      labelText: AppStrings.getString(
                                        'confirmPassword',
                                        currentLocale,
                                      ),
                                      isPassword:
                                          provider.isConfirmPasswordObscure,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          provider.isConfirmPasswordObscure
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),
                                        onPressed: () {
                                          provider
                                              .toggleConfirmPasswordVisibility();
                                        },
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            AppStrings.getString(
                                              'proofOfVerification',
                                              currentLocale,
                                            ),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Consumer<AdminRegisterProvider>(
                                            builder: (
                                              context,
                                              provider,
                                              child,
                                            ) {
                                              if (provider.isUploading) {
                                                return const CircularProgressIndicator();
                                              }

                                              if (provider.proofDocument ==
                                                  null) {
                                                return InkWell(
                                                  onTap:
                                                      () => provider
                                                          .pickProofDocument(
                                                            context,
                                                          ),
                                                  child: CircleAvatar(
                                                    radius: 20,
                                                    backgroundColor:
                                                        AppColors.mainColor,
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.cloud_upload,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                              return const SizedBox.shrink();
                                            },
                                          ),
                                        ],
                                      ),

                                      Consumer<AdminRegisterProvider>(
                                        builder: (context, provider, child) {
                                          if (provider.proofDocument != null) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Stack(
                                                alignment: Alignment.topRight,
                                                children: [
                                                  // Image preview container
                                                  Container(
                                                    width: double.infinity,
                                                    height: 250,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      border: Border.all(
                                                        color:
                                                            Colors.grey[300]!,
                                                      ),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      child: Image.file(
                                                        provider.proofDocument!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) {
                                                          return Container(
                                                            color:
                                                                Colors
                                                                    .grey[200],
                                                            child: const Icon(
                                                              Icons
                                                                  .error_outline,
                                                              color: Colors.red,
                                                              size: 50,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),

                                                  // Remove button
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(0.3),
                                                          blurRadius: 4,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: IconButton(
                                                      onPressed: () {
                                                        provider
                                                            .removeProofDocument();
                                                      },
                                                      icon: const Icon(
                                                        Icons.close,
                                                        color: Colors.white,
                                                        size: 20,
                                                      ),
                                                      padding: EdgeInsets.zero,
                                                      constraints:
                                                          const BoxConstraints(
                                                            minWidth: 36,
                                                            minHeight: 36,
                                                          ),
                                                    ),
                                                  ),

                                                  // Change image button at bottom
                                                  Positioned(
                                                    bottom: 8,
                                                    right: 8,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.mainColor,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: IconButton(
                                                        onPressed:
                                                            () => provider
                                                                .pickProofDocument(
                                                                  context,
                                                                ),
                                                        icon: const Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              6,
                                                            ),
                                                        constraints:
                                                            const BoxConstraints(
                                                              minWidth: 36,
                                                              minHeight: 36,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 40),
                                InkWell(
                                  onTap: () {
                                    final error = provider.validateFields();
                                    if (error != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(error)),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                AdminRegisterScreenTwo(),
                                      ),
                                    );
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
                                      child: Text(
                                        AppStrings.getString(
                                          'next',
                                          currentLocale,
                                        ),
                                        style: GoogleFonts.poppins(
                                          color: AppColors.whiteBackground,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
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
