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

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _apiKey,
          'types': 'establishment|geocode',
        },
      );

      if (response.statusCode == 200 && response.data['predictions'] != null) {
        setState(() {
          _searchResults = List<Map<String, dynamic>>.from(response.data['predictions']);
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _selectSearchResult(Map<String, dynamic> prediction) async {
    try {
      final placeId = prediction['place_id'];
      if (placeId == null) return;

      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _apiKey,
          'fields': 'geometry,formatted_address',
        },
      );

      if (response.statusCode == 200 && response.data['result'] != null) {
        final result = response.data['result'];
        final geometry = result['geometry'];
        final location = geometry?['location'];
        
        if (location != null) {
          final latLng = LatLng(location['lat'], location['lng']);
          
          setState(() {
            _selectedLocation = latLng;
            _selectedAddress = result['formatted_address'] ?? prediction['description'];
            _searchResults = [];
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a location...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchPlaces('');
                            },
                          )
                        : null,
                  ),
                  onChanged: _searchPlaces,
                ),
                
                // Search Results
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else if (_searchResults.isNotEmpty)
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(result['description'] ?? ''),
                          onTap: () => _selectSearchResult(result),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          
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
