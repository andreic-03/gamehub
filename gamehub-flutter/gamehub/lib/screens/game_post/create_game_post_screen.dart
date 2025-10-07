import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'dart:async';
import '../../models/game/games_response_model.dart';
import '../../services/game/game_service.dart';
import '../../core/utils/error_util.dart';
import '../../models/game_post/game_post_request_model.dart';
import '../../services/game_post/game_post_service.dart';
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
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _descriptionController = TextEditingController();
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

  Future<void> _createGamePost() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    await _viewModel.createGamePost(
      context: context,
      gameIdController: _gameIdController,
      locationController: _locationController,
      latitudeController: _latitudeController,
      longitudeController: _longitudeController,
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
    _latitudeController.dispose();
    _longitudeController.dispose();
    _maxParticipantsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Game Post'),
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
                            labelText: 'Game Name',
                            border: const OutlineInputBorder(),
                            suffixIcon: _gameNameController.text.isEmpty
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    tooltip: 'Clear',
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
                              return 'Please enter a game name';
                            }
                            if (_gameIdController.text.isEmpty) {
                              return 'Please select a game from the suggestions';
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
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _longitudeController,
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Scheduled Date & Time',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                labelText: 'Date',
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
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                labelText: 'Time',
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
                      decoration: const InputDecoration(
                        labelText: 'Max Participants',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter max participants';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _createGamePost,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Create Game Post'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 