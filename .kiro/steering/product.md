# Product Overview

VKU Schedule is a cross-platform Flutter app (Android/iOS/Web) for optimizing university course schedules at VKU (Vietnam-Korea University of Information and Communication Technology).

## Core Purpose

The app uses NSGA-II (Non-dominated Sorting Genetic Algorithm II) multi-objective optimization to generate optimal weekly timetables based on student preferences and constraints.

## Key Features

- Authentication with email/password and SSO placeholder
- Semester and subject selection with search
- Natural language preference input (Vietnamese NLP)
- Weight configuration for 6 optimization criteria (Teacher, Class Group, Day, Consecutive, Rest, Room)
- NSGA-II optimization generating multiple schedule options
- Schedule comparison (2-3 options with highlighted differences)
- Weekly timetable view (Monday-Sunday grid)
- Local storage and Google Calendar sync (skeleton)
- Settings and profile management

## Current State

This is a prototype using mock data. Real API integration is pending for:
- NLP service (ViT5 model)
- Course data from server
- Authentication backend
- Google Calendar OAuth2

## Branding

- Primary colors: VKU Green (#074B2A), VKU Orange (#FFA000)
- Vietnamese language support with Roboto/Noto Sans fonts
- Material Design with custom VKU theme
