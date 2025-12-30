import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../localization/localized_text.dart';
import '../../localization/localization_service.dart';
import '../../models/game/games_response_model.dart';
import '../../models/game_post/game_post_response_model.dart';
import '../../widgets/custom_back_button.dart';
import '../../widgets/map_picker_widget.dart';
import 'edit_game_post_view_model.dart';

class EditGamePostScreen extends StatefulWidget {
  final GamePostResponseModel? gamePost; // null => create, not null => update
  const EditGamePostScreen({Key? key, this.gamePost}) : super(key: key);

  @override
  State<EditGamePostScreen> createState() => _EditGamePostScreenState();
}

class _EditGamePostScreenState extends State<EditGamePostScreen> {
  static const double _topPadding = 120.0;

  final _formKey = GlobalKey<FormState>();
  late final EditGamePostViewModel _vm;
  bool _isSearchingGames = false;
  List<GamesResponseModel> _gameSuggestions = [];
  bool get isCreate => widget.gamePost == null;

  @override
  void initState() {
    super.initState();
    _vm = EditGamePostViewModel(originalGamePost: widget.gamePost);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Create helpers
  Future<void> _selectDate() async => _vm.selectDate(context);
  Future<void> _selectTime() async => _vm.selectTime(context);

  void _closeGameSuggestions() {
    setState(() {
      _gameSuggestions = [];
    });
  }

  Future<void> _openMapPicker() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerWidget(
          initialLocation: _vm.hasCoordinates
              ? LatLng(_vm.latitude!, _vm.longitude!)
              : null,
          initialAddress: _vm.locationController.text.isNotEmpty
              ? _vm.locationController.text
              : null,
          onLocationSelected: (latitude, longitude, address) {
            _vm.setCoordinates(latitude, longitude, address);
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _vm.submit(context: context);
    if (result != null && mounted) {
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_vm.isLoading)
            const Center(child: CircularProgressIndicator())
          else
            GestureDetector(
              onTap: _closeGameSuggestions,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, _topPadding, 16.0, 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isCreate) ...[
                        // Hosted by card (update only)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    widget.gamePost!.gamePictureUrl,
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
                                        widget.gamePost!.gameName,
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'game_post.hosted_by'.localized.replaceAll('{name}', widget.gamePost!.hostName),
                                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        // Game Selection Card (create only)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'create_game_post.game_name'.localized,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _vm.gameNameController,
                                  decoration: InputDecoration(
                                    labelText: 'create_game_post.game_name'.localized,
                                    suffixIcon: _vm.gameNameController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            icon: const Icon(Icons.clear),
                                            tooltip: 'create_game_post.clear'.localized,
                                            onPressed: () {
                                              setState(() {
                                                _vm.gameNameController.clear();
                                                _vm.gameIdController.clear();
                                                _gameSuggestions = [];
                                              });
                                            },
                                          ),
                                  ),
                                  onTap: () => _vm.onGameFieldFocused(
                                    setSearching: (v) => setState(() { _isSearchingGames = v; }),
                                    setSuggestions: (s) => setState(() { _gameSuggestions = s; }),
                                  ),
                                  onChanged: (q) => _vm.onGameNameChanged(
                                    q,
                                    setSearching: (v) => setState(() { _isSearchingGames = v; }),
                                    setSuggestions: (s) => setState(() { _gameSuggestions = s; }),
                                    clearSelection: () => _vm.gameIdController.clear(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'create_game_post.please_enter_game_name'.localized;
                                    }
                                    if (_vm.gameIdController.text.isEmpty) {
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
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        final game = _gameSuggestions[index];
                                        return ListTile(
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                                          dense: true,
                                          title: Text(game.gameName),
                                          subtitle: Text(game.gameCategory),
                                          onTap: () => setState(() {
                                            _vm.selectGame(
                                              game,
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
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Location Card (shared)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'create_game_post.location'.localized,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _vm.locationController,
                                decoration: InputDecoration(
                                  labelText: 'create_game_post.location_name'.localized,
                                  prefixIcon: const Icon(Icons.location_on_outlined),
                                ),
                                validator: _vm.validateLocation,
                                textInputAction: TextInputAction.next,
                                onTap: _closeGameSuggestions,
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: _openMapPicker,
                                  icon: const Icon(Icons.map),
                                  label: Text(
                                    _vm.hasCoordinates
                                        ? 'create_game_post.location_selected'.localized
                                        : 'create_game_post.select_location_on_map_button'.localized,
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    backgroundColor: _vm.hasCoordinates
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

                      // Date & Time Card (shared)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCreate ? 'create_game_post.scheduled_date_time'.localized : 'game_post.scheduled'.localized,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ListenableBuilder(
                                listenable: _vm,
                                builder: (context, child) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _selectDate(),
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
                                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                      ),
                                                      Text(
                                                        '${_vm.selectedDate.year}-${_vm.selectedDate.month.toString().padLeft(2, '0')}-${_vm.selectedDate.day.toString().padLeft(2, '0')}',
                                                        style: const TextStyle(fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _selectTime(),
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
                                                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                      ),
                                                      Text(
                                                        '${_vm.selectedTime.hour.toString().padLeft(2, '0')}:${_vm.selectedTime.minute.toString().padLeft(2, '0')}',
                                                        style: const TextStyle(fontSize: 16),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              ListenableBuilder(
                                listenable: _vm,
                                builder: (context, child) {
                                  final errorText = _vm.validateDateTime();
                                  if (errorText == null) return const SizedBox.shrink();
                                  return Text(
                                    errorText,
                                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Participants & Description Card (shared)
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
                                controller: _vm.maxParticipantsController,
                                decoration: InputDecoration(
                                  labelText: 'create_game_post.max_participants'.localized,
                                  prefixIcon: const Icon(Icons.people_outline),
                                  suffixText: !isCreate
                                      ? 'game_post.current_participants'.localized.replaceAll('{count}', widget.gamePost!.currentParticipantCount.toString())
                                      : null,
                                ),
                                validator: _vm.validateMaxParticipants,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _vm.descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'create_game_post.description_optional'.localized,
                                  prefixIcon: const Icon(Icons.description_outlined),
                                ),
                                validator: _vm.validateDescription,
                                maxLines: 3,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: ListenableBuilder(
                            listenable: LocalizationService.instance,
                            builder: (context, child) {
                              return Text(isCreate ? 'create_game_post.create_button'.localized : 'game_post.save'.localized);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
          CustomBackButton(heroTag: 'edit_game_post_back_button'),
        ],
      ),
    );
  }
}


