import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Applique un délai de debounce avant d'exécuter [restartable], pour les recherches.
EventTransformer<T> debounceRestartable<T>(Duration duration) {
  return (events, mapper) {
    return restartable<T>().call(
      events.asyncExpand((event) async* {
        await Future<void>.delayed(duration);
        yield event;
      }),
      mapper,
    );
  };
}
