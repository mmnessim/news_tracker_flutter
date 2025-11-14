# News Tracker 
[![Codemagic build status](https://api.codemagic.io/apps/6910a0283b17a0cb13d03352/6910a0283b17a0cb13d03351/status_badge.svg)](https://codemagic.io/app/6910a0283b17a0cb13d03352/6910a0283b17a0cb13d03351/latest_build)

A Flutter application for tracking news articles based on user-defined search terms. It fetches the
latest news from NewsAPI and sends notifications at scheduled times.

# Under Construction!

This app is very much a work in progress and many core features are not yet implemented. It is also
a learning project for me in Flutter. Some planned features include:

- Optional user authentication
- Local persistence for users who don't want to make an account
- Refactoring to use RSS feeds instead of NewsAPI
- Notification options for each tracked term
- Rebranding to focus on research instead of general news
- Adding a Go backend to handle RSS, user authentication, and more
- UI/UX improvements
- Tests!

## Features

- Add and manage search terms for news tracking
- Fetch and display news articles from NewsAPI
- Schedule daily notifications for new results
- View article details in a web browser
- Persistent storage of search terms and notification preferences

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/mmnessim/news_tracker_flutter.git
   cd news_tracker_flutter
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up environment variables:
    - Create a `.env` file in the root directory
    - Add your NewsAPI key: `API_KEY=your_api_key_here`

4. Run the app:
   ```bash
   flutter run
   ```

## Usage

- Add search terms to track specific news topics
- Set notification time for daily updates
- Tap on articles to view them in your browser
- Long press on search terms to delete them

## Dependencies

- flutter_local_notifications: For scheduling notifications
- http: For API requests
- shared_preferences: For local storage
- flutter_dotenv: For environment variables
- url_launcher: For opening URLs
- intl: For date/time formatting
- timezone: For time zone handling
- permission_handler: For managing permissions

## Development

Run tests:

```bash
flutter test
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

