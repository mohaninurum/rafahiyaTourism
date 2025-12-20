import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../const/color.dart';
import '../../provider/zakat_provider.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class ZakatCalculatorScreen extends StatefulWidget {
  const ZakatCalculatorScreen({super.key});

  @override
  State<ZakatCalculatorScreen> createState() => _ZakatCalculatorScreenState();
}

class _ZakatCalculatorScreenState extends State<ZakatCalculatorScreen> {
  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return ChangeNotifierProvider(
      create: (context) => ZakatProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Content
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header
                  _buildHeader(context, currentLocale),
                  const SizedBox(height: 20),
                  // Nisab Standard Toggle
                  _buildNisabToggle(context, currentLocale),
                  const SizedBox(height: 20),
                  // Input Form
                  _buildInputForm(context, currentLocale),
                  const SizedBox(height: 30),
                  // Results
                  _buildResultsCard(context, currentLocale),
                  const SizedBox(height: 20),
                  // Calculate Button
                  _buildCalculateButton(context, currentLocale),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String currentLocale) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 50,
            color: AppColors.mainColor,
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.getString('calculateYourZakat', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.mainColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            AppStrings.getString('zakatCalculatorDescription', currentLocale),
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabToggle(BuildContext context, String currentLocale) {
    final provider = Provider.of<ZakatProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.getString('nisabStandard', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textColor,
            ),
          ),
          ToggleButtons(
            isSelected: [provider.useGoldStandard, !provider.useGoldStandard],
            onPressed: (index) {
              provider.toggleNisabStandard();
            },
            borderRadius: BorderRadius.circular(8),
            selectedColor: Colors.white,
            fillColor: AppColors.mainColor,
            color: AppColors.mainColor,
            constraints: const BoxConstraints(
              minWidth: 70,
              minHeight: 35,
            ),
            children: [
              Text(AppStrings.getString('gold', currentLocale), style: GoogleFonts.poppins()),
              Text(AppStrings.getString('silver', currentLocale), style: GoogleFonts.poppins()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm(BuildContext context, String currentLocale) {
    final provider = Provider.of<ZakatProvider>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteBackground,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCurrencyInputField(
            context,
            label: AppStrings.getString('cashSavings', currentLocale),
            icon: Icons.attach_money,
            value: provider.cashSavings,
            onChanged: provider.updateCashSavings,
            currentLocale: currentLocale,
          ),
          _buildCurrencyInputField(
            context,
            label: AppStrings.getString('goldValue', currentLocale),
            icon: Icons.workspace_premium,
            value: provider.goldValue,
            onChanged: provider.updateGoldValue,
            currentLocale: currentLocale,
          ),
          _buildCurrencyInputField(
            context,
            label: AppStrings.getString('silverValue', currentLocale),
            icon: Icons.monetization_on,
            value: provider.silverValue,
            onChanged: provider.updateSilverValue,
            currentLocale: currentLocale,
          ),
          _buildCurrencyInputField(
            context,
            label: AppStrings.getString('investments', currentLocale),
            icon: Icons.trending_up,
            value: provider.investments,
            onChanged: provider.updateInvestments,
            currentLocale: currentLocale,
          ),
          _buildCurrencyInputField(
            context,
            label: AppStrings.getString('businessAssets', currentLocale),
            icon: Icons.business,
            value: provider.businessAssets,
            onChanged: provider.updateBusinessAssets,
            currentLocale: currentLocale,
          ),
          _buildCurrencyInputField(
            context,
            label: AppStrings.getString('otherAssets', currentLocale),
            icon: Icons.category,
            value: provider.otherAssets,
            onChanged: provider.updateOtherAssets,
            currentLocale: currentLocale,
          ),
          _buildCurrencyInputField(
            context,
            label: AppStrings.getString('liabilitiesDebts', currentLocale),
            icon: Icons.credit_card,
            value: provider.liabilities,
            onChanged: provider.updateLiabilities,
            currentLocale: currentLocale,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInputField(
      BuildContext context, {
        required String label,
        required IconData icon,
        required double value,
        required Function(double) onChanged,
        required String currentLocale,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        initialValue: value == 0 ? '' : value.toStringAsFixed(2),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          prefixIcon: Icon(icon, color: AppColors.mainColor),
          prefixText: '\₹ ',
          prefixStyle: GoogleFonts.poppins(color: AppColors.textColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.whiteBackground),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.mainColor),
          ),
          filled: true,
          fillColor: AppColors.whiteBackground,
        ),
        style: GoogleFonts.poppins(),
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        validator: (value) {
          if (value == null || value.isEmpty) return null;
          final num = double.tryParse(value);
          if (num == null) return AppStrings.getString('enterValidNumber', currentLocale);
          if (num < 0) return AppStrings.getString('valueCannotBeNegative', currentLocale);
          return null;
        },
        onChanged: (value) {
          if (value.isEmpty) {
            onChanged(0);
            return;
          }
          final num = double.tryParse(value);
          if (num != null && num >= 0) {
            onChanged(num);
          }
        },
      ),
    );
  }

  Widget _buildResultsCard(BuildContext context, String currentLocale) {
    final provider = Provider.of<ZakatProvider>(context);
    final currencyFormat = NumberFormat.currency(symbol: '\₹', decimalDigits: 2);

    if (provider.netWorth <= 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mainColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppStrings.getString('zakatSummary', currentLocale),
            style: GoogleFonts.poppins(
              fontSize: 20,
              color: AppColors.whiteBackground,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          _buildResultRow(
            context,
            label: AppStrings.getString('totalNetWorth', currentLocale),
            value: currencyFormat.format(provider.netWorth),
            currentLocale: currentLocale,
          ),
          _buildResultRow(
            context,
            label: AppStrings.getString('nisabThreshold', currentLocale),
            value: currencyFormat.format(provider.nisabThreshold),
            currentLocale: currentLocale,
          ),
          const Divider(
            color: Colors.white54,
            height: 30,
          ),
          _buildResultRow(
            context,
            label: AppStrings.getString('zakatPayable', currentLocale),
            value: currencyFormat.format(provider.zakatAmount),
            isHighlighted: true,
            currentLocale: currentLocale,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: provider.isNisabReached
                  ? Colors.green
                  : Colors.orange,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              provider.isNisabReached
                  ? AppStrings.getString('nisabReachedMessage', currentLocale)
                  : AppStrings.getString('nisabNotReachedMessage', currentLocale),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
      BuildContext context, {
        required String label,
        required String value,
        bool isHighlighted = false,
        required String currentLocale,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.whiteBackground,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: isHighlighted ? Colors.amber.shade200 : AppColors.whiteBackground,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton(BuildContext context, String currentLocale) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Calculation happens automatically through provider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppStrings.getString('zakatCalculatedSuccessfully', currentLocale),
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.mainColor,
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mainColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: Text(
          AppStrings.getString('calculateZakat', currentLocale),
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}