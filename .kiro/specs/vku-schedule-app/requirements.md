# Requirements Document - VKU Schedule App

## Introduction

VKU Schedule is a mobile application (Android/iOS) designed to optimize university course schedules for students at Vietnam-Korea University of Information and Communication Technology (VKU). Students select their desired subjects and express scheduling preferences in natural Vietnamese language. The mobile app sends this information to a Backend Server which employs NSGA-II (Non-dominated Sorting Genetic Algorithm II) optimization and ViT5 NLP model to generate approximately 5 personalized schedule options. The application features a modern, clean design aesthetic and provides an intuitive interface for viewing and comparing schedule options.

## Glossary

- **VKU Schedule System**: The Flutter mobile application for Android and iOS platforms
- **Backend Server**: The server-side system that processes optimization requests using NSGA-II and ViT5 NLP model
- **Schedule Option**: A single generated timetable solution representing one possible arrangement of courses
- **Session**: A specific class meeting time for a subject (e.g., Monday 7:00-9:00 AM)
- **Subject**: A university course that a student can enroll in
- **Preference Text**: User-defined scheduling preferences expressed in natural Vietnamese language
- **Weekly Grid**: The calendar view displaying Monday through Sunday with time slots
- **Optimization Request**: The API call containing a JSON payload with "queries" (array of subject names) and "prompt" (preference text) sent to the Backend Server
- **Optimization Response**: The API response containing "message", "schedules" array with schedule options, each having a "schedule" array of sessions and a "score"
- **Session Data**: Contains course_name, teacher, day, periods (array of time slots), room, area, class_index, class_size, language, field, and sub_topic

## Requirements

### Requirement 1: Google Authentication

**User Story:** As a VKU student, I want to log into the application using my Google account, so that I can quickly access the app without creating separate credentials.

#### Acceptance Criteria

1. WHEN a user taps the Google Sign-In button, THE VKU Schedule System SHALL initiate the Google OAuth2 authentication flow
2. WHEN Google authentication succeeds, THE VKU Schedule System SHALL receive and store the authentication token securely in local storage
3. WHEN Google authentication fails, THE VKU Schedule System SHALL display an error message and allow the user to retry
4. THE VKU Schedule System SHALL include the authentication token in all API requests to the Backend Server
5. WHEN a user's authentication token expires, THE VKU Schedule System SHALL prompt the user to re-authenticate with Google

### Requirement 2: Subject Search and Selection

**User Story:** As a student, I want to search for subjects by name and select them, so that I can quickly specify which courses need to be scheduled.

#### Acceptance Criteria

1. THE VKU Schedule System SHALL provide a search input field for finding subjects by name
2. WHEN a user types in the search field, THE VKU Schedule System SHALL filter and display matching subjects in real-time
3. THE VKU Schedule System SHALL display search results showing subject name, code, and basic information
4. WHEN a user selects a subject from search results, THE VKU Schedule System SHALL add it to the selected subjects list
5. THE VKU Schedule System SHALL allow users to remove previously selected subjects from their collection

### Requirement 3: Natural Language Preference Input

**User Story:** As a student, I want to express my scheduling preferences in natural Vietnamese language, so that I can easily communicate my constraints without using technical terminology.

#### Acceptance Criteria

1. THE VKU Schedule System SHALL provide a text input field for users to enter scheduling preferences in Vietnamese
2. THE VKU Schedule System SHALL allow multi-line text input to accommodate detailed preference descriptions
3. THE VKU Schedule System SHALL validate that preference text is not empty before allowing submission
4. THE VKU Schedule System SHALL display example preference statements to guide users on input format
5. THE VKU Schedule System SHALL store the preference text for inclusion in the optimization request to the Backend Server

### Requirement 4: Optimization Request Submission

**User Story:** As a student, I want to submit my selected subjects and preferences to get personalized schedule options, so that I can find the best timetable arrangement.

#### Acceptance Criteria

1. WHEN a user has selected subjects and entered preference text, THE VKU Schedule System SHALL enable the optimization submission button
2. WHEN a user submits an optimization request, THE VKU Schedule System SHALL construct a JSON payload with "queries" array containing selected subject names and "prompt" string containing preference text
3. THE VKU Schedule System SHALL send the JSON payload to the Backend Server via HTTP POST request with authentication token in headers
4. WHILE waiting for the Backend Server response, THE VKU Schedule System SHALL display a loading indicator with progress message
5. WHEN the optimization request times out after 60 seconds, THE VKU Schedule System SHALL display an error message and provide a retry option

### Requirement 5: Schedule Options Reception

**User Story:** As a student, I want to receive multiple optimized schedule options from the server, so that I can choose the best timetable for my needs.

#### Acceptance Criteria

1. WHEN the Backend Server returns an optimization response, THE VKU Schedule System SHALL parse the JSON response containing "message" and "schedules" array
2. THE VKU Schedule System SHALL extract each schedule option from the "schedules" array, including the "schedule" sessions array and "score" value
3. THE VKU Schedule System SHALL parse session data including course_name, teacher, day, periods, room, area, class_index, class_size, language, field, and sub_topic
4. THE VKU Schedule System SHALL store the received schedule options in local storage for offline access
5. WHEN the Backend Server returns an error response or empty schedules array, THE VKU Schedule System SHALL display an appropriate error message in Vietnamese

### Requirement 6: Schedule Options Display and Navigation

**User Story:** As a student, I want to view all generated schedule options in a list, so that I can browse through different timetable arrangements.

#### Acceptance Criteria

1. WHEN optimization completes successfully, THE VKU Schedule System SHALL display a list of all generated schedule options
2. THE VKU Schedule System SHALL show summary information for each schedule option including total sessions, free days, and optimization score
3. WHEN a user selects a schedule option from the list, THE VKU Schedule System SHALL navigate to the detailed view of that option
4. THE VKU Schedule System SHALL allow users to mark schedule options as favorites for quick access
5. THE VKU Schedule System SHALL sort schedule options by optimization score in descending order by default

### Requirement 7: Schedule Comparison

**User Story:** As a student, I want to compare 2-3 schedule options side by side with differences highlighted, so that I can easily identify which option best meets my needs.

#### Acceptance Criteria

1. WHEN a user selects multiple schedule options for comparison, THE VKU Schedule System SHALL display them in a side-by-side comparison view
2. THE VKU Schedule System SHALL limit comparison to a maximum of 3 schedule options simultaneously
3. THE VKU Schedule System SHALL highlight differences between schedules including different time slots, teachers, and rooms
4. THE VKU Schedule System SHALL use a modern, clean visual design with subtle colors to differentiate schedules without being overly colorful
5. WHEN a user selects a preferred option from the comparison view, THE VKU Schedule System SHALL allow saving that option as the active schedule

### Requirement 8: Weekly Timetable View

**User Story:** As a student, I want to view my selected schedule in a weekly calendar grid format, so that I can see my classes arranged by day and time.

#### Acceptance Criteria

1. THE VKU Schedule System SHALL display the Weekly Grid with columns for Monday (Thứ Hai) through Sunday (Chủ Nhật)
2. THE VKU Schedule System SHALL render each session as a card showing course_name, teacher, room, and periods using a modern, minimalist design
3. WHEN a user taps on a session card, THE VKU Schedule System SHALL display detailed information including all session data (area, class_index, class_size, language, field, sub_topic)
4. THE VKU Schedule System SHALL position sessions in the grid based on the "day" and "periods" array from session data
5. THE VKU Schedule System SHALL use subtle, distinct colors to differentiate between different subjects without creating a visually overwhelming interface

### Requirement 9: Local Data Persistence

**User Story:** As a student, I want my selected subjects, preferences, and saved schedules to be stored locally on my device, so that I can access them without an internet connection.

#### Acceptance Criteria

1. WHEN a user saves a schedule, THE VKU Schedule System SHALL store the schedule data in the local Hive database
2. THE VKU Schedule System SHALL persist user preferences and weight configurations in local storage
3. WHEN the application restarts, THE VKU Schedule System SHALL load previously saved data from local storage
4. THE VKU Schedule System SHALL store authentication tokens in secure local storage
5. WHEN a user clears application data, THE VKU Schedule System SHALL remove all locally stored information

### Requirement 10: Google Calendar Synchronization

**User Story:** As a student, I want to sync my optimized schedule to Google Calendar, so that I can access my timetable across all my devices and receive calendar notifications.

#### Acceptance Criteria

1. WHEN a user initiates Google Calendar sync, THE VKU Schedule System SHALL use the existing Google authentication token from login
2. WHEN sync is initiated, THE VKU Schedule System SHALL create calendar events for each session in the selected schedule using Google Calendar API
3. THE VKU Schedule System SHALL set event titles to include subject name and session type
4. THE VKU Schedule System SHALL set event locations to the room information from each session
5. WHEN calendar sync completes successfully, THE VKU Schedule System SHALL display a confirmation message to the user

### Requirement 11: Settings and Profile Management

**User Story:** As a student, I want to manage my profile information and application settings, so that I can customize the app experience and update my personal details.

#### Acceptance Criteria

1. THE VKU Schedule System SHALL display user profile information including name, email, and student ID
2. WHEN a user updates profile information, THE VKU Schedule System SHALL validate the input and save changes to local storage
3. THE VKU Schedule System SHALL provide settings for language preference, notification preferences, and theme selection
4. WHEN a user changes application settings, THE VKU Schedule System SHALL apply the changes immediately without requiring app restart
5. THE VKU Schedule System SHALL provide a logout option that clears authentication tokens and returns to the login screen

### Requirement 12: Onboarding Experience

**User Story:** As a first-time user, I want to see an introduction to the app's features and how to use them, so that I can quickly understand how to optimize my schedule.

#### Acceptance Criteria

1. WHEN a user opens the application for the first time, THE VKU Schedule System SHALL display the onboarding flow with a modern, clean design
2. THE VKU Schedule System SHALL present onboarding screens explaining subject selection, preference input, and schedule viewing
3. WHEN a user completes the onboarding flow, THE VKU Schedule System SHALL mark onboarding as completed in local storage
4. THE VKU Schedule System SHALL provide a skip option allowing users to bypass onboarding screens
5. THE VKU Schedule System SHALL allow users to access onboarding screens again from the settings menu

### Requirement 13: Mobile Platform Compatibility

**User Story:** As a student, I want to use the application on my Android or iOS smartphone, so that I can access my schedule optimization on the go.

#### Acceptance Criteria

1. THE VKU Schedule System SHALL run on Android devices with minimum SDK version 23
2. THE VKU Schedule System SHALL run on iOS devices with minimum version 13.0
3. THE VKU Schedule System SHALL adapt the user interface layout responsively for different screen sizes and orientations
4. THE VKU Schedule System SHALL maintain consistent functionality across both Android and iOS platforms
5. THE VKU Schedule System SHALL use a modern, clean design aesthetic with appropriate spacing and typography for mobile devices

### Requirement 14: Error Handling and User Feedback

**User Story:** As a student, I want to receive clear error messages and feedback when something goes wrong, so that I understand what happened and how to resolve issues.

#### Acceptance Criteria

1. WHEN an error occurs during any operation, THE VKU Schedule System SHALL display a user-friendly error message in Vietnamese
2. WHEN a network request fails, THE VKU Schedule System SHALL inform the user and provide a retry option
3. WHILE the system is processing a long-running operation, THE VKU Schedule System SHALL display a loading indicator with progress information
4. WHEN a user action completes successfully, THE VKU Schedule System SHALL display a confirmation message
5. THE VKU Schedule System SHALL log error details for debugging purposes without exposing technical information to users

### Requirement 15: Vietnamese Language Interface

**User Story:** As a Vietnamese student, I want the entire application interface to be in Vietnamese, so that I can easily understand and use all features.

#### Acceptance Criteria

1. THE VKU Schedule System SHALL display all user interface text, labels, and buttons in Vietnamese language
2. THE VKU Schedule System SHALL display all error messages and notifications in Vietnamese
3. THE VKU Schedule System SHALL use Vietnamese for all onboarding content and help text
4. THE VKU Schedule System SHALL format dates and times according to Vietnamese locale conventions
5. THE VKU Schedule System SHALL use appropriate Vietnamese fonts (Roboto, Noto Sans) for optimal readability

### Requirement 16: Modern UI Design System

**User Story:** As a student, I want the application to have a modern, clean visual design, so that I enjoy using it and can easily navigate the interface.

#### Acceptance Criteria

1. THE VKU Schedule System SHALL use a modern color palette with VKU Green and VKU Orange as accent colors
2. THE VKU Schedule System SHALL apply consistent spacing, typography, and component styling throughout the application
3. THE VKU Schedule System SHALL use subtle shadows, rounded corners, and smooth transitions for a contemporary feel
4. THE VKU Schedule System SHALL avoid excessive use of bright colors, maintaining a clean and professional appearance
5. THE VKU Schedule System SHALL ensure sufficient contrast ratios for text and interactive elements to maintain readability
