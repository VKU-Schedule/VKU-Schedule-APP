# Design Document - VKU Schedule App

## Overview

VKU Schedule is a Flutter mobile application that provides an intuitive interface for students to optimize their university course schedules. The app follows a client-server architecture where the mobile client handles user interaction, data presentation, and local persistence, while a backend server performs the heavy computational tasks of NLP processing and NSGA-II optimization.

### Key Design Principles

1. **Modern & Clean UI**: Minimalist design with subtle colors, avoiding visual clutter
2. **Vietnamese-First**: All UI text, messages, and content in Vietnamese language
3. **Offline-Capable**: Local storage for schedules and user data
4. **Responsive**: Smooth interactions with loading states and error handling
5. **Feature-First Architecture**: Organized by features for maintainability

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────┐
│         Flutter Mobile App              │
│  (Android SDK 23+ / iOS 13+)           │
│                                         │
│  ┌──────────────────────────────────┐  │
│  │   Presentation Layer             │  │
│  │   (UI Screens & Widgets)         │  │
│  └──────────────────────────────────┘  │
│              ↕                          │
│  ┌──────────────────────────────────┐  │
│  │   State Management               │  │
│  │   (Riverpod Providers)           │  │
│  └──────────────────────────────────┘  │
│              ↕                          │
│  ┌──────────────────────────────────┐  │
│  │   Data Layer                     │  │
│  │   (Repositories & Services)      │  │
│  └──────────────────────────────────┘  │
│              ↕                          │
│  ┌──────────────────────────────────┐  │
│  │   Local Storage (Hive)           │  │
│  └──────────────────────────────────┘  │
└─────────────────────────────────────────┘
              ↕ HTTP/REST
┌─────────────────────────────────────────┐
│         Backend Server                  │
│   (NSGA-II + ViT5 NLP)                 │
└─────────────────────────────────────────┘
              ↕ OAuth2
┌─────────────────────────────────────────┐
│      Google Services                    │
│   (Authentication & Calendar)           │
└─────────────────────────────────────────┘
```

