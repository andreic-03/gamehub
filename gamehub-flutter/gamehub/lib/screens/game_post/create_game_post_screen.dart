import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../models/game/games_response_model.dart';
import '../../services/game/game_service.dart';
import '../../core/utils/error_util.dart';
import '../../models/game_post/game_post_request_model.dart';
import '../../services/game_post/game_post_service.dart';
import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../../widgets/map_picker_widget.dart';
import 'create_game_post_view_model.dart';

class CreateGamePostScreen extends StatefulWidget {
  const CreateGamePostScreen({Key? key}) : super(key: key);

  @override
  State<CreateGamePostScreen> createState() => _CreateGamePostScreenState();
}

class _CreateGamePostScreenState extends State<CreateGamePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _gamePostService = GetIt.instance<GamePostService>();
  final _viewModel = GetIt.instance<CreateGamePostViewModel>();
  bool _isLoading = false;

  // Form fields
  final _gameIdController = TextEditingController();
  final _gameNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Location coordinates (will be set by map picker)
  double? _selectedLatitude;
  double? _selectedLongitude;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Realtime search state
  List<GamesResponseModel> _gameSuggestions = [];
  bool _isSearchingGames = false;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await _viewModel.selectDate(context, _selectedDate, _selectedTime);
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await _viewModel.selectTime(context, _selectedTime);
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year, 
          _selectedDate.month, 
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerWidget(
          initialLocation: _selectedLatitude != null && _selectedLongitude != null
              ? LatLng(_selectedLatitude!, _selectedLongitude!)
              : null,
          initialAddress: _locationController.text.isNotEmpty ? _locationController.text : null,
          onLocationSelected: (latitude, longitude, address) {
            setState(() {
              _selectedLatitude = latitude;
              _selectedLongitude = longitude;
              if (address != null && address.isNotEmpty) {
                _locationController.text = address;
              }
            });
          },
        ),
      ),
    );
  }

  Future<void> _createGamePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await _viewModel.createGamePost(
      context: context,
      gameIdController: _gameIdController,
      locationController: _locationController,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      scheduledDate: _selectedDate,
      maxParticipantsController: _maxParticipantsController,
      descriptionController: _descriptionController,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    
    // Return true to indicate successful creation
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _gameIdController.dispose();
    _gameNameController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const LocalizedText('create_game_post.title'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Game Name search field with realtime suggestions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _gameNameController,
                          decoration: InputDecoration(
                            labelText: 'create_game_post.game_name'.localized,
                            border: const OutlineInputBorder(),
                            suffixIcon: _gameNameController.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    tooltip: 'create_game_post.clear'.localized,
                                    onPressed: () {
                                      setState(() {
                                        _gameNameController.clear();
                                        _gameIdController.clear();
                                        _gameSuggestions = [];
                                      });
                                    },
                                  ),
                          ),
                          onTap: () => _viewModel.onGameFieldFocused(
                            setSearching: (v) => setState(() { _isSearchingGames = v; }),
                            setSuggestions: (s) => setState(() { _gameSuggestions = s; }),
                          ),
                          onChanged: (q) => _viewModel.onGameNameChanged(
                            q,
                            setSearching: (v) => setState(() { _isSearchingGames = v; }),
                            setSuggestions: (s) => setState(() { _gameSuggestions = s; }),
                            clearSelection: () => _gameIdController.clear(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'create_game_post.please_enter_game_name'.localized;
                            }
                            if (_gameIdController.text.isEmpty) {
                              return 'create_game_post.please_select_game'.localized;
                            }
                            return null;
                          },
                        ),
                        if (_isSearchingGames)
                          const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: LinearProgressIndicator(minHeight: 2),
                          ),
                        if (_gameSuggestions.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              border: Border.all(color: Theme.of(context).dividerColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final game = _gameSuggestions[index];
                                return ListTile(
                                  title: Text(game.gameName),
                                  subtitle: Text(game.gameCategory),
                                  onTap: () => setState(() {
                                    _viewModel.selectGame(
                                      game,
                                      gameNameController: _gameNameController,
                                      gameIdController: _gameIdController,
                                      setSuggestions: (s) { _gameSuggestions = s; },
                                    );
                                  }),
                                );
                              },
                              separatorBuilder: (_, __) => const Divider(height: 1),
                              itemCount: _gameSuggestions.length,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'create_game_post.location'.localized,
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'create_game_post.please_enter_location'.localized;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Map Picker Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openMapPicker,
                        icon: const Icon(Icons.map),
                        label: Text(
                          _selectedLatitude != null && _selectedLongitude != null
                              ? 'Location Selected ✓'
                              : 'Select Location on Map',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _selectedLatitude != null && _selectedLongitude != null
                              ? Colors.green
                              : Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: LocalizationService.instance,
                      builder: (context, child) {
                        return Text(
                          'create_game_post.scheduled_date_time'.localized,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                labelText: 'create_game_post.date'.localized,
                              ),
                              child: Text(
                                "${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectTime(context),
                            child: InputDecorator(
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                labelText: 'create_game_post.time'.localized,
                              ),
                              child: Text(
                                "${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _maxParticipantsController,
                      decoration: InputDecoration(
                        labelText: 'create_game_post.max_participants'.localized,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'create_game_post.please_enter_max_participants'.localized;
                        }
                        if (int.tryParse(value) == null) {
                          return 'create_game_post.please_enter_valid_number'.localized;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'create_game_post.description_optional'.localized,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createGamePost,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: ListenableBuilder(
                        listenable: LocalizationService.instance,
                        builder: (context, child) {
                          return Text('create_game_post.create_button'.localized);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 