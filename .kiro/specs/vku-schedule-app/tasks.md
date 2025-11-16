# Implementation Plan - VKU Schedule App

## Task List

- [ ] 1. Setup project structure and dependencies
  - Create Flutter project with proper package name
  - Add all required dependencies to pubspec.yaml (riverpod, dio, hive, google_sign_in, googleapis, go_router, intl)
  - Configure analysis_options.yaml with linting rules
  - Create feature-first directory structure (features/, core/, models/, services/, data/)
  - _Requirements: 13.1, 13.2_

- [ ] 2. Implement core theme and design system
  - Create VKU color palette constants (VKU Green #074B2A, VKU Orange #FFA000)
  - Define typography styles for Vietnamese text (Roboto, Noto Sans)
  - Implement spacing system (8dp base unit)
  - Create reusable component styles (cards, buttons, inputs)
  - _Requirements: 16.1, 16.2, 16.3, 16.4, 15.5_

- [x] 3. Create data models with JSON serialization
- [x] 3.1 Implement Subject model
  - Create Subject class with courseName and subTopic fields
  - Add fromJson and toJson methods
  - _Requirements: 2.5_

- [x] 3.2 Implement Session model
  - Create Session class with all fields (courseName, teacher, day, periods, room, area, classIndex, classSize, language, field, subTopic)
  - Add fromJson method to parse API response
  - _Requirements: 5.3_

- [x] 3.3 Implement ScheduleOption and related models
  - Create ScheduleEntry class
  - Create ScheduleOption class with schedule array and score
  - Implement fromJson parsing for nested structure
  - Add id generation for local identification
  - _Requirements: 5.1, 5.2, 6.2_

- [x] 3.4 Implement API request/response models
  - Create OptimizationRequest model with queries and prompt
  - Create OptimizationResponse model with message and schedules
  - Add toJson for requests and fromJson for responses
  - _Requirements: 4.2_

- [x] 4. Setup local storage with Hive
- [x] 4.1 Create Hive models with type adapters
  - Create UserProfile HiveObject with name, email, studentId, photoUrl
  - Create SavedSchedule HiveObject with id, scheduleJson, savedAt, isActive
  - Create AppSettings HiveObject with hasCompletedOnboarding, themeMode, notificationsEnabled
  - Generate Hive type adapters using build_runner
  - _Requirements: 9.2, 9.3, 11.2_

- [x] 4.2 Implement LocalStorageService
  - Initialize Hive boxes on app startup
  - Implement saveSchedule and getSavedSchedules methods
  - Implement saveUserProfile and getUserProfile methods
  - Implement saveSettings and getSettings methods
  - Add error handling for storage operations
  - _Requirements: 9.1, 9.3, 9.5_

- [-] 5. Implement authentication with Google Sign-In
- [ ] 5.1 Configure Google Sign-In for Android and iOS
  - Add google-services.json for Android
  - Add GoogleService-Info.plist for iOS
  - Configure OAuth client IDs
  - _Requirements: 1.1_

- [x] 5.2 Create AuthService
  - Implement signInWithGoogle method using google_sign_in package
  - Implement signOut method
  - Implement getAuthToken method to retrieve current token
  - Create authStateChanges stream for reactive auth state
  - Store auth token securely in local storage
  - _Requirements: 1.2, 1.4, 1.5_

- [x] 5.3 Create auth Riverpod providers
  - Create authServiceProvider
  - Create authStateProvider (StreamProvider)
  - Create currentUserProvider
  - _Requirements: 1.1, 1.2_


- [x] 6. Implement API service with Dio
- [x] 6.1 Create Dio client with interceptors
  - Configure base URL for backend server
  - Add auth token interceptor to inject token in headers
  - Add logging interceptor for debugging
  - Configure timeout (60s for optimization, 10s for search)
  - Enable gzip compression
  - _Requirements: 4.4, 4.5_

- [x] 6.2 Implement ApiService
  - Create searchSubjects method calling POST /search-recommend
  - Create optimizeSchedule method calling POST /api/convert
  - Implement error handling and mapping to Vietnamese messages
  - Add retry logic for network failures
  - _Requirements: 2.2, 4.3, 14.2_

- [x] 6.3 Create API Riverpod providers
  - Create apiServiceProvider
  - Create searchResultsProvider (FutureProvider)
  - Create submitOptimizationProvider (FutureProvider.family)
  - _Requirements: 4.1, 5.1_

- [x] 7. Setup navigation with GoRouter
  - Define route paths for all screens
  - Implement route guards for authentication
  - Configure initial route based on auth state and onboarding status
  - Add navigation transitions
  - _Requirements: 12.1, 12.3_

- [x] 8. Implement login screen
  - Create login UI with VKU logo and welcome message in Vietnamese
  - Add Google Sign-In button with proper styling
  - Show loading indicator during authentication
  - Handle auth errors and display Vietnamese error messages
  - Navigate to onboarding or home after successful login
  - _Requirements: 1.1, 1.2, 1.3, 15.1, 15.2_


- [x] 9. Implement onboarding screens
  - Create 3-4 onboarding slides with Vietnamese text and illustrations
  - Add skip and next navigation buttons
  - Implement page indicator dots
  - Save onboarding completion status to local storage
  - Navigate to subject search after completion
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 15.3_

- [ ] 10. Implement subject search and selection feature
- [ ] 10.1 Create subject search UI
  - Create app bar with Vietnamese title "Chọn môn học"
  - Add search input field with placeholder "Tìm kiếm môn học..."
  - Implement debounced search (300ms delay)
  - Display search results list with course name and sub_topic
  - Show loading indicator while searching
  - Display "Không tìm thấy kết quả" for empty results
  - _Requirements: 2.1, 2.2, 15.1_

- [ ] 10.2 Implement subject selection logic
  - Create selectedSubjectsProvider (StateNotifierProvider)
  - Add subjects to selected list on tap
  - Display selected subjects as removable chips
  - Implement remove subject functionality
  - Enable continue button when at least one subject selected
  - _Requirements: 2.3, 2.4, 14.1_

- [ ] 11. Implement preference input screen
  - Create app bar with Vietnamese title "Sở thích của bạn"
  - Add multi-line text input (4-6 lines)
  - Display Vietnamese placeholder examples
  - Create preferenceTextProvider (StateProvider)
  - Add submit button "Tối ưu hóa lịch" that triggers optimization
  - Validate inputs before submission
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 15.1_


- [ ] 12. Implement optimization request and loading
- [ ] 12.1 Create optimization submission logic
  - Construct OptimizationRequest with queries array and prompt string
  - Call ApiService.optimizeSchedule with request payload
  - Include auth token in request headers
  - Handle 60-second timeout
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [ ] 12.2 Create loading screen
  - Display circular progress indicator
  - Show Vietnamese status text "Đang tối ưu hóa lịch học của bạn..."
  - Add subtext "Vui lòng đợi trong giây lát"
  - Handle timeout and display error message
  - _Requirements: 14.3, 15.2_

- [ ] 12.3 Handle optimization response
  - Parse OptimizationResponse with message and schedules array
  - Extract schedule options with sessions and scores
  - Store schedules in scheduleOptionsProvider
  - Save schedules to local storage for offline access
  - Navigate to schedule options list on success
  - Display Vietnamese error message on failure
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 9.1_

- [ ] 13. Implement schedule options list screen
- [ ] 13.1 Create schedule list UI
  - Create app bar with Vietnamese title "Phương án lịch học"
  - Display list of schedule option cards
  - Show option number, score badge, and summary info
  - Add favorite icon (star) for each option
  - Add compare checkbox for each option
  - Enable compare button when 2-3 options selected
  - _Requirements: 6.1, 6.2, 6.4, 15.1_

- [ ] 13.2 Implement schedule list interactions
  - Navigate to detail view on card tap
  - Toggle favorite status on star icon tap
  - Manage comparison selection (max 3 options)
  - Sort schedules by score in descending order
  - _Requirements: 6.3, 6.5, 7.2_


- [ ] 14. Implement weekly timetable view
- [ ] 14.1 Create weekly grid component
  - Create grid layout with columns for Thứ Hai through Chủ Nhật
  - Create rows for time slots (Tiết 1-12)
  - Implement responsive grid sizing
  - Add day headers in Vietnamese
  - Add time slot labels
  - _Requirements: 8.1, 15.4_

- [ ] 14.2 Render session cards in grid
  - Position sessions based on day and periods array
  - Create session card widget with modern, minimalist design
  - Display course name, teacher, room, and periods on card
  - Apply subtle subject colors from design system
  - Add left border with subject color
  - Handle multi-period sessions (spanning multiple rows)
  - _Requirements: 8.2, 8.4, 8.5, 16.3, 16.4_

- [ ] 14.3 Implement session detail modal
  - Create bottom sheet or dialog for session details
  - Display all session data in Vietnamese labels
  - Show course_name, teacher, room, day, periods, area, class_index, class_size, language, field, sub_topic
  - Add close button
  - _Requirements: 8.3, 15.1_

- [ ] 14.4 Add schedule actions
  - Add save schedule button
  - Add sync to Google Calendar button
  - Add share functionality
  - Implement save to local storage
  - _Requirements: 9.1, 10.1_

- [ ] 15. Implement schedule comparison screen
  - Create horizontal scrollable view for 2-3 schedules
  - Display simplified weekly grid for each schedule
  - Highlight differences between schedules (different time slots, teachers, rooms)
  - Use modern, clean design with subtle colors
  - Add select button for each option
  - Save selected option as active schedule
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_


- [ ] 16. Implement Google Calendar synchronization
- [ ] 16.1 Setup Google Calendar API
  - Configure googleapis and googleapis_auth packages
  - Setup OAuth2 scopes for Calendar API
  - Use existing Google auth token from login
  - _Requirements: 10.1_

- [ ] 16.2 Create CalendarSyncService
  - Implement syncScheduleToCalendar method
  - Create calendar events for each session
  - Set event title with subject name
  - Set event location with room information
  - Set event time based on day and periods
  - Handle sync errors gracefully
  - _Requirements: 10.2, 10.3, 10.4_

- [ ] 16.3 Integrate calendar sync in UI
  - Add sync button in schedule detail screen
  - Show loading indicator during sync
  - Display Vietnamese confirmation message on success
  - Display Vietnamese error message on failure
  - _Requirements: 10.5, 14.2, 15.2_

- [ ] 17. Implement settings and profile screen
- [ ] 17.1 Create settings UI
  - Create app bar with Vietnamese title "Cài đặt"
  - Add profile section with avatar, name, email
  - Add editable student ID field
  - Add settings sections (theme, notifications, onboarding)
  - Add about section
  - Add logout button at bottom
  - _Requirements: 11.1, 11.3, 15.1_

- [ ] 17.2 Implement settings functionality
  - Create userProfileProvider and appSettingsProvider
  - Implement profile update with validation
  - Save changes to local storage
  - Apply settings changes immediately without restart
  - Implement logout that clears tokens and navigates to login
  - Add option to view onboarding again
  - _Requirements: 11.2, 11.4, 11.5, 12.5_


- [ ] 18. Implement error handling and user feedback
  - Create error message mapping for all error types (network, API, validation, auth)
  - Implement Vietnamese error messages for all scenarios
  - Add retry buttons for recoverable errors
  - Show loading indicators for all async operations
  - Display confirmation messages for successful actions
  - Implement error logging without exposing details to users
  - _Requirements: 14.1, 14.2, 14.3, 14.4, 14.5, 15.2_

- [ ] 19. Implement Vietnamese localization
  - Create Vietnamese string constants for all UI text
  - Implement date/time formatting with Vietnamese locale
  - Use intl package for proper localization
  - Ensure all labels, buttons, messages are in Vietnamese
  - Configure Vietnamese fonts (Roboto, Noto Sans)
  - _Requirements: 15.1, 15.2, 15.3, 15.4, 15.5_

- [ ] 20. Implement responsive design and accessibility
  - Ensure minimum touch target size of 48x48dp
  - Verify color contrast ratios (WCAG AA)
  - Add semantic labels for screen readers
  - Support portrait and landscape orientations
  - Adapt layouts for different screen sizes
  - Test on various Android and iOS devices
  - _Requirements: 13.3, 13.4, 13.5, 16.5_

- [ ] 21. Polish UI with modern design system
  - Apply consistent spacing using 8dp base unit
  - Add subtle shadows and rounded corners to components
  - Implement smooth transitions and animations
  - Ensure VKU Green and Orange are used appropriately as accents
  - Avoid excessive bright colors, maintain clean appearance
  - Review all screens for design consistency
  - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.5_


- [ ] 22. Performance optimization
  - Implement lazy loading for schedule details
  - Add caching for API responses
  - Implement debouncing for search input (300ms)
  - Optimize image loading and caching
  - Properly dispose controllers and cancel subscriptions
  - Set max size for Hive boxes
  - Test app performance and memory usage
  - _Requirements: 9.3, 2.2_

- [ ] 23. Security implementation
  - Store auth tokens using flutter_secure_storage
  - Implement token refresh mechanism
  - Clear all tokens on logout
  - Use HTTPS only for API calls
  - Validate SSL certificates
  - Sanitize user input before API calls
  - Encrypt sensitive data in Hive
  - _Requirements: 1.4, 1.5, 9.4, 11.5_

- [ ]* 24. Write integration tests
  - Test complete authentication flow
  - Test subject search and selection flow
  - Test optimization request and response handling
  - Test schedule display and navigation
  - Test comparison feature
  - Test offline mode with cached data
  - Test error scenarios
  - _Requirements: All_

- [ ] 25. Platform-specific configuration
  - Configure Android minimum SDK 23 and target SDK
  - Configure iOS minimum version 13.0
  - Setup ProGuard rules for Android release
  - Configure app signing for both platforms
  - Add app icons and splash screens
  - Configure app permissions (internet, calendar)
  - _Requirements: 13.1, 13.2_

- [ ] 26. Final testing and polish
  - Test on physical Android devices (SDK 23+)
  - Test on physical iOS devices (13.0+)
  - Verify all Vietnamese text and localization
  - Test Google Sign-In on both platforms
  - Test Google Calendar sync
  - Verify error handling for all edge cases
  - Check performance and memory usage
  - Review UI consistency and design
  - _Requirements: All_

