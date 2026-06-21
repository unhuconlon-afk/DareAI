MASTER PLAN (SUPER PLAN)

Habit-Tracking & Body Optimization App

This plan is built directly on the technical stack you already know well (C++ OOP for the core engine, Flutter for the client, Firebase for the backend), with the psychological flow tuned around the idea of "releasing pent-up energy."


1. Core Architecture & Metabolic Algorithm (C++ Backend)

The core engine doesn't do extreme calorie counting. Instead, it focuses on quantifying the change in your body when you get up and do exercises (e.g. Poomsae forms) instead of sitting and procrastinating.


Uses the MET index for measurement, with the Net MET difference between sitting still (~1.3 MET) and being active (~3.8 MET) set at 2.5 MET.
Calculates calories burned per minute using the thermodynamic formula:


Kcal/min=MET×3.5×X200Kcal/min = \frac{MET \times 3.5 \times X}{200}Kcal/min=200MET×3.5×X​
(Where XX
X is your actual body weight in kg).


Implements this logic via a HabitConverter class in C++ following OOP standards, taking weight and extra minutes of discipline per day as inputs.
The algorithm automatically calculates net calories over 30 days and converts that into the amount of stored fat burned, based on the physiological constant of 7700 Kcal/kg.
The output ("future pie chart") won't just report fat loss — it will also highlight increased core muscle firmness and a reset of deep focus ability.



2. UX/UI & Microcopy System (Flutter Client)

The interface completely removes the pressure around weight, instead treating the body like a biological machine that needs charging and lubricating.


Active State: Displays an orange/neon-yellow energy wave chart and a soft blue muscle heat map. The main screen focuses on two metrics: current Energy Level (% bio-battery) and Flexibility Score (range of motion / ROM distance).
Stagnant State: The interface shifts to a muted gray or dim blue tone — absolutely no imagery of excess fat or threatening red X marks.
Instant rewards: Uses copy that acknowledges feeling refreshed and limber, e.g. "Energy surge!" or praise for joints that just expanded their range of motion for smoother movement.
Civil pressing: Uses mechanical/physics language to motivate. Nudges to release pent-up energy via 5-minute stretching sessions, or a firm warning like "don't let your biological machine rust" when stagnation drags on. Strictly avoids body-shaming language or guilt-inducing phrasing.



3. Technical Infrastructure & Social Pressure (Firebase + FCM)

The SOS message flow — triggered when you break discipline — is designed to keep client and server separate, ensuring security and preventing cheating.


Client side (Flutter): Integrates the cloud_functions package, using an activateLazyStateAlert function to securely send userId and delay time (delayMinutes) to the server when you miss a session.
Server side (Node.js — v2): Cloud Functions receives the data, validates it, and queries Firestore to fetch the guarantor_token (the device token of your supervisor — e.g. girlfriend or family member).
Data message packaging: The message is pushed via Firebase Cloud Messaging (FCM) in background/data-only format (payload data only, e.g. type: "SOS_LAZY_STATE"). All fields such as delayTime must be cast to String.
OS-level configuration: Set high priority (priority: "high") on Android and enable background delivery (content-available: 1) on iOS so the notification can cut through battery-saving modes.
Receiving device trigger: The supervisor's device uses the FirebaseMessaging.onBackgroundMessage handler to decode the data string and trigger an alert sound or display a custom warning screen.



4. Self-Testing Roadmap (Dogfooding)

To validate the whole system, your daily execution loop looks like this:


Set a mindless-scrolling time limit on your personal phone.
When that time limit is exceeded, an "effort toll" screen appears. Instead of a walk, configure the system to require 1–2 Taekwondo forms to spike heart rate and immediately shift physiological state.
If you keep delaying and skip the movement prompt, Cloud Functions triggers and fires a hidden data message to your supervisor's device to apply direct social pressure.
At the end of each day, check the detail column in the app to read the C++ core's projected report on energy level and joint flexibility if you keep up this discipline for the next 30 days.