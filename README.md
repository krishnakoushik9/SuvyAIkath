# SuvyAIkth - Intelligent Educational Platform

SuvyAIkth is a comprehensive educational application designed to enhance learning experiences through AI-powered features, interactive content, and personalized study tools. The app is built with Flutter and integrates Google's Gemini AI for intelligent quiz generation and learning assistance.

## 🌟 Key Features

### 1. AI-Powered Learning
- **Smart Quiz Generation**: Automatically generates quizzes from study materials using Gemini AI
- **Adaptive Learning**: Adjusts question difficulty based on user performance
- **Instant Feedback**: Provides detailed explanations for quiz answers

### 2. Study Management
- **Task Tracking**: Create and manage study tasks with due dates and priorities
- **Progress Analytics**: Visualize learning progress with interactive charts
- **PDF Integration**: Built-in PDF viewer for course materials

### 3. User Experience
- **Modern UI/UX**: Clean, intuitive interface with smooth animations
- **Dark/Light Theme**: Choose your preferred color scheme
- **Responsive Design**: Works on phones and tablets

### 4. Productivity Tools
- **Study Timer**: Track study sessions
- **Reminders**: Get notifications for upcoming tasks and study goals
- **Offline Access**: Continue learning without internet connection

## 🛠 Technical Stack

### Core Technologies
- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Provider
- **Local Storage**: SharedPreferences, Hive
- **Networking**: Dio, HTTP

### Key Dependencies
- `permission_handler`: For managing app permissions
- `flutter_pdfview`: For PDF rendering
- `lottie`: For smooth animations
- `fl_chart`: For data visualization
- `google_fonts`: For custom typography
- `flutter_local_notifications`: For local notifications
- `google_generative_ai`: For AI-powered features

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for emulators)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/medha-ai.git
   cd medha-ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**
   Create a `.env` file in the root directory and add your API keys:
   ```
   GEMINI_API_KEY=your_gemini_api_key_here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 🏗 Project Structure

```
lib/
├── main.dart                 # App entry point
├── config/                  
│   └── theme.dart           # App theming and styling
├── models/                  
│   └── quiz_question.dart   # Data models
├── providers/               # State management
├── screens/                 # App screens
│   ├── home_screen.dart     # Main dashboard
│   ├── quiz_screen.dart     # AI-powered quiz
│   ├── tasks_screen.dart    # Task management
│   ├── progress_screen.dart # Learning analytics
│   ├── search_screen.dart   # Content search
│   ├── profile_screen.dart  # User profile
│   ├── pdf_viewer_screen.dart # PDF viewer
│   └── oauth_screen.dart    # Authentication
├── services/                # Business logic
│   ├── gemini_service.dart  # AI integration
│   └── file_service.dart    # File operations
├── utils/                   
│   ├── permission_handler.dart # Permission management
│   ├── notifications.dart   # Notification service
│   └── constants.dart       # App constants
└── widgets/                 # Reusable UI components
    ├── animated_card.dart   # Custom animations
    ├── mic_animation.dart   # Voice input UI
    └── progress_bar.dart    # Custom progress indicators
```

## 🔒 Permissions

The app requests the following permissions:

- **Storage**: To save and access study materials
- **Internet**: For AI features and content updates
- **Notifications**: For study reminders
- **Camera** (optional): For scanning documents
- **Microphone** (optional): For voice input

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📧 Contact

For support or questions, please contact [legionkoushik3@gmail.com](mailto:legionkoushik3@gmail.com)

---

<div align="center">
  Made with ❤️ by Team Shasakta
</div>
