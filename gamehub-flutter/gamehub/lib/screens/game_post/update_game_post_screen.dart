import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/utils/date_util.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../widgets/map_picker_widget.dart';
import 'update_game_post_view_model.dart';

class UpdateGamePostScreen extends StatefulWidget {
  final GamePostResponseModel gamePost;

  const UpdateGamePostScreen({
    Key? key,
    required this.gamePost,
  }) : super(key: key);

  @override
  State<UpdateGamePostScreen> createState() => _UpdateGamePostScreenState();
}

class _UpdateGamePostScreenState extends State<UpdateGamePostScreen> {
  late final UpdateGamePostViewModel _viewModel;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _viewModel = UpdateGamePostViewModel(originalGamePost: widget.gamePost);
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16.0, 120.0, 16.0, 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Game Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              widget.gamePost.gamePictureUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.gamePost.gameName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Hosted by ${widget.gamePost.hostName}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Location Section
              _buildSectionHeader('game_post.location'.localized),
              const SizedBox(height: 8),
              TextFormField(
                controller: _viewModel.locationController,
                decoration: InputDecoration(
                  hintText: 'game_post.enter_location'.localized,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                validator: _viewModel.validateLocation,
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              // Map Picker Section
              _buildSectionHeader('game_post.coordinates'.localized),
              const SizedBox(height: 8),
              
              // Map Picker Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.map),
                  label: Text(
                    _viewModel.hasCoordinates()
                        ? 'Location Selected ✓'
                        : 'Select Location on Map',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _viewModel.hasCoordinates()
                        ? Colors.green
                        : Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Date and Time Section
              _buildSectionHeader('game_post.scheduled'.localized),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        return InkWell(
                          onTap: () => _viewModel.selectDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateUtil.formatDate(_viewModel.selectedDate),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: _viewModel,
                      builder: (context, child) {
                        return InkWell(
                          onTap: () => _viewModel.selectTime(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(_viewModel.selectedTime.format(context)),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Max Participants Section
              _buildSectionHeader('game_post.max_participants'.localized),
              const SizedBox(height: 8),
              TextFormField(
                controller: _viewModel.maxParticipantsController,
                decoration: InputDecoration(
                  hintText: 'game_post.enter_max_participants'.localized,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.people),
                  suffixText: 'game_post.current_participants'.localized.replaceAll('{count}', widget.gamePost.currentParticipantCount.toString()),
                ),
                validator: _viewModel.validateMaxParticipants,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
              
              const SizedBox(height: 16),
              
              // Description Section
              _buildSectionHeader('game_post.description'.localized),
              const SizedBox(height: 8),
              TextFormField(
                controller: _viewModel.descriptionController,
                decoration: InputDecoration(
                  hintText: 'game_post.enter_description'.localized,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: _viewModel.validateDescription,
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, child) {
                    return ElevatedButton(
                      onPressed: _viewModel.isLoading ? null : _saveGamePost,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _viewModel.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'game_post.save'.localized,
                              style: const TextStyle(fontSize: 18),
                            ),
                    );
                  },
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Error Message
              ListenableBuilder(
                listenable: _viewModel,
                builder: (context, child) {
                  if (_viewModel.error == null) return const SizedBox.shrink();
                  
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _viewModel.error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ],
            ),
            ),
          ),
          // Custom back button
          Positioned(
            top: 50,
            left: 16,
            child: FloatingActionButton.small(
              heroTag: "update_game_post_back_button",
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
    );
  }

  Future<void> _saveGamePost() async {
    if (_formKey.currentState!.validate()) {
      final success = await _viewModel.updateGamePost();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('game_post.updated_successfully'.localized),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate successful update
      }
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerWidget(
          initialLocation: _viewModel.hasCoordinates()
              ? LatLng(
                  double.parse(_viewModel.latitudeController.text),
                  double.parse(_viewModel.longitudeController.text),
                )
              : null,
          initialAddress: _viewModel.locationController.text.isNotEmpty
              ? _viewModel.locationController.text
              : null,
          onLocationSelected: (latitude, longitude, address) {
            _viewModel.updateCoordinates(latitude, longitude, address);
          },
        ),
      ),
    );
  }
}
