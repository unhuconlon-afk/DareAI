#ifndef HABIT_CONVERTER_H
#define HABIT_CONVERTER_H

// The physiological constant: 7700 Kcal = 1 kg of fat
constexpr double FAT_LOSS_CONSTANT_KCAL_PER_KG = 7700.0;
// Net MET difference (Active 3.8 - Stagnant 1.3)
constexpr double NET_MET_DELTA = 2.5;

class HabitConverter {
private:
    double weightKg;
    double activeDurationMinutes;

public:
    HabitConverter(double weightKg, double activeDurationMinutes);

    // Getters and Setters
    void setWeightKg(double weight);
    double getWeightKg() const;

    void setActiveDurationMinutes(double duration);
    double getActiveDurationMinutes() const;

    // Core Metabolic Formula: Kcal/min = (MET * 3.5 * X) / 200
    double calculateKcalPerMinute() const;

    // Calculate total calories burned per day
    double calculateDailyKcalBurned() const;

    // Calculate total projected calories over 30 days
    double calculate30DayProjectedKcalBurned() const;

    // Convert projected calories to fat loss (in kg)
    double calculate30DayFatLossKg() const;
};

// C API for Dart FFI bindings
#ifdef __cplusplus
extern "C" {
#endif

    // Create an instance of HabitConverter
    void* HabitConverter_create(double weightKg, double activeDurationMinutes);
    
    // Destroy the instance
    void HabitConverter_destroy(void* instance);
    
    // Getters
    double HabitConverter_getWeightKg(void* instance);
    double HabitConverter_getActiveDurationMinutes(void* instance);
    
    // Setters
    void HabitConverter_setWeightKg(void* instance, double weightKg);
    void HabitConverter_setActiveDurationMinutes(void* instance, double activeDurationMinutes);
    
    // Calculations
    double HabitConverter_calculateKcalPerMinute(void* instance);
    double HabitConverter_calculateDailyKcalBurned(void* instance);
    double HabitConverter_calculate30DayProjectedKcalBurned(void* instance);
    double HabitConverter_calculate30DayFatLossKg(void* instance);

#ifdef __cplusplus
}
#endif

#endif // HABIT_CONVERTER_H
