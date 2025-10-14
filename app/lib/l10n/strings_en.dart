import 'package:bijbelquiz/constants/urls.dart';

class AppStrings {
  // Common
  static const String appName = 'BibleQuiz';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String back = 'Back';
  static const String submit = 'Submit';
  static const String cancel = 'Cancel';
  static const String ok = 'OK';

  // Quiz Screen
  static const String question = 'Question';
  static const String score = 'Score';
  static const String correct = 'Correct!';
  static const String incorrect = 'Incorrect';
  static const String quizComplete = 'Quiz Complete!';
  static const String yourScore = 'Your score: ';
  static const String unlockBiblicalReference = 'Unlock Biblical Reference (Beta)';
  static const String biblicalReference = 'Biblical Reference';
  static const String close = 'Close';

  // Settings
  static const String settings = 'Settings';
  static const String sound = 'Sound';
  static const String notifications = 'Notifications';
  static const String language = 'Language';
  static const String theme = 'Theme';
  static const String darkMode = 'Dark Mode';
  static const String lightMode = 'Light Mode';
  static const String systemDefault = 'System Default';

  // Lessons
  static const String lessons = 'Lessons';
  static const String continueLearning = 'Continue Learning';

  // Store
  static const String store = 'Store';
  static const String unlockAll = 'Unlock All';
  static const String purchaseSuccessful = 'Purchase Successful!';

  // Donation
  static const String donate = 'Support Us';
  static const String donateButton = 'Donate Now';
  static const String donateExplanation = 'Support the development of this app with a donation. This is necessary to further develop/maintain the app.';

  // Guide
  static const String guide = 'Guide';
  static const String howToPlay = 'How to Play';

  // Errors
  static const String connectionError = 'No internet connection';
  static const String connectionErrorMsg = 'Please check your internet connection and try again.';
  static const String unknownError = 'An error has occurred';
  static const String errorNoQuestions = 'No valid questions found';
  static const String errorLoadQuestions = 'Error loading questions';
  static const String couldNotOpenDonationPage = 'Could not open the donation page';

  // Quiz metrics
  static const String streak = 'Streak';
  static const String best = 'Best';
  static const String time = 'Time';
  static const String screenSizeNotSupported = 'Screen size not supported';

  // Time up dialog
  static const String timeUp = 'Time is up!';
  static const String timeUpMessage = 'You did not answer in time. Your streak has been reset.';
  static const String notEnoughPoints = 'Not enough points';

  // Lesson complete screen
  static const String lessonComplete = 'Lesson Complete';
  static const String percentage = 'Percentage';
  static const String bestStreak = 'Best Streak';
  static const String retryLesson = 'Retry Lesson';
  static const String nextLesson = 'Next Lesson';
  static const String backToLessons = 'Back to Lessons';

  // Settings screen
  static const String display = 'Display';
  static const String chooseTheme = 'Choose your theme';
  static const String lightTheme = 'Light';
  static const String systemTheme = 'System';
  static const String darkTheme = 'Dark';
  static const String oledTheme = 'OLED';
  static const String greenTheme = 'Green';
  static const String orangeTheme = 'Orange';
  static const String tryAgain = 'Try Again';
  static const String couldNotOpenStatusPage = 'Could not open the status page.';

  // Lesson select screen
  static const String couldNotLoadLessons = 'Could not load lessons';
  static const String progress = 'Progress';
  static const String resetProgress = 'Reset Progress';
  static const String resetProgressConfirmation = 'Are you sure you want to reset your progress? This cannot be undone.';
  static const String confirm = 'Confirm';
  static const String startLesson = 'Start Lesson';
  static const String locked = 'Locked';
  static const String complete = 'Complete';
  static const String perfectScore = 'Perfect Score!';
  static const String retry = 'Retry';

  // Guide screen
  static const String previous = 'Previous';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';
  static const String welcomeTitle = 'Welcome to BibleQuiz';
  static const String welcomeDescription = 'Discover the Bible in a fun and interactive way with challenging questions and lessons.';
  static const String howToPlayTitle = 'How to Play?';
  static const String howToPlayDescription = 'Answer questions about the Bible and earn points. The faster you answer, the more points you earn!';
  static const String notificationsTitle = 'Stay Updated';
  static const String notificationsDescription = 'Receive reminders and challenges to improve your Bible knowledge.';
  static const String enableNotifications = 'Enable Notifications';
  static const String notificationsEnabled = 'Notifications Enabled';
  static const String continueText = 'Continue';
  static const String trackProgressTitle = 'Track Your Progress';
  static const String trackProgressDescription = 'Keep track of your scores and improve over time.';
  static const String customizeExperienceTitle = 'Customize Your Experience';
  static final String customizeExperienceDescription = 'Adjust your theme, game speed, and sound effects in the settings. Do you have any questions or suggestions? We would love to hear from you via ${AppUrls.contactEmail}';
  static const String supportUsDescription = 'Do you find this app useful? Please consider a donation to help us maintain and improve the app. Every contribution is appreciated!';
  static const String donateNow = 'Donate Now';

  // Activation screen
  static const String activationTitle = 'Activate your account';
  static const String activationSubtitle = 'Enter your activation code to use the app';
  static const String activationCodeHint = 'Enter your activation code';
  static const String activateButton = 'Activate';
  static const String verifyButton = 'Verify';
  static const String verifying = 'Verifying...';
  static const String activationTip = 'Enter the activation code you received upon purchase.';
  static const String activationSuccess = 'Successfully activated!';
  static const String activationError = 'Invalid activation code. Please try again.';
  static const String activationErrorTitle = 'Activation failed';
  static const String activationSuccessMessage = 'Your account has been successfully activated. Enjoy the app!';
  static const String activationRequired = 'Activation required';
  static const String activationRequiredMessage = 'You must activate the app before you can use it.';

  // Store screen
  static const String yourStars = 'Your Stars';
  static const String availableStars = 'Available Stars';
  static const String powerUps = 'Power-ups';
  static const String themes = 'Themes';
  static const String availableThemes = 'Available Themes';
  static const String unlockTheme = 'Unlock Theme';
  static const String unlocked = 'Unlocked';
  static const String notEnoughStars = 'Not enough stars';
  static const String unlockFor = 'Unlock for';
  static const String stars = 'stars';
  static const String free = 'Free';
  static const String purchased = 'Purchased';
  static const String confirmPurchase = 'Confirm Purchase';
  static const String purchaseConfirmation = 'Are you sure you want to unlock this theme for';
  static const String purchaseSuccess = 'Theme successfully unlocked!';
  static const String purchaseError = 'Not enough stars to unlock this theme.';
  static const String couldNotOpenDownloadPage = 'Could not open the download page';

  // Power-ups
  static const String doubleStars5Questions = 'Double Stars (5 questions)';
  static const String doubleStars5QuestionsDesc = 'Earn double stars for your next 5 questions';
  static const String tripleStars5Questions = 'Triple Stars (5 questions)';
  static const String tripleStars5QuestionsDesc = 'Earn triple stars for your next 5 questions';
  static const String fiveTimesStars5Questions = '5x Stars (5 questions)';
  static const String fiveTimesStars5QuestionsDesc = 'Earn 5x stars for your next 5 questions';
  static const String doubleStars60Seconds = 'Double Stars (60 seconds)';
  static const String doubleStars60SecondsDesc = 'Earn double stars for 60 seconds';

  // Theme names
  static const String oledThemeName = 'OLED Theme';
  static const String oledThemeDesc = 'Unlock a true black, high-contrast theme';
  static const String greenThemeName = 'Green Theme';
  static const String greenThemeDesc = 'Unlock a fresh green theme';
  static const String orangeThemeName = 'Orange Theme';
  static const String orangeThemeDesc = 'Unlock a vibrant orange theme';

  // Settings screen
  static const String supportUsTitle = 'Support Us';
  static const String errorLoadingSettings = 'Error loading settings';
  static const String gameSettings = 'Game Settings';
  static const String gameSpeed = 'Game Speed';
  static const String chooseGameSpeed = 'Choose the speed of the game';
  static const String slow = 'Slow';
  static const String medium = 'Medium';
  static const String fast = 'Fast';
  static const String muteSoundEffects = 'Mute Sound Effects';
  static const String muteSoundEffectsDesc = 'Turn off all game sounds';
  static const String about = 'About';

  // Server status
  static const String serverStatus = 'Server Status';
  static const String checkServiceStatus = 'Check the status of our services';
  static const String openStatusPage = 'Open Status Page';

  // Notifications
  static const String motivationNotifications = 'Motivation Notifications (Beta)';
  static const String motivationNotificationsDesc = 'Receive daily reminders for BibleQuiz';

  // Actions
  static const String actions = 'Actions';
  static const String exportStats = 'Export Stats';
  static const String exportStatsDesc = 'Save your progress and scores as text';
  static const String importStats = 'Import Stats';
  static const String importStatsDesc = 'Load previously exported stats';
  static const String resetAndLogout = 'Reset and Logout';
  static const String resetAndLogoutDesc = 'Clear all data and deactivate the app';
  static const String showIntroduction = 'Show Introduction';
  static const String reportIssue = 'Report Issue';
  static const String clearQuestionCache = 'Clear Question Cache';
  static const String contactUs = 'Contact Us';
  static const String emailNotAvailable = 'Could not open email client';
  static const String cacheCleared = 'Question cache cleared!';

  // Debug/Test
  static const String testAllFeatures = 'Test All Features';

  // Footer
  static const String copyright = '© 2024-2025 ThomasNow Productions';
  static const String version = 'Version';

  // Social
  static const String social = 'Social';
  static const String comingSoon = 'Coming Soon!';
  static const String socialComingSoonMessage = 'The social features of BibleQuiz are coming soon. Stay tuned for updates!';

  // Bible Bot
  static const String bibleBot = 'Bible Bot';

  // Errors
  static const String couldNotOpenEmail = 'Could not open email client';

  // Popups
  static const String followUs = 'Follow us';
  static const String followUsMessage = 'Follow us on Mastodon, Pixelfed, Kwebler, Signal, Discord, and Bluesky for updates and community!';
  static const String followMastodon = 'Follow Mastodon';
  static const String followPixelfed = 'Follow Pixelfed';
  static const String followKwebler = 'Follow Kwebler';
  static const String followSignal = 'Follow Signal';
  static const String followDiscord = 'Follow Discord';
  static const String followBluesky = 'Follow Bluesky';
  static final String mastodonUrl = AppUrls.mastodonUrl;
  static final String pixelfedUrl = AppUrls.pixelfedUrl;
  static final String kweblerUrl = AppUrls.kweblerUrl;
  static final String signalUrl = AppUrls.signalUrl;
  static final String discordUrl = AppUrls.discordUrl;
  static final String blueskyUrl = AppUrls.blueskyUrl;

  // Satisfaction Survey
  static const String satisfactionSurvey = 'Help us improve';
  static const String satisfactionSurveyMessage = 'Take a few minutes to help us improve the app. Your feedback is important!';
  static const String satisfactionSurveyButton = 'Fill out survey';

  // Difficulty Feedback
  static const String difficultyFeedbackTitle = 'How do you like the difficulty?';
  static const String difficultyFeedbackMessage = 'Let us know if the questions are too easy or too hard.';
  static const String difficultyTooHard = 'Too hard';
  static const String difficultyGood = 'Good';
  static const String difficultyTooEasy = 'Too easy';

  // Quiz Screen
  static const String skip = 'Skip';
  static const String overslaan = 'Skip';
  static const String notEnoughStarsForSkip = 'Not enough stars to skip!';

  // Settings Screen
  static const String resetAndLogoutConfirmation = 'This will remove all scores, progress, cache, settings, and activation. The app will be deactivated and will require a new activation code. This action cannot be undone.';

  // Guide Screen
  static const String donationError = 'An error occurred while opening the donation page';
  static const String notificationPermissionDenied = 'Notification permission denied.';
  static const String soundEffectsDescription = 'Turn all game sounds on or off';

  // Store Screen
  static const String doubleStarsActivated = 'Double Stars activated for 5 questions!';
  static const String tripleStarsActivated = 'Triple Stars activated for 5 questions!';
  static const String fiveTimesStarsActivated = '5x Stars activated for 5 questions!';
  static const String doubleStars60SecondsActivated = 'Double Stars activated for 60 seconds!';
  static const String powerupActivated = 'Power-up Activated!';
  static const String backToQuiz = 'Back to the quiz';
  static const String themeUnlocked = 'unlocked!';

  // Lesson Select Screen
  static const String onlyLatestUnlockedLesson = 'You can only play the most recently unlocked lesson';
  static const String starsEarned = 'stars earned';
  static const String readyForNextChallenge = 'Ready for your next challenge?';
  static const String continueLesson = 'Continue:';
  static const String freePractice = 'Free Practice (random)';
  static const String lessonNumber = 'Lesson';

  // Biblical Reference Dialog
  static const String invalidBiblicalReference = 'Invalid biblical reference';
  static const String errorLoadingBiblicalText = 'Error loading the biblical text';
  static const String errorLoadingWithDetails = 'Error loading:';
  static const String resumeToGame = 'Resume Game';

  // Settings Screen
  static const String emailAddress = 'Email Address';

  // AI Theme
  static const String aiThemeFallback = 'AI Theme';
  static const String aiThemeGenerator = 'AI Theme Generator';
  static const String aiThemeGeneratorDescription = 'Describe your desired colors and let AI create a theme for you';

  // Settings Screen - Updates
  static const String checkForUpdates = 'Check for updates';
  static const String checkForUpdatesDescription = 'Look for new app versions';
  static const String checkForUpdatesTooltip = 'Check for updates';

  // Settings Screen - Privacy
  static const String privacyPolicy = 'Privacy Policy';
  static const String privacyPolicyDescription = 'Read our privacy policy';
  static const String couldNotOpenPrivacyPolicy = 'Could not open privacy policy';
  static const String openPrivacyPolicyTooltip = 'Open privacy policy';

  // Settings Screen - Privacy & Analytics
  static const String privacyAndAnalytics = 'Privacy & Analytics';
  static const String analytics = 'Analytics';
  static const String analyticsDescription = 'Help us improve the app by sending anonymous usage data';

  // Social Media
  static const String followOnSocialMedia = 'Follow on social media';
  static const String followUsOnSocialMedia = 'Follow us on social media';
  static const String mastodon = 'Mastodon';
  static const String pixelfed = 'Pixelfed';
  static const String kwebler = 'Kwebler';
  static const String discord = 'Discord';
  static const String signal = 'Signal';
  static const String bluesky = 'Bluesky';
  static const String couldNotOpenPlatform = 'Could not open {platform}';

  // Settings Provider Errors
  static const String languageMustBeNl = 'Language must be "nl" (only Dutch allowed)';
  static const String failedToSaveTheme = 'Failed to save theme setting:';
  static const String failedToSaveSlowMode = 'Failed to save slow mode setting:';
  static const String failedToSaveGameSpeed = 'Failed to save game speed setting:';
  static const String failedToUpdateDonationStatus = 'Failed to update donation status:';
  static const String failedToUpdateCheckForUpdateStatus = 'Failed to update check for update status:';
  static const String failedToSaveMuteSetting = 'Failed to save mute setting:';
  static const String failedToSaveGuideStatus = 'Failed to save guide status:';
  static const String failedToResetGuideStatus = 'Failed to reset guide status:';
  static const String failedToResetCheckForUpdateStatus = 'Failed to reset check for update status:';
  static const String failedToSaveNotificationSetting = 'Failed to save notification setting:';

  // Export/Import Stats
  static const String exportStatsTitle = 'Export Stats';
  static const String exportStatsMessage = 'Copy this text to save your progress:';
  static const String importStatsTitle = 'Import Stats';
  static const String importStatsMessage = 'Paste your previously exported stats here:';
  static const String importStatsHint = 'Paste here...';
  static const String statsExportedSuccessfully = 'Stats successfully exported!';
  static const String statsImportedSuccessfully = 'Stats successfully imported!';
  static const String failedToExportStats = 'Failed to export stats:';
  static const String failedToImportStats = 'Failed to import stats:';
  static const String invalidOrTamperedData = 'Invalid or tampered data';
  static const String pleaseEnterValidString = 'Please enter a valid string';

}
