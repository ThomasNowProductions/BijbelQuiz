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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BibleQuiz'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Test Your Bible Knowledge'**
  String get appDescription;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @incorrect.
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// No description provided for @quizComplete.
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// No description provided for @yourScore.
  ///
  /// In en, this message translates to:
  /// **'Your score: '**
  String get yourScore;

  /// No description provided for @unlockBiblicalReference.
  ///
  /// In en, this message translates to:
  /// **'Unlock Bible Reference (Beta)'**
  String get unlockBiblicalReference;

  /// No description provided for @biblicalReference.
  ///
  /// In en, this message translates to:
  /// **'Bible Reference'**
  String get biblicalReference;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @continueLearning.
  ///
  /// In en, this message translates to:
  /// **'Continue Learning'**
  String get continueLearning;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @unlockAll.
  ///
  /// In en, this message translates to:
  /// **'Unlock All'**
  String get unlockAll;

  /// No description provided for @purchaseSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Purchase Successful!'**
  String get purchaseSuccessful;

  /// No description provided for @donate.
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get donate;

  /// No description provided for @donateButton.
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donateButton;

  /// No description provided for @donateExplanation.
  ///
  /// In en, this message translates to:
  /// **'Support the development of this app with a donation. This is needed to continue developing/maintaining the app.'**
  String get donateExplanation;

  /// No description provided for @guide.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get guide;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to Play'**
  String get howToPlay;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get connectionError;

  /// No description provided for @connectionErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get connectionErrorMsg;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get unknownError;

  /// No description provided for @errorNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'No valid questions found'**
  String get errorNoQuestions;

  /// No description provided for @errorLoadQuestions.
  ///
  /// In en, this message translates to:
  /// **'Error loading questions'**
  String get errorLoadQuestions;

  /// No description provided for @couldNotOpenDonationPage.
  ///
  /// In en, this message translates to:
  /// **'Could not open donation page'**
  String get couldNotOpenDonationPage;

  /// No description provided for @aiError.
  ///
  /// In en, this message translates to:
  /// **'AI service error occurred'**
  String get aiError;

  /// No description provided for @apiError.
  ///
  /// In en, this message translates to:
  /// **'API service error occurred'**
  String get apiError;

  /// No description provided for @storageError.
  ///
  /// In en, this message translates to:
  /// **'Storage error occurred'**
  String get storageError;

  /// No description provided for @syncError.
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed'**
  String get syncError;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission required for this feature'**
  String get permissionDenied;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @screenSizeNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Screen size not supported'**
  String get screenSizeNotSupported;

  /// No description provided for @yourProgress.
  ///
  /// In en, this message translates to:
  /// **'Your Progress'**
  String get yourProgress;

  /// No description provided for @dailyStreak.
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get dailyStreak;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue With'**
  String get continueWith;

  /// No description provided for @multiplayerQuiz.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer Quiz'**
  String get multiplayerQuiz;

  /// No description provided for @chooseGameDuration.
  ///
  /// In en, this message translates to:
  /// **'Choose game duration'**
  String get chooseGameDuration;

  /// No description provided for @startMultiplayerQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start Multiplayer Quiz'**
  String get startMultiplayerQuiz;

  /// No description provided for @multiplayerDescription.
  ///
  /// In en, this message translates to:
  /// **'Play against each other on one phone! The phone is split in two - the top half rotates 180 degrees.'**
  String get multiplayerDescription;

  /// No description provided for @gameRules.
  ///
  /// In en, this message translates to:
  /// **'Game rules:'**
  String get gameRules;

  /// No description provided for @ruleBothPlayers.
  ///
  /// In en, this message translates to:
  /// **'• Both players answer Bible questions'**
  String get ruleBothPlayers;

  /// No description provided for @ruleCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'• A correct answer gives points'**
  String get ruleCorrectAnswer;

  /// No description provided for @ruleWinner.
  ///
  /// In en, this message translates to:
  /// **'• The one with the correct answers at the end wins'**
  String get ruleWinner;

  /// No description provided for @ruleScreenRotation.
  ///
  /// In en, this message translates to:
  /// **'• The top half of the screen rotates 180 degrees on mobile'**
  String get ruleScreenRotation;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time is up!'**
  String get timeUp;

  /// No description provided for @timeUpMessage.
  ///
  /// In en, this message translates to:
  /// **'You did not answer in time. Your streak has been reset.'**
  String get timeUpMessage;

  /// No description provided for @notEnoughPoints.
  ///
  /// In en, this message translates to:
  /// **'Not Enough Points'**
  String get notEnoughPoints;

  /// No description provided for @lessonComplete.
  ///
  /// In en, this message translates to:
  /// **'Lesson Complete'**
  String get lessonComplete;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'Percentage'**
  String get percentage;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @retryLesson.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryLesson;

  /// No description provided for @nextLesson.
  ///
  /// In en, this message translates to:
  /// **'Next Lesson'**
  String get nextLesson;

  /// No description provided for @backToLessons.
  ///
  /// In en, this message translates to:
  /// **'Back to Lessons'**
  String get backToLessons;

  /// No description provided for @endScore.
  ///
  /// In en, this message translates to:
  /// **'End Score'**
  String get endScore;

  /// No description provided for @endScoreHint.
  ///
  /// In en, this message translates to:
  /// **'Your total score in percentage on a speedometer'**
  String get endScoreHint;

  /// No description provided for @display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your theme'**
  String get chooseTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @oledTheme.
  ///
  /// In en, this message translates to:
  /// **'OLED'**
  String get oledTheme;

  /// No description provided for @greenTheme.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get greenTheme;

  /// No description provided for @orangeTheme.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orangeTheme;

  /// No description provided for @showNavigationLabels.
  ///
  /// In en, this message translates to:
  /// **'Show Navigation Labels'**
  String get showNavigationLabels;

  /// No description provided for @showNavigationLabelsDesc.
  ///
  /// In en, this message translates to:
  /// **'Show or hide text labels below navigation icons'**
  String get showNavigationLabelsDesc;

  /// No description provided for @colorfulMode.
  ///
  /// In en, this message translates to:
  /// **'Colorful Mode'**
  String get colorfulMode;

  /// No description provided for @colorfulModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Enable different colors for lesson cards'**
  String get colorfulModeDesc;

  /// No description provided for @hidePopup.
  ///
  /// In en, this message translates to:
  /// **'Hide promotion popup'**
  String get hidePopup;

  /// No description provided for @hidePopupDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you only want to enable this setting if you have donated to us? We have no way to verify this, but we trust you to be honest.'**
  String get hidePopupDesc;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @couldNotOpenStatusPage.
  ///
  /// In en, this message translates to:
  /// **'Could not open status page.'**
  String get couldNotOpenStatusPage;

  /// No description provided for @lessonLayout.
  ///
  /// In en, this message translates to:
  /// **'Lesson Layout'**
  String get lessonLayout;

  /// No description provided for @chooseLessonLayout.
  ///
  /// In en, this message translates to:
  /// **'Choose how lessons are displayed'**
  String get chooseLessonLayout;

  /// No description provided for @layoutGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get layoutGrid;

  /// No description provided for @layoutList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get layoutList;

  /// No description provided for @layoutCompactGrid.
  ///
  /// In en, this message translates to:
  /// **'Compact Grid'**
  String get layoutCompactGrid;

  /// No description provided for @couldNotLoadLessons.
  ///
  /// In en, this message translates to:
  /// **'Could not load lessons'**
  String get couldNotLoadLessons;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @resetProgress.
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get resetProgress;

  /// No description provided for @resetProgressConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset your progress? This cannot be undone.'**
  String get resetProgressConfirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @startLesson.
  ///
  /// In en, this message translates to:
  /// **'Start Lesson'**
  String get startLesson;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get locked;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @perfectScore.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score!'**
  String get perfectScore;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BibleQuiz'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover the Bible in a fun and interactive way with challenging questions and lessons.'**
  String get welcomeDescription;

  /// No description provided for @howToPlayTitle.
  ///
  /// In en, this message translates to:
  /// **'How to Play?'**
  String get howToPlayTitle;

  /// No description provided for @howToPlayDescription.
  ///
  /// In en, this message translates to:
  /// **'Answer questions about the Bible. The more accurate your answer, the more points you earn. You can later spend points in the shop on exclusive themes and power-ups.'**
  String get howToPlayDescription;

  /// No description provided for @trackProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Play alone, with friends or family'**
  String get trackProgressTitle;

  /// No description provided for @trackProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Go to the \"Social\" tab to follow friends or click on Multiplayer Quiz to play together.'**
  String get trackProgressDescription;

  /// No description provided for @customizeExperienceTitle.
  ///
  /// In en, this message translates to:
  /// **'Customize Your Experience'**
  String get customizeExperienceTitle;

  /// No description provided for @customizeExperienceDescription.
  ///
  /// In en, this message translates to:
  /// **'Customize your theme, game speed, and sound effects in the settings. Do you have any questions or suggestions? We would love to hear from you at {email}'**
  String customizeExperienceDescription(Object email);

  /// No description provided for @supportUsDescription.
  ///
  /// In en, this message translates to:
  /// **'Do you find this app useful? Consider donating to help us maintain and improve the app. Every contribution is appreciated!'**
  String get supportUsDescription;

  /// No description provided for @donateNow.
  ///
  /// In en, this message translates to:
  /// **'Donate Now'**
  String get donateNow;

  /// No description provided for @activationTitle.
  ///
  /// In en, this message translates to:
  /// **'Activate your account'**
  String get activationTitle;

  /// No description provided for @activationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your activation code to use the app'**
  String get activationSubtitle;

  /// No description provided for @activationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your activation code'**
  String get activationCodeHint;

  /// No description provided for @activateButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activateButton;

  /// No description provided for @verifyButton.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// No description provided for @verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get verifying;

  /// No description provided for @activationTip.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code you received with your purchase.'**
  String get activationTip;

  /// No description provided for @activationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Successfully activated!'**
  String get activationSuccess;

  /// No description provided for @activationError.
  ///
  /// In en, this message translates to:
  /// **'Invalid activation code. Please try again.'**
  String get activationError;

  /// No description provided for @activationErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Activation Failed'**
  String get activationErrorTitle;

  /// No description provided for @activationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your account has been successfully activated. Enjoy the app!'**
  String get activationSuccessMessage;

  /// No description provided for @activationRequired.
  ///
  /// In en, this message translates to:
  /// **'Activation Required'**
  String get activationRequired;

  /// No description provided for @activationRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'You must activate the app before you can use it.'**
  String get activationRequiredMessage;

  /// No description provided for @yourStars.
  ///
  /// In en, this message translates to:
  /// **'Your Stars'**
  String get yourStars;

  /// No description provided for @availableStars.
  ///
  /// In en, this message translates to:
  /// **'Available Stars'**
  String get availableStars;

  /// No description provided for @powerUps.
  ///
  /// In en, this message translates to:
  /// **'Power-ups'**
  String get powerUps;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// No description provided for @availableThemes.
  ///
  /// In en, this message translates to:
  /// **'Available Themes'**
  String get availableThemes;

  /// No description provided for @unlockTheme.
  ///
  /// In en, this message translates to:
  /// **'Unlock Theme'**
  String get unlockTheme;

  /// No description provided for @unlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get unlocked;

  /// No description provided for @notEnoughStars.
  ///
  /// In en, this message translates to:
  /// **'Not Enough Stars'**
  String get notEnoughStars;

  /// No description provided for @unlockFor.
  ///
  /// In en, this message translates to:
  /// **'Unlock for'**
  String get unlockFor;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'stars'**
  String get stars;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @confirmPurchase.
  ///
  /// In en, this message translates to:
  /// **'Confirm Purchase'**
  String get confirmPurchase;

  /// No description provided for @purchaseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unlock this theme for'**
  String get purchaseConfirmation;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Theme successfully unlocked!'**
  String get purchaseSuccess;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Not enough stars to unlock this theme.'**
  String get purchaseError;

  /// No description provided for @couldNotOpenDownloadPage.
  ///
  /// In en, this message translates to:
  /// **'Could not open download page'**
  String get couldNotOpenDownloadPage;

  /// No description provided for @themeUnlockedWithSwitchOption.
  ///
  /// In en, this message translates to:
  /// **'unlocked! You can always return to the default theme in settings.'**
  String get themeUnlockedWithSwitchOption;

  /// No description provided for @doubleStars5Questions.
  ///
  /// In en, this message translates to:
  /// **'Double Stars (5 questions)'**
  String get doubleStars5Questions;

  /// No description provided for @doubleStars5QuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn double stars for your next 5 questions'**
  String get doubleStars5QuestionsDesc;

  /// No description provided for @tripleStars5Questions.
  ///
  /// In en, this message translates to:
  /// **'Triple Stars (5 questions)'**
  String get tripleStars5Questions;

  /// No description provided for @tripleStars5QuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn triple stars for your next 5 questions'**
  String get tripleStars5QuestionsDesc;

  /// No description provided for @fiveTimesStars5Questions.
  ///
  /// In en, this message translates to:
  /// **'5x Stars (5 questions)'**
  String get fiveTimesStars5Questions;

  /// No description provided for @fiveTimesStars5QuestionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn 5x stars for your next 5 questions'**
  String get fiveTimesStars5QuestionsDesc;

  /// No description provided for @doubleStars60Seconds.
  ///
  /// In en, this message translates to:
  /// **'Double Stars (60 seconds)'**
  String get doubleStars60Seconds;

  /// No description provided for @doubleStars60SecondsDesc.
  ///
  /// In en, this message translates to:
  /// **'Earn double stars for 60 seconds'**
  String get doubleStars60SecondsDesc;

  /// No description provided for @oledThemeName.
  ///
  /// In en, this message translates to:
  /// **'OLED Theme'**
  String get oledThemeName;

  /// No description provided for @oledThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock a true black, high-contrast theme'**
  String get oledThemeDesc;

  /// No description provided for @greenThemeName.
  ///
  /// In en, this message translates to:
  /// **'Green Theme'**
  String get greenThemeName;

  /// No description provided for @greenThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock a fresh green theme'**
  String get greenThemeDesc;

  /// No description provided for @orangeThemeName.
  ///
  /// In en, this message translates to:
  /// **'Orange Theme'**
  String get orangeThemeName;

  /// No description provided for @orangeThemeDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock a vibrant orange theme'**
  String get orangeThemeDesc;

  /// No description provided for @couponTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a coupon code?'**
  String get couponTitle;

  /// No description provided for @couponDescription.
  ///
  /// In en, this message translates to:
  /// **'Redeem it here for rewards'**
  String get couponDescription;

  /// No description provided for @couponRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get couponRedeem;

  /// No description provided for @couponDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Redeem Coupon'**
  String get couponDialogTitle;

  /// No description provided for @couponCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Coupon code'**
  String get couponCodeLabel;

  /// No description provided for @couponCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. SUMMER2023'**
  String get couponCodeHint;

  /// No description provided for @couponSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get couponSuccessTitle;

  /// No description provided for @couponStarsReceived.
  ///
  /// In en, this message translates to:
  /// **'You received {amount} stars!'**
  String couponStarsReceived(Object amount);

  /// No description provided for @couponThemeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'You unlocked a new theme!'**
  String get couponThemeUnlocked;

  /// No description provided for @couponErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get couponErrorTitle;

  /// No description provided for @couponInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid coupon code'**
  String get couponInvalid;

  /// No description provided for @couponExpired.
  ///
  /// In en, this message translates to:
  /// **'This coupon has expired'**
  String get couponExpired;

  /// No description provided for @couponMaxUsed.
  ///
  /// In en, this message translates to:
  /// **'This coupon is no longer valid (maximum uses reached)'**
  String get couponMaxUsed;

  /// No description provided for @couponAlreadyRedeemed.
  ///
  /// In en, this message translates to:
  /// **'This coupon has already been redeemed'**
  String get couponAlreadyRedeemed;

  /// No description provided for @couponMaxPerDay.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 5 coupons can be redeemed per day'**
  String get couponMaxPerDay;

  /// No description provided for @qrCode.
  ///
  /// In en, this message translates to:
  /// **'QR-code'**
  String get qrCode;

  /// No description provided for @qrCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code'**
  String get qrCodeDescription;

  /// No description provided for @qrScannerMobileOnly.
  ///
  /// In en, this message translates to:
  /// **'QR Scanner only available on mobile'**
  String get qrScannerMobileOnly;

  /// No description provided for @invalidQRCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid QR code'**
  String get invalidQRCode;

  /// No description provided for @cameraAccessRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera access required'**
  String get cameraAccessRequired;

  /// No description provided for @cameraAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'To scan QR codes, the app needs access to your camera. This permission is only used for scanning coupons.'**
  String get cameraAccessDescription;

  /// No description provided for @grantCameraPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant camera permission'**
  String get grantCameraPermission;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get cameraError;

  /// No description provided for @cameraInitializationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while initializing the camera: '**
  String get cameraInitializationError;

  /// No description provided for @initializingCamera.
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get initializingCamera;

  /// No description provided for @qrCodeTutorial.
  ///
  /// In en, this message translates to:
  /// **'Hold the QR code within the frame for automatic detection'**
  String get qrCodeTutorial;

  /// No description provided for @supportUsTitle.
  ///
  /// In en, this message translates to:
  /// **'Support Us'**
  String get supportUsTitle;

  /// No description provided for @errorLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error loading settings'**
  String get errorLoadingSettings;

  /// No description provided for @gameSettings.
  ///
  /// In en, this message translates to:
  /// **'Game Settings'**
  String get gameSettings;

  /// No description provided for @gameSpeed.
  ///
  /// In en, this message translates to:
  /// **'Game Speed'**
  String get gameSpeed;

  /// No description provided for @chooseGameSpeed.
  ///
  /// In en, this message translates to:
  /// **'Choose the speed of the game'**
  String get chooseGameSpeed;

  /// No description provided for @slow.
  ///
  /// In en, this message translates to:
  /// **'Slow'**
  String get slow;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @fast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get fast;

  /// No description provided for @muteSoundEffects.
  ///
  /// In en, this message translates to:
  /// **'Mute Sound Effects'**
  String get muteSoundEffects;

  /// No description provided for @muteSoundEffectsDesc.
  ///
  /// In en, this message translates to:
  /// **'Turn off all game sounds'**
  String get muteSoundEffectsDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @serverStatus.
  ///
  /// In en, this message translates to:
  /// **'Server Status'**
  String get serverStatus;

  /// No description provided for @checkServiceStatus.
  ///
  /// In en, this message translates to:
  /// **'Check the status of our services'**
  String get checkServiceStatus;

  /// No description provided for @openStatusPage.
  ///
  /// In en, this message translates to:
  /// **'Open Status Page'**
  String get openStatusPage;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @exportStats.
  ///
  /// In en, this message translates to:
  /// **'Export Statistics'**
  String get exportStats;

  /// No description provided for @exportStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save your progress and scores as text'**
  String get exportStatsDesc;

  /// No description provided for @importStats.
  ///
  /// In en, this message translates to:
  /// **'Import Statistics'**
  String get importStats;

  /// No description provided for @importStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Load previously exported statistics'**
  String get importStatsDesc;

  /// No description provided for @resetAndLogout.
  ///
  /// In en, this message translates to:
  /// **'Reset and Log Out'**
  String get resetAndLogout;

  /// No description provided for @resetAndLogoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear all data and deactivate app'**
  String get resetAndLogoutDesc;

  /// No description provided for @showIntroduction.
  ///
  /// In en, this message translates to:
  /// **'Show Introduction'**
  String get showIntroduction;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// No description provided for @clearQuestionCache.
  ///
  /// In en, this message translates to:
  /// **'Clear Question Cache'**
  String get clearQuestionCache;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @emailNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client'**
  String get emailNotAvailable;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Question cache cleared!'**
  String get cacheCleared;

  /// No description provided for @testAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Test All Features'**
  String get testAllFeatures;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024-2025 ThomasNow Productions'**
  String get copyright;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon!'**
  String get comingSoon;

  /// No description provided for @socialComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'BibleQuiz social features are coming soon. Stay tuned for updates!'**
  String get socialComingSoonMessage;

  /// No description provided for @manageYourBqid.
  ///
  /// In en, this message translates to:
  /// **'Manage Your BQID'**
  String get manageYourBqid;

  /// No description provided for @manageYourBqidSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your BQID, registered devices and more'**
  String get manageYourBqidSubtitle;

  /// No description provided for @moreSocialFeaturesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'More social features coming soon'**
  String get moreSocialFeaturesComingSoon;

  /// No description provided for @socialFeatures.
  ///
  /// In en, this message translates to:
  /// **'Social Features'**
  String get socialFeatures;

  /// No description provided for @connectWithOtherUsers.
  ///
  /// In en, this message translates to:
  /// **'Connect with other BibleQuiz users, share achievements and compete on the leaderboards!'**
  String get connectWithOtherUsers;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @myFollowing.
  ///
  /// In en, this message translates to:
  /// **'My Following'**
  String get myFollowing;

  /// No description provided for @myFollowers.
  ///
  /// In en, this message translates to:
  /// **'My Followers'**
  String get myFollowers;

  /// No description provided for @messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search Users'**
  String get searchUsers;

  /// No description provided for @searchByUsername.
  ///
  /// In en, this message translates to:
  /// **'Search by username'**
  String get searchByUsername;

  /// No description provided for @enterUsernameToSearch.
  ///
  /// In en, this message translates to:
  /// **'Enter username to search...'**
  String get enterUsernameToSearch;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @unfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get unfollow;

  /// No description provided for @yourself.
  ///
  /// In en, this message translates to:
  /// **'Yourself'**
  String get yourself;

  /// No description provided for @bibleBot.
  ///
  /// In en, this message translates to:
  /// **'Bible Bot'**
  String get bibleBot;

  /// No description provided for @couldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email client'**
  String get couldNotOpenEmail;

  /// No description provided for @couldNotOpenUpdatePage.
  ///
  /// In en, this message translates to:
  /// **'Could not open update page'**
  String get couldNotOpenUpdatePage;

  /// No description provided for @errorOpeningUpdatePage.
  ///
  /// In en, this message translates to:
  /// **'Error opening update page: '**
  String get errorOpeningUpdatePage;

  /// No description provided for @couldNotCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Could not copy link'**
  String get couldNotCopyLink;

  /// No description provided for @errorCopyingLink.
  ///
  /// In en, this message translates to:
  /// **'Could not copy link: '**
  String get errorCopyingLink;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invitation link copied to clipboard!'**
  String get inviteLinkCopied;

  /// No description provided for @statsLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Statistics link copied to clipboard!'**
  String get statsLinkCopied;

  /// No description provided for @copyStatsLinkToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy your statistics link to the clipboard'**
  String get copyStatsLinkToClipboard;

  /// No description provided for @importButton.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importButton;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow Us'**
  String get followUs;

  /// No description provided for @followUsMessage.
  ///
  /// In en, this message translates to:
  /// **'Follow us on social media for updates and community!'**
  String get followUsMessage;

  /// No description provided for @followMastodon.
  ///
  /// In en, this message translates to:
  /// **'Follow Mastodon'**
  String get followMastodon;

  /// No description provided for @followPixelfed.
  ///
  /// In en, this message translates to:
  /// **'Follow Pixelfed'**
  String get followPixelfed;

  /// No description provided for @followKwebler.
  ///
  /// In en, this message translates to:
  /// **'Follow Kwebler'**
  String get followKwebler;

  /// No description provided for @followSignal.
  ///
  /// In en, this message translates to:
  /// **'Follow Signal'**
  String get followSignal;

  /// No description provided for @followDiscord.
  ///
  /// In en, this message translates to:
  /// **'Follow Discord'**
  String get followDiscord;

  /// No description provided for @followBluesky.
  ///
  /// In en, this message translates to:
  /// **'Follow Bluesky'**
  String get followBluesky;

  /// No description provided for @followNooki.
  ///
  /// In en, this message translates to:
  /// **'Follow Nooki'**
  String get followNooki;

  /// No description provided for @mastodonUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bijbelquiz.app/mastodon'**
  String get mastodonUrl;

  /// No description provided for @pixelfedUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bijbelquiz.app/pixelfed'**
  String get pixelfedUrl;

  /// No description provided for @kweblerUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bijbelquiz.app/kwebler'**
  String get kweblerUrl;

  /// No description provided for @signalUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bijbelquiz.app/signal'**
  String get signalUrl;

  /// No description provided for @discordUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bijbelquiz.app/discord'**
  String get discordUrl;

  /// No description provided for @blueskyUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bijbelquiz.app/bluesky'**
  String get blueskyUrl;

  /// No description provided for @nookiUrl.
  ///
  /// In en, this message translates to:
  /// **'https://bijbelquiz.app/nooki'**
  String get nookiUrl;

  /// No description provided for @satisfactionSurvey.
  ///
  /// In en, this message translates to:
  /// **'Help Us Improve'**
  String get satisfactionSurvey;

  /// No description provided for @satisfactionSurveyMessage.
  ///
  /// In en, this message translates to:
  /// **'Take a few minutes to help us improve the app. Your feedback is important! You will receive 25 free points as a thank you.'**
  String get satisfactionSurveyMessage;

  /// No description provided for @satisfactionSurveyButton.
  ///
  /// In en, this message translates to:
  /// **'Fill out survey'**
  String get satisfactionSurveyButton;

  /// No description provided for @difficultyFeedbackTitle.
  ///
  /// In en, this message translates to:
  /// **'How do you find the difficulty level?'**
  String get difficultyFeedbackTitle;

  /// No description provided for @difficultyFeedbackMessage.
  ///
  /// In en, this message translates to:
  /// **'Let us know if the questions are too easy or too difficult.'**
  String get difficultyFeedbackMessage;

  /// No description provided for @difficultyTooHard.
  ///
  /// In en, this message translates to:
  /// **'Too difficult'**
  String get difficultyTooHard;

  /// No description provided for @difficultyGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get difficultyGood;

  /// No description provided for @difficultyTooEasy.
  ///
  /// In en, this message translates to:
  /// **'Too easy'**
  String get difficultyTooEasy;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @createAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Create an account to unlock social features and sync your progress across devices!'**
  String get createAccountMessage;

  /// No description provided for @createAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccountButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @overslaan.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get overslaan;

  /// No description provided for @notEnoughStarsForSkip.
  ///
  /// In en, this message translates to:
  /// **'Not enough stars to skip!'**
  String get notEnoughStarsForSkip;

  /// No description provided for @resetAndLogoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will remove all scores, progress, cache, settings and activation. The app will be deactivated and requires a new activation code. This action cannot be undone.'**
  String get resetAndLogoutConfirmation;

  /// No description provided for @donationError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while opening the donation page'**
  String get donationError;

  /// No description provided for @soundEffectsDescription.
  ///
  /// In en, this message translates to:
  /// **'Turn game sounds on or off'**
  String get soundEffectsDescription;

  /// No description provided for @doubleStarsActivated.
  ///
  /// In en, this message translates to:
  /// **'Double Stars activated for 5 questions!'**
  String get doubleStarsActivated;

  /// No description provided for @tripleStarsActivated.
  ///
  /// In en, this message translates to:
  /// **'Triple Stars activated for 5 questions!'**
  String get tripleStarsActivated;

  /// No description provided for @fiveTimesStarsActivated.
  ///
  /// In en, this message translates to:
  /// **'5x Stars activated for 5 questions!'**
  String get fiveTimesStarsActivated;

  /// No description provided for @doubleStars60SecondsActivated.
  ///
  /// In en, this message translates to:
  /// **'Double Stars activated for 60 seconds!'**
  String get doubleStars60SecondsActivated;

  /// No description provided for @powerupActivated.
  ///
  /// In en, this message translates to:
  /// **'Power-up Activated!'**
  String get powerupActivated;

  /// No description provided for @backToQuiz.
  ///
  /// In en, this message translates to:
  /// **'Back to Quiz'**
  String get backToQuiz;

  /// No description provided for @themeUnlocked.
  ///
  /// In en, this message translates to:
  /// **'unlocked!'**
  String get themeUnlocked;

  /// No description provided for @onlyLatestUnlockedLesson.
  ///
  /// In en, this message translates to:
  /// **'You can only play the most recently unlocked lesson'**
  String get onlyLatestUnlockedLesson;

  /// No description provided for @starsEarned.
  ///
  /// In en, this message translates to:
  /// **'stars earned'**
  String get starsEarned;

  /// No description provided for @readyForNextChallenge.
  ///
  /// In en, this message translates to:
  /// **'Ready for your next challenge?'**
  String get readyForNextChallenge;

  /// No description provided for @continueLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue With:'**
  String get continueLesson;

  /// No description provided for @freePractice.
  ///
  /// In en, this message translates to:
  /// **'Free Practice (random)'**
  String get freePractice;

  /// No description provided for @invalidBiblicalReference.
  ///
  /// In en, this message translates to:
  /// **'Invalid Bible reference'**
  String get invalidBiblicalReference;

  /// No description provided for @errorLoadingBiblicalText.
  ///
  /// In en, this message translates to:
  /// **'Error loading Bible text'**
  String get errorLoadingBiblicalText;

  /// No description provided for @errorLoadingWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading:'**
  String get errorLoadingWithDetails;

  /// No description provided for @resumeToGame.
  ///
  /// In en, this message translates to:
  /// **'Resume Game'**
  String get resumeToGame;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @aiThemeFallback.
  ///
  /// In en, this message translates to:
  /// **'AI Theme'**
  String get aiThemeFallback;

  /// No description provided for @aiThemeGenerator.
  ///
  /// In en, this message translates to:
  /// **'AI Theme Generator'**
  String get aiThemeGenerator;

  /// No description provided for @aiThemeGeneratorDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe your desired colors and let AI create a theme for you'**
  String get aiThemeGeneratorDescription;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesDescription.
  ///
  /// In en, this message translates to:
  /// **'Search for new app versions'**
  String get checkForUpdatesDescription;

  /// No description provided for @checkForUpdatesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdatesTooltip;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'Read our privacy policy'**
  String get privacyPolicyDescription;

  /// No description provided for @couldNotOpenPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Could not open privacy policy'**
  String get couldNotOpenPrivacyPolicy;

  /// No description provided for @openPrivacyPolicyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open privacy policy'**
  String get openPrivacyPolicyTooltip;

  /// No description provided for @privacyAndAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Analytics'**
  String get privacyAndAnalytics;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @analyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app by sending anonymous usage data'**
  String get analyticsDescription;

  /// No description provided for @localApi.
  ///
  /// In en, this message translates to:
  /// **'Local API'**
  String get localApi;

  /// No description provided for @enableLocalApi.
  ///
  /// In en, this message translates to:
  /// **'Enable Local API'**
  String get enableLocalApi;

  /// No description provided for @enableLocalApiDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow external apps to access quiz data'**
  String get enableLocalApiDesc;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKey;

  /// No description provided for @generateApiKey.
  ///
  /// In en, this message translates to:
  /// **'Generate a key for API access'**
  String get generateApiKey;

  /// No description provided for @apiPort.
  ///
  /// In en, this message translates to:
  /// **'API Port'**
  String get apiPort;

  /// No description provided for @apiPortDesc.
  ///
  /// In en, this message translates to:
  /// **'Port for local API server'**
  String get apiPortDesc;

  /// No description provided for @apiStatus.
  ///
  /// In en, this message translates to:
  /// **'API Status'**
  String get apiStatus;

  /// No description provided for @apiStatusDesc.
  ///
  /// In en, this message translates to:
  /// **'Shows if the API server is running'**
  String get apiStatusDesc;

  /// No description provided for @apiDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get apiDisabled;

  /// No description provided for @apiRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get apiRunning;

  /// No description provided for @apiStarting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get apiStarting;

  /// No description provided for @copyApiKey.
  ///
  /// In en, this message translates to:
  /// **'Copy API Key'**
  String get copyApiKey;

  /// No description provided for @regenerateApiKey.
  ///
  /// In en, this message translates to:
  /// **'Regenerate API Key'**
  String get regenerateApiKey;

  /// No description provided for @regenerateApiKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Regenerate API Key'**
  String get regenerateApiKeyTitle;

  /// No description provided for @regenerateApiKeyMessage.
  ///
  /// In en, this message translates to:
  /// **'This will generate a new API key and invalidate the current one. Continue?'**
  String get regenerateApiKeyMessage;

  /// No description provided for @apiKeyCopied.
  ///
  /// In en, this message translates to:
  /// **'API key copied to clipboard'**
  String get apiKeyCopied;

  /// No description provided for @apiKeyCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not copy API key'**
  String get apiKeyCopyFailed;

  /// No description provided for @generateKey.
  ///
  /// In en, this message translates to:
  /// **'Generate Key'**
  String get generateKey;

  /// No description provided for @apiKeyGenerated.
  ///
  /// In en, this message translates to:
  /// **'New API key generated'**
  String get apiKeyGenerated;

  /// No description provided for @followOnSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Follow on social media'**
  String get followOnSocialMedia;

  /// No description provided for @followUsOnSocialMedia.
  ///
  /// In en, this message translates to:
  /// **'Follow us on social media'**
  String get followUsOnSocialMedia;

  /// No description provided for @mastodon.
  ///
  /// In en, this message translates to:
  /// **'Mastodon'**
  String get mastodon;

  /// No description provided for @pixelfed.
  ///
  /// In en, this message translates to:
  /// **'Pixelfed'**
  String get pixelfed;

  /// No description provided for @kwebler.
  ///
  /// In en, this message translates to:
  /// **'Kwebler'**
  String get kwebler;

  /// No description provided for @discord.
  ///
  /// In en, this message translates to:
  /// **'Discord'**
  String get discord;

  /// No description provided for @signal.
  ///
  /// In en, this message translates to:
  /// **'Signal'**
  String get signal;

  /// No description provided for @bluesky.
  ///
  /// In en, this message translates to:
  /// **'Bluesky'**
  String get bluesky;

  /// No description provided for @nooki.
  ///
  /// In en, this message translates to:
  /// **'Nooki'**
  String get nooki;

  /// No description provided for @couldNotOpenPlatform.
  ///
  /// In en, this message translates to:
  /// **'Could not open {platform}'**
  String couldNotOpenPlatform(Object platform);

  /// No description provided for @shareAppWithFriends.
  ///
  /// In en, this message translates to:
  /// **'Share app with friends'**
  String get shareAppWithFriends;

  /// No description provided for @shareYourStats.
  ///
  /// In en, this message translates to:
  /// **'Share your statistics'**
  String get shareYourStats;

  /// No description provided for @inviteFriend.
  ///
  /// In en, this message translates to:
  /// **'Invite a friend'**
  String get inviteFriend;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @enterFriendName.
  ///
  /// In en, this message translates to:
  /// **'Enter your friend\'s name'**
  String get enterFriendName;

  /// No description provided for @inviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Invite your friend to BibleQuiz!'**
  String get inviteMessage;

  /// No description provided for @customizeInvite.
  ///
  /// In en, this message translates to:
  /// **'Personalize your invitation'**
  String get customizeInvite;

  /// No description provided for @sendInvite.
  ///
  /// In en, this message translates to:
  /// **'Send invitation'**
  String get sendInvite;

  /// No description provided for @languageMustBeNl.
  ///
  /// In en, this message translates to:
  /// **'Language must be \"nl\" (only Dutch allowed)'**
  String get languageMustBeNl;

  /// No description provided for @failedToSaveTheme.
  ///
  /// In en, this message translates to:
  /// **'Could not save theme setting:'**
  String get failedToSaveTheme;

  /// No description provided for @failedToSaveSlowMode.
  ///
  /// In en, this message translates to:
  /// **'Could not save slow mode setting:'**
  String get failedToSaveSlowMode;

  /// No description provided for @failedToSaveGameSpeed.
  ///
  /// In en, this message translates to:
  /// **'Could not save game speed setting:'**
  String get failedToSaveGameSpeed;

  /// No description provided for @failedToUpdateDonationStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not update donation status:'**
  String get failedToUpdateDonationStatus;

  /// No description provided for @failedToUpdateCheckForUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not update check for update status:'**
  String get failedToUpdateCheckForUpdateStatus;

  /// No description provided for @failedToSaveMuteSetting.
  ///
  /// In en, this message translates to:
  /// **'Could not save mute setting:'**
  String get failedToSaveMuteSetting;

  /// No description provided for @failedToSaveGuideStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not save guide status:'**
  String get failedToSaveGuideStatus;

  /// No description provided for @failedToResetGuideStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not reset guide status:'**
  String get failedToResetGuideStatus;

  /// No description provided for @failedToResetCheckForUpdateStatus.
  ///
  /// In en, this message translates to:
  /// **'Could not reset check for update status:'**
  String get failedToResetCheckForUpdateStatus;

  /// No description provided for @exportStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Statistics'**
  String get exportStatsTitle;

  /// No description provided for @exportStatsMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy this text to save your progress:'**
  String get exportStatsMessage;

  /// No description provided for @importStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Statistics'**
  String get importStatsTitle;

  /// No description provided for @importStatsMessage.
  ///
  /// In en, this message translates to:
  /// **'Paste your previously exported statistics here:'**
  String get importStatsMessage;

  /// No description provided for @importStatsHint.
  ///
  /// In en, this message translates to:
  /// **'Paste here...'**
  String get importStatsHint;

  /// No description provided for @statsExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Statistics exported successfully!'**
  String get statsExportedSuccessfully;

  /// No description provided for @statsImportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Statistics imported successfully!'**
  String get statsImportedSuccessfully;

  /// No description provided for @failedToExportStats.
  ///
  /// In en, this message translates to:
  /// **'Could not export statistics:'**
  String get failedToExportStats;

  /// No description provided for @failedToImportStats.
  ///
  /// In en, this message translates to:
  /// **'Could not import statistics:'**
  String get failedToImportStats;

  /// No description provided for @invalidOrTamperedData.
  ///
  /// In en, this message translates to:
  /// **'Invalid or tampered data'**
  String get invalidOrTamperedData;

  /// No description provided for @pleaseEnterValidString.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid string'**
  String get pleaseEnterValidString;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @exportAllDataJson.
  ///
  /// In en, this message translates to:
  /// **'Export All Data (JSON)'**
  String get exportAllDataJson;

  /// No description provided for @exportAllDataJsonDesc.
  ///
  /// In en, this message translates to:
  /// **'Export all app data including settings, stats, and progress as JSON'**
  String get exportAllDataJsonDesc;

  /// No description provided for @exportAllDataJsonTitle.
  ///
  /// In en, this message translates to:
  /// **'Export All Data (JSON)'**
  String get exportAllDataJsonTitle;

  /// No description provided for @exportAllDataJsonMessage.
  ///
  /// In en, this message translates to:
  /// **'Your complete app data has been exported as JSON. You can copy this data to save it or share it.'**
  String get exportAllDataJsonMessage;

  /// No description provided for @copyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to Clipboard'**
  String get copyToClipboard;

  /// No description provided for @jsonDataCopied.
  ///
  /// In en, this message translates to:
  /// **'JSON data copied to clipboard'**
  String get jsonDataCopied;

  /// No description provided for @multiDeviceSync.
  ///
  /// In en, this message translates to:
  /// **'Multi-Device Sync'**
  String get multiDeviceSync;

  /// No description provided for @currentlySynced.
  ///
  /// In en, this message translates to:
  /// **'You are currently synced. Data is shared in real-time between devices.'**
  String get currentlySynced;

  /// No description provided for @yourSyncId.
  ///
  /// In en, this message translates to:
  /// **'Your Sync ID:'**
  String get yourSyncId;

  /// No description provided for @shareSyncId.
  ///
  /// In en, this message translates to:
  /// **'Share this ID with other devices to join.'**
  String get shareSyncId;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Error: '**
  String get errorGeneric;

  /// No description provided for @multiDeviceSyncButton.
  ///
  /// In en, this message translates to:
  /// **'Multi-Device Sync'**
  String get multiDeviceSyncButton;

  /// No description provided for @syncDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Sync data between devices using a code'**
  String get syncDataDescription;

  /// No description provided for @syncDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect to another device to sync your progress and statistics.'**
  String get syncDescription;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'BQID'**
  String get userId;

  /// No description provided for @enterUserId.
  ///
  /// In en, this message translates to:
  /// **'Enter a BQID to connect to another device'**
  String get enterUserId;

  /// No description provided for @userIdCode.
  ///
  /// In en, this message translates to:
  /// **'BQID'**
  String get userIdCode;

  /// No description provided for @connectToUser.
  ///
  /// In en, this message translates to:
  /// **'Connect to BQID'**
  String get connectToUser;

  /// No description provided for @createUserId.
  ///
  /// In en, this message translates to:
  /// **'Create a new BQID'**
  String get createUserId;

  /// No description provided for @createUserIdDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a new BQID and share the code with others to connect.'**
  String get createUserIdDescription;

  /// No description provided for @currentlyConnectedToUser.
  ///
  /// In en, this message translates to:
  /// **'You are currently connected to a BQID. Data is shared between devices.'**
  String get currentlyConnectedToUser;

  /// No description provided for @yourUserId.
  ///
  /// In en, this message translates to:
  /// **'Your BQID:'**
  String get yourUserId;

  /// No description provided for @shareUserId.
  ///
  /// In en, this message translates to:
  /// **'Share this ID with other devices to connect.'**
  String get shareUserId;

  /// No description provided for @leaveUserId.
  ///
  /// In en, this message translates to:
  /// **'Remove BQID from this device'**
  String get leaveUserId;

  /// No description provided for @userIdDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect to another device with a BQID to sync your data and statistics.'**
  String get userIdDescription;

  /// No description provided for @pleaseEnterUserId.
  ///
  /// In en, this message translates to:
  /// **'Please enter a BQID'**
  String get pleaseEnterUserId;

  /// No description provided for @failedToConnectToUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to the BQID. Check the ID and try again.'**
  String get failedToConnectToUser;

  /// No description provided for @failedToCreateUserId.
  ///
  /// In en, this message translates to:
  /// **'Failed to create BQID. Please try again.'**
  String get failedToCreateUserId;

  /// No description provided for @userIdButton.
  ///
  /// In en, this message translates to:
  /// **'BQID'**
  String get userIdButton;

  /// No description provided for @userIdDescriptionSetting.
  ///
  /// In en, this message translates to:
  /// **'Create or connect to a BQID to sync your progress'**
  String get userIdDescriptionSetting;

  /// No description provided for @createUserIdButton.
  ///
  /// In en, this message translates to:
  /// **'Create a BQID'**
  String get createUserIdButton;

  /// No description provided for @of.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get of;

  /// No description provided for @tapToCopyUserId.
  ///
  /// In en, this message translates to:
  /// **'Tap to copy BQID'**
  String get tapToCopyUserId;

  /// No description provided for @userIdCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'BQID copied to clipboard'**
  String get userIdCopiedToClipboard;

  /// No description provided for @notFollowing.
  ///
  /// In en, this message translates to:
  /// **'You are not following anyone yet'**
  String get notFollowing;

  /// No description provided for @joinRoomToViewFollowing.
  ///
  /// In en, this message translates to:
  /// **'You need to join a room to see who you are following'**
  String get joinRoomToViewFollowing;

  /// No description provided for @searchUsersToFollow.
  ///
  /// In en, this message translates to:
  /// **'Search for users to start following them'**
  String get searchUsersToFollow;

  /// No description provided for @noFollowers.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any followers yet'**
  String get noFollowers;

  /// No description provided for @joinRoomToViewFollowers.
  ///
  /// In en, this message translates to:
  /// **'You need to join a room to see your followers'**
  String get joinRoomToViewFollowers;

  /// No description provided for @shareBQIDFollowers.
  ///
  /// In en, this message translates to:
  /// **'Share your BQID with others to start getting followers'**
  String get shareBQIDFollowers;

  /// No description provided for @noActiveMessages.
  ///
  /// In en, this message translates to:
  /// **'No active messages'**
  String get noActiveMessages;

  /// No description provided for @noActiveMessagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'There are currently no messages to display'**
  String get noActiveMessagesSubtitle;

  /// No description provided for @errorLoadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get errorLoadingMessages;

  /// No description provided for @expiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get expiresIn;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @hoursMessage.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hoursMessage;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @lessThanAMinute.
  ///
  /// In en, this message translates to:
  /// **'less than a minute'**
  String get lessThanAMinute;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @bijbelquizGenTitle.
  ///
  /// In en, this message translates to:
  /// **'BibleQuiz Gen'**
  String get bijbelquizGenTitle;

  /// No description provided for @bijbelquizGenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your year in '**
  String get bijbelquizGenSubtitle;

  /// No description provided for @bijbelquizGenWelcomeText.
  ///
  /// In en, this message translates to:
  /// **'Review your achievements today and share your BibleQuiz year!'**
  String get bijbelquizGenWelcomeText;

  /// No description provided for @questionsAnswered.
  ///
  /// In en, this message translates to:
  /// **'Questions answered'**
  String get questionsAnswered;

  /// No description provided for @bijbelquizGenQuestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You have hopefully learned many new things.'**
  String get bijbelquizGenQuestionsSubtitle;

  /// No description provided for @mistakesMade.
  ///
  /// In en, this message translates to:
  /// **'Mistakes made'**
  String get mistakesMade;

  /// No description provided for @bijbelquizGenMistakesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Every mistake is a chance to learn and grow in your Bible knowledge!'**
  String get bijbelquizGenMistakesSubtitle;

  /// No description provided for @timeSpent.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get timeSpent;

  /// No description provided for @bijbelquizGenTimeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You took time to deepen your Bible knowledge!'**
  String get bijbelquizGenTimeSubtitle;

  /// No description provided for @bijbelquizGenBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bijbelquizGenBestStreak;

  /// No description provided for @bijbelquizGenStreakSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your longest streak shows your consistency and dedication!'**
  String get bijbelquizGenStreakSubtitle;

  /// No description provided for @yearInReview.
  ///
  /// In en, this message translates to:
  /// **'Your year in review'**
  String get yearInReview;

  /// No description provided for @bijbelquizGenYearReviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'An overview of your BibleQuiz performance in the past year!'**
  String get bijbelquizGenYearReviewSubtitle;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @correctAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get correctAnswers;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @thankYouForUsingBijbelQuiz.
  ///
  /// In en, this message translates to:
  /// **'Thank you for using BibleQuiz!'**
  String get thankYouForUsingBijbelQuiz;

  /// No description provided for @bijbelquizGenThankYouText.
  ///
  /// In en, this message translates to:
  /// **'We hope our app has been a blessing this past year.'**
  String get bijbelquizGenThankYouText;

  /// No description provided for @bijbelquizGenDonateButton.
  ///
  /// In en, this message translates to:
  /// **'Donate to us to show your continued support for our development, so we can continue to improve the app and so you can look back on another educational year next year.'**
  String get bijbelquizGenDonateButton;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @bijbelquizGenSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get bijbelquizGenSkip;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @reportSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your report has been submitted successfully!'**
  String get reportSubmittedSuccessfully;

  /// No description provided for @reportSubmissionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report. Please try again later.'**
  String get reportSubmissionFailed;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @reportBugDescription.
  ///
  /// In en, this message translates to:
  /// **'Report a bug or issue with the app'**
  String get reportBugDescription;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @pleaseEnterSubject.
  ///
  /// In en, this message translates to:
  /// **'Please enter a subject'**
  String get pleaseEnterSubject;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @pleaseEnterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @reportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Report Question'**
  String get reportQuestion;

  /// No description provided for @questionReportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Question reported successfully'**
  String get questionReportedSuccessfully;

  /// No description provided for @errorReportingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Error reporting question'**
  String get errorReportingQuestion;

  /// No description provided for @apiErrorPrefix.
  ///
  /// In en, this message translates to:
  /// **'API Error: '**
  String get apiErrorPrefix;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @compactGrid.
  ///
  /// In en, this message translates to:
  /// **'Compact Grid'**
  String get compactGrid;

  /// No description provided for @useTheme.
  ///
  /// In en, this message translates to:
  /// **'Use Theme'**
  String get useTheme;

  /// No description provided for @failedToRemoveDevice.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove device'**
  String get failedToRemoveDevice;

  /// No description provided for @errorRemovingDevice.
  ///
  /// In en, this message translates to:
  /// **'Error removing device: '**
  String get errorRemovingDevice;

  /// No description provided for @sharedStats.
  ///
  /// In en, this message translates to:
  /// **'Shared Statistics'**
  String get sharedStats;

  /// No description provided for @newGame.
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// No description provided for @loadingMessages.
  ///
  /// In en, this message translates to:
  /// **'Loading messages...'**
  String get loadingMessages;

  /// No description provided for @errorLoadingUsernames.
  ///
  /// In en, this message translates to:
  /// **'Error loading usernames: '**
  String get errorLoadingUsernames;

  /// No description provided for @urlCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard!'**
  String get urlCopiedToClipboard;

  /// No description provided for @tryAgainButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgainButton;

  /// No description provided for @checkConnection.
  ///
  /// In en, this message translates to:
  /// **'Check Connection'**
  String get checkConnection;

  /// No description provided for @goToQuiz.
  ///
  /// In en, this message translates to:
  /// **'Go to Quiz'**
  String get goToQuiz;

  /// No description provided for @errorLoadingAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Error loading analytics'**
  String get errorLoadingAnalytics;

  /// No description provided for @bibleReferenceCopiedForSharing.
  ///
  /// In en, this message translates to:
  /// **'Bible reference copied for sharing'**
  String get bibleReferenceCopiedForSharing;

  /// No description provided for @errorHandlingTest.
  ///
  /// In en, this message translates to:
  /// **'Error Handling Test'**
  String get errorHandlingTest;

  /// No description provided for @errorHandlingTestDescription.
  ///
  /// In en, this message translates to:
  /// **'This screen demonstrates the new error handling system'**
  String get errorHandlingTestDescription;

  /// No description provided for @testErrorHandling.
  ///
  /// In en, this message translates to:
  /// **'Test Error Handling'**
  String get testErrorHandling;

  /// No description provided for @testErrorDialog.
  ///
  /// In en, this message translates to:
  /// **'Test Error Dialog'**
  String get testErrorDialog;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @searchSettings.
  ///
  /// In en, this message translates to:
  /// **'Search settings...'**
  String get searchSettings;

  /// No description provided for @lessonLayoutSettings.
  ///
  /// In en, this message translates to:
  /// **'Lesson Layout'**
  String get lessonLayoutSettings;

  /// No description provided for @chooseLessonLayoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how lessons are displayed'**
  String get chooseLessonLayoutDesc;

  /// No description provided for @showIntroductionDesc.
  ///
  /// In en, this message translates to:
  /// **'View the app introduction and tutorial'**
  String get showIntroductionDesc;

  /// No description provided for @clearQuestionCacheDesc.
  ///
  /// In en, this message translates to:
  /// **'Remove cached questions to free up storage space'**
  String get clearQuestionCacheDesc;

  /// No description provided for @followOnSocialMediaDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with us on social media platforms'**
  String get followOnSocialMediaDesc;

  /// No description provided for @inviteFriendDesc.
  ///
  /// In en, this message translates to:
  /// **'Share a personalized invite link with friends'**
  String get inviteFriendDesc;

  /// No description provided for @bugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// No description provided for @bugReportDesc.
  ///
  /// In en, this message translates to:
  /// **'Report bugs and issues with the app'**
  String get bugReportDesc;

  /// No description provided for @streakLabel.
  ///
  /// In en, this message translates to:
  /// **' streak'**
  String get streakLabel;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @lastScore.
  ///
  /// In en, this message translates to:
  /// **'Last score:'**
  String get lastScore;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get notAvailable;

  /// No description provided for @followedUsersScores.
  ///
  /// In en, this message translates to:
  /// **'Scores of Followed Users'**
  String get followedUsersScores;

  /// No description provided for @thankYouForSupport.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your support!'**
  String get thankYouForSupport;

  /// No description provided for @thankYouForYourSupport.
  ///
  /// In en, this message translates to:
  /// **'We appreciate you using BibleQuiz and participating in our community.'**
  String get thankYouForYourSupport;

  /// No description provided for @supportWithDonation.
  ///
  /// In en, this message translates to:
  /// **'Support us with a donation'**
  String get supportWithDonation;

  /// No description provided for @bijbelquizGenDonationText.
  ///
  /// In en, this message translates to:
  /// **'Your donation helps us maintain and improve BibleQuiz for you and others.'**
  String get bijbelquizGenDonationText;

  /// No description provided for @noExpirationDate.
  ///
  /// In en, this message translates to:
  /// **'No expiration date'**
  String get noExpirationDate;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @enterUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUsername;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John2025'**
  String get usernameHint;

  /// No description provided for @saveUsername.
  ///
  /// In en, this message translates to:
  /// **'Save username'**
  String get saveUsername;

  /// No description provided for @pleaseEnterUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUsername;

  /// No description provided for @usernameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Username must be at most 30 characters'**
  String get usernameTooLong;

  /// No description provided for @usernameAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken'**
  String get usernameAlreadyTaken;

  /// No description provided for @usernameBlacklisted.
  ///
  /// In en, this message translates to:
  /// **'This username is not allowed'**
  String get usernameBlacklisted;

  /// No description provided for @usernameSaved.
  ///
  /// In en, this message translates to:
  /// **'Username saved!'**
  String get usernameSaved;

  /// No description provided for @beta.
  ///
  /// In en, this message translates to:
  /// **'Beta'**
  String get beta;

  /// No description provided for @shareStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Share your stats'**
  String get shareStatsTitle;

  /// No description provided for @shareYourBijbelQuizStats.
  ///
  /// In en, this message translates to:
  /// **'Share your BibleQuiz stats'**
  String get shareYourBijbelQuizStats;

  /// No description provided for @correctAnswersShare.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get correctAnswersShare;

  /// No description provided for @currentStreakShare.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreakShare;

  /// No description provided for @bestStreakShare.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreakShare;

  /// No description provided for @mistakesShare.
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get mistakesShare;

  /// No description provided for @accuracyShare.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracyShare;

  /// No description provided for @timeSpentShare.
  ///
  /// In en, this message translates to:
  /// **'Time spent'**
  String get timeSpentShare;

  /// No description provided for @shareResults.
  ///
  /// In en, this message translates to:
  /// **'Share your results'**
  String get shareResults;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get copyLink;

  /// No description provided for @automaticBugReports.
  ///
  /// In en, this message translates to:
  /// **'Automatic bug reporting'**
  String get automaticBugReports;

  /// No description provided for @automaticBugReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically send bug reports when errors occur (recommended)'**
  String get automaticBugReportsDesc;

  /// No description provided for @dataSuccessfullySynchronized.
  ///
  /// In en, this message translates to:
  /// **'Data successfully synchronized'**
  String get dataSuccessfullySynchronized;

  /// No description provided for @synchronizationFailed.
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed: '**
  String get synchronizationFailed;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @adjustNameAndBio.
  ///
  /// In en, this message translates to:
  /// **'Adjust name and bio'**
  String get adjustNameAndBio;

  /// No description provided for @changeUsername.
  ///
  /// In en, this message translates to:
  /// **'Change Username'**
  String get changeUsername;

  /// No description provided for @adjustYourUsername.
  ///
  /// In en, this message translates to:
  /// **'Adjust your username'**
  String get adjustYourUsername;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @secureYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Secure your account'**
  String get secureYourAccount;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Sign out from this device'**
  String get signOutFromDevice;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @permanentlyDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account'**
  String get permanentlyDeleteAccount;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @bioOptional.
  ///
  /// In en, this message translates to:
  /// **'Bio (optional)'**
  String get bioOptional;

  /// No description provided for @newUsername.
  ///
  /// In en, this message translates to:
  /// **'New username'**
  String get newUsername;

  /// No description provided for @chooseUniqueName.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique name'**
  String get chooseUniqueName;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @atLeast6Characters.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get atLeast6Characters;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @fillAllPasswordFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all password fields'**
  String get fillAllPasswordFields;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @newPasswordMin6Chars.
  ///
  /// In en, this message translates to:
  /// **'New password must contain at least 6 characters'**
  String get newPasswordMin6Chars;

  /// No description provided for @enterNewUsername.
  ///
  /// In en, this message translates to:
  /// **'Enter a new username'**
  String get enterNewUsername;

  /// No description provided for @usernameMin3Chars.
  ///
  /// In en, this message translates to:
  /// **'Username must contain at least 3 characters'**
  String get usernameMin3Chars;

  /// No description provided for @usernameMax20Chars.
  ///
  /// In en, this message translates to:
  /// **'Username may contain at most 20 characters'**
  String get usernameMax20Chars;

  /// No description provided for @usernameNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This username is not allowed'**
  String get usernameNotAllowed;

  /// No description provided for @thisUsernameAlreadyTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken'**
  String get thisUsernameAlreadyTaken;

  /// No description provided for @usernameSuccessfullyChanged.
  ///
  /// In en, this message translates to:
  /// **'Username successfully changed'**
  String get usernameSuccessfullyChanged;

  /// No description provided for @failedToChangeUsername.
  ///
  /// In en, this message translates to:
  /// **'Failed to change username'**
  String get failedToChangeUsername;

  /// No description provided for @displayNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Display name is required'**
  String get displayNameRequired;

  /// No description provided for @profileSuccessfullyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile successfully updated'**
  String get profileSuccessfullyUpdated;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed'**
  String get signOutFailed;

  /// No description provided for @passwordSuccessfullyChanged.
  ///
  /// In en, this message translates to:
  /// **'Password successfully changed'**
  String get passwordSuccessfullyChanged;

  /// No description provided for @failedToChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password'**
  String get failedToChangePassword;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @notUpdated.
  ///
  /// In en, this message translates to:
  /// **'Not updated'**
  String get notUpdated;

  /// No description provided for @lastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync'**
  String get lastSync;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// No description provided for @noLeaderboardData.
  ///
  /// In en, this message translates to:
  /// **'No leaderboard data available'**
  String get noLeaderboardData;

  /// No description provided for @elim50CouponMessage.
  ///
  /// In en, this message translates to:
  /// **'You got 50 points and got 50 cents donated for the renovation of Elim!'**
  String get elim50CouponMessage;

  /// No description provided for @loginWithBqid.
  ///
  /// In en, this message translates to:
  /// **'Login with your BQID'**
  String get loginWithBqid;

  /// No description provided for @socialFeaturesMessage.
  ///
  /// In en, this message translates to:
  /// **'Create an account to use social features, such as searching for users, making friends and sending messages.'**
  String get socialFeaturesMessage;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @usernameSignupHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique name'**
  String get usernameSignupHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get confirmPasswordHint;

  /// No description provided for @accountCreatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created! Check your email for verification.'**
  String get accountCreatedMessage;

  /// No description provided for @fillEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Fill in your email and password to continue.'**
  String get fillEmailAndPassword;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields to create an account.'**
  String get fillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match. Check if you entered the same in both fields.'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters for your security.'**
  String get passwordTooShort;

  /// No description provided for @checkingPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is being checked for security...'**
  String get checkingPassword;

  /// No description provided for @passwordCompromised.
  ///
  /// In en, this message translates to:
  /// **'This password has been found in data breaches. Choose a different password for your security.'**
  String get passwordCompromised;

  /// No description provided for @usernameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Username must contain at least 3 characters.'**
  String get usernameTooShort;

  /// No description provided for @usernameSignupTooLong.
  ///
  /// In en, this message translates to:
  /// **'Username may contain at most 20 characters.'**
  String get usernameSignupTooLong;

  /// No description provided for @usernameInvalidChars.
  ///
  /// In en, this message translates to:
  /// **'Username may only contain letters, numbers and underscores.'**
  String get usernameInvalidChars;

  /// No description provided for @checkingUsername.
  ///
  /// In en, this message translates to:
  /// **'Username availability is being checked...'**
  String get checkingUsername;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password. Check your details and try again.'**
  String get invalidEmailOrPassword;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Your email has not been verified. Check your inbox and click the verification link.'**
  String get emailNotConfirmed;

  /// No description provided for @tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment before trying again.'**
  String get tooManyRequests;

  /// No description provided for @passwordTooShortGeneric.
  ///
  /// In en, this message translates to:
  /// **'Password should be at least 6 characters.'**
  String get passwordTooShortGeneric;

  /// No description provided for @invalidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address. Make sure you entered a valid email address.'**
  String get invalidEmailAddress;

  /// No description provided for @userAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'An account with this email address already exists. Try logging in or use a different email address.'**
  String get userAlreadyRegistered;

  /// No description provided for @signupDisabled.
  ///
  /// In en, this message translates to:
  /// **'Sign up is currently disabled. Try again later.'**
  String get signupDisabled;

  /// No description provided for @weakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak. Choose a stronger password with more characters.'**
  String get weakPassword;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again or contact support if the problem persists.'**
  String get genericError;

  /// No description provided for @guideAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get guideAccount;

  /// No description provided for @guideAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Create an account or log in to save your progress and use social features.'**
  String get guideAccountDescription;

  /// No description provided for @couponRedeemDescription.
  ///
  /// In en, this message translates to:
  /// **'You can redeem coupon codes later at the shop menu.'**
  String get couponRedeemDescription;

  /// No description provided for @termsAgreementText.
  ///
  /// In en, this message translates to:
  /// **'By continuing you agree to our '**
  String get termsAgreementText;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'terms of service'**
  String get termsOfService;

  /// No description provided for @progressOverview.
  ///
  /// In en, this message translates to:
  /// **'Progress overview'**
  String get progressOverview;

  /// No description provided for @progressOverviewHint.
  ///
  /// In en, this message translates to:
  /// **'Shows your current progress through lessons'**
  String get progressOverviewHint;

  /// No description provided for @lessonCompletionProgress.
  ///
  /// In en, this message translates to:
  /// **'Lesson completion progress'**
  String get lessonCompletionProgress;

  /// No description provided for @lessonsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} out of {total} lessons completed'**
  String lessonsCompleted(Object total, Object unlocked);

  /// No description provided for @continueWithLesson.
  ///
  /// In en, this message translates to:
  /// **'Continue with lesson: {lessonTitle}'**
  String continueWithLesson(Object lessonTitle);

  /// No description provided for @continueWithLessonHint.
  ///
  /// In en, this message translates to:
  /// **'Start the next recommended lesson in your progress'**
  String get continueWithLessonHint;

  /// No description provided for @practiceMode.
  ///
  /// In en, this message translates to:
  /// **'Practice mode'**
  String get practiceMode;

  /// No description provided for @practiceModeHint.
  ///
  /// In en, this message translates to:
  /// **'Start a random practice quiz without affecting progress'**
  String get practiceModeHint;

  /// No description provided for @multiplayerMode.
  ///
  /// In en, this message translates to:
  /// **'Multiplayer mode'**
  String get multiplayerMode;

  /// No description provided for @multiplayerModeHint.
  ///
  /// In en, this message translates to:
  /// **'Start a multiplayer quiz game'**
  String get multiplayerModeHint;

  /// No description provided for @startRandomPracticeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start a random practice quiz'**
  String get startRandomPracticeQuiz;

  /// No description provided for @playButton.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playButton;

  /// No description provided for @dailyStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'You have been using BibleQuiz for {streakDays} {streakDays, plural, =1{day} other{days}} in a row'**
  String dailyStreakDescription(Object appName, num streakDays);

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @questionReportedByUser.
  ///
  /// In en, this message translates to:
  /// **'Question reported by user'**
  String get questionReportedByUser;

  /// No description provided for @invalidBiblicalReferenceInQuestion.
  ///
  /// In en, this message translates to:
  /// **'Invalid biblical reference in question'**
  String get invalidBiblicalReferenceInQuestion;

  /// No description provided for @pleaseEnterDataToImport.
  ///
  /// In en, this message translates to:
  /// **'Please enter data to import'**
  String get pleaseEnterDataToImport;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed: '**
  String get importFailed;

  /// No description provided for @errorLoadingStore.
  ///
  /// In en, this message translates to:
  /// **'Error loading store'**
  String get errorLoadingStore;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed, please try again'**
  String get purchaseFailed;

  /// No description provided for @purchaseErrorString.
  ///
  /// In en, this message translates to:
  /// **'Error during purchase: {error}'**
  String purchaseErrorString(Object error);

  /// No description provided for @christmasTheme.
  ///
  /// In en, this message translates to:
  /// **'Christmas Theme'**
  String get christmasTheme;

  /// No description provided for @christmasThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'A festive Christmas theme with red and green colors'**
  String get christmasThemeDescription;

  /// No description provided for @terminalGreenTheme.
  ///
  /// In en, this message translates to:
  /// **'Terminal Green'**
  String get terminalGreenTheme;

  /// No description provided for @terminalGreenThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'A classic terminal theme with green text on a black background'**
  String get terminalGreenThemeDescription;

  /// No description provided for @oceanBlueTheme.
  ///
  /// In en, this message translates to:
  /// **'Ocean Blue'**
  String get oceanBlueTheme;

  /// No description provided for @oceanBlueThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'A bright ocean blue theme for a fresh look'**
  String get oceanBlueThemeDescription;

  /// No description provided for @roseWhiteTheme.
  ///
  /// In en, this message translates to:
  /// **'Rose White'**
  String get roseWhiteTheme;

  /// No description provided for @roseWhiteThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'An elegant pink and white theme'**
  String get roseWhiteThemeDescription;

  /// No description provided for @darkWoodTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Wood'**
  String get darkWoodTheme;

  /// No description provided for @darkWoodThemeDescription.
  ///
  /// In en, this message translates to:
  /// **'A warm dark wood theme'**
  String get darkWoodThemeDescription;

  /// No description provided for @paymentError.
  ///
  /// In en, this message translates to:
  /// **'Payment error: {error}'**
  String paymentError(Object error);

  /// No description provided for @errorOpeningAiThemeGenerator.
  ///
  /// In en, this message translates to:
  /// **'Error opening AI theme generator'**
  String get errorOpeningAiThemeGenerator;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount!'**
  String get discount;

  /// No description provided for @bibleReferenceCopied.
  ///
  /// In en, this message translates to:
  /// **'Bible reference copied: {reference}'**
  String bibleReferenceCopied(Object reference);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareBibleReference.
  ///
  /// In en, this message translates to:
  /// **'Bible reference: {reference} ({translation})'**
  String shareBibleReference(Object reference, Object translation);

  /// No description provided for @lessonLabel.
  ///
  /// In en, this message translates to:
  /// **'Lesson {index}: {title}'**
  String lessonLabel(Object index, Object title);

  /// No description provided for @unlockedButNotPlayable.
  ///
  /// In en, this message translates to:
  /// **'unlocked but not playable'**
  String get unlockedButNotPlayable;

  /// No description provided for @lockedHint.
  ///
  /// In en, this message translates to:
  /// **'This lesson is locked. Complete previous lessons to unlock it.'**
  String get lockedHint;

  /// No description provided for @unlockedButNotPlayableHint.
  ///
  /// In en, this message translates to:
  /// **'This lesson is unlocked but you can only play the most recently unlocked lesson.'**
  String get unlockedButNotPlayableHint;

  /// No description provided for @tapToStart.
  ///
  /// In en, this message translates to:
  /// **'Tap to start this lesson'**
  String get tapToStart;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended: {label}'**
  String recommended(Object label);

  /// No description provided for @lessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Lesson {index}'**
  String lessonNumber(Object index);

  /// No description provided for @bookIconSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Book icon representing lesson content'**
  String get bookIconSemanticLabel;

  /// No description provided for @lockedSpecialLessonSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked special lesson'**
  String get lockedSpecialLessonSemanticLabel;

  /// No description provided for @lockedLessonSemanticLabel.
  ///
  /// In en, this message translates to:
  /// **'Locked lesson'**
  String get lockedLessonSemanticLabel;

  /// No description provided for @mcqLabel.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice question'**
  String get mcqLabel;

  /// No description provided for @mcqHint.
  ///
  /// In en, this message translates to:
  /// **'Select the correct answer from the options below'**
  String get mcqHint;

  /// No description provided for @answerOptionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer options'**
  String get answerOptionsLabel;

  /// No description provided for @answerOptionsHint.
  ///
  /// In en, this message translates to:
  /// **'Choose one of the {count} options'**
  String answerOptionsHint(Object count);

  /// No description provided for @fitbLabel.
  ///
  /// In en, this message translates to:
  /// **'Fill in the blank question'**
  String get fitbLabel;

  /// No description provided for @fitbHint.
  ///
  /// In en, this message translates to:
  /// **'Select the word that completes the sentence'**
  String get fitbHint;

  /// No description provided for @fitbHint2.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct word to fill in the blank'**
  String get fitbHint2;

  /// No description provided for @tfLabel.
  ///
  /// In en, this message translates to:
  /// **'True or False question'**
  String get tfLabel;

  /// No description provided for @tfHint.
  ///
  /// In en, this message translates to:
  /// **'Select whether the statement is true or false'**
  String get tfHint;

  /// No description provided for @tfHint2.
  ///
  /// In en, this message translates to:
  /// **'Choose True or False'**
  String get tfHint2;

  /// No description provided for @trueText.
  ///
  /// In en, this message translates to:
  /// **'True'**
  String get trueText;

  /// No description provided for @falseText.
  ///
  /// In en, this message translates to:
  /// **'False'**
  String get falseText;

  /// No description provided for @questionLabel.
  ///
  /// In en, this message translates to:
  /// **'Question: {question}'**
  String questionLabel(Object question);

  /// No description provided for @blank.
  ///
  /// In en, this message translates to:
  /// **'______'**
  String get blank;

  /// No description provided for @recommendedAd.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedAd;

  /// No description provided for @moreInformation.
  ///
  /// In en, this message translates to:
  /// **'More Information'**
  String get moreInformation;

  /// No description provided for @lessonLocked.
  ///
  /// In en, this message translates to:
  /// **'Lesson is still locked'**
  String get lessonLocked;

  /// No description provided for @languageNl.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get languageNl;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;
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
