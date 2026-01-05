import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'custom_back_button.dart';
import '../core/utils/location_cache.dart';

class MapPickerWidget extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;
  final Function(double latitude, double longitude, String? address) onLocationSelected;

  const MapPickerWidget({
    Key? key,
    this.initialLocation,
    this.initialAddress,
    required this.onLocationSelected,
  }) : super(key: key);

  @override
  State<MapPickerWidget> createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends State<MapPickerWidget> {
  static const double _topPadding = 100.0;

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  String? _selectedAddress;
  bool _isLoading = false;
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  final String _apiKey = "AIzaSyA2qlgjLn2BTCez31R15rFdCTzw86UPI_M";
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false; // Track if a search was performed
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _selectedAddress = widget.initialAddress;
    
    // If no initial location, use current location
    if (_selectedLocation == null) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      double latitude;
      double longitude;
      
      // Try to use cached location first
      if (LocationCache.hasLocation) {
        latitude = LocationCache.cachedLatitude!;
        longitude = LocationCache.cachedLongitude!;
      } else {
        // If no cached location, fetch it
        final position = await Geolocator.getCurrentPosition();
        latitude = position.latitude;
        longitude = position.longitude;
        
        // Cache it for future use
        LocationCache.setPosition(position);
      }
      
      setState(() {
        _selectedLocation = LatLng(latitude, longitude);
      });
    } catch (e) {
      // Fallback to a default location (e.g., Paris)
      setState(() {
        _selectedLocation = const LatLng(48.8566, 2.3522);
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }

    // Show loading only after debounce to avoid flickering
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {
          _isSearching = true;
        });
        _searchPlaces(trimmedQuery);
      }
    });
  }

  Future<void> _searchPlaces(String query) async {
    if (!mounted || query.length < 3) {
      return;
    }

    try {
      // Using the new Places API (New)
      final response = await _dio.post(
        'https://places.googleapis.com/v1/places:autocomplete',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
          },
        ),
        data: {
          'input': query,
        },
      );

      if (!mounted) return;

      final data = response.data;
      if (response.statusCode == 200 && data != null && data['suggestions'] != null) {
        final suggestions = List<Map<String, dynamic>>.from(data['suggestions']);
        // Transform to match our expected format
        final predictions = suggestions.map((s) {
          final placePrediction = s['placePrediction'];
          return {
            'place_id': placePrediction?['placeId'],
            'description': placePrediction?['text']?['text'] ?? '',
          };
        }).toList();

        setState(() {
          _searchResults = predictions;
          _isSearching = false;
          _hasSearched = true;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  Future<void> _selectSearchResult(Map<String, dynamic> prediction) async {
    try {
      final placeId = prediction['place_id'];
      if (placeId == null) return;

      // Using the new Places API (New)
      final response = await _dio.get(
        'https://places.googleapis.com/v1/places/$placeId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': _apiKey,
            'X-Goog-FieldMask': 'location,formattedAddress',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final location = data['location'];

        if (location != null) {
          final latLng = LatLng(
            location['latitude']?.toDouble() ?? 0.0,
            location['longitude']?.toDouble() ?? 0.0,
          );

          setState(() {
            _selectedLocation = latLng;
            _selectedAddress = data['formattedAddress'] ?? prediction['description'];
            _searchResults = [];
            _hasSearched = false;
            _searchController.clear();
          });

          _mapController?.animateCamera(
            CameraUpdate.newLatLng(latLng),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting place details: $e')),
      );
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _selectedAddress = null; // Clear address when manually selecting
    });
  }

  void _confirmSelection() {
    if (_selectedLocation != null) {
      widget.onLocationSelected(
        _selectedLocation!.latitude,
        _selectedLocation!.longitude,
        _selectedAddress,
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map and Search Bar Column
          Column(
            children: [
              // TODO Uncomment for use of the search if needed in the future
              // Search Bar Container (fixed height)
              // Container(
              //   padding: EdgeInsets.fromLTRB(16, _topPadding, 16, 16),
              //   child: TextField(
              //     controller: _searchController,
              //     decoration: InputDecoration(
              //       hintText: 'Search for a location...',
              //       prefixIcon: const Icon(Icons.search),
              //       border: OutlineInputBorder(
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       suffixIcon: _searchController.text.isNotEmpty
              //           ? IconButton(
              //               icon: const Icon(Icons.clear),
              //               onPressed: () {
              //                 _debounceTimer?.cancel();
              //                 _searchController.clear();
              //                 setState(() {
              //                   _searchResults = [];
              //                   _isSearching = false;
              //                   _hasSearched = false;
              //                 });
              //               },
              //             )
              //           : null,
              //     ),
              //     onChanged: _onSearchChanged,
              //   ),
              // ),

              // Map
              Expanded(
                child: _selectedLocation == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation!,
                          zoom: 15,
                        ),
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        onTap: _onMapTapped,
                        markers: _selectedLocation != null
                            ? {
                                Marker(
                                  markerId: const MarkerId('selected_location'),
                                  position: _selectedLocation!,
                                  draggable: true,
                                  onDragEnd: (LatLng newPosition) {
                                    setState(() {
                                      _selectedLocation = newPosition;
                                      _selectedAddress = null;
                                    });
                                  },
                                ),
                              }
                            : {},
                      ),
              ),
            ],
          ),

          // // Search Results Overlay
          // if (_isSearching || _searchResults.isNotEmpty || (_hasSearched && _searchResults.isEmpty))
          //   Positioned(
          //     top: _topPadding + 56 + 8, // below search bar
          //     left: 16,
          //     right: 16,
          //     child: Material(
          //       elevation: 4,
          //       borderRadius: BorderRadius.circular(8),
          //       child: Container(
          //         constraints: const BoxConstraints(maxHeight: 200),
          //         decoration: BoxDecoration(
          //           color: Theme.of(context).cardColor,
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child: _isSearching
          //             ? const Padding(
          //                 padding: EdgeInsets.all(16),
          //                 child: Center(child: CircularProgressIndicator()),
          //               )
          //             : _searchResults.isEmpty
          //                 ? const Padding(
          //                     padding: EdgeInsets.all(16),
          //                     child: Center(
          //                       child: Text(
          //                         'No results found',
          //                         style: TextStyle(color: Colors.grey),
          //                       ),
          //                     ),
          //                   )
          //                 : ListView.builder(
          //                     shrinkWrap: true,
          //                     padding: EdgeInsets.zero,
          //                     itemCount: _searchResults.length,
          //                     itemBuilder: (context, index) {
          //                       final result = _searchResults[index];
          //                       return ListTile(
          //                         leading: const Icon(Icons.location_on),
          //                         title: Text(result['description'] ?? ''),
          //                         onTap: () => _selectSearchResult(result),
          //                       );
          //                     },
          //                   ),
          //       ),
          //     ),
          //   ),

          // Background barrier to hide scrolling content behind back button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: _topPadding,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
          ),
          CustomBackButton(
            heroTag: "map_picker_back_button",
          ),
        ],
      ),
      floatingActionButton: _selectedLocation != null
          ? FloatingActionButton.extended(
              onPressed: _confirmSelection,
              backgroundColor: Colors.green,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Confirm Location',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
