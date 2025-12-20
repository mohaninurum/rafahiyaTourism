import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/view/super_admin_code/superadminprovider/app_setting_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rafahiyatourism/provider/locale_provider.dart';
import 'package:rafahiyatourism/utils/language/app_strings.dart';

class ContactManagementScreen extends StatefulWidget {
  const ContactManagementScreen({super.key});

  @override
  State<ContactManagementScreen> createState() => _ContactManagementScreenState();
}

class _ContactManagementScreenState extends State<ContactManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadContactInfo();
    });
  }

  Future<void> _loadContactInfo() async {
    setState(() => _isLoading = true);
    await Provider.of<AppSettingsProvider>(context, listen: false).fetchContactInfo();
    setState(() => _isLoading = false);
  }

  Future<void> _saveContactInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final success = await Provider.of<AppSettingsProvider>(context, listen: false)
          .updateContactInfo();

      setState(() => _isLoading = false);

      final currentLocale = _getCurrentLocale(context);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('contactInformationSaved', currentLocale)),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _isEditing = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.getString('failedToSaveContact', currentLocale)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _launchURL(String url) async {
    final currentLocale = _getCurrentLocale(context);
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.getString('couldNotLaunch', currentLocale)} $url')),
      );
    }
  }

  void _launchPhone(String phone) async {
    final currentLocale = _getCurrentLocale(context);
    if (phone.isEmpty) return;

    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.getString('couldNotCall', currentLocale)} $phone')),
      );
    }
  }

  void _launchEmail(String email) async {
    final currentLocale = _getCurrentLocale(context);
    if (email.isEmpty) return;

    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.getString('couldNotEmail', currentLocale)} $email')),
      );
    }
  }

  void _launchWhatsApp(String whatsapp) async {
    final currentLocale = _getCurrentLocale(context);
    if (whatsapp.isEmpty) return;

    final String url = "https://wa.me/$whatsapp";
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.getString('couldNotOpenWhatsApp', currentLocale))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);
    final provider = Provider.of<AppSettingsProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          AppStrings.getString('contactInformation', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
        ),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit, color: Colors.white),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : () => setState(() => _isEditing = false),
              child: Text(
                  AppStrings.getString('cancel', currentLocale),
                  style: GoogleFonts.poppins(color: Colors.white)
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.mainColor))
          : Padding(
        padding: EdgeInsets.all(isSmallScreen ? 16.0 : 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header
              _buildHeader(currentLocale),
              const SizedBox(height: 24),

              // Contact Cards
              if (!_isEditing) _buildContactCards(provider, currentLocale),

              // Edit Form
              if (_isEditing) _buildEditForm(provider, currentLocale),

              // Action Buttons
              if (_isEditing) _buildActionButtons(currentLocale),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String currentLocale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.getString('rafahiyahTourismContact', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isEditing
              ? AppStrings.getString('updateContactInfoBelow', currentLocale)
              : AppStrings.getString('manageCustomerContact', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCards(AppSettingsProvider provider, String currentLocale) {
    return Column(
      children: [
        // Phone
        if (provider.contactPhone.isNotEmpty)
          _buildContactCard(
            icon: Icons.phone,
            title: AppStrings.getString('phoneNumber', currentLocale),
            value: provider.contactPhone,
            onTap: () => _launchPhone(provider.contactPhone),
            color: Colors.blue,
          ),

        // Email
        if (provider.contactEmail.isNotEmpty)
          _buildContactCard(
            icon: Icons.email,
            title: AppStrings.getString('emailAddress', currentLocale),
            value: provider.contactEmail,
            onTap: () => _launchEmail(provider.contactEmail),
            color: Colors.red,
          ),

        // Address
        if (provider.contactAddress.isNotEmpty)
          _buildContactCard(
            icon: Icons.location_on,
            title: AppStrings.getString('address', currentLocale),
            value: provider.contactAddress,
            color: Colors.green,
          ),

        // Website
        if (provider.contactWebsite.isNotEmpty)
          _buildContactCard(
            icon: Icons.language,
            title: AppStrings.getString('website', currentLocale),
            value: provider.contactWebsite,
            onTap: () => _launchURL(provider.contactWebsite),
            color: Colors.purple,
          ),

        // WhatsApp
        if (provider.contactWhatsApp.isNotEmpty)
          _buildContactCard(
            icon: FontAwesomeIcons.whatsapp,
            title: AppStrings.getString('whatsapp', currentLocale),
            value: provider.contactWhatsApp,
            onTap: () => _launchWhatsApp(provider.contactWhatsApp),
            color: Colors.green,
          ),

        // Social Media
        if (provider.contactFacebook.isNotEmpty ||
            provider.contactInstagram.isNotEmpty ||
            provider.contactTwitter.isNotEmpty)
          _buildSocialMediaCard(provider, currentLocale),

        // Empty State
        if (provider.contactPhone.isEmpty &&
            provider.contactEmail.isEmpty &&
            provider.contactAddress.isEmpty &&
            provider.contactWebsite.isEmpty &&
            provider.contactWhatsApp.isEmpty &&
            provider.contactFacebook.isEmpty &&
            provider.contactInstagram.isEmpty &&
            provider.contactTwitter.isEmpty)
          _buildEmptyState(currentLocale),
      ],
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color?.withOpacity(0.1) ?? AppColors.mainColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color ?? AppColors.mainColor, size: 24),
        ),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: GoogleFonts.poppins()),
        trailing: onTap != null
            ? Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[600])
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialMediaCard(AppSettingsProvider provider, String currentLocale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getString('socialMedia', currentLocale),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (provider.contactFacebook.isNotEmpty)
                  _buildSocialIcon(
                    icon: FontAwesomeIcons.facebook,
                    color: Colors.blue[700]!,
                    onTap: () => _launchURL(provider.contactFacebook),
                  ),
                if (provider.contactInstagram.isNotEmpty)
                  _buildSocialIcon(
                    icon: FontAwesomeIcons.instagram,
                    color: Colors.pink,
                    onTap: () => _launchURL(provider.contactInstagram),
                  ),
                if (provider.contactTwitter.isNotEmpty)
                  _buildSocialIcon(
                    icon: FontAwesomeIcons.twitter,
                    color: Colors.blue[400]!,
                    onTap: () => _launchURL(provider.contactTwitter),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildEmptyState(String currentLocale) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.contact_phone, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              AppStrings.getString('noContactInfo', currentLocale),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.getString('addContactDetails', currentLocale),
              style: GoogleFonts.poppins(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm(AppSettingsProvider provider, String currentLocale) {
    return Column(
      children: [
        _buildTextField(
          controller: provider.phoneController,
          label: AppStrings.getString('phoneNumber', currentLocale),
          icon: Icons.phone,
          hint: '+1234567890',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: provider.emailController,
          label: AppStrings.getString('emailAddress', currentLocale),
          icon: Icons.email,
          hint: 'contact@rafahiyah.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: provider.addressController,
          label: AppStrings.getString('address', currentLocale),
          icon: Icons.location_on,
          hint: '123 Tourism Street, City, Country',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: provider.websiteController,
          label: AppStrings.getString('website', currentLocale),
          icon: Icons.language,
          hint: 'https://www.rafahiyah.com',
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: provider.whatsappController,
          label: AppStrings.getString('whatsapp', currentLocale),
          icon: FontAwesomeIcons.whatsapp,
          hint: '1234567890',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 24),
        Text(
          AppStrings.getString('socialMediaLinks', currentLocale),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.mainColor,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: provider.facebookController,
          label: AppStrings.getString('facebook', currentLocale),
          icon: FontAwesomeIcons.facebook,
          hint: 'https://facebook.com/rafahiyah',
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: provider.instagramController,
          label: AppStrings.getString('instagram', currentLocale),
          icon: FontAwesomeIcons.instagram,
          hint: 'https://instagram.com/rafahiyah',
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: provider.twitterController,
          label: AppStrings.getString('twitter', currentLocale),
          icon: FontAwesomeIcons.twitter,
          hint: 'https://twitter.com/rafahiyah',
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.mainColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.mainColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildActionButtons(String currentLocale) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveContactInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                AppStrings.getString('saveChanges', currentLocale),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}