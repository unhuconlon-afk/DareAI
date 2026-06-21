import 'dart:ffi' as ffi;
import 'dart:io';

// Typedefs for C functions
typedef _CreateC =
    ffi.Pointer<ffi.Void> Function(
      ffi.Double weightKg,
      ffi.Double activeDurationMinutes,
    );
typedef _CreateDart =
    ffi.Pointer<ffi.Void> Function(
      double weightKg,
      double activeDurationMinutes,
    );

typedef _DestroyC = ffi.Void Function(ffi.Pointer<ffi.Void> instance);
typedef _DestroyDart = void Function(ffi.Pointer<ffi.Void> instance);

typedef _GetDoubleC = ffi.Double Function(ffi.Pointer<ffi.Void> instance);
typedef _GetDoubleDart = double Function(ffi.Pointer<ffi.Void> instance);

typedef _SetDoubleC =
    ffi.Void Function(ffi.Pointer<ffi.Void> instance, ffi.Double value);
typedef _SetDoubleDart =
    void Function(ffi.Pointer<ffi.Void> instance, double value);

/// A Dart service that binds to the native C++ metabolic engine via FFI.
class MetabolicFFIService {
  late final ffi.DynamicLibrary _lib;

  late final _CreateDart _create;
  late final _DestroyDart _destroy;
  late final _GetDoubleDart _getWeightKg;
  late final _GetDoubleDart _getActiveDurationMinutes;
  late final _SetDoubleDart _setWeightKg;
  late final _SetDoubleDart _setActiveDurationMinutes;
  late final _GetDoubleDart _calculateKcalPerMinute;
  late final _GetDoubleDart _calculateDailyKcalBurned;
  late final _GetDoubleDart _calculate30DayProjectedKcalBurned;
  late final _GetDoubleDart _calculate30DayFatLossKg;

  MetabolicFFIService() {
    // Load the dynamic library
    if (Platform.isAndroid) {
      _lib = ffi.DynamicLibrary.open('libhabit_converter.so');
    } else if (Platform.isIOS || Platform.isMacOS) {
      // In iOS/macOS, the library is statically linked into the executable.
      _lib = ffi.DynamicLibrary.process();
    } else if (Platform.isWindows) {
      _lib = ffi.DynamicLibrary.open('habit_converter.dll');
    } else if (Platform.isLinux) {
      _lib = ffi.DynamicLibrary.open('libhabit_converter.so');
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    // Bind methods
    _create = _lib.lookupFunction<_CreateC, _CreateDart>(
      'HabitConverter_create',
    );
    _destroy = _lib.lookupFunction<_DestroyC, _DestroyDart>(
      'HabitConverter_destroy',
    );
    _getWeightKg = _lib.lookupFunction<_GetDoubleC, _GetDoubleDart>(
      'HabitConverter_getWeightKg',
    );
    _getActiveDurationMinutes = _lib
        .lookupFunction<_GetDoubleC, _GetDoubleDart>(
          'HabitConverter_getActiveDurationMinutes',
        );
    _setWeightKg = _lib.lookupFunction<_SetDoubleC, _SetDoubleDart>(
      'HabitConverter_setWeightKg',
    );
    _setActiveDurationMinutes = _lib
        .lookupFunction<_SetDoubleC, _SetDoubleDart>(
          'HabitConverter_setActiveDurationMinutes',
        );
    _calculateKcalPerMinute = _lib.lookupFunction<_GetDoubleC, _GetDoubleDart>(
      'HabitConverter_calculateKcalPerMinute',
    );
    _calculateDailyKcalBurned = _lib
        .lookupFunction<_GetDoubleC, _GetDoubleDart>(
          'HabitConverter_calculateDailyKcalBurned',
        );
    _calculate30DayProjectedKcalBurned = _lib
        .lookupFunction<_GetDoubleC, _GetDoubleDart>(
          'HabitConverter_calculate30DayProjectedKcalBurned',
        );
    _calculate30DayFatLossKg = _lib.lookupFunction<_GetDoubleC, _GetDoubleDart>(
      'HabitConverter_calculate30DayFatLossKg',
    );
  }

  /// Calculates the projected fat loss (in kg) over 30 days based on weight and daily active duration.
  double get30DayFatLoss(double weightKg, double durationMinutes) {
    // 1. Create native C++ instance
    final instance = _create(weightKg, durationMinutes);

    // 2. Compute logic natively
    final fatLoss = _calculate30DayFatLossKg(instance);

    // 3. Cleanup C++ memory
    _destroy(instance);

    return fatLoss;
  }

  /// Calculates all metabolic metrics and returns them in a Dart Map
  Map<String, double> calculateAllMetrics(
    double weightKg,
    double durationMinutes,
  ) {
    final instance = _create(weightKg, durationMinutes);

    final metrics = {
      'kcalPerMinute': _calculateKcalPerMinute(instance),
      'dailyKcalBurned': _calculateDailyKcalBurned(instance),
      'projected30DayKcalBurned': _calculate30DayProjectedKcalBurned(instance),
      'projected30DayFatLossKg': _calculate30DayFatLossKg(instance),
    };

    _destroy(instance);
    return metrics;
  }
}
