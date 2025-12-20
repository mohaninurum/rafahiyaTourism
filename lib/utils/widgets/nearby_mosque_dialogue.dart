import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rafahiyatourism/const/color.dart';
import 'package:rafahiyatourism/provider/nearby_mosque_provider.dart';
import 'package:rafahiyatourism/utils/services/location_service.dart';
import 'package:rafahiyatourism/utils/widgets/location_permission_dialogue.dart';

import '../services/geocoding_service.dart';

class NearbyMosqueDialog extends StatefulWidget {
  final VoidCallback? onDismissed;
  final Function(String mosqueUid, Map<String, dynamic> mosqueData) onMosqueSelected;

  const NearbyMosqueDialog({
    super.key,
    required this.onMosqueSelected,
    this.onDismissed,
  });

  @override
  State<NearbyMosqueDialog> createState() => _NearbyMosqueDialogState();
}

class _NearbyMosqueDialogState extends State<NearbyMosqueDialog> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _usingCustomLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeNearbyMosques();
  }

  Future<void> _initializeNearbyMosques() async {
    final canGetLocation = await LocationService.canGetLocation();

    if (!canGetLocation) {
      await _showLocationDialog();
      return;
    }

    final nearbyProvider = Provider.of<NearbyMosqueProvider>(context, listen: false);
    await nearbyProvider.fetchNearbyMosques();
  }

  Future<void> _showLocationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationPermissionDialog(
        onResult: (success) {
          Navigator.of(context).pop(success);
        },
      ),
    );

    if (result == true) {
      final nearbyProvider = Provider.of<NearbyMosqueProvider>(context, listen: false);
      await nearbyProvider.fetchNearbyMosques();
    } else {
      final nearbyProvider = Provider.of<NearbyMosqueProvider>(context, listen: false);
      nearbyProvider.setSearchRadius(20.0);
      await nearbyProvider.fetchNearbyMosques();
    }
  }

  Future<void> _searchByAddress(String address) async {
    if (address.isEmpty) {
      setState(() {
        _isSearching = false;
        _usingCustomLocation = false;
      });

      final nearbyProvider = Provider.of<NearbyMosqueProvider>(context, listen: false);
      await nearbyProvider.fetchNearbyMosques();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final location = await GeocodingService.geocodeAddress(address);

      if (location != null) {
        setState(() {
          _usingCustomLocation = true;
        });

        final nearbyProvider = Provider.of<NearbyMosqueProvider>(context, listen: false);
        await nearbyProvider.fetchMosquesByCoordinates(
            location['lat']!,
            location['lng']!,
            address
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not find location for "$address"'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _usingCustomLocation = false;
      _searchController.clear();
    });

    final nearbyProvider = Provider.of<NearbyMosqueProvider>(context, listen: false);
    await nearbyProvider.fetchNearbyMosques();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: EdgeInsets.all(20),
      child: Container(
        constraints: BoxConstraints(maxHeight: 700), // Increased height for search bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildSearchBar(),
            SizedBox(height: 16),
            _buildRadiusSlider(),
            SizedBox(height: 16),
            Expanded(child: _buildMosqueList()),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mainColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Mosques',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Search by current location or enter any address',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onDismissed?.call();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<NearbyMosqueProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              // TextField(
              //   controller: _searchController,
              //   decoration: InputDecoration(
              //     hintText: 'Enter address (e.g., Mujahid Colony, Vehari)',
              //     prefixIcon: Icon(Icons.search, color: AppColors.mainColor),
              //     suffixIcon: _searchController.text.isNotEmpty
              //         ? IconButton(
              //       icon: Icon(Icons.clear, color: Colors.grey),
              //       onPressed: () {
              //         _searchController.clear();
              //         _useCurrentLocation();
              //       },
              //     )
              //         : null,
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //       borderSide: BorderSide(color: AppColors.mainColor),
              //     ),
              //     focusedBorder: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //       borderSide: BorderSide(color: AppColors.mainColor, width: 2),
              //     ),
              //   ),
              //   onSubmitted: _searchByAddress,
              // ),
              // SizedBox(height: 8),
              if (_usingCustomLocation && provider.userPosition != null)
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Showing mosques near "${provider.customLocationName}"',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton(
                      onPressed: _useCurrentLocation,
                      child: Text(
                        'Use My Location',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.mainColor,
                          fontWeight: FontWeight.bold,
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

  Widget _buildRadiusSlider() {
    return Consumer<NearbyMosqueProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Search Radius',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${provider.searchRadius.toStringAsFixed(1)} km',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Slider(
                value: provider.searchRadius,
                min: 1.0,
                max: 40.0, // Increased max to 40km as requested
                divisions: 39,
                onChanged: (value) {
                  provider.setSearchRadius(value);
                },
                onChangeEnd: (value) {
                  if (_usingCustomLocation) {
                    // Re-search with new radius for custom location
                    _searchByAddress(_searchController.text);
                  } else {
                    provider.fetchNearbyMosques();
                  }
                },
                activeColor: AppColors.mainColor,
                inactiveColor: AppColors.mainColor.withOpacity(0.3),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 km', style: GoogleFonts.poppins(fontSize: 12)),
                  Text('40 km', style: GoogleFonts.poppins(fontSize: 12)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMosqueList() {
    return Consumer<NearbyMosqueProvider>(
      builder: (context, provider, child) {
        if (_isSearching) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.mainColor),
                SizedBox(height: 16),
                Text(
                  'Searching for mosques...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          );
        }

        if (provider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.mainColor),
                SizedBox(height: 16),
                Text(
                  'Searching for nearby mosques...',
                  style: GoogleFonts.poppins(),
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    provider.error!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _usingCustomLocation
                        ? _searchByAddress(_searchController.text)
                        : provider.fetchNearbyMosques(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                    ),
                    child: Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.nearbyMosques.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 50, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    _usingCustomLocation
                        ? 'No mosques found near "${provider.customLocationName}" within ${provider.searchRadius.toStringAsFixed(1)} km'
                        : 'No mosques found within ${provider.searchRadius.toStringAsFixed(1)} km',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try increasing the search radius or searching a different location',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.grey),
                  ),
                  if (!_usingCustomLocation)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          _searchController.text = 'Pimpri Colony, Pune';
                          _searchByAddress(_searchController.text);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainColor,
                        ),
                        child: Text('Search Example Location'),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16),
          itemCount: provider.nearbyMosques.length,
          itemBuilder: (context, index) {
            final mosque = provider.nearbyMosques[index];
            return _buildMosqueItem(mosque, index);
          },
        );
      },
    );
  }

  Widget _buildMosqueItem(Map<String, dynamic> mosque, int index) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.mainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.mosque, color: AppColors.mainColor),
        ),
        title: Text(
          mosque['masjidName'] ?? 'Unknown Mosque',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              mosque['address'] ?? 'No address available',
              style: GoogleFonts.poppins(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                mosque['distanceText'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.mainColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          widget.onMosqueSelected(mosque['uid'], mosque);
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDismissed?.call();
              },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                final provider = Provider.of<NearbyMosqueProvider>(context, listen: false);
                if (_usingCustomLocation) {
                  _searchByAddress(_searchController.text);
                } else {
                  provider.fetchNearbyMosques();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainColor,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Refresh', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}