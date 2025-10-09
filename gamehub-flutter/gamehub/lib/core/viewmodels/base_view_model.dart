import 'package:flutter/foundation.dart';

/// Base ViewModel class that all ViewModels should extend.
/// Provides common functionality like state management and error handling.
class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _disposed = false;

  /// Returns whether the ViewModel is currently loading data
  bool get isLoading => _isLoading;

  /// Returns the current error message, if any
  String? get errorMessage => _errorMessage;

  /// Returns whether the ViewModel is currently in an error state
  bool get hasError => _errorMessage != null;

  /// Sets the loading state and notifies listeners
  void setLoading(bool loading) {
    if (_disposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// Clears any error messages and notifies listeners
  void clearError() {
    if (_disposed) return;
    _errorMessage = null;
    notifyListeners();
  }

  /// Sets an error message and notifies listeners
  void setError(String message) {
    if (_disposed) return;
    _errorMessage = message;
    notifyListeners();
  }

  /// Helper method to run async operations with proper loading and error handling
  Future<T?> runBusyFuture<T>(Future<T> Function() busyFuture) async {
    if (_disposed) return null;
    try {
      setLoading(true);
      clearError();
      final result = await busyFuture();
      setLoading(false);
      return result;
    } catch (e) {
      setLoading(false);
      setError(e.toString());
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
} 