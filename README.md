# Pattern Pulse - Christmas Pattern Memory Game

## Project Overview
- **Project**: Final Project - Pattern Pulse  
- **Student**: David Deng  
- **Course**: iOS App Development
- **Date**: December 2025
- **Platform**: iOS 17.0+

## Features

### Core Game Features
- **Pattern Memory Challenge**: Watch and repeat increasingly complex card sequences
- **Multiple Difficulty Levels**: Easy, Medium, and Hard modes with different timing
- **Progressive Difficulty**: Patterns get longer and faster as you advance levels
- **Lives System**: Start with 3 lives, lose one for each incorrect pattern
- **Scoring System**: Points based on difficulty, speed, and level reached
- **Christmas Theme**: 18 unique Christmas-themed card images with festive backgrounds

### Technical Features
- **MVVM Architecture**: Clean separation of Model, View, and ViewModel components
- **Persistent Storage**: High scores and saved games persist between app sessions
- **Navigation System**: Multiple screens with smooth transitions
- **Auto-Save**: Games automatically save and can be continued later
- **High Score Leaderboard**: Top 10 scores with player names and dates
- **Visual Feedback**: Card animations, timer bars, and interactive elements
- **Responsive Design**: Adapts to different device sizes

### User Interface
- **Custom App Icon**: Christmas-themed icon matching the game aesthetic
- **Animated Cards**: Scale and pulse animations for card interactions
- **Progress Visualization**: Timer bar with color-coded urgency indicators
- **Christmas Background**: Festive background image with adjustable opacity
- **Intuitive Controls**: Simple tap-to-play mechanics with clear visual cues

## How to Play

### Getting Started
1. Launch the app and select your difficulty level
2. Watch the pattern sequence as cards light up
3. Tap the cards in the exact same order
4. Complete the pattern to advance to the next level
5. Try to achieve the highest score possible!

### Game Rules
- **Easy Mode**: Slow patterns, 30 seconds per turn
- **Medium Mode**: Moderate speed, 25 seconds per turn  
- **Hard Mode**: Fast patterns, 20 seconds per turn
- **Lives**: Start with 3 lives, lose 1 per incorrect pattern
- **Scoring**: Higher scores for faster completion and higher levels
- **High Scores**: Top 10 scores are saved to the leaderboard

### Additional Features
- **Continue Game**: Unfinished games can be resumed from the main menu
- **Instructions**: Detailed gameplay guide available in-app
- **High Scores**: View the top 10 scores with player names and dates
- **Reset Option**: Clear all high scores if desired

## Technical Implementation

### Architecture
- **MVVM Pattern**: Clear separation of concerns across three layers:
  - **Model**: `PatternModel`, `CardModel`, `GameSession`, `HighScore`
  - **View**: `StartView`, `GameView`, `HighScoresView`, `InstructionsView`
  - **ViewModel**: `PatternGameViewModel` - Manages game state and logic

### Persistent Storage
- **Storage Manager**: `StorageManager.swift` handles all data persistence
- **UserDefaults**: Uses JSON encoding/decoding with `Codable` protocol
- **Data Types Saved**:
  - High scores (top 10 with player names, dates, and difficulty)
  - Game sessions (for continue game functionality)
- **Auto-Save**: Triggers when app moves to background

### Navigation System
- **SwiftUI Navigation**: Uses `NavigationView` and `NavigationLink`
- **Multiple Screens**:
  - Start screen with difficulty selection
  - Game screen with live gameplay
  - High scores leaderboard
  - Instructions screen
  - Game over screen with score submission

### Game Logic
- **Pattern Generation**: Random sequences based on difficulty and level
- **Timing System**: Display speed and time limits scale with progression
- **State Management**: `GameState` enum tracks current game phase
- **Score Calculation**: Formula based on difficulty, speed, and level
- **Input Validation**: Compares player input against generated patterns

### UI Components
- **Custom Card Views**: `ChristmasCardView` with tap animations
- **Progress Indicators**: Timer bar with color transitions
- **Grid Layout**: 3x3 card grid using `LazyVGrid`
- **Button Styles**: Custom `GameButtonStyle` for consistent interaction
- **Background System**: Layered ZStack with semi-transparent overlays

## Setup Instructions

### Requirements
- **Xcode**: 15.0 or higher
- **iOS**: 17.0 or higher
- **Device**: iPhone or iPad simulator/device

### Installation
1. Clone or download the project files
2. Open `FinalProject.xcodeproj` in Xcode
3. Build and run the project (⌘R)
4. The app will launch in the selected simulator or connected device

### Asset Requirements
- **Card Images**: 18 Christmas-themed images named `christmas1.jpg` through `christmas18.jpg`
- **Background**: `christmas-background.jpg` for the main background
- **App Icon**: Set through Xcode's Assets catalog

## Demo Video
[![Watch the demo video](https://img.youtube.com/vi/JgFX4Tx0uvI/0.jpg)](https://youtube.com/watch?v=JgFX4Tx0uvI)

## Image Credits
- **Christmas Card Images**: Custom Christmas-themed illustrations/stock images
- **Background Pattern**: Christmas-themed background image
- **App Icon**: Custom designed Christmas tree icon
- **SF Symbols**: Apple's SF Symbols for interface icons
