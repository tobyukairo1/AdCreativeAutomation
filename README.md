# AI-Driven Ad Creative Automation

An iOS app that leverages AI to automate the creation and optimization of advertising creatives across multiple platforms.

## Features

- AI-powered creative generation
- Multi-platform support (Facebook, TikTok)
- Campaign management and performance tracking
- Automated media optimization
- Smart targeting recommendations
- Performance analytics

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+
- OpenAI API Key
- Facebook Marketing API Access
- TikTok Marketing API Access

## Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/AdCreativeAutomation.git
cd AdCreativeAutomation
```

2. Open the project in Xcode
```bash
open AdCreativeAutomation.xcodeproj
```

3. Configure API Keys
- Add your API keys to the keychain using the app's settings
- Ensure you have proper access to the Facebook and TikTok Marketing APIs

4. Build and run the project

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures and business logic
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Services**: Network, AI, and platform-specific operations

## Dependencies

- SwiftUI for UI
- Combine for reactive programming
- OpenAI API for creative generation
- Facebook Marketing API
- TikTok Marketing API

## Configuration

The app uses a Config.plist file for managing:
- API endpoints
- Feature flags
- Platform-specific settings

## Security

- API keys are stored securely in the keychain
- Network requests are encrypted
- User data is handled according to privacy best practices

## License

This project is licensed under the MIT License - see the LICENSE file for details 