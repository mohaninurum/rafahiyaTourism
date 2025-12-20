import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../data/subAdminProvider/map_search_provider.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({super.key});

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late GoogleMapController _mapController;

  Future<void> _searchAndNavigate(
      String address,
      MapSearchProvider provider,
      ) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        LatLng latLng = LatLng(loc.latitude, loc.longitude);

        _mapController.animateCamera(CameraUpdate.newLatLng(latLng));
        await _updateLocation(latLng, provider);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Address not found: $e")));
    }
  }

  Future<void> _updateLocation(
      LatLng position,
      MapSearchProvider provider,
      ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address = "${place.street}, ${place.locality}, ${place.country}";
        provider.updateLocation(position, address);
      }
    } catch (e) {
      // Fallback address if geocoding fails
      String address = "Lat: ${position.latitude}, Lng: ${position.longitude}";
      provider.updateLocation(position, address);
    }
  }

  void _confirmSelection(BuildContext context, MapSearchProvider provider) {
    if (provider.selectedLatLng != null) {
      // Return both address and coordinates
      Navigator.pop(context, {
        'address': provider.selectedAddress,
        'latitude': provider.selectedLatLng!.latitude,
        'longitude': provider.selectedLatLng!.longitude,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select a Location')),
      body: Consumer<MapSearchProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: LatLng(31.5204, 74.3587),
                  zoom: 14,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                },
                onTap: (pos) => _updateLocation(pos, provider),
                markers: provider.selectedLatLng != null
                    ? {
                  Marker(
                    markerId: const MarkerId("selected"),
                    position: provider.selectedLatLng!,
                  ),
                }
                    : {},
              ),
              Positioned(
                top: 20,
                left: 15,
                right: 15,
                child: Material(
                  elevation: 5,
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search location...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onSubmitted: (value) => _searchAndNavigate(value, provider),
                  ),
                ),
              ),
              if (provider.selectedAddress.isNotEmpty)
                Positioned(
                  bottom: 90,
                  left: 15,
                  right: 15,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.selectedAddress,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Lat: ${provider.selectedLatLng?.latitude.toStringAsFixed(6) ?? 'N/A'}, "
                                "Lng: ${provider.selectedLatLng?.longitude.toStringAsFixed(6) ?? 'N/A'}",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 30,
                left: 50,
                right: 50,
                child: ElevatedButton(
                  onPressed: provider.selectedLatLng != null
                      ? () => _confirmSelection(context, provider)
                      : null,
                  child: const Text("Select this location"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}