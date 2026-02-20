import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../provider/home_masjid_data_provider.dart';
import '../../provider/multi_mosque_provider.dart';
import '../../provider/mosque_search_provider.dart';
import '../../utils/services/get_time_zone.dart';
import '../../utils/services/mosque_subscription_manager.dart';

class MosqueSearchDropdown extends StatefulWidget {

  final int tabIndex;
  final TextEditingController controller;
  const MosqueSearchDropdown({super.key, required this.controller, required this.tabIndex});

  @override
  _MosqueSearchDropdownState createState() => _MosqueSearchDropdownState();
}

class _MosqueSearchDropdownState extends State<MosqueSearchDropdown> {
  @override
  void initState() {
    super.initState();

    // Load mosques when the widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final searchProvider = Provider.of<MosqueSearchProvider>(context, listen: false);
      searchProvider.loadMosques();
    });

    widget.controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final searchProvider = Provider.of<MosqueSearchProvider>(context, listen: false);

    // Only search if we have text and mosques are loaded
    if (widget.controller.text.isNotEmpty && searchProvider.mosques.isNotEmpty) {
      searchProvider.filterMosques(widget.controller.text);
    } else {
      searchProvider.clearSearch();
    }
  }

  Future<void> _selectMosque(Map<String, dynamic> mosque) async {
    widget.controller.text = mosque['name'];

    final multiProvider = Provider.of<MultiMosqueProvider>(context, listen: false);
    multiProvider.setMosque(widget.tabIndex, mosque['uid'], mosque['name'], mosque['address']);

    // Immediately fetch the detailed data including prayer times
    final homeDataProvider = Provider.of<HomeMasjidDataProvider>(context, listen: false);
    homeDataProvider.fetchMosqueData(widget.tabIndex, mosque['uid']);

    // Clear the search and hide dropdown
    final searchProvider = Provider.of<MosqueSearchProvider>(context, listen: false);
    searchProvider.clearSearch();
    FocusScope.of(context).unfocus();
    await MosqueSubscriptionManager.updateMosqueSubscriptions(
      [mosque['uid'], "xyz789"],
    );

  }
  @override
  Widget build(BuildContext context) {
    return Consumer<MosqueSearchProvider>(
      builder: (context, searchProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Mosque',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: widget.controller,
              readOnly: widget.tabIndex == 2 ? true : false,
              decoration: InputDecoration(
                labelText: 'Masjid Name',
                labelStyle: GoogleFonts.poppins(color: Colors.grey),
                border: const OutlineInputBorder(),
                suffixIcon: searchProvider.isLoading
                    ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.search),
              ),
              onChanged: (value) {
                // Trigger search on text change
                if (value.isNotEmpty && searchProvider.mosques.isNotEmpty) {
                  searchProvider.filterMosques(value);
                } else {
                  searchProvider.clearSearch();
                }
              },
            ),
            const SizedBox(height: 8),
            if (searchProvider.filteredMosques.isNotEmpty && widget.controller.text.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: searchProvider.filteredMosques.length,
                  itemBuilder: (context, index) {
                    final mosque = searchProvider.filteredMosques[index];
                    return ListTile(
                      title: Text(mosque['name']),
                      subtitle: Text(mosque['address']),
                      onTap: () => _selectMosque(mosque),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}