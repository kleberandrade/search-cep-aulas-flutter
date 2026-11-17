import 'package:flutter/foundation.dart';

import '../domain/cep.dart';
import '../models/result_cep.dart';
import '../services/via_cep_service.dart';

sealed class SearchState {
  const SearchState();
}

final class SearchIdle extends SearchState {
  const SearchIdle();
}

final class SearchLoading extends SearchState {
  const SearchLoading();
}

final class SearchSuccess extends SearchState {
  const SearchSuccess(this.address);
  final ResultCep address;
}

final class SearchError extends SearchState {
  const SearchError(this.message);
  final String message;
}

/// Each edit/search invalidates older responses without blocking the input.
class SearchController extends ChangeNotifier {
  SearchController(this.service);
  final AddressLookup service;
  SearchState state = const SearchIdle();
  int _generation = 0;
  bool _disposed = false;

  void inputChanged() {
    _generation++;
    _emit(const SearchIdle());
  }

  Future<void> search(String input) async {
    final generation = ++_generation;
    try {
      final cep = Cep.parse(input);
      _emit(const SearchLoading());
      final address = await service.lookup(cep);
      if (generation == _generation) _emit(SearchSuccess(address));
    } on FormatException {
      if (generation == _generation) {
        _emit(
          const SearchError(
            'Informe um CEP com 8 dígitos. Exemplo: 01001-000.',
          ),
        );
      }
    } on LookupFailure catch (error) {
      if (generation == _generation) _emit(SearchError(error.message));
    }
  }

  void _emit(SearchState next) {
    if (_disposed) return;
    state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
