#include "habit_converter.h"

// Constructor
HabitConverter::HabitConverter(double weightKg, double activeDurationMinutes)
    : weightKg(weightKg), activeDurationMinutes(activeDurationMinutes) {}

// Getters and Setters
void HabitConverter::setWeightKg(double weight) {
    weightKg = weight;
}

double HabitConverter::getWeightKg() const {
    return weightKg;
}

void HabitConverter::setActiveDurationMinutes(double duration) {
    activeDurationMinutes = duration;
}

double HabitConverter::getActiveDurationMinutes() const {
    return activeDurationMinutes;
}

// Core Metabolic Formula: Kcal/min = (MET * 3.5 * X) / 200
double HabitConverter::calculateKcalPerMinute() const {
    return (NET_MET_DELTA * 3.5 * weightKg) / 200.0;
}

// Calculate total calories burned per day
double HabitConverter::calculateDailyKcalBurned() const {
    return calculateKcalPerMinute() * activeDurationMinutes;
}

// Calculate total projected calories over 30 days
double HabitConverter::calculate30DayProjectedKcalBurned() const {
    return calculateDailyKcalBurned() * 30.0;
}

// Convert projected calories to fat loss (in kg)
double HabitConverter::calculate30DayFatLossKg() const {
    return calculate30DayProjectedKcalBurned() / FAT_LOSS_CONSTANT_KCAL_PER_KG;
}

// ---------------------------------------------------------
// C API for Dart FFI bindings
// ---------------------------------------------------------

#ifdef __cplusplus
extern "C" {
#endif

void* HabitConverter_create(double weightKg, double activeDurationMinutes) {
    return new HabitConverter(weightKg, activeDurationMinutes);
}

void HabitConverter_destroy(void* instance) {
    if (instance) {
        delete static_cast<HabitConverter*>(instance);
    }
}

double HabitConverter_getWeightKg(void* instance) {
    if (instance) {
        return static_cast<HabitConverter*>(instance)->getWeightKg();
    }
    return 0.0;
}

double HabitConverter_getActiveDurationMinutes(void* instance) {
    if (instance) {
        return static_cast<HabitConverter*>(instance)->getActiveDurationMinutes();
    }
    return 0.0;
}

void HabitConverter_setWeightKg(void* instance, double weightKg) {
    if (instance) {
        static_cast<HabitConverter*>(instance)->setWeightKg(weightKg);
    }
}

void HabitConverter_setActiveDurationMinutes(void* instance, double activeDurationMinutes) {
    if (instance) {
        static_cast<HabitConverter*>(instance)->setActiveDurationMinutes(activeDurationMinutes);
    }
}

double HabitConverter_calculateKcalPerMinute(void* instance) {
    if (instance) {
        return static_cast<HabitConverter*>(instance)->calculateKcalPerMinute();
    }
    return 0.0;
}

double HabitConverter_calculateDailyKcalBurned(void* instance) {
    if (instance) {
        return static_cast<HabitConverter*>(instance)->calculateDailyKcalBurned();
    }
    return 0.0;
}

double HabitConverter_calculate30DayProjectedKcalBurned(void* instance) {
    if (instance) {
        return static_cast<HabitConverter*>(instance)->calculate30DayProjectedKcalBurned();
    }
    return 0.0;
}

double HabitConverter_calculate30DayFatLossKg(void* instance) {
    if (instance) {
        return static_cast<HabitConverter*>(instance)->calculate30DayFatLossKg();
    }
    return 0.0;
}

#ifdef __cplusplus
}
#endif
