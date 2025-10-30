import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/utils/error_util.dart';
import '../../core/utils/date_util.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../widgets/map_picker_widget.dart';
import '../../widgets/custom_back_button.dart';
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
                                  'game_post.hosted_by'.localized.replaceAll('{name}', widget.gamePost.hostName),
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

              const SizedBox(height: 16),

              // Location Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'game_post.location'.localized,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _viewModel.locationController,
                        decoration: InputDecoration(
                          labelText: 'create_game_post.location_name'.localized,
                          prefixIcon: const Icon(Icons.location_on_outlined),
                        ),
                        validator: _viewModel.validateLocation,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _openMapPicker,
                          icon: const Icon(Icons.map),
                          label: Text(
                            _viewModel.hasCoordinates()
                                ? 'create_game_post.location_selected'.localized
                                : 'create_game_post.select_location_on_map_button'.localized,
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Date & Time Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'game_post.scheduled'.localized,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ListenableBuilder(
                              listenable: _viewModel,
                              builder: (context, child) {
                                return InkWell(
                                  onTap: () => _viewModel.selectDate(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'create_game_post.date_label'.localized,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              Text(
                                                DateUtil.formatDate(_viewModel.selectedDate),
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ListenableBuilder(
                              listenable: _viewModel,
                              builder: (context, child) {
                                return InkWell(
                                  onTap: () => _viewModel.selectTime(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(Icons.access_time, size: 20, color: Colors.grey.shade600),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'create_game_post.time_label'.localized,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              Text(
                                                _viewModel.selectedTime.format(context),
                                                style: const TextStyle(fontSize: 16),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ListenableBuilder(
                        listenable: _viewModel,
                        builder: (context, child) {
                          final errorText = _viewModel.validateDateTime();
                          if (errorText == null) return const SizedBox.shrink();
                          return Text(
                            'create_game_post.date_must_be_future'.localized,
                            style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Participants & Description Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'create_game_post.details'.localized,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _viewModel.maxParticipantsController,
                        decoration: InputDecoration(
                          labelText: 'create_game_post.max_participants'.localized,
                          prefixIcon: const Icon(Icons.people_outline),
                          suffixText: 'game_post.current_participants'.localized.replaceAll('{count}', widget.gamePost.currentParticipantCount.toString()),
                        ),
                        validator: _viewModel.validateMaxParticipants,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _viewModel.descriptionController,
                        decoration: InputDecoration(
                          labelText: 'create_game_post.description_optional'.localized,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),
                        validator: _viewModel.validateDescription,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

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
            ],
            ),
            ),
          ),
          // Custom back button
          CustomBackButton(
            heroTag: "update_game_post_back_button",
          ),
        ],
      ),
    );
  }

  Future<void> _saveGamePost() async {
    if (_formKey.currentState!.validate()) {
      final updated = await _viewModel.updateGamePost(context: context);
      if (updated != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('game_post.updated_successfully'.localized),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, updated); // Return updated model to details
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
