import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_stats_provider.dart';
import '../providers/lesson_progress_provider.dart';
import '../providers/settings_provider.dart';
import '../services/logger.dart';
import '../l10n/strings_nl.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _currentCode;

  @override
  void initState() {
    super.initState();
    _setupSyncListeners();
  }

  void _setupSyncListeners() {
    final gameStatsProvider = Provider.of<GameStatsProvider>(context, listen: false);
    final lessonProgressProvider = Provider.of<LessonProgressProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    gameStatsProvider.setupSyncListener();
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() {
        _error = AppStrings.pleaseEnterSyncCode;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final gameStatsProvider = Provider.of<GameStatsProvider>(context, listen: false);
      final lessonProgressProvider = Provider.of<LessonProgressProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      final success = await gameStatsProvider.joinSyncRoom(code);

      if (success) {
        setState(() {
          _currentCode = code;
        });
        AppLogger.info('Successfully joined sync room: $code');
        Navigator.of(context).pop(true); // Return success
      } else {
        setState(() {
          _error = AppStrings.failedToJoinSyncRoom;
        });
      }
    } catch (e) {
      setState(() {
        _error = '${AppStrings.errorGeneric}${e.toString()}';
      });
      AppLogger.error('Error joining sync room', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _leaveRoom() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final gameStatsProvider = Provider.of<GameStatsProvider>(context, listen: false);
      final lessonProgressProvider = Provider.of<LessonProgressProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      await gameStatsProvider.leaveSyncRoom();

      AppLogger.info('Left sync room');
      Navigator.of(context).pop(false); // Return left
    } catch (e) {
      setState(() {
        _error = '${AppStrings.errorLeavingSyncRoom}${e.toString()}';
      });
      AppLogger.error('Error leaving sync room', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _generateSyncCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  Future<void> _startRoom() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final code = _generateSyncCode();
      final gameStatsProvider = Provider.of<GameStatsProvider>(context, listen: false);
      final lessonProgressProvider = Provider.of<LessonProgressProvider>(context, listen: false);
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

      final success = await gameStatsProvider.joinSyncRoom(code);

      if (success) {
        setState(() {
          _currentCode = code;
        });
        AppLogger.info('Successfully started sync room: $code');
        Navigator.of(context).pop(true); // Return success
      } else {
        setState(() {
          _error = AppStrings.failedToStartSyncRoom;
        });
      }
    } catch (e) {
      setState(() {
        _error = '${AppStrings.errorGeneric}${e.toString()}';
      });
      AppLogger.error('Error starting sync room', e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameStatsProvider = Provider.of<GameStatsProvider>(context);
    final isInRoom = gameStatsProvider.syncService.isInRoom;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.multiDeviceSync),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null)
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16),
            if (!isInRoom)
              Column(
                children: [
                  Text(
                    AppStrings.enterSyncCode,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    decoration: InputDecoration(
                      labelText: AppStrings.syncCode,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _joinRoom,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(AppStrings.joinSyncRoom),
                  ),
                  SizedBox(height: 16),
                  Text(
                    AppStrings.or,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _startRoom,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(AppStrings.startSyncRoom),
                  ),
                ],
              )
            else
              Column(
                children: [
                  Text(
                    AppStrings.currentlySynced,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      border: Border.all(color: Colors.blue),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          AppStrings.yourSyncId,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          gameStatsProvider.syncService.currentRoomId ?? AppStrings.unknownError,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          AppStrings.shareSyncId,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _leaveRoom,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text(AppStrings.leaveSyncRoom),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}