# QueueLess  Smart Virtual Queue Management System

Flutter prototype for a virtual queue app (Riphah Institute of System Engineering / MS Data Sciences project).

## Roles

| Role        | What you can do                                      |
|-------------|------------------------------------------------------|
| **User**    | Join a department queue, see ticket #, people ahead, estimated wait, cancel ticket |
| **Management** | Select a department, view waiting list, Call Next, Serve, Skip |
| **Admin**   | Overview of all departments + waiting counts + served count + average service time |

## Current status (no backend yet)

- All data is kept **in memory** (`QueueService`).
- Closing the app resets everything.
- Firebase / real database will be added later.

## How to run

```bash
flutter pub get
flutter run
```

## Project structure

```
lib/
  main.dart
  models/
    department.dart
    ticket.dart
  services/
    queue_service.dart      # in-memory queue logic
  screens/
    login_screen.dart       # 3-role login with fade/slide animations
    user_home_screen.dart
    staff_home_screen.dart
    admin_home_screen.dart
```

## Login animations

- Fade + slide entrance on the login screen
- Loading buffer (CircularProgressIndicator) when choosing a role
- Fade page transition into the selected role home

## Next steps (planned)

- Firebase Auth + Firestore for real multi-device queues
- Push notifications when ticket is called
- QR check-in
- Better admin analytics
