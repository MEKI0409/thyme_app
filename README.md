# 🌿 Thyme — AI-Powered Wellness Companion

Thyme is a gentle, gamified wellness app that combines AI-powered mood tracking, habit building, kindness journaling, and a virtual garden — all designed with calm gamification principles that support without pressuring.

## Features

### 🌸 Mood Journal
- Write freely about how you're feeling
- AI-powered sentiment analysis detects your mood automatically (Gemini API)
- Keyword-based fallback when offline
- Supports 11 mood categories: happy, calm, anxious, sad, stressed, angry, tired, hopeful, confused, lonely, neutral

### 🎯 Gentle Habits
- Create habits across 6 categories: Mindfulness, Exercise, Social, Creative, Learning, Self-Care
- Streak tracking with anti-exploit protection (rewards only once per day per habit)
- Mood-based habit recommendations (e.g. Mindfulness suggested when anxious)
- Therapeutic pairing bonuses — completing recommended habits for your current mood gives extra garden rewards

### 🌿 Living Garden
- Your plant grows from Seedling (Level 0) to Mighty Tree (Level 10)
- Earn water drops and sunlight points by completing habits, writing journals, recording kindness, and chatting with Fern
- Mood-responsive visual effects: butterflies (happy), falling petals (stressed), fireflies (calm), raindrops (sad), breathing guide (anxious)
- Ambient sounds change with mood: cheerful birds, gentle stream, soft rain, evening crickets
- Unlock custom plant colors with sunlight points
- Rest bonus — your garden rewards you for coming back after a break, never punishes absence

### 🌿 AI Companion — Fern
- Forest spirit companion powered by Gemini AI
- Context-aware: Fern knows your current mood, habit progress, and garden level
- Dynamic suggestion chips change based on time of day, mood, and habit completion
- Chatting with Fern rewards your garden (+1 water, +1 sunlight after 3 messages)
- Warm offline fallback responses when API is unavailable

### 💝 Kindness Chain
- Record acts of kindness across 7 categories: Self, Family, Friends, Stranger, Nature, Community, Other
- Quick-add suggestion chips to lower input friction
- Community tab — share anonymously and "ripple" others' kindness
- Streak milestones with celebration animations (3, 7, 14, 30 days)
- Category distribution visualization
- Mood-aware prompts — gentler suggestions when you're struggling

### ⚙️ Additional Features
- Firebase Authentication (email/password, email verification, password reset)
- Firestore with offline persistence
- Onboarding flow for new users
- Accessibility: text scale clamping (0.8x–1.3x)
- No-guilt design: the app never punishes missed days

---

## Getting Started

### Prerequisites

- **Flutter SDK** ≥ 3.0.0 — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Firebase project** with Firestore, Authentication enabled
- **Gemini API Key** (free) — for AI features

### Step 1 — Clone the Repository

```bash
git clone https://github.com/MEKI0409/thyme_app.git
cd thyme_app
```

### Step 2 — Install Dependencies

```bash
flutter pub get
```

### Step 3 — Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/) and create a new project (or use existing)
2. Enable **Authentication** → Email/Password sign-in method
3. Enable **Cloud Firestore** in production mode
4. Add your app platforms:

**Android:**
- Register your app with package name `com.thyme.app`
- Download `google-services.json`
- Place it in `android/app/google-services.json`

**iOS:**
- Register your app with bundle ID `com.thyme.app`
- Download `GoogleService-Info.plist`
- Place it in `ios/Runner/GoogleService-Info.plist`

### Step 4 — Get a Gemini API Key (Free)

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Sign in with your Google account
3. Click **Create API Key**
4. Copy the key

> **Note:** The API key is never stored in source code. It is injected at build time via `--dart-define`.

### Step 5 — Run the App

```bash
# Development (with API key)
flutter run --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
flutter run --dart-define=COHERE_API_KEY=YOUR_KEY_HERE

# Without API key (AI features will use offline fallback)
flutter run
```

### Step 6 — Build for Release

```bash
# Android APK
flutter build apk --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE

# Android App Bundle (for Play Store)
flutter build appbundle --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE

# iOS
flutter build ios --dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
```

### Android Studio

Go to **Run → Edit Configurations → Additional run args** and add:

```
--dart-define=GEMINI_API_KEY=YOUR_KEY_HERE
--dart-define=COHERE_API_KEY=YOUR_KEY_HERE
```

---

## Audio Assets

The garden ambient sound feature requires audio files. Place the following MP3 files in `assets/audio/`:

| File | Mood | Description |
|------|------|-------------|
| `gentle_stream.mp3` | Anxious | Calming stream sounds |
| `soft_rain.mp3` | Sad | Gentle rain |
| `forest_birds.mp3` | Stressed | Forest bird calls |
| `cheerful_birds.mp3` | Happy | Upbeat bird songs |
| `evening_crickets.mp3` | Calm | Night cricket sounds |
| `nature_ambient.mp3` | Neutral | General nature ambience |

Free sources: [Freesound.org](https://freesound.org), [Pixabay Audio](https://pixabay.com/sound-effects/) (use CC0 licensed files). Recommended file size: 1–3MB each, 30–60 seconds (loops automatically).

---

## Project Structure

```
lib/
├── main.dart                          # App entry, Firebase init, Provider setup
├── controllers/
│   ├── auth_controller.dart           # Authentication state
│   ├── habit_controller.dart          # Habit CRUD + streak tracking
│   ├── mood_controller.dart           # Mood entries + sentiment analysis
│   ├── garden_controller.dart         # Garden state + reward system
│   ├── kindness_controller.dart       # Kindness chain + community
│   └── settings_controller.dart       # User preferences
├── models/
│   ├── user_model.dart
│   ├── habit_model.dart
│   ├── mood_entry_model.dart
│   ├── garden_model.dart
│   ├── kindness_chain_model.dart
│   ├── chat_message_model.dart
│   └── settings_model.dart
├── services/
│   ├── firebase_service.dart          # Firestore + Auth wrapper
│   ├── gemini_service.dart            # AI companion (Fern)
│   ├── sentiment_service.dart         # Mood detection (Gemini + keyword fallback)
│   ├── garden_audio_service.dart      # Ambient sound playback
│   ├── garden_service.dart            # Garden reward calculations
│   ├── mood_responsive_garden_service.dart  # Mood → visual effects mapping
│   ├── recommendation_service.dart    # Habit recommendations
│   ├── gentle_insights_service.dart   # Non-judgmental user insights
│   ├── journal_prompts_service.dart   # Reflective journal prompts
│   └── welcome_back_service.dart      # No-guilt return messages
│   └── cohere_service.dart            # AI companion (Fern -- Fallback)
├── screens/
│   ├── home_screen.dart
│   ├── auth_screen.dart
│   ├── garden_screen.dart
│   ├── ai_coach_screen.dart           # Fern chat
│   ├── kindness_chain_screen.dart
│   ├── onboarding_screen.dart
│   └── splash_screen.dart
├── widgets/
│   ├── cute_garden_icons.dart         # Custom-painted plant icons
│   ├── cute_widgets.dart              # Shared UI components
│   ├── garden_ambiance_widget.dart    # Mood-responsive particle effects
│   ├── plant_level_up_animation.dart  # Level-up celebration
│   ├── reward_animation_widget.dart   # Habit reward animation
│   └── gentle_stats_card.dart         # Statistics display
└── utils/
    ├── theme.dart                     # CuteTheme color system
    ├── constants.dart                 # App-wide constants + reward formulas
    └── date_utils.dart                # Date formatting utilities
```

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter (Dart) |
| Backend | Firebase (Auth, Firestore) |
| AI | Google Gemini API (`gemini-2.5-flash-lite`) |
| State Management | Provider |
| Audio | audioplayers |
| Charts | fl_chart |
| Fonts | Google Fonts (Poppins) |

---

## Design Philosophy: Calm Gamification

Thyme follows calm gamification principles throughout:

- **No punishment** — Missing days never removes progress. Plants rest, they don't die.
- **No pressure** — Recommendations are invitations, not requirements. Language is always gentle.
- **No comparison** — Community kindness is anonymous. There are no leaderboards.
- **Rest is rewarded** — Coming back after absence gives a "rest bonus" instead of a penalty.
- **Emotions are welcomed** — The garden adapts to all moods equally. Sadness gets warm rain, not a "cheer up" message.

---

## License

This project is developed as a Final Year Project (FYP). All rights reserved.

---

## Acknowledgments

- Gemini API by Google for AI-powered features
- Flutter and Firebase teams for the development framework
- Freesound.org contributors for ambient audio assets