# LearnSphere AI

<p align="center">
  <img src="assets/images/logo.png" alt="LearnSphere AI Logo" width="120"/>
</p>

<p align="center">
  <strong>An intelligent learning platform powered by AI</strong>
</p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#tech-stack">Tech Stack</a> •
  <a href="#getting-started">Getting Started</a> •
  <a href="#project-structure">Project Structure</a> •
  <a href="#license">License</a>
</p>

---

## Overview

LearnSphere AI is a comprehensive AI-powered learning assistant built with Flutter. It leverages OpenAI's GPT models to provide students with an interactive tutoring experience, lecture summarization, quiz generation, and organized study materials.

**Developed by Terry Mardaymootoo**

---

## Features

### 🤖 AI Tutor Chat
- Interactive chatbot powered by GPT-3.5 Turbo
- Step-by-step explanations and guided learning
- Conversation history for review
- Encourages critical thinking over direct answers

### 📚 Lecture Storage
- Upload and organize lecture notes (PDF support)
- Module-based organization
- Cloud storage with Firebase

### 📝 Lecture Summary
- AI-powered summarization of lecture content
- Handles large documents through intelligent chunking
- Save and review summaries

### 🎯 Challenge Mode
- Auto-generated quizzes from lecture content
- Multiple difficulty levels (Easy, Medium, Hard)
- Customizable question count
- Quiz history and performance tracking

### 🎨 Additional Features
- Beautiful animated splash screen
- Onboarding flow for new users
- Dark/Light theme support
- Google Sign-In authentication

---

## Screenshots

### Authentication & Home
<p align="center">
  <img src="screenshots/Google%20sign%20in.jpeg" alt="Google Sign In" width="250"/>
  &nbsp;&nbsp;
  <img src="screenshots/Homescreen.jpeg" alt="Home Screen" width="250"/>
</p>

### AI Tutor Chat
<p align="center">
  <img src="screenshots/AI%20Tutor%20Chat.jpeg" alt="AI Tutor Chat" width="250"/>
</p>

### Lecture Storage & Organization
<p align="center">
  <img src="screenshots/Lecture%20Storage.jpeg" alt="Lecture Storage" width="250"/>
  &nbsp;&nbsp;
  <img src="screenshots/Lecture%20Notes%20Storage.jpeg" alt="Lecture Notes" width="250"/>
</p>

### Lecture Summarization
<p align="center">
  <img src="screenshots/PDF%20and%20Plain%20text%20summarisation.jpeg" alt="PDF and Text Summarization" width="250"/>
  &nbsp;&nbsp;
  <img src="screenshots/Summarised%20text%20list.jpeg" alt="Saved Summaries" width="250"/>
</p>

### Challenge Mode & Quizzes
<p align="center">
  <img src="screenshots/Challenge%20Mode.jpeg" alt="Challenge Mode" width="250"/>
  &nbsp;&nbsp;
  <img src="screenshots/Generated%20MCQs.jpeg" alt="Generated MCQs" width="250"/>
</p>

### Quiz Results & Performance
<p align="center">
  <img src="screenshots/Corrections.jpeg" alt="Quiz Corrections" width="250"/>
  &nbsp;&nbsp;
  <img src="screenshots/Performance%20Metrics.jpeg" alt="Performance Metrics" width="250"/>
  &nbsp;&nbsp;
  <img src="screenshots/Performance%20tracking.jpeg" alt="Performance Tracking" width="250"/>
</p>

---

## Tech Stack

| Category | Technology |
|----------|------------|
| **Framework** | Flutter 3.9+ |
| **Language** | Dart |
| **State Management** | GetX, Provider |
| **Backend** | Firebase (Auth, Firestore, Storage, Cloud Functions) |
| **AI** | OpenAI GPT-3.5 Turbo |
| **Local Storage** | Hive |
| **PDF Processing** | Syncfusion Flutter PDF |
| **Animations** | Lottie, Flutter Animate |

---

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Firebase CLI
- Node.js 18+ (for Cloud Functions)
- An OpenAI API key
- A Firebase project

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Terry-M26/learn_sphere_ai.git
   cd learn_sphere_ai