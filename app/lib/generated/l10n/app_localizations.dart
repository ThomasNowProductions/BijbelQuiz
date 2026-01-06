import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'BibleQuiz'**
  String get appName;

  /// App description shown in stores
  ///
  /// In en, this message translates to:
  /// **'Test Your Bible Knowledge'**
  String get appDescription;

  /// Shown while content is loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Navigate back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Quiz question label
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// Current score display
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Correct answer feedback
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// Incorrect answer feedback
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Shown when quiz is finished
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// Display user's score
  ///
  /// In en, this message translates to:
  /// **'Your score: '**
  String get yourScore;

  /// Button to unlock biblical references feature
  ///
  /// In en, this message translates to:
  /// **'Unlock Bible Reference (Beta)'**
  String get unlockBiblicalReference;

  /// Biblical reference label
  ///
  /// In en, this message translates to:
  /// **'Bible Reference'**
  String get biblicalReference;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Sound settings
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Theme settings
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Dark mode option
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Light mode option
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// System default theme option
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// Lessons section
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// Continue learning button
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// Store screen title
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// Unlock all content option
  ///
  /// In en, this message translates to:
  /// **'Unlock All'**
  String get unlockAll;

  /// Purchase completed successfully
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful!'**
  String get purchaseSuccessful;

  /// Donation section title
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get donate;

  /// Donate button
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donateButton;

  /// Explanation for donation request
  ///
  /// In en, this message translates to:
  /// **'Support the development of this app with a donation. This is needed to continue developing/maintaining the app.'**
  String get donateExplanation;

  /// Guide screen title
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// How to play section
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// Network connection error
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get connectionError;

  /// Instructions for connection error
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get connectionErrorMsg;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get unknownError;

  /// No questions available error
  ///
  /// In en, this message translates to:
  /// **'No valid questions found'**
  String get errorNoQuestions;

  /// Question loading error
  ///
  /// In en, this message translates to:
  /// **'Error loading questions'**
  String get errorLoadQuestions;

  /// Error opening donation page
  ///
  /// In en, this message translates to:
  /// **'Could not open donation page'**
  String get couldNotOpenDonationPage;

  /// AI service error
  ///
  /// In en, this message translates to:
  /// **'AI service error occurred'**
  String get aiError;

  /// API service error
  ///
  /// In en, this message translates to:
  /// **'API service error occurred'**
  String get apiError;

  /// Storage error
  ///
  /// In en, this message translates to:
  /// **'Storage error occurred'**
  String get storageError;

  /// Sync operation failed
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed'**
  String get syncError;

  /// Permission denied error
  ///
  /// In en, this message translates to:
  /// **'Permission required for this feature'**
  String get permissionDenied;

  /// Streak metric label
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// Best score/result
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// Time label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Unsupported screen size error
  ///
  /// In en, this message translates to:
  /// **'Screen size not supported'**
  String get screenSizeNotSupported;

  /// Progress section title
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// Daily streak label
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get dailyStreak;

  /// Continue with section
  ///
  /// In en, this message translates to:
  /// **'Continue With'**
  String get continueWith;

  /// Multiplayer quiz option
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Quiz'**
  String get multiplayerQuiz;

  /// Game duration selection
  ///
  /// In en, this message translates to:
  /// **'Choose game duration'**
  String get chooseGameDuration;

  /// Start multiplayer quiz button
  ///
  /// In en, this message translates to:
  /// **'Start Multiplayer Quiz'**
  String get startMultiplayerQuiz;

  /// Multiplayer quiz description
  ///
  /// In en, this message translates to:
  /// **'Play against each other on one phone! The phone is split in two - the top half rotates 180 degrees.'**
  String get multiplayerDescription;

  /// Game rules section
  ///
  /// In en, this message translates to:
  /// **'Game rules:'**
  String get gameRules;

  /// Multiplayer rule: both players answer
  ///
  /// In en, this message translates to:
  /// **'• Both players answer Bible questions'**
  String get ruleBothPlayers;

  /// Multiplayer rule: points for correct answers
  ///
  /// In en, this message translates to:
  /// **'• A correct answer gives points'**
  String get ruleCorrectAnswer;

  /// Multiplayer rule: winner determination
  ///
  /// In en, this message translates to:
  /// **'• The one with the correct answers at the end wins'**
  String get ruleWinner;

  /// Multiplayer rule: screen rotation
  ///
  /// In en, this message translates to:
  /// **'• The top half of the screen rotates 180 degrees on mobile'**
  String get ruleScreenRotation;

  /// Time expired message
  ///
  /// In en, this message translates to:
  /// **'Time is up!'**
  String get timeUp;

  /// Time up explanation with streak reset
  ///
  /// In en, this message translates to:
  /// **'You did not answer in time. Your streak has been reset.'**
  String get timeUpMessage;

  /// Insufficient points
  ///
  /// In en, this message translates to:
  /// **'Not Enough Points'**
  String get notEnoughPoints;

  /// Lesson completion message
  ///
  /// In en, this message translates to:
  /// **'Lesson Complete'**
  String get lessonComplete;

  /// Percentage label
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// Retry lesson button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryLesson;

  /// Next lesson button
  ///
  /// In en, this message translates to:
  /// **'Next Lesson'**
  String get nextLesson;

  /// Back to lessons button
  ///
  /// In en, this message translates to:
  /// **'Back to Lessons'**
  String get backToLessons;

  /// Final score label
  ///
  /// In en, this message translates to:
  /// **'End Score'**
  String get endScore;

  /// End score hint
  ///
  /// In en, this message translates to:
  /// **'Your total score in percentage on a speedometer'**
  String get endScoreHint;

  /// Display settings section
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// Theme selection prompt
  ///
  /// In en, this message translates to:
  /// **'Choose your theme'**
  String get chooseTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// OLED theme option
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get oledTheme;

  /// Green theme option
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get greenTheme;

  /// Orange theme option
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orangeTheme;

  /// Navigation labels toggle
  ///
  /// In en, this message translates to:
  /// **'Show Navigation Labels'**
  String get showNavigationLabels;

  /// Navigation labels description
  ///
  /// In en, this message translates to:
  /// **'Show or hide text labels below navigation icons'**
  String get showNavigationLabelsDesc;

  /// Colorful mode toggle
  ///
  /// In en, this message translates to:
  /// **'Colorful Mode'**
  String get colorfulMode;

  /// Colorful mode description
  ///
  /// In en, this message translates to:
  /// **'Enable different colors for lesson cards'**
  String get colorfulModeDesc;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Error opening status page
  ///
  /// In en, this message translates to:
  /// **'Could not open status page.'**
  String get couldNotOpenStatusPage;

  /// Lesson layout setting
  ///
  /// In en, this message translates to:
  /// **'Lesson Layout'**
  String get lessonLayout;

  /// Lesson layout selection
  ///
  /// In en, this message translates to:
  /// **'Choose how lessons are displayed'**
  String get chooseLessonLayout;

  /// Grid layout option
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get layoutGrid;

  /// List layout option
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get layoutList;

  /// Compact grid layout option
  ///
  /// In en, this message translates to:
  /// **'Compact Grid'**
  String get layoutCompactGrid;

  /// Error loading lessons
  ///
  /// In en, this message translates to:
  /// **'Could not load lessons'**
  String get couldNotLoadLessons;

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Reset progress button
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// Reset progress confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your progress? This cannot be undone.'**
  String get resetProgressConfirmation;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Start lesson button
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get startLesson;

  /// Locked status
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Perfect score achieved
  ///
  /// In en, this message translates to:
  /// **'Perfect Score!'**
  String get perfectScore;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Previous button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// Welcome screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to BibleQuiz'**
  String get welcomeTitle;

  /// Welcome screen description
  ///
  /// In en, this message translates to:
  /// **'Discover the Bible in a fun and interactive way with challenging questions and lessons.'**
  String get welcomeDescription;

  /// How to play section title
  ///
  /// In en, this message translates to:
  /// **'How to Play?'**
  String get howToPlayTitle;

  /// How to play description
  ///
  /// In en, this message translates to:
  /// **'Answer questions about the Bible. The more accurate your answer, the more points you earn. You can later spend points in the shop on exclusive themes and power-ups.'**
  String get howToPlayDescription;

  /// Track progress section title
  ///
  /// In en, this message translates to:
  /// **'Play alone, with friends or family'**
  String get trackProgressTitle;

  /// Track progress description
  ///
  /// In en, this message translates to:
  /// **'Go to the \"Social\" tab to follow friends or click on Multiplayer Quiz to play together.'**
  String get trackProgressDescription;

  /// Customization section title
  ///
  /// In en, this message translates to:
  /// **'Customize Your Experience'**
  String get customizeExperienceTitle;

  /// Customization description
  ///
  /// In en, this message translates to:
  /// **'Customize your theme, game speed, and sound effects in the settings. Do you have any questions or suggestions? We would love to hear from you at {contactEmail}'**
  String customizeExperienceDescription(String contactEmail);

  /// Support us description
  ///
  /// In en, this message translates to:
  /// **'Do you find this app useful? Consider donating to help us maintain and improve the app. Every contribution is appreciated!'**
  String get supportUsDescription;

  /// Donate now button
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donateNow;

  /// Activation screen title
  ///
  /// In en, this message translates to:
  /// **'Activate your account'**
  String get activationTitle;

  /// Activation screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your activation code to use the app'**
  String get activationSubtitle;

  /// Activation code input hint
  ///
  /// In en, this message translates to:
  /// **'Enter your activation code'**
  String get activationCodeHint;

  /// Activate button
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateButton;

  /// Verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// Verifying status
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// Activation tip
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code you received with your purchase.'**
  String get activationTip;

  /// Activation success message
  ///
  /// In en, this message translates to:
  /// **'Successfully activated!'**
  String get activationSuccess;

  /// Activation error message
  ///
  /// In en, this message translates to:
  /// **'Invalid activation code. Please try again.'**
  String get activationError;

  /// Activation error title
  ///
  /// In en, this message translates to:
  /// **'Activation Failed'**
  String get activationErrorTitle;

  /// Activation success details
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully activated. Enjoy the app!'**
  String get activationSuccessMessage;

  /// Activation required message
  ///
  /// In en, this message translates to:
  /// **'Activation Required'**
  String get activationRequired;

  /// Activation required details
  ///
  /// In en, this message translates to:
  /// **'You must activate the app before you can use it.'**
  String get activationRequiredMessage;

  /// Stars balance display
  ///
  /// In en, this message translates to:
  /// **'Your Stars'**
  String get yourStars;

  /// Available stars label
  ///
  /// In en, this message translates to:
  /// **'Available Stars'**
  String get availableStars;

  /// Power-ups section
  ///
  /// In en, this message translates to:
  /// **'Power-ups'**
  String get powerUps;

  /// Themes section
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// Available themes label
  ///
  /// In en, this message translates to:
  /// **'Available Themes'**
  String get availableThemes;

  /// Unlock theme button
  ///
  /// In en, this message translates to:
  /// **'Unlock Theme'**
  String get unlockTheme;

  /// Unlocked status
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// Insufficient stars
  ///
  /// In en, this message translates to:
  /// **'Not Enough Stars'**
  String get notEnoughStars;

  /// Unlock cost prefix
  ///
  /// In en, this message translates to:
  /// **'Unlock for'**
  String get unlockFor;

  /// Stars unit
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get stars;

  /// Free item
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Purchased status
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// Confirm purchase button
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchase;

  /// Purchase confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlock this theme for'**
  String get purchaseConfirmation;

  /// Purchase success message
  ///
  /// In en, this message translates to:
  /// **'Theme successfully unlocked!'**
  String get purchaseSuccess;

  /// Purchase error message
  ///
  /// In en, this message translates to:
  /// **'Not enough stars to unlock this theme.'**
  String get purchaseError;

  /// Error opening download page
  ///
  /// In en, this message translates to:
  /// **'Could not open download page'**
  String get couldNotOpenDownloadPage;

  /// Theme unlocked with switch option
  ///
  /// In en, this message translates to:
  /// **'unlocked! You can always return to the default theme in settings.'**
  String get themeUnlockedWithSwitchOption;

  /// Double stars power-up
  ///
  /// In en, this message translates to:
  /// **'Double Stars (5 questions)'**
  String get doubleStars5Questions;

  /// Double stars power-up description
  ///
  /// In en, this message translates to:
  /// **'Earn double stars for your next 5 questions'**
  String get doubleStars5QuestionsDesc;

  /// Triple stars power-up
  ///
  /// In en, this message translates to:
  /// **'Triple Stars (5 questions)'**
  String get tripleStars5Questions;

  /// Triple stars power-up description
  ///
  /// In en, this message translates to:
  /// **'Earn triple stars for your next 5 questions'**
  String get tripleStars5QuestionsDesc;

  /// 5x stars power-up
  ///
  /// In en, this message translates to:
  /// **'5x Stars (5 questions)'**
  String get fiveTimesStars5Questions;

  /// 5x stars power-up description
  ///
  /// In en, this message translates to:
  /// **'Earn 5x stars for your next 5 questions'**
  String get fiveTimesStars5QuestionsDesc;

  /// Double stars for 60 seconds power-up
  ///
  /// In en, this message translates to:
  /// **'Double Stars (60 seconds)'**
  String get doubleStars60Seconds;

  /// Double stars 60s description
  ///
  /// In en, this message translates to:
  /// **'Earn double stars for 60 seconds'**
  String get doubleStars60SecondsDesc;

  /// OLED theme name
  ///
  /// In en, this message translates to:
  /// **'OLED Theme'**
  String get oledThemeName;

  /// OLED theme description
  ///
  /// In en, this message translates to:
  /// **'Unlock a true black, high-contrast theme'**
  String get oledThemeDesc;

  /// Green theme name
  ///
  /// In en, this message translates to:
  /// **'Green Theme'**
  String get greenThemeName;

  /// Green theme description
  ///
  /// In en, this message translates to:
  /// **'Unlock a fresh green theme'**
  String get greenThemeDesc;

  /// Orange theme name
  ///
  /// In en, this message translates to:
  /// **'Orange Theme'**
  String get orangeThemeName;

  /// Orange theme description
  ///
  /// In en, this message translates to:
  /// **'Unlock a vibrant orange theme'**
  String get orangeThemeDesc;

  /// Coupon section title
  ///
  /// In en, this message translates to:
  /// **'Have a coupon code?'**
  String get couponTitle;

  /// Coupon description
  ///
  /// In en, this message translates to:
  /// **'Redeem it here for rewards'**
  String get couponDescription;

  /// Redeem coupon button
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get couponRedeem;

  /// Coupon dialog title
  ///
  /// In en, this message translates to:
  /// **'Redeem Coupon'**
  String get couponDialogTitle;

  /// Coupon code label
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponCodeLabel;

  /// Coupon code input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. SUMMER2023'**
  String get couponCodeHint;

  /// Coupon success title
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get couponSuccessTitle;

  /// Coupon stars reward message
  ///
  /// In en, this message translates to:
  /// **'You received {amount} stars!'**
  String couponStarsReceived(int amount);

  /// Coupon theme unlocked message
  ///
  /// In en, this message translates to:
  /// **'You unlocked a new theme!'**
  String get couponThemeUnlocked;

  /// Coupon error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get couponErrorTitle;

  /// Invalid coupon message
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get couponInvalid;

  /// Expired coupon message
  ///
  /// In en, this message translates to:
  /// **'This coupon has expired'**
  String get couponExpired;

  /// Coupon max uses reached
  ///
  /// In en, this message translates to:
  /// **'This coupon is no longer valid (maximum uses reached)'**
  String get couponMaxUsed;

  /// Already redeemed coupon message
  ///
  /// In en, this message translates to:
  /// **'This coupon has already been redeemed'**
  String get couponAlreadyRedeemed;

  /// Coupon daily limit
  ///
  /// In en, this message translates to:
  /// **'Maximum of 5 coupons can be redeemed per day'**
  String get couponMaxPerDay;

  /// QR code label
  ///
  /// In en, this message translates to:
  /// **'QR-code'**
  String get qrCode;

  /// QR code scanning description
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code'**
  String get qrCodeDescription;

  /// QR scanner mobile only warning
  ///
  /// In en, this message translates to:
  /// **'QR Scanner only available on mobile'**
  String get qrScannerMobileOnly;

  /// Invalid QR code message
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQRCode;

  /// Camera permission required
  ///
  /// In en, this message translates to:
  /// **'Camera access required'**
  String get cameraAccessRequired;

  /// Camera permission description
  ///
  /// In en, this message translates to:
  /// **'To scan QR codes, the app needs access to your camera. This permission is only used for scanning coupons.'**
  String get cameraAccessDescription;

  /// Grant camera permission button
  ///
  /// In en, this message translates to:
  /// **'Grant camera permission'**
  String get grantCameraPermission;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// Camera error
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get cameraError;

  /// Camera initialization error
  ///
  /// In en, this message translates to:
  /// **'An error occurred while initializing the camera: '**
  String get cameraInitializationError;

  /// Camera initialization status
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// QR code scanning tutorial
  ///
  /// In en, this message translates to:
  /// **'Hold the QR code within the frame for automatic detection'**
  String get qrCodeTutorial;

  /// Support us section title
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get supportUsTitle;

  /// Settings loading error
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// Game settings section
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// Game speed label
  ///
  /// In en, this message translates to:
  /// **'Game Speed'**
  String get gameSpeed;

  /// Game speed selection
  ///
  /// In en, this message translates to:
  /// **'Choose the speed of the game'**
  String get chooseGameSpeed;

  /// Slow speed option
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// Medium speed option
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Fast speed option
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// Mute sound effects toggle
  ///
  /// In en, this message translates to:
  /// **'Mute Sound Effects'**
  String get muteSoundEffects;

  /// Mute sound effects description
  ///
  /// In en, this message translates to:
  /// **'Turn off all game sounds'**
  String get muteSoundEffectsDesc;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Server status section
  ///
  /// In en, this message translates to:
  /// **'Server Status'**
  String get serverStatus;

  /// Service status check description
  ///
  /// In en, this message translates to:
  /// **'Check the status of our services'**
  String get checkServiceStatus;

  /// Open status page button
  ///
  /// In en, this message translates to:
  /// **'Open Status Page'**
  String get openStatusPage;

  /// Actions section
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// Export statistics button
  ///
  /// In en, this message translates to:
  /// **'Export Statistics'**
  String get exportStats;

  /// Export statistics description
  ///
  /// In en, this message translates to:
  /// **'Save your progress and scores as text'**
  String get exportStatsDesc;

  /// Import statistics button
  ///
  /// In en, this message translates to:
  /// **'Import Statistics'**
  String get importStats;

  /// Import statistics description
  ///
  /// In en, this message translates to:
  /// **'Load previously exported statistics'**
  String get importStatsDesc;

  /// Reset and logout button
  ///
  /// In en, this message translates to:
  /// **'Reset and Log Out'**
  String get resetAndLogout;

  /// Reset and logout description
  ///
  /// In en, this message translates to:
  /// **'Clear all data and deactivate app'**
  String get resetAndLogoutDesc;

  /// Show introduction button
  ///
  /// In en, this message translates to:
  /// **'Show Introduction'**
  String get showIntroduction;

  /// Report issue button
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// Clear question cache button
  ///
  /// In en, this message translates to:
  /// **'Clear Question Cache'**
  String get clearQuestionCache;

  /// Contact us button
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Email client not available
  ///
  /// In en, this message translates to:
  /// **'Could not open email client'**
  String get emailNotAvailable;

  /// Cache cleared message
  ///
  /// In en, this message translates to:
  /// **'Question cache cleared!'**
  String get cacheCleared;

  /// Test all features button
  ///
  /// In en, this message translates to:
  /// **'Test All Features'**
  String get testAllFeatures;

  /// Copyright notice
  ///
  /// In en, this message translates to:
  /// **'© 2024-2026 ThomasNow Productions'**
  String get copyright;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Social section
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// Coming soon message
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!'**
  String get comingSoon;

  /// Social features coming soon message
  ///
  /// In en, this message translates to:
  /// **'BibleQuiz social features are coming soon. Stay tuned for updates!'**
  String get socialComingSoonMessage;

  /// Manage BQID button
  ///
  /// In en, this message translates to:
  /// **'Manage Your BQID'**
  String get manageYourBqid;

  /// Manage BQID subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your BQID, registered devices and more'**
  String get manageYourBqidSubtitle;

  /// More social features coming soon
  ///
  /// In en, this message translates to:
  /// **'More social features coming soon'**
  String get moreSocialFeaturesComingSoon;

  /// Social features section
  ///
  /// In en, this message translates to:
  /// **'Social Features'**
  String get socialFeatures;

  /// Connect with other users description
  ///
  /// In en, this message translates to:
  /// **'Connect with other BibleQuiz users, share achievements and compete on the leaderboards!'**
  String get connectWithOtherUsers;

  /// Search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Following list label
  ///
  /// In en, this message translates to:
  /// **'My Following'**
  String get myFollowing;

  /// Followers list label
  ///
  /// In en, this message translates to:
  /// **'My Followers'**
  String get myFollowers;

  /// Messages label
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Search users button
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// Search by username option
  ///
  /// In en, this message translates to:
  /// **'Search by username'**
  String get searchByUsername;

  /// Username search input hint
  ///
  /// In en, this message translates to:
  /// **'Enter username to search...'**
  String get enterUsernameToSearch;

  /// No users found message
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// Follow button
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// Unfollow button
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// Yourself label
  ///
  /// In en, this message translates to:
  /// **'Yourself'**
  String get yourself;

  /// Bible Bot label
  ///
  /// In en, this message translates to:
  /// **'Bible Bot'**
  String get bibleBot;

  /// Could not open email
  ///
  /// In en, this message translates to:
  /// **'Could not open email client'**
  String get couldNotOpenEmail;

  /// Could not open update page
  ///
  /// In en, this message translates to:
  /// **'Could not open update page'**
  String get couldNotOpenUpdatePage;

  /// Error opening update page
  ///
  /// In en, this message translates to:
  /// **'Error opening update page: '**
  String get errorOpeningUpdatePage;

  /// Could not copy link
  ///
  /// In en, this message translates to:
  /// **'Could not copy link'**
  String get couldNotCopyLink;

  /// Error copying link
  ///
  /// In en, this message translates to:
  /// **'Could not copy link: '**
  String get errorCopyingLink;

  /// Invite link copied message
  ///
  /// In en, this message translates to:
  /// **'Invitation link copied to clipboard!'**
  String get inviteLinkCopied;

  /// Stats link copied message
  ///
  /// In en, this message translates to:
  /// **'Statistics link copied to clipboard!'**
  String get statsLinkCopied;

  /// Copy stats link description
  ///
  /// In en, this message translates to:
  /// **'Copy your statistics link to the clipboard'**
  String get copyStatsLinkToClipboard;

  /// Import button
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// Follow us label
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// Follow us message
  ///
  /// In en, this message translates to:
  /// **'Follow us on social media for updates and community!'**
  String get followUsMessage;

  /// Follow Mastodon button
  ///
  /// In en, this message translates to:
  /// **'Follow Mastodon'**
  String get followMastodon;

  /// Follow Pixelfed button
  ///
  /// In en, this message translates to:
  /// **'Follow Pixelfed'**
  String get followPixelfed;

  /// Follow Kwebler button
  ///
  /// In en, this message translates to:
  /// **'Follow Kwebler'**
  String get followKwebler;

  /// Follow Signal button
  ///
  /// In en, this message translates to:
  /// **'Follow Signal'**
  String get followSignal;

  /// Follow Discord button
  ///
  /// In en, this message translates to:
  /// **'Follow Discord'**
  String get followDiscord;

  /// Follow Bluesky button
  ///
  /// In en, this message translates to:
  /// **'Follow Bluesky'**
  String get followBluesky;

  /// Follow Nooki button
  ///
  /// In en, this message translates to:
  /// **'Follow Nooki'**
  String get followNooki;

  /// Could not open platform
  ///
  /// In en, this message translates to:
  /// **'Could not open {platform}'**
  String couldNotOpenPlatform(String platform);

  /// Share app button
  ///
  /// In en, this message translates to:
  /// **'Share app with friends'**
  String get shareAppWithFriends;

  /// Share stats button
  ///
  /// In en, this message translates to:
  /// **'Share your statistics'**
  String get shareYourStats;

  /// Invite friend button
  ///
  /// In en, this message translates to:
  /// **'Invite a friend'**
  String get inviteFriend;

  /// Enter your name input
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// Enter friend name input
  ///
  /// In en, this message translates to:
  /// **'Enter your friend\'s name'**
  String get enterFriendName;

  /// Invite message
  ///
  /// In en, this message translates to:
  /// **'Invite your friend to BibleQuiz!'**
  String get inviteMessage;

  /// Customize invite button
  ///
  /// In en, this message translates to:
  /// **'Personalize your invitation'**
  String get customizeInvite;

  /// Send invite button
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get sendInvite;

  /// Language must be Dutch error
  ///
  /// In en, this message translates to:
  /// **'Language must be \"nl\" (only Dutch allowed)'**
  String get languageMustBeNl;

  /// Failed to save theme
  ///
  /// In en, this message translates to:
  /// **'Could not save theme setting:'**
  String get failedToSaveTheme;

  /// Failed to save slow mode
  ///
  /// In en, this message translates to:
  /// **'Could not save slow mode setting:'**
  String get failedToSaveSlowMode;

  /// Failed to save game speed
  ///
  /// In en, this message translates to:
  /// **'Could not save game speed setting:'**
  String get failedToSaveGameSpeed;

  /// Failed to update donation status
  ///
  /// In en, this message translates to:
  /// **'Could not update donation status:'**
  String get failedToUpdateDonationStatus;

  /// Failed to update check for update status
  ///
  /// In en, this message translates to:
  /// **'Could not update check for update status:'**
  String get failedToUpdateCheckForUpdateStatus;

  /// Failed to save mute setting
  ///
  /// In en, this message translates to:
  /// **'Could not save mute setting:'**
  String get failedToSaveMuteSetting;

  /// Failed to save guide status
  ///
  /// In en, this message translates to:
  /// **'Could not save guide status:'**
  String get failedToSaveGuideStatus;

  /// Failed to reset guide status
  ///
  /// In en, this message translates to:
  /// **'Could not reset guide status:'**
  String get failedToResetGuideStatus;

  /// Failed to reset check for update status
  ///
  /// In en, this message translates to:
  /// **'Could not reset check for update status:'**
  String get failedToResetCheckForUpdateStatus;

  /// Export statistics title
  ///
  /// In en, this message translates to:
  /// **'Export Statistics'**
  String get exportStatsTitle;

  /// Export statistics message
  ///
  /// In en, this message translates to:
  /// **'Copy this text to save your progress:'**
  String get exportStatsMessage;

  /// Import statistics title
  ///
  /// In en, this message translates to:
  /// **'Import Statistics'**
  String get importStatsTitle;

  /// Import statistics message
  ///
  /// In en, this message translates to:
  /// **'Paste your previously exported statistics here:'**
  String get importStatsMessage;

  /// Import statistics hint
  ///
  /// In en, this message translates to:
  /// **'Paste here...'**
  String get importStatsHint;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Statistics exported successfully!'**
  String get statsExportedSuccessfully;

  /// Import success message
  ///
  /// In en, this message translates to:
  /// **'Statistics imported successfully!'**
  String get statsImportedSuccessfully;

  /// Export failed message
  ///
  /// In en, this message translates to:
  /// **'Could not export statistics:'**
  String get failedToExportStats;

  /// Import failed message
  ///
  /// In en, this message translates to:
  /// **'Could not import statistics:'**
  String get failedToImportStats;

  /// Invalid data message
  ///
  /// In en, this message translates to:
  /// **'Invalid or tampered data'**
  String get invalidOrTamperedData;

  /// Valid string required
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid string'**
  String get pleaseEnterValidString;

  /// Copy code button
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// Code copied message
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// Export all data button
  ///
  /// In en, this message translates to:
  /// **'Export All Data (JSON)'**
  String get exportAllDataJson;

  /// Export all data description
  ///
  /// In en, this message translates to:
  /// **'Export all app data including settings, stats, and progress as JSON'**
  String get exportAllDataJsonDesc;

  /// Export all data title
  ///
  /// In en, this message translates to:
  /// **'Export All Data (JSON)'**
  String get exportAllDataJsonTitle;

  /// Export all data message
  ///
  /// In en, this message translates to:
  /// **'Your complete app data has been exported as JSON. You can copy this data to save it or share it.'**
  String get exportAllDataJsonMessage;

  /// Copy to clipboard button
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// JSON data copied message
  ///
  /// In en, this message translates to:
  /// **'JSON data copied to clipboard'**
  String get jsonDataCopied;

  /// Multi-device sync section
  ///
  /// In en, this message translates to:
  /// **'Multi-Device Sync'**
  String get multiDeviceSync;

  /// Currently synced message
  ///
  /// In en, this message translates to:
  /// **'You are currently synced. Data is shared in real-time between devices.'**
  String get currentlySynced;

  /// Your sync ID label
  ///
  /// In en, this message translates to:
  /// **'Your Sync ID:'**
  String get yourSyncId;

  /// Share sync ID description
  ///
  /// In en, this message translates to:
  /// **'Share this ID with other devices to join.'**
  String get shareSyncId;

  /// Generic error prefix
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorGeneric;

  /// Multi-device sync button
  ///
  /// In en, this message translates to:
  /// **'Multi-Device Sync'**
  String get multiDeviceSyncButton;

  /// Sync data description
  ///
  /// In en, this message translates to:
  /// **'Sync data between devices using a code'**
  String get syncDataDescription;

  /// Sync description
  ///
  /// In en, this message translates to:
  /// **'Connect to another device to sync your progress and statistics.'**
  String get syncDescription;

  /// User ID label
  ///
  /// In en, this message translates to:
  /// **'BQID'**
  String get userId;

  /// Enter user ID input
  ///
  /// In en, this message translates to:
  /// **'Enter a BQID to connect to another device'**
  String get enterUserId;

  /// User ID code
  ///
  /// In en, this message translates to:
  /// **'BQID'**
  String get userIdCode;

  /// Connect to user button
  ///
  /// In en, this message translates to:
  /// **'Connect to BQID'**
  String get connectToUser;

  /// Create user ID button
  ///
  /// In en, this message translates to:
  /// **'Create a new BQID'**
  String get createUserId;

  /// Create user ID description
  ///
  /// In en, this message translates to:
  /// **'Create a new BQID and share the code with others to connect.'**
  String get createUserIdDescription;

  /// Currently connected message
  ///
  /// In en, this message translates to:
  /// **'You are currently connected to a BQID. Data is shared between devices.'**
  String get currentlyConnectedToUser;

  /// Your user ID label
  ///
  /// In en, this message translates to:
  /// **'Your BQID:'**
  String get yourUserId;

  /// Share user ID description
  ///
  /// In en, this message translates to:
  /// **'Share this ID with other devices to connect.'**
  String get shareUserId;

  /// Leave user ID button
  ///
  /// In en, this message translates to:
  /// **'Remove BQID from this device'**
  String get leaveUserId;

  /// User ID description
  ///
  /// In en, this message translates to:
  /// **'Connect to another device with a BQID to sync your data and statistics.'**
  String get userIdDescription;

  /// Please enter user ID
  ///
  /// In en, this message translates to:
  /// **'Please enter a BQID'**
  String get pleaseEnterUserId;

  /// Failed to connect message
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to the BQID. Check the ID and try again.'**
  String get failedToConnectToUser;

  /// Failed to create user ID
  ///
  /// In en, this message translates to:
  /// **'Failed to create BQID. Please try again.'**
  String get failedToCreateUserId;

  /// User ID button
  ///
  /// In en, this message translates to:
  /// **'BQID'**
  String get userIdButton;

  /// User ID setting description
  ///
  /// In en, this message translates to:
  /// **'Create or connect to a BQID to sync your progress'**
  String get userIdDescriptionSetting;

  /// Create user ID button
  ///
  /// In en, this message translates to:
  /// **'Create a BQID'**
  String get createUserIdButton;

  /// Or separator
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get of;

  /// Tap to copy user ID
  ///
  /// In en, this message translates to:
  /// **'Tap to copy BQID'**
  String get tapToCopyUserId;

  /// User ID copied message
  ///
  /// In en, this message translates to:
  /// **'BQID copied to clipboard'**
  String get userIdCopiedToClipboard;

  /// Not following anyone message
  ///
  /// In en, this message translates to:
  /// **'You are not following anyone yet'**
  String get notFollowing;

  /// Join room to view following
  ///
  /// In en, this message translates to:
  /// **'You need to join a room to see who you are following'**
  String get joinRoomToViewFollowing;

  /// Search users to follow
  ///
  /// In en, this message translates to:
  /// **'Search for users to start following them'**
  String get searchUsersToFollow;

  /// No followers message
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any followers yet'**
  String get noFollowers;

  /// Join room to view followers
  ///
  /// In en, this message translates to:
  /// **'You need to join a room to see your followers'**
  String get joinRoomToViewFollowers;

  /// Share BQID to get followers
  ///
  /// In en, this message translates to:
  /// **'Share your BQID with others to start getting followers'**
  String get shareBQIDFollowers;

  /// No messages label
  ///
  /// In en, this message translates to:
  /// **'No messages'**
  String get noActiveMessages;

  /// No messages subtitle
  ///
  /// In en, this message translates to:
  /// **'There are currently no messages to display'**
  String get noActiveMessagesSubtitle;

  /// Error loading messages
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get errorLoadingMessages;

  /// Error updating reaction
  ///
  /// In en, this message translates to:
  /// **'Error updating reaction'**
  String get errorUpdatingReaction;

  /// Loading messages
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// Expires in label
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get expiresIn;

  /// Expiring soon label
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursMessage;

  /// Minutes unit
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Less than a minute
  ///
  /// In en, this message translates to:
  /// **'less than a minute'**
  String get lessThanAMinute;

  /// Created label
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// Year in review title
  ///
  /// In en, this message translates to:
  /// **'BibleQuiz Gen'**
  String get bijbelquizGenTitle;

  /// Year in review subtitle
  ///
  /// In en, this message translates to:
  /// **'Your year in '**
  String get bijbelquizGenSubtitle;

  /// Year in review welcome text
  ///
  /// In en, this message translates to:
  /// **'Review your achievements today and share your BibleQuiz year!'**
  String get bijbelquizGenWelcomeText;

  /// Questions answered label
  ///
  /// In en, this message translates to:
  /// **'Questions answered'**
  String get questionsAnswered;

  /// Questions answered subtitle
  ///
  /// In en, this message translates to:
  /// **'You have hopefully learned many new things.'**
  String get bijbelquizGenQuestionsSubtitle;

  /// Mistakes made label
  ///
  /// In en, this message translates to:
  /// **'Mistakes made'**
  String get mistakesMade;

  /// Mistakes made subtitle
  ///
  /// In en, this message translates to:
  /// **'Every mistake is a chance to learn and grow in your Bible knowledge!'**
  String get bijbelquizGenMistakesSubtitle;

  /// Time spent label
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get timeSpent;

  /// Time spent subtitle
  ///
  /// In en, this message translates to:
  /// **'You took time to deepen your Bible knowledge!'**
  String get bijbelquizGenTimeSubtitle;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bijbelquizGenBestStreak;

  /// Streak subtitle
  ///
  /// In en, this message translates to:
  /// **'Your longest streak shows your consistency and dedication!'**
  String get bijbelquizGenStreakSubtitle;

  /// Year in review label
  ///
  /// In en, this message translates to:
  /// **'Your year in review'**
  String get yearInReview;

  /// Year review subtitle
  ///
  /// In en, this message translates to:
  /// **'An overview of your BibleQuiz performance in the past year!'**
  String get bijbelquizGenYearReviewSubtitle;

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Correct answers label
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get correctAnswers;

  /// Accuracy label
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// Thank you message
  ///
  /// In en, this message translates to:
  /// **'Thank you for using BibleQuiz!'**
  String get thankYouForUsingBijbelQuiz;

  /// Thank you text
  ///
  /// In en, this message translates to:
  /// **'We hope our app has been a blessing this past year.'**
  String get bijbelquizGenThankYouText;

  /// Donate button text
  ///
  /// In en, this message translates to:
  /// **'Donate to us to show your continued support for our development, so we can continue to improve the app and so you can look back on another educational year next year.'**
  String get bijbelquizGenDonateButton;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get bijbelquizGenSkip;

  /// Success label
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Report submitted success
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted successfully!'**
  String get reportSubmittedSuccessfully;

  /// Report submission failed
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report. Please try again later.'**
  String get reportSubmissionFailed;

  /// Report bug button
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// Report bug description
  ///
  /// In en, this message translates to:
  /// **'Report a bug or issue with the app'**
  String get reportBugDescription;

  /// Subject label
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// Please enter subject
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get pleaseEnterSubject;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Please enter description
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// Email optional label
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// Report question button
  ///
  /// In en, this message translates to:
  /// **'Report Question'**
  String get reportQuestion;

  /// Question reported success
  ///
  /// In en, this message translates to:
  /// **'Question reported successfully'**
  String get questionReportedSuccessfully;

  /// Error reporting question
  ///
  /// In en, this message translates to:
  /// **'Error reporting question'**
  String get errorReportingQuestion;

  /// Grid layout
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// List layout
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// Compact grid layout
  ///
  /// In en, this message translates to:
  /// **'Compact Grid'**
  String get compactGrid;

  /// Use theme button
  ///
  /// In en, this message translates to:
  /// **'Use Theme'**
  String get useTheme;

  /// Failed to remove device
  ///
  /// In en, this message translates to:
  /// **'Failed to remove device'**
  String get failedToRemoveDevice;

  /// Error removing device
  ///
  /// In en, this message translates to:
  /// **'Error removing device: '**
  String get errorRemovingDevice;

  /// Shared statistics
  ///
  /// In en, this message translates to:
  /// **'Shared Statistics'**
  String get sharedStats;

  /// New game button
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// Error loading usernames
  ///
  /// In en, this message translates to:
  /// **'Error loading usernames: '**
  String get errorLoadingUsernames;

  /// URL copied message
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard!'**
  String get urlCopiedToClipboard;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// Check connection button
  ///
  /// In en, this message translates to:
  /// **'Check Connection'**
  String get checkConnection;

  /// Go to quiz button
  ///
  /// In en, this message translates to:
  /// **'Go to Quiz'**
  String get goToQuiz;

  /// Error loading analytics
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics'**
  String get errorLoadingAnalytics;

  /// Bible reference copied for sharing
  ///
  /// In en, this message translates to:
  /// **'Bible reference copied for sharing'**
  String get bibleReferenceCopiedForSharing;

  /// Error handling test
  ///
  /// In en, this message translates to:
  /// **'Error Handling Test'**
  String get errorHandlingTest;

  /// Error handling test description
  ///
  /// In en, this message translates to:
  /// **'This screen demonstrates the new error handling system'**
  String get errorHandlingTestDescription;

  /// Test error handling button
  ///
  /// In en, this message translates to:
  /// **'Test Error Handling'**
  String get testErrorHandling;

  /// Test error dialog button
  ///
  /// In en, this message translates to:
  /// **'Test Error Dialog'**
  String get testErrorDialog;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Search settings input
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get searchSettings;

  /// Lesson layout settings
  ///
  /// In en, this message translates to:
  /// **'Lesson Layout'**
  String get lessonLayoutSettings;

  /// Choose lesson layout description
  ///
  /// In en, this message translates to:
  /// **'Choose how lessons are displayed'**
  String get chooseLessonLayoutDesc;

  /// Show introduction description
  ///
  /// In en, this message translates to:
  /// **'View the app introduction and tutorial'**
  String get showIntroductionDesc;

  /// Clear question cache description
  ///
  /// In en, this message translates to:
  /// **'Remove cached questions to free up storage space'**
  String get clearQuestionCacheDesc;

  /// Follow on social media description
  ///
  /// In en, this message translates to:
  /// **'Connect with us on social media platforms'**
  String get followOnSocialMediaDesc;

  /// Invite friend description
  ///
  /// In en, this message translates to:
  /// **'Share a personalized invite link with friends'**
  String get inviteFriendDesc;

  /// Bug report button
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// Bug report description
  ///
  /// In en, this message translates to:
  /// **'Report bugs and issues with the app'**
  String get bugReportDesc;

  /// Streak label suffix
  ///
  /// In en, this message translates to:
  /// **' streak'**
  String get streakLabel;

  /// Unknown user label
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// Last score label
  ///
  /// In en, this message translates to:
  /// **'Last score:'**
  String get lastScore;

  /// Not available label
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get notAvailable;

  /// Followed users scores
  ///
  /// In en, this message translates to:
  /// **'Scores of Followed Users'**
  String get followedUsersScores;

  /// Thank you for support
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get thankYouForSupport;

  /// Thank you for your support message
  ///
  /// In en, this message translates to:
  /// **'We appreciate you using BibleQuiz and participating in our community.'**
  String get thankYouForYourSupport;

  /// Support with donation button
  ///
  /// In en, this message translates to:
  /// **'Support us with a donation'**
  String get supportWithDonation;

  /// Donation text
  ///
  /// In en, this message translates to:
  /// **'Your donation helps us maintain and improve BibleQuiz for you and others.'**
  String get bijbelquizGenDonationText;

  /// No expiration date
  ///
  /// In en, this message translates to:
  /// **'No expiration date'**
  String get noExpirationDate;

  /// Username label
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Enter username input
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// Username input hint
  ///
  /// In en, this message translates to:
  /// **'e.g. John2026'**
  String get usernameHint;

  /// Save username button
  ///
  /// In en, this message translates to:
  /// **'Save username'**
  String get saveUsername;

  /// Please enter username
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// Username too long error
  ///
  /// In en, this message translates to:
  /// **'Username must be at most 30 characters'**
  String get usernameTooLong;

  /// Username already taken error
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameAlreadyTaken;

  /// Username blacklisted error
  ///
  /// In en, this message translates to:
  /// **'This username is not allowed'**
  String get usernameBlacklisted;

  /// Username saved message
  ///
  /// In en, this message translates to:
  /// **'Username saved!'**
  String get usernameSaved;

  /// Beta label
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get beta;

  /// Share stats title
  ///
  /// In en, this message translates to:
  /// **'Share your stats'**
  String get shareStatsTitle;

  /// Share your BibleQuiz stats
  ///
  /// In en, this message translates to:
  /// **'Share your BibleQuiz stats'**
  String get shareYourBijbelQuizStats;

  /// Correct answers for sharing
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get correctAnswersShare;

  /// Current streak for sharing
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreakShare;

  /// Best streak for sharing
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreakShare;

  /// Mistakes for sharing
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get mistakesShare;

  /// Accuracy for sharing
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyShare;

  /// Time spent for sharing
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get timeSpentShare;

  /// Share results button
  ///
  /// In en, this message translates to:
  /// **'Share your results'**
  String get shareResults;

  /// Copy link button
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// Automatic bug reports toggle
  ///
  /// In en, this message translates to:
  /// **'Automatic bug reporting'**
  String get automaticBugReports;

  /// Automatic bug reports description
  ///
  /// In en, this message translates to:
  /// **'Automatically send bug reports when errors occur (recommended)'**
  String get automaticBugReportsDesc;

  /// Motivational notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Motivational notifications'**
  String get motivationalNotifications;

  /// Motivational notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive 1-3 notifications per day between 06:00 and 23:00 to encourage you to do a quiz'**
  String get motivationalNotificationsDesc;

  /// Data sync success
  ///
  /// In en, this message translates to:
  /// **'Data successfully synchronized'**
  String get dataSuccessfullySynchronized;

  /// Sync failed message
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed: '**
  String get synchronizationFailed;

  /// Edit profile button
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Adjust name and bio button
  ///
  /// In en, this message translates to:
  /// **'Adjust name and bio'**
  String get adjustNameAndBio;

  /// Change username button
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get changeUsername;

  /// Adjust your username button
  ///
  /// In en, this message translates to:
  /// **'Adjust your username'**
  String get adjustYourUsername;

  /// Change password button
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Secure your account button
  ///
  /// In en, this message translates to:
  /// **'Secure your account'**
  String get secureYourAccount;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out from device button
  ///
  /// In en, this message translates to:
  /// **'Sign out from this device'**
  String get signOutFromDevice;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Permanently delete account button
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account'**
  String get permanentlyDeleteAccount;

  /// Display name label
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// Bio optional label
  ///
  /// In en, this message translates to:
  /// **'Bio (optional)'**
  String get bioOptional;

  /// New username input
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get newUsername;

  /// Choose unique name
  ///
  /// In en, this message translates to:
  /// **'Choose a unique name'**
  String get chooseUniqueName;

  /// Current password input
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// New password input
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// Minimum 6 characters
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Characters;

  /// Confirm new password input
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// Fill all password fields
  ///
  /// In en, this message translates to:
  /// **'Fill in all password fields'**
  String get fillAllPasswordFields;

  /// Passwords do not match
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// New password minimum 6 characters
  ///
  /// In en, this message translates to:
  /// **'New password must contain at least 6 characters'**
  String get newPasswordMin6Chars;

  /// Enter new username
  ///
  /// In en, this message translates to:
  /// **'Enter a new username'**
  String get enterNewUsername;

  /// Username minimum 3 characters
  ///
  /// In en, this message translates to:
  /// **'Username must contain at least 3 characters'**
  String get usernameMin3Chars;

  /// Username maximum 20 characters
  ///
  /// In en, this message translates to:
  /// **'Username may contain at most 20 characters'**
  String get usernameMax20Chars;

  /// Username not allowed
  ///
  /// In en, this message translates to:
  /// **'This username is not allowed'**
  String get usernameNotAllowed;

  /// Username already taken
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get thisUsernameAlreadyTaken;

  /// Username changed success
  ///
  /// In en, this message translates to:
  /// **'Username successfully changed'**
  String get usernameSuccessfullyChanged;

  /// Username change failed
  ///
  /// In en, this message translates to:
  /// **'Failed to change username'**
  String get failedToChangeUsername;

  /// Display name required
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get displayNameRequired;

  /// Profile update success
  ///
  /// In en, this message translates to:
  /// **'Profile successfully updated'**
  String get profileSuccessfullyUpdated;

  /// Profile update failed
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// Sign out failed
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// Password change success
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed'**
  String get passwordSuccessfullyChanged;

  /// Password change failed
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// Updated label
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// Not updated label
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get notUpdated;

  /// Last sync label
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get lastSync;

  /// User label
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Account label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Syncing status
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// Sync button
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Change button
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Never label
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Just now label
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Minutes ago label
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// Hours ago label
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// Days ago label
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No email label
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// Leaderboard label
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No leaderboard data
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data available'**
  String get noLeaderboardData;

  /// ELIM50 coupon message
  ///
  /// In en, this message translates to:
  /// **'You got 50 points and got 50 cents donated for the renovation of Elim!'**
  String get elim50CouponMessage;

  /// Login with BQID button
  ///
  /// In en, this message translates to:
  /// **'Login with your BQID'**
  String get loginWithBqid;

  /// Social features message
  ///
  /// In en, this message translates to:
  /// **'Create an account to use social features, such as searching for users, making friends and sending messages.'**
  String get socialFeaturesMessage;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// Email label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email input hint
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// Username signup hint
  ///
  /// In en, this message translates to:
  /// **'Choose a unique name'**
  String get usernameSignupHint;

  /// Password label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password input hint
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordHint;

  /// Confirm password label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// Confirm password hint
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get confirmPasswordHint;

  /// Account created message
  ///
  /// In en, this message translates to:
  /// **'Account created! Check your email for verification.'**
  String get accountCreatedMessage;

  /// Fill email and password
  ///
  /// In en, this message translates to:
  /// **'Fill in your email and password to continue.'**
  String get fillEmailAndPassword;

  /// Enter valid email
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get enterValidEmail;

  /// Fill all fields
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields to create an account.'**
  String get fillAllFields;

  /// Passwords do not match
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match. Check if you entered the same in both fields.'**
  String get passwordsDoNotMatch;

  /// Password too short
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters for your security.'**
  String get passwordTooShort;

  /// Checking password
  ///
  /// In en, this message translates to:
  /// **'Password is being checked for security...'**
  String get checkingPassword;

  /// Password compromised
  ///
  /// In en, this message translates to:
  /// **'This password has been found in data breaches. Choose a different password for your security.'**
  String get passwordCompromised;

  /// Username too short
  ///
  /// In en, this message translates to:
  /// **'Username must contain at least 3 characters.'**
  String get usernameTooShort;

  /// Username too long
  ///
  /// In en, this message translates to:
  /// **'Username may contain at most 20 characters.'**
  String get usernameSignupTooLong;

  /// Username invalid characters
  ///
  /// In en, this message translates to:
  /// **'Username may only contain letters, numbers and underscores.'**
  String get usernameInvalidChars;

  /// Checking username
  ///
  /// In en, this message translates to:
  /// **'Username availability is being checked...'**
  String get checkingUsername;

  /// Invalid email or password
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Check your details and try again.'**
  String get invalidEmailOrPassword;

  /// Email not confirmed
  ///
  /// In en, this message translates to:
  /// **'Your email has not been verified. Check your inbox and click the verification link.'**
  String get emailNotConfirmed;

  /// Too many requests
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment before trying again.'**
  String get tooManyRequests;

  /// Password too short generic
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 6 characters.'**
  String get passwordTooShortGeneric;

  /// Invalid email address
  ///
  /// In en, this message translates to:
  /// **'Invalid email address. Make sure you entered a valid email address.'**
  String get invalidEmailAddress;

  /// User already registered
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists. Try logging in or use a different email address.'**
  String get userAlreadyRegistered;

  /// Sign up disabled
  ///
  /// In en, this message translates to:
  /// **'Sign up is currently disabled. Try again later.'**
  String get signupDisabled;

  /// Weak password
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Choose a stronger password with more characters.'**
  String get weakPassword;

  /// Generic error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again or contact support if the problem persists.'**
  String get genericError;

  /// Guide account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get guideAccount;

  /// Guide account description
  ///
  /// In en, this message translates to:
  /// **'Create an account or log in to save your progress and use social features.'**
  String get guideAccountDescription;

  /// Coupon redeem description
  ///
  /// In en, this message translates to:
  /// **'You can redeem coupon codes later at the shop menu.'**
  String get couponRedeemDescription;

  /// Terms agreement text
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get termsAgreementText;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get termsOfService;

  /// Progress overview
  ///
  /// In en, this message translates to:
  /// **'Progress overview'**
  String get progressOverview;

  /// Progress overview hint
  ///
  /// In en, this message translates to:
  /// **'Shows your current progress through lessons'**
  String get progressOverviewHint;

  /// Lesson completion progress
  ///
  /// In en, this message translates to:
  /// **'Lesson completion progress'**
  String get lessonCompletionProgress;

  /// Lessons completed progress
  ///
  /// In en, this message translates to:
  /// **'{unlocked} out of {total} lessons completed'**
  String lessonsCompleted(int unlocked, int total);

  /// Continue with specific lesson
  ///
  /// In en, this message translates to:
  /// **'Continue with lesson: {lessonTitle}'**
  String continueWithLesson(String lessonTitle);

  /// Continue with lesson hint
  ///
  /// In en, this message translates to:
  /// **'Start the next recommended lesson in your progress'**
  String get continueWithLessonHint;

  /// Practice mode
  ///
  /// In en, this message translates to:
  /// **'Practice mode'**
  String get practiceMode;

  /// Practice mode hint
  ///
  /// In en, this message translates to:
  /// **'Start a random practice quiz without affecting progress'**
  String get practiceModeHint;

  /// Multiplayer mode
  ///
  /// In en, this message translates to:
  /// **'Multiplayer mode'**
  String get multiplayerMode;

  /// Multiplayer mode hint
  ///
  /// In en, this message translates to:
  /// **'Start a multiplayer quiz game'**
  String get multiplayerModeHint;

  /// Start random practice quiz button
  ///
  /// In en, this message translates to:
  /// **'Start a random practice quiz'**
  String get startRandomPracticeQuiz;

  /// Play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playButton;

  /// No description provided for @dailyStreakDescription_one.
  ///
  /// In en, this message translates to:
  /// **'You have been using BibleQuiz for a day in a row'**
  String dailyStreakDescription_one(Object streakDays);

  /// No description provided for @dailyStreakDescription_other.
  ///
  /// In en, this message translates to:
  /// **'You have been using BibleQuiz for {streakDays} days in a row'**
  String dailyStreakDescription_other(Object streakDays);

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// Question reported by user
  ///
  /// In en, this message translates to:
  /// **'Question reported by user'**
  String get questionReportedByUser;

  /// Invalid biblical reference in question
  ///
  /// In en, this message translates to:
  /// **'Invalid biblical reference in question'**
  String get invalidBiblicalReferenceInQuestion;

  /// Please enter data to import
  ///
  /// In en, this message translates to:
  /// **'Please enter data to import'**
  String get pleaseEnterDataToImport;

  /// Import failed message
  ///
  /// In en, this message translates to:
  /// **'Import failed: '**
  String get importFailed;

  /// Error loading store
  ///
  /// In en, this message translates to:
  /// **'Error loading store'**
  String get errorLoadingStore;

  /// Purchase failed message
  ///
  /// In en, this message translates to:
  /// **'Purchase failed, please try again'**
  String get purchaseFailed;

  /// Purchase error string
  ///
  /// In en, this message translates to:
  /// **'Error during purchase: {error}'**
  String purchaseErrorString(String error);

  /// Christmas theme name
  ///
  /// In en, this message translates to:
  /// **'Christmas Theme'**
  String get christmasTheme;

  /// Christmas theme description
  ///
  /// In en, this message translates to:
  /// **'A festive Christmas theme with red and green colors'**
  String get christmasThemeDescription;

  /// Terminal green theme name
  ///
  /// In en, this message translates to:
  /// **'Terminal Green'**
  String get terminalGreenTheme;

  /// Terminal green theme description
  ///
  /// In en, this message translates to:
  /// **'A classic terminal theme with green text on a black background'**
  String get terminalGreenThemeDescription;

  /// Ocean blue theme name
  ///
  /// In en, this message translates to:
  /// **'Ocean Blue'**
  String get oceanBlueTheme;

  /// Ocean blue theme description
  ///
  /// In en, this message translates to:
  /// **'A bright ocean blue theme for a fresh look'**
  String get oceanBlueThemeDescription;

  /// Rose white theme name
  ///
  /// In en, this message translates to:
  /// **'Rose White'**
  String get roseWhiteTheme;

  /// Rose white theme description
  ///
  /// In en, this message translates to:
  /// **'An elegant pink and white theme'**
  String get roseWhiteThemeDescription;

  /// Dark wood theme name
  ///
  /// In en, this message translates to:
  /// **'Dark Wood'**
  String get darkWoodTheme;

  /// Dark wood theme description
  ///
  /// In en, this message translates to:
  /// **'A warm dark wood theme'**
  String get darkWoodThemeDescription;

  /// Payment error message
  ///
  /// In en, this message translates to:
  /// **'Payment error: {error}'**
  String paymentError(String error);

  /// Error opening AI theme generator
  ///
  /// In en, this message translates to:
  /// **'Error opening AI theme generator'**
  String get errorOpeningAiThemeGenerator;

  /// Discount label
  ///
  /// In en, this message translates to:
  /// **'Discount!'**
  String get discount;

  /// Bible reference copied message
  ///
  /// In en, this message translates to:
  /// **'Bible reference copied: {reference}'**
  String bibleReferenceCopied(String reference);

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Share Bible reference
  ///
  /// In en, this message translates to:
  /// **'Bible reference: {reference} ({translation})'**
  String shareBibleReference(String reference, String translation);

  /// Lesson label with number and title
  ///
  /// In en, this message translates to:
  /// **'Lesson {index}: {title}'**
  String lessonLabel(int index, String title);

  /// Unlocked but not playable status
  ///
  /// In en, this message translates to:
  /// **'unlocked but not playable'**
  String get unlockedButNotPlayable;

  /// Locked lesson hint
  ///
  /// In en, this message translates to:
  /// **'This lesson is locked. Complete previous lessons to unlock it.'**
  String get lockedHint;

  /// Unlocked but not playable hint
  ///
  /// In en, this message translates to:
  /// **'This lesson is unlocked but you can only play the most recent unlocked lesson.'**
  String get unlockedButNotPlayableHint;

  /// Tap to start lesson
  ///
  /// In en, this message translates to:
  /// **'Tap to start this lesson'**
  String get tapToStart;

  /// Recommended label
  ///
  /// In en, this message translates to:
  /// **'Recommended: {label}'**
  String recommended(String label);

  /// Lesson number
  ///
  /// In en, this message translates to:
  /// **'Lesson {index}'**
  String lessonNumber(int index);

  /// Book icon accessibility label
  ///
  /// In en, this message translates to:
  /// **'Book icon representing lesson content'**
  String get bookIconSemanticLabel;

  /// Locked special lesson accessibility label
  ///
  /// In en, this message translates to:
  /// **'Locked special lesson'**
  String get lockedSpecialLessonSemanticLabel;

  /// Locked lesson accessibility label
  ///
  /// In en, this message translates to:
  /// **'Locked lesson'**
  String get lockedLessonSemanticLabel;

  /// Multiple choice question label
  ///
  /// In en, this message translates to:
  /// **'Multiple choice question'**
  String get mcqLabel;

  /// Multiple choice hint
  ///
  /// In en, this message translates to:
  /// **'Select the correct answer from the options below'**
  String get mcqHint;

  /// Answer options label
  ///
  /// In en, this message translates to:
  /// **'Answer options'**
  String get answerOptionsLabel;

  /// Answer options hint
  ///
  /// In en, this message translates to:
  /// **'Choose one of the {count} options'**
  String answerOptionsHint(int count);

  /// Fill in the blank label
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank question'**
  String get fitbLabel;

  /// Fill in the blank hint
  ///
  /// In en, this message translates to:
  /// **'Select the word that completes the sentence'**
  String get fitbHint;

  /// Fill in the blank hint 2
  ///
  /// In en, this message translates to:
  /// **'Choose the correct word to fill in the blank'**
  String get fitbHint2;

  /// True or false label
  ///
  /// In en, this message translates to:
  /// **'True or False question'**
  String get tfLabel;

  /// True or false hint
  ///
  /// In en, this message translates to:
  /// **'Select whether the statement is true or false'**
  String get tfHint;

  /// True or false hint 2
  ///
  /// In en, this message translates to:
  /// **'Choose True or False'**
  String get tfHint2;

  /// True option
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueText;

  /// False option
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseText;

  /// Question label
  ///
  /// In en, this message translates to:
  /// **'Question: {question}'**
  String questionLabel(String question);

  /// Blank placeholder
  ///
  /// In en, this message translates to:
  /// **'______'**
  String get blank;

  /// Lesson locked message
  ///
  /// In en, this message translates to:
  /// **'Lesson is still locked'**
  String get lessonLocked;

  /// Dutch language name
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageNl;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// Selected accessibility label
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selectedEn;

  /// New messages or login required
  ///
  /// In en, this message translates to:
  /// **'New messages or login required'**
  String get newMessagesOrLoginRequiredEn;

  /// Active discounts available
  ///
  /// In en, this message translates to:
  /// **'Active discounts available'**
  String get activeDiscountsAvailableEn;

  /// Enabled status
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabledEn;

  /// Disabled status
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabledEn;

  /// Clear search accessibility label
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearchEn;

  /// Open BQID settings accessibility label
  ///
  /// In en, this message translates to:
  /// **'Open BQID settings'**
  String get openBQIDSettingsEn;

  /// Section icon accessibility label
  ///
  /// In en, this message translates to:
  /// **'{section} section icon'**
  String sectionIconEn(String section);

  /// Page indicator accessibility label
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String pageIndicatorEn(int current, int total);

  /// Reaction button accessibility label
  ///
  /// In en, this message translates to:
  /// **'{emoji} reaction'**
  String reactionButtonEn(Object emoji);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
