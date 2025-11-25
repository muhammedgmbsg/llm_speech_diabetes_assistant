# Diabetes AI Assistant & Tracker App

This project is a comprehensive mobile health application designed to assist diabetic patients. It combines **Generative AI (Google Gemini 2.0 Flash)** for personalized health coaching with a robust **Blood Sugar Tracking System**.

The app features a modern UI built with **Flutter & GetX**, supports **Voice Interaction (STT/TTS)**, and provides real-time data visualization without requiring a backend server (Local-first architecture).

---

## Repository Notes

1.  **Mobile App Source:** Complete Flutter code is located under `lib/`.
    * `controllers/`: State management logic (GetX).
    * `views/`: Modern UI screens with gradient designs.
    * `services/`: API integrations (Gemini AI) and local storage logic.
2.  **Configuration:** API Keys and constant definitions are in `lib/constants/app_constants.dart`.
3.  **Assets:** App icons and static images are stored in the `assets/` directory.
4.  **Dependencies:** All required packages (fl_chart, google_generative_ai, etc.) are listed in `pubspec.yaml`.

---

## Project Introduction

This end-to-end system aims to simplify diabetes management. Users can track their glucose levels with visual feedback and interact with an AI health coach via text or voice.

The system creates a seamless experience by combining:
* **Quantitative Data:** Tracking blood sugar trends via interactive graphs.
* **Qualitative Support:** An AI assistant that acts as a specialized diabetes coach, strictly filtered to answer only health-related questions.

---

## Risk Indicators & Color Coding

The application automatically categorizes blood sugar readings to give immediate visual feedback:

| Status | Range (mg/dL) | Color Indicator | Meaning |
| :--- | :--- | :--- | :--- |
| **Low (Hypoglycemia)** | < 70 | 🔴 **Red** | Dangerous low blood sugar. Immediate carbohydrate intake usually required. |
| **Normal / Ideal** | 70 - 140 | 🟢 **Green** | Healthy range. Maintenance of current lifestyle is advised. |
| **Borderline** | 140 - 180 | 🟡 **Yellow** | Elevated levels. Attention to diet and activity is needed. |
| **High (Hyperglycemia)** | > 180 | 🔴 **Red** | Dangerous high blood sugar. Medical consultation or insulin adjustment may be necessary. |

---

<img width="340" height="800" alt="Screenshot_1764081035" src="https://github.com/user-attachments/assets/ecabd994-ac5b-4aa3-ade7-6fb1e8634368" />
<img width="340" height="800" alt="Screenshot_1764081058" src="https://github.com/user-attachments/assets/a04b91eb-0235-4c2d-aad4-c689cc108508" />
<img width="340" height="800" alt="Screenshot_1764081088" src="https://github.com/user-attachments/assets/176171dc-6cd3-45f3-87c6-d3902fbefa57" />

## Features

1.  **AI Health Coach (Gemini 2.0):**
    * Context-aware chatbot specialized in diabetes.
    * Strict "System Instructions" to prevent non-health related topics.
    * Persona-based responses (Friendly, Professional).

2.  **Voice Interaction:**
    * **Speech-to-Text:** Users can ask questions by holding the microphone button.
    * **Text-to-Speech:** The AI reads answers aloud (supports multiple voice options).

3.  **Advanced Tracking System:**
    * Log blood sugar levels with timestamps.
    * **Interactive Charts:** Dynamic line charts with gradient fills and threshold lines.
    * Local persistence using `Shared Preferences`.

4.  **Modern UI/UX:**
    * **GetX Architecture:** Clean separation of UI and Logic.
    * **Glassmorphism & Gradients:** Modern aesthetics with soft shadows and rounded corners.
    * **Floating Navigation:** Custom animated bottom bar.

---

## Tech Stack

* **Framework:** Flutter (Dart)
* **State Management:** GetX
* **AI Model:** Google Gemini 2.0 Flash (via `google_generative_ai`)
* **Visualization:** fl_chart
* **Voice:** speech_to_text, flutter_tts
* **Storage:** shared_preferences

---

## Usage

### Prerequisites

* Flutter SDK ≥ 3.0
* Android Studio / VS Code
* A valid **Google Gemini API Key** (Get it from Google AI Studio)

### Installation & Run

1.  **Clone the repository:**
    ```bash
    git clone <REPO_URL>
    cd <PROJECT_DIR>
    ```

2.  **Install Dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Configure API Key:**
    * Open `lib/constants/app_constants.dart`.
    * Replace `API_KEY_BURAYA` with your actual Gemini API Key.

4.  **Run the App:**
    ```bash
    flutter run
    ```

> **Note:** For voice features to work on Android 11+, ensure the `AndroidManifest.xml` includes the necessary `queries` for TTS services.
