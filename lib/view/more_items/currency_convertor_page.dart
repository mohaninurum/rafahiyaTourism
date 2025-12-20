import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../const/color.dart';
import '../../const/currency_services.dart';
import '../../provider/locale_provider.dart';
import '../../utils/language/app_strings.dart';

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});

  @override
  _CurrencyConverterPageState createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final CurrencyService _currencyService = CurrencyService();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _convertedController = TextEditingController();

  List<String> _currencies = [];
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _exchangeRate = 0.0;
  bool _isLoading = true;
  bool _isConverting = false;

  String _getCurrentLocale(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    return localeProvider.locale?.languageCode ?? 'en';
  }

  @override
  void initState() {
    super.initState();
    _loadCurrencies();
    _amountController.text = '1.00';
  }

  Future<void> _loadCurrencies() async {
    final currentLocale = _getCurrentLocale(context);
    try {
      final currencies = await _currencyService.getCurrencies();
      setState(() {
        _currencies = currencies;
        _isLoading = false;
      });
      _getExchangeRate();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackbar(AppStrings.getString('failedToLoadCurrencies', currentLocale));
    }
  }

  Future<void> _getExchangeRate() async {
    if (_fromCurrency.isEmpty || _toCurrency.isEmpty) return;

    final currentLocale = _getCurrentLocale(context);

    setState(() {
      _isConverting = true;
    });

    try {
      final rates = await _currencyService.getExchangeRates(_fromCurrency);
      setState(() {
        _exchangeRate = rates['rates'][_toCurrency] ?? 0.0;
      });
      _convertCurrency();
    } catch (e) {
      _showErrorSnackbar(AppStrings.getString('failedToGetExchangeRate', currentLocale));
    } finally {
      setState(() {
        _isConverting = false;
      });
    }
  }

  void _convertCurrency() {
    if (_amountController.text.isEmpty) {
      _convertedController.text = '0.00';
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final convertedAmount = amount * _exchangeRate;

    _convertedController.text = convertedAmount.toStringAsFixed(2);
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
    _getExchangeRate();
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = _getCurrentLocale(context);

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(
          AppStrings.getString('currencyConverter', currentLocale),
          style: GoogleFonts.poppins(
            color: AppColors.whiteColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_sharp, color: AppColors.whiteColor),
        ),
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAmountCard(currentLocale),
            const SizedBox(height: 20),
            _buildCurrencySelector(),
            const SizedBox(height: 30),
            _buildConvertButton(currentLocale),
            const SizedBox(height: 30),
            _buildResultCard(currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard(String currentLocale) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.getString('amount', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: AppStrings.getString('zeroDecimal', currentLocale),
              ),
              onChanged: (value) => _convertCurrency(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencySelector() {
    return Row(
      children: [
        Expanded(
          child: _buildCurrencyDropdown(
            value: _fromCurrency,
            onChanged: (value) {
              setState(() {
                _fromCurrency = value!;
              });
              _getExchangeRate();
            },
          ),
        ),
        IconButton(
          onPressed: _swapCurrencies,
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.swap_horiz,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: _buildCurrencyDropdown(
            value: _toCurrency,
            onChanged: (value) {
              setState(() {
                _toCurrency = value!;
              });
              _getExchangeRate();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown({
    required String value,
    required Function(String?) onChanged,
  }) {
    return Card(
      color: AppColors.whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: DropdownButton<String>(
          dropdownColor: AppColors.whiteColor,
          value: value,
          isExpanded: true,
          underline: const SizedBox(),
          items: _currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency,
              child: Text(
                currency,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildConvertButton(String currentLocale) {
    return ElevatedButton(
      onPressed: _isConverting ? null : _getExchangeRate,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mainColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      child: _isConverting
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.white,
        ),
      )
          : Text(
        AppStrings.getString('convert', currentLocale),
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: AppColors.whiteColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildResultCard(String currentLocale) {
    return Card(
      color: AppColors.whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              AppStrings.getString('convertedAmount', currentLocale),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _convertedController,
              readOnly: true,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.mainColor,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '1 $_fromCurrency = ${_exchangeRate.toStringAsFixed(6)} $_toCurrency',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _convertedController.dispose();
    super.dispose();
  }
}