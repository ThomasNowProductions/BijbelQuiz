import 'package:bijbelquiz/constants/urls.dart';
import 'strings_en.dart';

class AppStrings {
  static String _language = 'nl';
  
  static String get currentLanguage => _language;
  
  static void setLanguage(String lang) {
    _language = lang;
  }


  // Common
  static String get appName => _language == 'en' ? AppStringsEn.appName : 'BijbelQuiz';
  static String get appDescription => _language == 'en' ? AppStringsEn.appDescription : 'Test je Bijbelkennis';
  static String get loading => _language == 'en' ? AppStringsEn.loading : 'Laden...';
  static String get error => _language == 'en' ? AppStringsEn.error : 'Fout';
  static String get back => _language == 'en' ? AppStringsEn.back : 'Terug';
  static String get submit => _language == 'en' ? AppStringsEn.submit : 'Indienen';
  static String get cancel => _language == 'en' ? AppStringsEn.cancel : 'Annuleren';
  static String get ok => _language == 'en' ? AppStringsEn.ok : 'OK';

  // Quiz Screen
  static String get question => _language == 'en' ? AppStringsEn.question : 'Vraag';
  static String get score => _language == 'en' ? AppStringsEn.score : 'Score';
  static String get correct => _language == 'en' ? AppStringsEn.correct : 'Correct!';
  static String get incorrect => _language == 'en' ? AppStringsEn.incorrect : 'Niet correct';
  static String get quizComplete => _language == 'en' ? AppStringsEn.quizComplete : 'Quiz voltooid!';
  static String get yourScore => _language == 'en' ? AppStringsEn.yourScore : 'Jouw score: ';
  static String get unlockBiblicalReference => _language == 'en' ? AppStringsEn.unlockBiblicalReference : 'Ontgrendel Bijbelverwijzing (Béta)';
  static String get biblicalReference => _language == 'en' ? AppStringsEn.biblicalReference : 'Bijbelverwijzing';
  static String get close => _language == 'en' ? AppStringsEn.close : 'Sluiten';

  // Settings
  static String get settings => _language == 'en' ? AppStringsEn.settings : 'Instellingen';
  static String get sound => _language == 'en' ? AppStringsEn.sound : 'Geluid';
  static String get language => _language == 'en' ? AppStringsEn.language : 'Taal';
  static String get theme => _language == 'en' ? AppStringsEn.theme : 'Thema';
  static String get darkMode => _language == 'en' ? AppStringsEn.darkMode : 'Donkere modus';
  static String get lightMode => _language == 'en' ? AppStringsEn.lightMode : 'Lichte modus';
  static String get systemDefault => _language == 'en' ? AppStringsEn.systemDefault : 'Systeemstandaard';

  // Lessons
  static String get lessons => _language == 'en' ? AppStringsEn.lessons : 'Lessen';
  static String get continueLearning => _language == 'en' ? AppStringsEn.continueLearning : 'Verder leren';

  // Store
  static String get store => _language == 'en' ? AppStringsEn.store : 'Winkel';
  static String get unlockAll => _language == 'en' ? AppStringsEn.unlockAll : 'Alles ontgrendelen';
  static String get purchaseSuccessful => _language == 'en' ? AppStringsEn.purchaseSuccessful : 'Aankoop voltooid!';

  // Donation
  static String get donate => _language == 'en' ? AppStringsEn.donate : 'Ondersteun ons';
  static String get donateButton => _language == 'en' ? AppStringsEn.donateButton : 'Doneer nu';
  static String get donateExplanation => _language == 'en' ? AppStringsEn.donateExplanation : 'Steun de ontwikkeling van deze app met een donatie. Dit is nodig om de app verder te ontwikkelen/onderhouden.';

  // Guide
  static String get guide => _language == 'en' ? AppStringsEn.guide : 'Handleiding';
  static String get howToPlay => _language == 'en' ? AppStringsEn.howToPlay : 'Hoe te spelen';

  // Errors
  static String get connectionError => _language == 'en' ? AppStringsEn.connectionError : 'Geen internetverbinding';
  static String get connectionErrorMsg => _language == 'en' ? AppStringsEn.connectionErrorMsg : 'Controleer je internetverbinding en probeer het opnieuw.';
  static String get unknownError => _language == 'en' ? AppStringsEn.unknownError : 'Er is een fout opgetreden';
  static String get errorNoQuestions => _language == 'en' ? AppStringsEn.errorNoQuestions : 'Geen geldige vragen gevonden';
  static String get errorLoadQuestions => _language == 'en' ? AppStringsEn.errorLoadQuestions : 'Fout bij het laden van de vragen';
  static String get couldNotOpenDonationPage => _language == 'en' ? AppStringsEn.couldNotOpenDonationPage : 'Kon de donatiepagina niet openen';
  static String get aiError => _language == 'en' ? AppStringsEn.aiError : 'AI-service fout opgetreden';
  static String get apiError => _language == 'en' ? AppStringsEn.apiError : 'API-service fout opgetreden';
  static String get storageError => _language == 'en' ? AppStringsEn.storageError : 'Opslagfout opgetreden';
  static String get syncError => _language == 'en' ? AppStringsEn.syncError : 'Synchronisatie mislukt';
  static String get permissionDenied => _language == 'en' ? AppStringsEn.permissionDenied : 'Toestemming vereist voor deze functie';

  // Quiz metrics
  static String get streak => _language == 'en' ? AppStringsEn.streak : 'Reeks';
  static String get best => _language == 'en' ? AppStringsEn.best : 'Beste';
  static String get time => _language == 'en' ? AppStringsEn.time : 'Tijd';
  static String get screenSizeNotSupported => _language == 'en' ? AppStringsEn.screenSizeNotSupported : 'Schermgrootte niet ondersteund';
  static String get yourProgress => _language == 'en' ? AppStringsEn.yourProgress : 'Jouw voortgang';
  static String get dailyStreak => _language == 'en' ? AppStringsEn.dailyStreak : 'Dagelijkse reeks';
  static String get continueWith => _language == 'en' ? AppStringsEn.continueWith : 'Ga verder';
  static String get multiplayerQuiz => _language == 'en' ? AppStringsEn.multiplayerQuiz : 'Multiplayer Quiz';
  static String get chooseGameDuration => _language == 'en' ? AppStringsEn.chooseGameDuration : 'Kies spelduur';
  static String get startMultiplayerQuiz => _language == 'en' ? AppStringsEn.startMultiplayerQuiz : 'Start Multiplayer Quiz';
  static String get multiplayerDescription => _language == 'en' ? AppStringsEn.multiplayerDescription : 'Speel tegen elkaar op één telefoon! De telefoon wordt in tweeën gesplitst - bovenste helft draait 180 graden om.';
  static String get gameRules => _language == 'en' ? AppStringsEn.gameRules : 'Spelregels:';
  static String get ruleBothPlayers => _language == 'en' ? AppStringsEn.ruleBothPlayers : '• Beide spelers beantwoorden Bijbelvragen';
  static String get ruleCorrectAnswer => _language == 'en' ? AppStringsEn.ruleCorrectAnswer : '• Een correct antwoord geeft punten';
  static String get ruleWinner => _language == 'en' ? AppStringsEn.ruleWinner : '• Degene met de correcte antwoorden aan het einde wint';
  static String get ruleScreenRotation => _language == 'en' ? AppStringsEn.ruleScreenRotation : '• De bovenste helft van het scherm draait 180 graden op mobiel';

  // Time up dialog
  static String get timeUp => _language == 'en' ? AppStringsEn.timeUp : 'Tijd is om!';
  static String get timeUpMessage => _language == 'en' ? AppStringsEn.timeUpMessage : 'Je hebt niet op tijd geantwoord. Je reeks is gereset.';
  static String get notEnoughPoints => _language == 'en' ? AppStringsEn.notEnoughPoints : 'Onvoldoende punten';

  // Lesson complete screen
  static String get lessonComplete => _language == 'en' ? AppStringsEn.lessonComplete : 'Les voltooid';
  static String get percentage => _language == 'en' ? AppStringsEn.percentage : 'Percentage';
  static String get bestStreak => _language == 'en' ? AppStringsEn.bestStreak : 'Beste reeks';
  static String get streakLabel => _language == 'en' ? AppStringsEn.streakLabel : ' reeks';
  static String get retryLesson => _language == 'en' ? AppStringsEn.retryLesson : 'Opnieuw proberen';
  static String get nextLesson => _language == 'en' ? AppStringsEn.nextLesson : 'Volgende les';
  static String get backToLessons => _language == 'en' ? AppStringsEn.backToLessons : 'Terug naar lessen';
  static String get endScore => _language == 'en' ? AppStringsEn.endScore : 'Eindscore';
  static String get endScoreHint => _language == 'en' ? AppStringsEn.endScoreHint : 'Jouw totaalscore in percentage op een snelheidsmeter';

  // Settings screen
  static String get display => _language == 'en' ? AppStringsEn.display : 'Weergave';
  static String get chooseTheme => _language == 'en' ? AppStringsEn.chooseTheme : 'Kies je thema';
  static String get lightTheme => _language == 'en' ? AppStringsEn.lightTheme : 'Licht';
  static String get systemTheme => _language == 'en' ? AppStringsEn.systemTheme : 'Systeem';
  static String get darkTheme => _language == 'en' ? AppStringsEn.darkTheme : 'Donker';
  static String get oledTheme => _language == 'en' ? AppStringsEn.oledTheme : 'OLED';
  static String get greenTheme => _language == 'en' ? AppStringsEn.greenTheme : 'Groen';
  static String get orangeTheme => _language == 'en' ? AppStringsEn.orangeTheme : 'Oranje';
  static String get showNavigationLabels => _language == 'en' ? AppStringsEn.showNavigationLabels : 'Toon navigatielabels';
  static String get showNavigationLabelsDesc => _language == 'en' ? AppStringsEn.showNavigationLabelsDesc : 'Toon of verberg tekstlabels onder de navigatie-iconen';
  static String get colorfulMode => _language == 'en' ? AppStringsEn.colorfulMode : 'Kleurrijke modus';
  static String get colorfulModeDesc => _language == 'en' ? AppStringsEn.colorfulModeDesc : 'Zet verschillende kleuren aan voor leskaarten';
  static String get hidePopup => _language == 'en' ? AppStringsEn.hidePopup : 'Verberg promotie pop-up';
  static String get hidePopupDesc => _language == 'en' ? AppStringsEn.hidePopupDesc : 'Wil je deze instelling alleen aanzetten als u aan ons heeft gedoneerd? We hebben geen manier om het te verifieren, maar we vertrouwen erop dat je eerlijk bent.';
  static String get tryAgain => _language == 'en' ? AppStringsEn.tryAgain : 'Opnieuw proberen';
  static String get couldNotOpenStatusPage => _language == 'en' ? AppStringsEn.couldNotOpenStatusPage : 'Kon de statuspagina niet openen.';

  // Lesson select screen
  static String get couldNotLoadLessons => _language == 'en' ? AppStringsEn.couldNotLoadLessons : 'Kon lessen niet laden';
  static String get progress => _language == 'en' ? AppStringsEn.progress : 'Voortgang';
  static String get resetProgress => _language == 'en' ? AppStringsEn.resetProgress : 'Voortgang resetten';
  static String get resetProgressConfirmation => _language == 'en' ? AppStringsEn.resetProgressConfirmation : 'Weet je zeker dat je je voortgang wilt resetten? Dit kan niet ongedaan worden gemaakt.';
  static String get confirm => _language == 'en' ? AppStringsEn.confirm : 'Bevestigen';
  static String get startLesson => _language == 'en' ? AppStringsEn.startLesson : 'Start les';
  static String get locked => _language == 'en' ? AppStringsEn.locked : 'Vergrendeld';
  static String get complete => _language == 'en' ? AppStringsEn.complete : 'Voltooid';
  static String get perfectScore => _language == 'en' ? AppStringsEn.perfectScore : 'Perfecte score!';
  static String get retry => _language == 'en' ? AppStringsEn.retry : 'Opnieuw proberen';
  static String get unknownUser => _language == 'en' ? AppStringsEn.unknownUser : 'Onbekende Gebruiker';
  static String get lastScore => _language == 'en' ? AppStringsEn.lastScore : 'Laatste score:';
  static String get notAvailable => _language == 'en' ? AppStringsEn.notAvailable : 'Onbekend';

  // Guide screen
  static String get previous => _language == 'en' ? AppStringsEn.previous : 'Vorige';
  static String get next => _language == 'en' ? AppStringsEn.next : 'Volgende';
  static String get getStarted => _language == 'en' ? AppStringsEn.getStarted : 'Aan de slag';
  static String get welcomeTitle => _language == 'en' ? AppStringsEn.welcomeTitle : 'Welkom bij BijbelQuiz';
  static String get welcomeDescription => _language == 'en' ? AppStringsEn.welcomeDescription : 'Ontdek de Bijbel op een leuke en interactieve manier met uitdagende vragen en lessen.';
  static String get howToPlayTitle => _language == 'en' ? AppStringsEn.howToPlayTitle : 'Hoe speel je?';
  static String get howToPlayDescription => _language == 'en' ? AppStringsEn.howToPlayDescription : 'Beantwoord vragen over de Bijbel. Hoe accurater je antwoord, hoe meer punten je verdient. Punten kun je later uitgeven in de winkel voor exclusieve thema\'s en power-ups.';
  static String get trackProgressTitle => _language == 'en' ? AppStringsEn.trackProgressTitle : 'Speel alleen, met vrienden of familie';
  static String get trackProgressDescription => _language == 'en' ? AppStringsEn.trackProgressDescription : 'Ga naar het "Sociaal" tabblad om vrienden te volgen of klik op Multiplayer Quiz om samen te spelen.';
  static String get customizeExperienceTitle => _language == 'en' ? AppStringsEn.customizeExperienceTitle : 'Pas Je Ervaring Aan';
  static final String customizeExperienceDescription =
      'Pas je thema, speelsnelheid en de geluidseffecten aan in de instellingen. Heeft u nog vragen of suggesties? We horen graag van je via ${AppUrls.contactEmail}';
  static String get supportUsDescription => _language == 'en' ? AppStringsEn.supportUsDescription : 'Vind je deze app nuttig? Overweeg dan een donatie om ons te helpen de app te onderhouden en te verbeteren. Elke bijdrage wordt gewaardeerd!';
  static String get donateNow => _language == 'en' ? AppStringsEn.donateNow : 'Doneer Nu';

  // Activation screen
  static String get activationTitle => _language == 'en' ? AppStringsEn.activationTitle : 'Activeer je account';
  static String get activationSubtitle => _language == 'en' ? AppStringsEn.activationSubtitle : 'Voer je activatiecode in om de app te gebruiken';
  static String get activationCodeHint => _language == 'en' ? AppStringsEn.activationCodeHint : 'Voer je activatiecode in';
  static String get activateButton => _language == 'en' ? AppStringsEn.activateButton : 'Activeren';
  static String get verifyButton => _language == 'en' ? AppStringsEn.verifyButton : 'Verifiëren';
  static String get verifying => _language == 'en' ? AppStringsEn.verifying : 'Controleren...';
  static String get activationTip => _language == 'en' ? AppStringsEn.activationTip : 'Voer de activatiecode in die je hebt ontvangen bij aankoop.';
  static String get activationSuccess => _language == 'en' ? AppStringsEn.activationSuccess : 'Succesvol geactiveerd!';
  static String get activationError => _language == 'en' ? AppStringsEn.activationError : 'Ongeldige activatiecode. Probeer het opnieuw.';
  static String get activationErrorTitle => _language == 'en' ? AppStringsEn.activationErrorTitle : 'Activatie mislukt';
  static String get activationSuccessMessage => _language == 'en' ? AppStringsEn.activationSuccessMessage : 'Je account is succesvol geactiveerd. Veel plezier met de app!';
  static String get activationRequired => _language == 'en' ? AppStringsEn.activationRequired : 'Activatie vereist';
  static String get activationRequiredMessage => _language == 'en' ? AppStringsEn.activationRequiredMessage : 'Je moet de app activeren voordat je deze kunt gebruiken.';

  // Store screen
  static String get yourStars => _language == 'en' ? AppStringsEn.yourStars : 'Jouw sterren';
  static String get availableStars => _language == 'en' ? AppStringsEn.availableStars : 'Beschikbare sterren';
  static String get powerUps => _language == 'en' ? AppStringsEn.powerUps : 'Power-ups';
  static String get themes => _language == 'en' ? AppStringsEn.themes : 'Thema\'s';
  static String get availableThemes => _language == 'en' ? AppStringsEn.availableThemes : 'Beschikbare thema\'s';
  static String get unlockTheme => _language == 'en' ? AppStringsEn.unlockTheme : 'Ontgrendel thema';
  static String get unlocked => _language == 'en' ? AppStringsEn.unlocked : 'Ontgrendeld';
  static String get notEnoughStars => _language == 'en' ? AppStringsEn.notEnoughStars : 'Niet genoeg sterren';
  static String get unlockFor => _language == 'en' ? AppStringsEn.unlockFor : 'Ontgrendel voor';
  static String get stars => _language == 'en' ? AppStringsEn.stars : 'sterren';
  static String get free => _language == 'en' ? AppStringsEn.free : 'Gratis';
  static String get purchased => _language == 'en' ? AppStringsEn.purchased : 'Aangekocht';
  static String get confirmPurchase => _language == 'en' ? AppStringsEn.confirmPurchase : 'Bevestig aankoop';
  static String get purchaseConfirmation => _language == 'en' ? AppStringsEn.purchaseConfirmation : 'Weet je zeker dat je dit thema wilt ontgrendelen voor';
  static String get purchaseSuccess => _language == 'en' ? AppStringsEn.purchaseSuccess : 'Thema succesvol ontgrendeld!';
  static String get purchaseError => _language == 'en' ? AppStringsEn.purchaseError : 'Niet genoeg sterren om dit thema te ontgrendelen.';
  static String get couldNotOpenDownloadPage => _language == 'en' ? AppStringsEn.couldNotOpenDownloadPage : 'Kon de downloadpagina niet openen';
  static String get themeUnlockedWithSwitchOption => _language == 'en' ? AppStringsEn.themeUnlockedWithSwitchOption : 'ontgrendeld! Je kunt altijd terugkeren naar het standaardthema in de instellingen.';

  // Power-ups
  static String get doubleStars5Questions => _language == 'en' ? AppStringsEn.doubleStars5Questions : 'Dubbele sterren (5 vragen)';
  static String get doubleStars5QuestionsDesc => _language == 'en' ? AppStringsEn.doubleStars5QuestionsDesc : 'Verdien dubbele sterren voor je volgende 5 vragen';
  static String get tripleStars5Questions => _language == 'en' ? AppStringsEn.tripleStars5Questions : 'Driedubbele sterren (5 vragen)';
  static String get tripleStars5QuestionsDesc => _language == 'en' ? AppStringsEn.tripleStars5QuestionsDesc : 'Verdien driedubbele sterren voor je volgende 5 vragen';
  static String get fiveTimesStars5Questions => _language == 'en' ? AppStringsEn.fiveTimesStars5Questions : '5x sterren (5 vragen)';
  static String get fiveTimesStars5QuestionsDesc => _language == 'en' ? AppStringsEn.fiveTimesStars5QuestionsDesc : 'Verdien 5x sterren voor je volgende 5 vragen';
  static String get doubleStars60Seconds => _language == 'en' ? AppStringsEn.doubleStars60Seconds : 'Dubbele sterren (60 seconden)';
  static String get doubleStars60SecondsDesc => _language == 'en' ? AppStringsEn.doubleStars60SecondsDesc : 'Verdien dubbele sterren gedurende 60 seconden';

  // Theme names
  static String get oledThemeName => _language == 'en' ? AppStringsEn.oledThemeName : 'OLED thema';
  static String get oledThemeDesc => _language == 'en' ? AppStringsEn.oledThemeDesc : 'Ontgrendel een echt zwart, hoog-contrast thema';
  static String get greenThemeName => _language == 'en' ? AppStringsEn.greenThemeName : 'Groen thema';
  static String get greenThemeDesc => _language == 'en' ? AppStringsEn.greenThemeDesc : 'Ontgrendel een fris groen thema';
  static String get orangeThemeName => _language == 'en' ? AppStringsEn.orangeThemeName : 'Oranje thema';
  static String get orangeThemeDesc => _language == 'en' ? AppStringsEn.orangeThemeDesc : 'Ontgrendel een levendig oranje thema';

  // Coupons
  static String get couponTitle => _language == 'en' ? AppStringsEn.couponTitle : 'Coupon code';
  static String get couponDescription => _language == 'en' ? AppStringsEn.couponDescription : 'Wissel hem hier in voor beloningen';
  static String get couponRedeem => _language == 'en' ? AppStringsEn.couponRedeem : 'Inwisselen';
  static String get couponDialogTitle => _language == 'en' ? AppStringsEn.couponDialogTitle : 'Coupon inwisselen';
  static String get couponCodeLabel => _language == 'en' ? AppStringsEn.couponCodeLabel : 'Coupon code';
  static String get couponCodeHint => _language == 'en' ? AppStringsEn.couponCodeHint : 'Coupon hier...';
  static String get couponSuccessTitle => _language == 'en' ? AppStringsEn.couponSuccessTitle : 'Gefeliciteerd!';
  static String get couponStarsReceived => _language == 'en' ? AppStringsEn.couponStarsReceived : 'Je hebt {amount} sterren ontvangen!';
  static String get couponThemeUnlocked => _language == 'en' ? AppStringsEn.couponThemeUnlocked : 'Je hebt een nieuw thema ontgrendeld!';
  static String get couponErrorTitle => _language == 'en' ? AppStringsEn.couponErrorTitle : 'Fout';
  static String get couponInvalid => _language == 'en' ? AppStringsEn.couponInvalid : 'Ongeldige coupon code';
  static String get couponExpired => _language == 'en' ? AppStringsEn.couponExpired : 'Deze coupon is verlopen';
  static String get couponMaxUsed => _language == 'en' ? AppStringsEn.couponMaxUsed : 'Deze coupon is niet meer geldig (maximaal aantal keer gebruikt)';
  static String get couponAlreadyRedeemed => _language == 'en' ? AppStringsEn.couponAlreadyRedeemed : 'Deze coupon is al ingewisseld';
  static String get couponMaxPerDay => _language == 'en' ? AppStringsEn.couponMaxPerDay : 'Maximaal 5 coupons kunnen per dag worden ingewisseld';
  static String get qrCode => _language == 'en' ? AppStringsEn.qrCode : 'QR-code';
  static String get qrCodeDescription => _language == 'en' ? AppStringsEn.qrCodeDescription : 'Richt de camera op de QR-code';
  static String get qrScannerMobileOnly => _language == 'en' ? AppStringsEn.qrScannerMobileOnly : 'QR-scanner alleen beschikbaar op mobiel';
  static String get invalidQRCode => _language == 'en' ? AppStringsEn.invalidQRCode : 'Ongeldige QR-code';
  static String get cameraAccessRequired => _language == 'en' ? AppStringsEn.cameraAccessRequired : 'Camera toegang vereist';
  static String get cameraAccessDescription => _language == 'en' ? AppStringsEn.cameraAccessDescription : 'Om QR-codes te kunnen scannen, heeft de app toegang nodig tot je camera. Deze toestemming wordt alleen gebruikt voor het scannen van coupons.';
  static String get grantCameraPermission => _language == 'en' ? AppStringsEn.grantCameraPermission : 'Camera toestemming verlenen';
  static String get openSettings => _language == 'en' ? AppStringsEn.openSettings : 'Instellingen openen';
  static String get cameraError => _language == 'en' ? AppStringsEn.cameraError : 'Camera fout';
  static String get cameraInitializationError => _language == 'en' ? AppStringsEn.cameraInitializationError : 'Er is een fout opgetreden bij het initialiseren van de camera: ';
  static String get initializingCamera => _language == 'en' ? AppStringsEn.initializingCamera : 'Camera initialiseren...';
  static String get qrCodeTutorial => _language == 'en' ? AppStringsEn.qrCodeTutorial : 'Houd de QR-code binnen het kader voor automatische detectie';


  // Settings screen
  static String get supportUsTitle => _language == 'en' ? AppStringsEn.supportUsTitle : 'Ondersteun ons';
  static String get errorLoadingSettings => _language == 'en' ? AppStringsEn.errorLoadingSettings : 'Fout bij het laden van instellingen';
  static String get gameSettings => _language == 'en' ? AppStringsEn.gameSettings : 'Spelinstellingen';
  static String get gameSpeed => _language == 'en' ? AppStringsEn.gameSpeed : 'Spelsnelheid';
  static String get chooseGameSpeed => _language == 'en' ? AppStringsEn.chooseGameSpeed : 'Kies de snelheid van het spel';
  static String get slow => _language == 'en' ? AppStringsEn.slow : 'Langzaam';
  static String get medium => _language == 'en' ? AppStringsEn.medium : 'Gemiddeld';
  static String get fast => _language == 'en' ? AppStringsEn.fast : 'Snel';
  static String get muteSoundEffects => _language == 'en' ? AppStringsEn.muteSoundEffects : 'Geluidseffecten dempen';
  static String get muteSoundEffectsDesc => _language == 'en' ? AppStringsEn.muteSoundEffectsDesc : 'Schakel alle spelgeluiden uit';
  static String get about => _language == 'en' ? AppStringsEn.about : 'Over';

  // Server status
  static String get serverStatus => _language == 'en' ? AppStringsEn.serverStatus : 'Serverstatus';
  static String get checkServiceStatus => _language == 'en' ? AppStringsEn.checkServiceStatus : 'Controleer de status van onze services';
  static String get openStatusPage => _language == 'en' ? AppStringsEn.openStatusPage : 'Open statuspagina';

  // Notifications

  // Actions
  static String get actions => _language == 'en' ? AppStringsEn.actions : 'Acties';
  static String get exportStats => _language == 'en' ? AppStringsEn.exportStats : 'Statistieken exporteren';
  static String get exportStatsDesc => _language == 'en' ? AppStringsEn.exportStatsDesc : 'Sla je voortgang en scores op als tekst';
  static String get importStats => _language == 'en' ? AppStringsEn.importStats : 'Statistieken importeren';
  static String get importStatsDesc => _language == 'en' ? AppStringsEn.importStatsDesc : 'Laad eerder geëxporteerde statistieken';
  static String get resetAndLogout => _language == 'en' ? AppStringsEn.resetAndLogout : 'Resetten en uitloggen';
  static String get resetAndLogoutDesc => _language == 'en' ? AppStringsEn.resetAndLogoutDesc : 'Alle gegevens wissen en app deactiveren';
  static String get showIntroduction => _language == 'en' ? AppStringsEn.showIntroduction : 'Introductie tonen';
  static String get reportIssue => _language == 'en' ? AppStringsEn.reportIssue : 'Probleem melden';
  static String get clearQuestionCache => _language == 'en' ? AppStringsEn.clearQuestionCache : 'Vragencache wissen';
  static String get contactUs => _language == 'en' ? AppStringsEn.contactUs : 'Neem contact op';
  static String get emailNotAvailable => _language == 'en' ? AppStringsEn.emailNotAvailable : 'Kon e-mailclient niet openen';
  static String get cacheCleared => _language == 'en' ? AppStringsEn.cacheCleared : 'Vragencache gewist!';

  // Debug/Test
  static String get testAllFeatures => _language == 'en' ? AppStringsEn.testAllFeatures : 'Test Alle Functies';

  // Footer
  static String get copyright => _language == 'en' ? AppStringsEn.copyright : '© 2024-2025 ThomasNow Productions';
  static String get version => _language == 'en' ? AppStringsEn.version : 'Versie';

  // Social
  static String get social => _language == 'en' ? AppStringsEn.social : 'Sociaal';
  static String get comingSoon => _language == 'en' ? AppStringsEn.comingSoon : 'Binnenkort beschikbaar!';
  static String get socialComingSoonMessage => _language == 'en' ? AppStringsEn.socialComingSoonMessage : 'De sociale functies van BijbelQuiz zijn binnenkort beschikbaar. Blijf op de hoogte voor updates!';
  static String get manageYourBqid => _language == 'en' ? AppStringsEn.manageYourBqid : 'Beheer je BQID';
  static String get manageYourBqidSubtitle => _language == 'en' ? AppStringsEn.manageYourBqidSubtitle : 'Beheer je BQID, geregistreerde apparaten en meer';
  static String get moreSocialFeaturesComingSoon => _language == 'en' ? AppStringsEn.moreSocialFeaturesComingSoon : 'Meer sociale functies binnenkort beschikbaar';
  static String get socialFeatures => _language == 'en' ? AppStringsEn.socialFeatures : 'Sociale Functies';
  static String get connectWithOtherUsers => _language == 'en' ? AppStringsEn.connectWithOtherUsers : 'Verbind met andere BijbelQuiz-gebruikers, deel prestaties en strijd op de scoreborden!';
  static String get search => _language == 'en' ? AppStringsEn.search : 'Zoeken';
  static String get myFollowing => _language == 'en' ? AppStringsEn.myFollowing : 'Volgend';
  static String get myFollowers => _language == 'en' ? AppStringsEn.myFollowers : 'Volgers';
  static String get messages => _language == 'en' ? AppStringsEn.messages : 'Berichten';
  static String get followedUsersScores => _language == 'en' ? AppStringsEn.followedUsersScores : 'Scores van Gevolgde Gebruikers';
  static String get searchUsers => _language == 'en' ? AppStringsEn.searchUsers : 'Zoek Gebruikers';
  static String get searchByUsername => _language == 'en' ? AppStringsEn.searchByUsername : 'Zoek op gebruikersnaam';
  static String get enterUsernameToSearch => _language == 'en' ? AppStringsEn.enterUsernameToSearch : 'Voer gebruikersnaam in om te zoeken...';
  static String get noUsersFound => _language == 'en' ? AppStringsEn.noUsersFound : 'Geen gebruikers gevonden';
  static String get follow => _language == 'en' ? AppStringsEn.follow : 'Volgen';
  static String get unfollow => _language == 'en' ? AppStringsEn.unfollow : 'Ontvolgen';
  static String get yourself => _language == 'en' ? AppStringsEn.yourself : 'Zelf';

  // Bible Bot
  static String get bibleBot => _language == 'en' ? AppStringsEn.bibleBot : 'Bijbel Bot';

  // Errors
  static String get couldNotOpenEmail => _language == 'en' ? AppStringsEn.couldNotOpenEmail : 'Kon e-mailclient niet openen';
  static String get couldNotOpenUpdatePage => _language == 'en' ? AppStringsEn.couldNotOpenUpdatePage : 'Kon update pagina niet openen';
  static String get errorOpeningUpdatePage => _language == 'en' ? AppStringsEn.errorOpeningUpdatePage : 'Fout bij openen update pagina: ';
  static String get couldNotCopyLink => _language == 'en' ? AppStringsEn.couldNotCopyLink : 'Kon link niet kopiëren';
  static String get errorCopyingLink => _language == 'en' ? AppStringsEn.errorCopyingLink : 'Kon link niet kopiëren: ';
  static String get inviteLinkCopied => _language == 'en' ? AppStringsEn.inviteLinkCopied : 'Uitnodigingslink gekopieerd naar klembord!';
  static String get statsLinkCopied => _language == 'en' ? AppStringsEn.statsLinkCopied : 'Statistieken link gekopieerd naar klembord!';
  static String get copyStatsLinkToClipboard => _language == 'en' ? AppStringsEn.copyStatsLinkToClipboard : 'Kopieer je statistieken link naar het klembord';
  static String get importButton => _language == 'en' ? AppStringsEn.importButton : 'Importeren';

  // Popups
  static String get followUs => _language == 'en' ? AppStringsEn.followUs : 'Volg ons';
  static String get followUsMessage => _language == 'en' ? AppStringsEn.followUsMessage : 'Volg ons op social media voor updates en community!';
  static String get followMastodon => _language == 'en' ? AppStringsEn.followMastodon : 'Volg Mastodon';
  static String get followPixelfed => _language == 'en' ? AppStringsEn.followPixelfed : 'Volg Pixelfed';
  static String get followKwebler => _language == 'en' ? AppStringsEn.followKwebler : 'Volg Kwebler';
  static String get followSignal => _language == 'en' ? AppStringsEn.followSignal : 'Volg Signal';
  static String get followDiscord => _language == 'en' ? AppStringsEn.followDiscord : 'Volg Discord';
  static String get followBluesky => _language == 'en' ? AppStringsEn.followBluesky : 'Volg Bluesky';
  static String get followNooki => _language == 'en' ? AppStringsEn.followNooki : 'Volg Nooki';
  static final String mastodonUrl = AppUrls.mastodonUrl;
  static final String pixelfedUrl = AppUrls.pixelfedUrl;
  static final String kweblerUrl = AppUrls.kweblerUrl;
  static final String signalUrl = AppUrls.signalUrl;
  static final String discordUrl = AppUrls.discordUrl;
  static final String blueskyUrl = AppUrls.blueskyUrl;
  static final String nookiUrl = AppUrls.nookiUrl;

  // Satisfaction Survey
  static String get satisfactionSurvey => _language == 'en' ? AppStringsEn.satisfactionSurvey : 'Help ons te verbeteren';
  static String get satisfactionSurveyMessage => _language == 'en' ? AppStringsEn.satisfactionSurveyMessage : 'Neem een paar minuten om ons te helpen de app te verbeteren. Uw feedback is belangrijk!';
  static String get satisfactionSurveyButton => _language == 'en' ? AppStringsEn.satisfactionSurveyButton : 'Vul enquête in';

  // Difficulty Feedback
  static String get difficultyFeedbackTitle => _language == 'en' ? AppStringsEn.difficultyFeedbackTitle : 'Hoe bevalt de moeilijkheidsgraad?';
  static String get difficultyFeedbackMessage => _language == 'en' ? AppStringsEn.difficultyFeedbackMessage : 'Laat ons weten of de vragen te makkelijk of te moeilijk zijn.';
  static String get difficultyTooHard => _language == 'en' ? AppStringsEn.difficultyTooHard : 'Te moeilijk';
  static String get difficultyGood => _language == 'en' ? AppStringsEn.difficultyGood : 'Goed';
  static String get difficultyTooEasy => _language == 'en' ? AppStringsEn.difficultyTooEasy : 'Te makkelijk';

  // Account Creation
  static String get createAccount => _language == 'en' ? AppStringsEn.createAccount : 'Account aanmaken';
  static String get createAccountMessage => _language == 'en' ? AppStringsEn.createAccountMessage : 'Maak een account aan om sociale functies te ontgrendelen en je voortgang over apparaten te synchroniseren!';
  static String get createAccountButton => _language == 'en' ? AppStringsEn.createAccountButton : 'Account aanmaken';

  // Quiz Screen
  static String get skip => _language == 'en' ? AppStringsEn.skip : 'Skip';
  static String get overslaan => _language == 'en' ? AppStringsEn.overslaan : 'Overslaan';
  static String get notEnoughStarsForSkip => _language == 'en' ? AppStringsEn.notEnoughStarsForSkip : 'Niet genoeg sterren om over te slaan!';

  // Settings Screen
  static String get resetAndLogoutConfirmation => _language == 'en' ? AppStringsEn.resetAndLogoutConfirmation : 'Dit verwijdert alle scores, voortgang, cache, instellingen en activatie. De app wordt gedeactiveerd en vereist een nieuwe activatiecode. Deze actie kan niet ongedaan worden gemaakt.';

  // Guide Screen
  static String get donationError => _language == 'en' ? AppStringsEn.donationError : 'Er is een fout opgetreden bij het openen van de donatiepagina';
  static String get soundEffectsDescription => _language == 'en' ? AppStringsEn.soundEffectsDescription : 'Schakel alle spelgeluiden in of uit';

  // Store Screen
  static String get doubleStarsActivated => _language == 'en' ? AppStringsEn.doubleStarsActivated : 'Dubbele Sterren geactiveerd voor 5 vragen!';
  static String get tripleStarsActivated => _language == 'en' ? AppStringsEn.tripleStarsActivated : 'Driedubbele Sterren geactiveerd voor 5 vragen!';
  static String get fiveTimesStarsActivated => _language == 'en' ? AppStringsEn.fiveTimesStarsActivated : '5x Sterren geactiveerd voor 5 vragen!';
  static String get doubleStars60SecondsActivated => _language == 'en' ? AppStringsEn.doubleStars60SecondsActivated : 'Dubbele Sterren geactiveerd voor 60 seconden!';
  static String get powerupActivated => _language == 'en' ? AppStringsEn.powerupActivated : 'Power-up Geactiveerd!';
  static String get backToQuiz => _language == 'en' ? AppStringsEn.backToQuiz : 'Naar de quiz';
  static String get themeUnlocked => _language == 'en' ? AppStringsEn.themeUnlocked : 'ontgrendeld!';

  // Lesson Select Screen
  static String get onlyLatestUnlockedLesson => _language == 'en' ? AppStringsEn.onlyLatestUnlockedLesson : 'Je kunt alleen de meest recente ontgrendelde les spelen';
  static String get starsEarned => _language == 'en' ? AppStringsEn.starsEarned : 'sterren verdiend';
  static String get readyForNextChallenge => _language == 'en' ? AppStringsEn.readyForNextChallenge : 'Klaar voor je volgende uitdaging?';
  static String get continueLesson => _language == 'en' ? AppStringsEn.continueLesson : 'Ga verder:';
  static String get freePractice => _language == 'en' ? AppStringsEn.freePractice : 'Vrij oefenen';
  static String get lessonNumber => _language == 'en' ? AppStringsEn.lessonNumber : 'Les';

  // Biblical Reference Dialog
  static String get invalidBiblicalReference => _language == 'en' ? AppStringsEn.invalidBiblicalReference : 'Ongeldige bijbelverwijzing';
  static String get errorLoadingBiblicalText => _language == 'en' ? AppStringsEn.errorLoadingBiblicalText : 'Fout bij het laden van de bijbeltekst';
  static String get errorLoadingWithDetails => _language == 'en' ? AppStringsEn.errorLoadingWithDetails : 'Fout bij het laden:';
  static String get resumeToGame => _language == 'en' ? AppStringsEn.resumeToGame : 'Hervat spel';

  // Settings Screen
  static String get emailAddress => _language == 'en' ? AppStringsEn.emailAddress : 'E-mailadres';

  // AI Theme
  static String get aiThemeFallback => _language == 'en' ? AppStringsEn.aiThemeFallback : 'AI Thema';
  static String get aiThemeGenerator => _language == 'en' ? AppStringsEn.aiThemeGenerator : 'AI Thema Generator';
  static String get aiThemeGeneratorDescription => _language == 'en' ? AppStringsEn.aiThemeGeneratorDescription : 'Beschrijf je gewenste kleuren en laat AI een thema voor je maken';

  // Settings Screen - Updates
  static String get checkForUpdates => _language == 'en' ? AppStringsEn.checkForUpdates : 'Controleer op updates';
  static String get checkForUpdatesDescription => _language == 'en' ? AppStringsEn.checkForUpdatesDescription : 'Zoek naar nieuwe app-versies';
  static String get checkForUpdatesTooltip => _language == 'en' ? AppStringsEn.checkForUpdatesTooltip : 'Controleer op updates';

  // Settings Screen - Privacy
  static String get privacyPolicy => _language == 'en' ? AppStringsEn.privacyPolicy : 'Privacybeleid';
  static String get privacyPolicyDescription => _language == 'en' ? AppStringsEn.privacyPolicyDescription : 'Lees ons privacybeleid';
  static String get couldNotOpenPrivacyPolicy => _language == 'en' ? AppStringsEn.couldNotOpenPrivacyPolicy : 'Kon privacybeleid niet openen';
  static String get openPrivacyPolicyTooltip => _language == 'en' ? AppStringsEn.openPrivacyPolicyTooltip : 'Open privacybeleid';

  // Settings Screen - Privacy & Analytics
  static String get privacyAndAnalytics => _language == 'en' ? AppStringsEn.privacyAndAnalytics : 'Privacy & Analytics';
  static String get analytics => _language == 'en' ? AppStringsEn.analytics : 'Analytics';
  static String get analyticsDescription => _language == 'en' ? AppStringsEn.analyticsDescription : 'Help ons de app te verbeteren door anonieme gebruiksgegevens te verzenden';

  // Local API Settings
  static String get localApi => _language == 'en' ? AppStringsEn.localApi : 'Lokale API';
  static String get enableLocalApi => _language == 'en' ? AppStringsEn.enableLocalApi : 'Lokale API inschakelen';
  static String get enableLocalApiDesc => _language == 'en' ? AppStringsEn.enableLocalApiDesc : 'Sta externe apps toe om quizgegevens te benaderen';
  static String get apiKey => _language == 'en' ? AppStringsEn.apiKey : 'API-sleutel';
  static String get generateApiKey => _language == 'en' ? AppStringsEn.generateApiKey : 'Genereer een sleutel voor API-toegang';
  static String get apiPort => _language == 'en' ? AppStringsEn.apiPort : 'API-poort';
  static String get apiPortDesc => _language == 'en' ? AppStringsEn.apiPortDesc : 'Poort voor lokale API-server';
  static String get apiStatus => _language == 'en' ? AppStringsEn.apiStatus : 'API-status';
  static String get apiStatusDesc => _language == 'en' ? AppStringsEn.apiStatusDesc : 'Toont of de API-server draait';
  static String get apiDisabled => _language == 'en' ? AppStringsEn.apiDisabled : 'Uitgeschakeld';
  static String get apiRunning => _language == 'en' ? AppStringsEn.apiRunning : 'Draait';
  static String get apiStarting => _language == 'en' ? AppStringsEn.apiStarting : 'Starten...';
  static String get copyApiKey => _language == 'en' ? AppStringsEn.copyApiKey : 'API-sleutel kopiëren';
  static String get regenerateApiKey => _language == 'en' ? AppStringsEn.regenerateApiKey : 'API-sleutel opnieuw genereren';
  static String get regenerateApiKeyTitle => _language == 'en' ? AppStringsEn.regenerateApiKeyTitle : 'API-sleutel opnieuw genereren';
  static String get regenerateApiKeyMessage => _language == 'en' ? AppStringsEn.regenerateApiKeyMessage : 'Dit genereert een nieuwe API-sleutel en maakt de huidige ongeldig. Doorgaan?';
  static String get apiKeyCopied => _language == 'en' ? AppStringsEn.apiKeyCopied : 'API-sleutel gekopieerd naar klembord';
  static String get apiKeyCopyFailed => _language == 'en' ? AppStringsEn.apiKeyCopyFailed : 'Kon API-sleutel niet kopiëren';
  static String get generateKey => _language == 'en' ? AppStringsEn.generateKey : 'Genereer sleutel';
  static String get apiKeyGenerated => _language == 'en' ? AppStringsEn.apiKeyGenerated : 'Nieuwe API-sleutel gegenereerd';

  // Social Media
  static String get followOnSocialMedia => _language == 'en' ? AppStringsEn.followOnSocialMedia : 'Volg op social media';
  static String get followUsOnSocialMedia => _language == 'en' ? AppStringsEn.followUsOnSocialMedia : 'Volg ons op social media';
  static String get mastodon => _language == 'en' ? AppStringsEn.mastodon : 'Mastodon';
  static String get pixelfed => _language == 'en' ? AppStringsEn.pixelfed : 'Pixelfed';
  static String get kwebler => _language == 'en' ? AppStringsEn.kwebler : 'Kwebler';
  static String get discord => _language == 'en' ? AppStringsEn.discord : 'Discord';
  static String get signal => _language == 'en' ? AppStringsEn.signal : 'Signal';
  static String get bluesky => _language == 'en' ? AppStringsEn.bluesky : 'Bluesky';
  static String get nooki => _language == 'en' ? AppStringsEn.nooki : 'Nooki';
  static String get couldNotOpenPlatform => _language == 'en' ? AppStringsEn.couldNotOpenPlatform : 'Kon {platform} niet openen';
  static String get shareAppWithFriends => _language == 'en' ? AppStringsEn.shareAppWithFriends : 'Deel app met vrienden';
  static String get shareYourStats => _language == 'en' ? AppStringsEn.shareYourStats : 'Deel je statistieken';
  static String get inviteFriend => _language == 'en' ? AppStringsEn.inviteFriend : 'Nodig een vriend uit';
  static String get enterYourName => _language == 'en' ? AppStringsEn.enterYourName : 'Voer je naam in';
  static String get enterFriendName => _language == 'en' ? AppStringsEn.enterFriendName : 'Voer de naam van je vriend in';
  static String get inviteMessage => _language == 'en' ? AppStringsEn.inviteMessage : 'Nodig je vriend uit voor de BijbelQuiz!';
  static String get customizeInvite => _language == 'en' ? AppStringsEn.customizeInvite : 'Personaliseer je uitnodiging';
  static String get sendInvite => _language == 'en' ? AppStringsEn.sendInvite : 'Verzend uitnodiging';

  // Settings Provider Errors
  static String get languageMustBeNl => _language == 'en' ? AppStringsEn.languageMustBeNl : 'Taal moet "nl" zijn (alleen Nederlands toegestaan)';
  static String get failedToSaveTheme => _language == 'en' ? AppStringsEn.failedToSaveTheme : 'Kon thema-instelling niet opslaan:';
  static String get failedToSaveSlowMode => _language == 'en' ? AppStringsEn.failedToSaveSlowMode : 'Kon langzame modus-instelling niet opslaan:';
  static String get failedToSaveGameSpeed => _language == 'en' ? AppStringsEn.failedToSaveGameSpeed : 'Kon spelsnelheid-instelling niet opslaan:';
  static String get failedToUpdateDonationStatus => _language == 'en' ? AppStringsEn.failedToUpdateDonationStatus : 'Kon donatiestatus niet bijwerken:';
  static String get failedToUpdateCheckForUpdateStatus => _language == 'en' ? AppStringsEn.failedToUpdateCheckForUpdateStatus : 'Kon update-controle status niet bijwerken:';
  static String get failedToSaveMuteSetting => _language == 'en' ? AppStringsEn.failedToSaveMuteSetting : 'Kon demp-instelling niet opslaan:';
  static String get failedToSaveGuideStatus => _language == 'en' ? AppStringsEn.failedToSaveGuideStatus : 'Kon gidsstatus niet opslaan:';
  static String get failedToResetGuideStatus => _language == 'en' ? AppStringsEn.failedToResetGuideStatus : 'Kon gidsstatus niet resetten:';
  static String get failedToResetCheckForUpdateStatus => _language == 'en' ? AppStringsEn.failedToResetCheckForUpdateStatus : 'Kon update-controle status niet resetten:';

  // Export/Import Stats
  static String get exportStatsTitle => _language == 'en' ? AppStringsEn.exportStatsTitle : 'Statistieken exporteren';
  static String get exportStatsMessage => _language == 'en' ? AppStringsEn.exportStatsMessage : 'Kopieer deze tekst om je voortgang op te slaan:';
  static String get importStatsTitle => _language == 'en' ? AppStringsEn.importStatsTitle : 'Statistieken importeren';
  static String get importStatsMessage => _language == 'en' ? AppStringsEn.importStatsMessage : 'Plak je eerder geëxporteerde statistieken hier:';
  static String get importStatsHint => _language == 'en' ? AppStringsEn.importStatsHint : 'Plak hier...';
  static String get statsExportedSuccessfully => _language == 'en' ? AppStringsEn.statsExportedSuccessfully : 'Statistieken succesvol geëxporteerd!';
  static String get statsImportedSuccessfully => _language == 'en' ? AppStringsEn.statsImportedSuccessfully : 'Statistieken succesvol geïmporteerd!';
  static String get failedToExportStats => _language == 'en' ? AppStringsEn.failedToExportStats : 'Kon statistieken niet exporteren:';
  static String get failedToImportStats => _language == 'en' ? AppStringsEn.failedToImportStats : 'Kon statistieken niet importeren:';
  static String get invalidOrTamperedData => _language == 'en' ? AppStringsEn.invalidOrTamperedData : 'Ongeldige of gemanipuleerde gegevens';
  static String get pleaseEnterValidString => _language == 'en' ? AppStringsEn.pleaseEnterValidString : 'Voer een geldige tekst in';
  static String get copyCode => _language == 'en' ? AppStringsEn.copyCode : 'Code kopiëren';
  static String get codeCopied => _language == 'en' ? AppStringsEn.codeCopied : 'Code gekopieerd naar klembord';

  // Export All Data (JSON)
  static String get exportAllDataJson => _language == 'en' ? AppStringsEn.exportAllDataJson : 'Alle gegevens exporteren (JSON)';
  static String get exportAllDataJsonDesc => _language == 'en' ? AppStringsEn.exportAllDataJsonDesc : 'Exporteer alle app-gegevens inclusief instellingen, statistieken en voortgang als JSON';
  static String get exportAllDataJsonTitle => _language == 'en' ? AppStringsEn.exportAllDataJsonTitle : 'Alle gegevens exporteren (JSON)';
  static String get exportAllDataJsonMessage => _language == 'en' ? AppStringsEn.exportAllDataJsonMessage : 'Je volledige app-gegevens zijn geëxporteerd als JSON. Je kunt deze gegevens kopiëren om ze op te slaan of te delen.';
  static String get copyToClipboard => _language == 'en' ? AppStringsEn.copyToClipboard : 'Naar klembord kopiëren';
  static String get jsonDataCopied => _language == 'en' ? AppStringsEn.jsonDataCopied : 'JSON-gegevens gekopieerd naar klembord';

  // Sync Screen
  static String get multiDeviceSync => _language == 'en' ? AppStringsEn.multiDeviceSync : 'Multi-Apparaat Sync';
  static String get currentlySynced => _language == 'en' ? AppStringsEn.currentlySynced : 'Je bent momenteel gesynced. Gegevens worden in realtime gedeeld tussen apparaten.';
  static String get yourSyncId => _language == 'en' ? AppStringsEn.yourSyncId : 'Jouw Sync ID:';
  static String get shareSyncId => _language == 'en' ? AppStringsEn.shareSyncId : 'Deel deze ID met andere apparaten om toe te treden.';

  // Sync Error Messages
  static String get errorGeneric => _language == 'en' ? AppStringsEn.errorGeneric : 'Fout: ';

  // Settings Screen Sync Button
  static String get multiDeviceSyncButton => _language == 'en' ? AppStringsEn.multiDeviceSyncButton : 'Multi-Apparaat Sync';
  static String get syncDataDescription => _language == 'en' ? AppStringsEn.syncDataDescription : 'Sync data tussen apparaten met behulp van een code';

  // Sync Screen Additional Strings
  static String get syncDescription => _language == 'en' ? AppStringsEn.syncDescription : 'Verbind met een ander apparaat om je voortgang en statistieken te synchroniseren.';

  // User ID Screen (rebranded from sync)
  static String get userId => _language == 'en' ? AppStringsEn.userId : 'BQID';
  static String get enterUserId => _language == 'en' ? AppStringsEn.enterUserId : 'Voer een BQID in om verbinding te maken met een ander apparaat';
  static String get userIdCode => _language == 'en' ? AppStringsEn.userIdCode : 'BQID';
  static String get connectToUser => _language == 'en' ? AppStringsEn.connectToUser : 'Verbdinden met BQID';
  static String get createUserId => _language == 'en' ? AppStringsEn.createUserId : 'Maak een nieuwe BQID';
  static String get createUserIdDescription => _language == 'en' ? AppStringsEn.createUserIdDescription : 'Maak een nieuwe BQID en deel de code met anderen om verbinding te maken.';
  static String get currentlyConnectedToUser => _language == 'en' ? AppStringsEn.currentlyConnectedToUser : 'Je bent momenteel verbonden met een BQID. Gegevens worden gedeeld tussen apparaten.';
  static String get yourUserId => _language == 'en' ? AppStringsEn.yourUserId : 'Jouw BQID:';
  static String get shareUserId => _language == 'en' ? AppStringsEn.shareUserId : 'Deel dit ID met andere apparaten om verbinding te maken.';
  static String get leaveUserId => _language == 'en' ? AppStringsEn.leaveUserId : 'Verwijder BQID van dit apparaat';
  static String get userIdDescription => _language == 'en' ? AppStringsEn.userIdDescription : 'Verbind met een ander apparaat met een BQID om je data en statistieken te sychroniseren.';
  static String get pleaseEnterUserId => _language == 'en' ? AppStringsEn.pleaseEnterUserId : 'Voer een BQID in';
  static String get failedToConnectToUser => _language == 'en' ? AppStringsEn.failedToConnectToUser : 'Kon niet verbinden met de BQID. Controleer het ID en probeer opnieuw.';
  static String get failedToCreateUserId => _language == 'en' ? AppStringsEn.failedToCreateUserId : 'Kon BQID niet maken. Probeer opnieuw.';
  static String get userIdButton => _language == 'en' ? AppStringsEn.userIdButton : 'BQID';
  static String get userIdDescriptionSetting => _language == 'en' ? AppStringsEn.userIdDescriptionSetting : 'Maak of verbind met een BQID om je voortgang te synchroniseren';
  static String get createUserIdButton => _language == 'en' ? AppStringsEn.createUserIdButton : 'Maak een BQID';
  static String get of => _language == 'en' ? AppStringsEn.of : 'Of';
  static String get tapToCopyUserId => _language == 'en' ? AppStringsEn.tapToCopyUserId : 'Tik om BQID te kopiëren';
  static String get userIdCopiedToClipboard => _language == 'en' ? AppStringsEn.userIdCopiedToClipboard : 'BQID gekopieerd naar klembord';

  // BijbelQuiz Gen (Year in Review) Strings
  static String get bijbelquizGenTitle => _language == 'en' ? AppStringsEn.bijbelquizGenTitle : 'BijbelQuiz Gen';
  static String get bijbelquizGenSubtitle => _language == 'en' ? AppStringsEn.bijbelquizGenSubtitle : 'Jouw jaar in ';
  static String get bijbelquizGenWelcomeText => _language == 'en' ? AppStringsEn.bijbelquizGenWelcomeText : 'Bekijk je prestaties van vandaag en deel jouw BijbelQuiz-jaar!';
  static String get questionsAnswered => _language == 'en' ? AppStringsEn.questionsAnswered : 'Vragen beantwoord';
  static String get bijbelquizGenQuestionsSubtitle => _language == 'en' ? AppStringsEn.bijbelquizGenQuestionsSubtitle : 'Je hebt hopelijk veel nieuwe dingen geleerd.';
  static String get mistakesMade => _language == 'en' ? AppStringsEn.mistakesMade : 'Fouten gemaakt';
  static String get bijbelquizGenMistakesSubtitle => _language == 'en' ? AppStringsEn.bijbelquizGenMistakesSubtitle : 'Elke fout is een kans om te leren en groeien in je Bijbelkennis!';
  static String get timeSpent => _language == 'en' ? AppStringsEn.timeSpent : 'Tijd besteed';
  static String get bijbelquizGenTimeSubtitle => _language == 'en' ? AppStringsEn.bijbelquizGenTimeSubtitle : 'Je hebt tijd genomen om je Bijbelkennis te verdiepen!';
  static String get bijbelquizGenBestStreak => _language == 'en' ? AppStringsEn.bijbelquizGenBestStreak : 'Beste reeks';
  static String get bijbelquizGenStreakSubtitle => _language == 'en' ? AppStringsEn.bijbelquizGenStreakSubtitle : 'Je langste reeks toont je consistentie en toewijding!';
  static String get yearInReview => _language == 'en' ? AppStringsEn.yearInReview : 'Jouw jaar in review';
  static String get bijbelquizGenYearReviewSubtitle => _language == 'en' ? AppStringsEn.bijbelquizGenYearReviewSubtitle : 'Een overzicht van je BijbelQuiz prestaties in het afgelopen jaar!';
  static String get hours => _language == 'en' ? AppStringsEn.hours : 'Uren';
  static String get correctAnswers => _language == 'en' ? AppStringsEn.correctAnswers : 'Correcte antwoorden';
  static String get accuracy => _language == 'en' ? AppStringsEn.accuracy : 'Nauwkeurigheid';
  static String get currentStreak => _language == 'en' ? AppStringsEn.currentStreak : 'Huidige reeks';
  static String get thankYouForUsingBijbelQuiz => _language == 'en' ? AppStringsEn.thankYouForUsingBijbelQuiz : 'Bedankt voor het gebruik van BijbelQuiz!';
  static String get bijbelquizGenThankYouText => _language == 'en' ? AppStringsEn.bijbelquizGenThankYouText : 'We hopen dat onze app het afgelopen jaar tot Zegen mocht zijn. Bedankt voor je steun en betrokkenheid!';
  static String get bijbelquizGenDonateButton => _language == 'en' ? AppStringsEn.bijbelquizGenDonateButton : 'Doneer';
  static String get done => _language == 'en' ? AppStringsEn.done : 'Klaar';
  static String get bijbelquizGenSkip => _language == 'en' ? AppStringsEn.bijbelquizGenSkip : 'Overslaan';
  static String get thankYouForSupport => _language == 'en' ? AppStringsEn.thankYouForSupport : 'Bedankt voor je steun!';
  static String get thankYouForYourSupport => _language == 'en' ? AppStringsEn.thankYouForYourSupport : 'We waarderen dat je BijbelQuiz gebruikt en deelneemt aan onze gemeenschap.';
  static String get supportWithDonation => _language == 'en' ? AppStringsEn.supportWithDonation : 'Ondersteun ons met een donatie';
  static String get bijbelquizGenDonationText => _language == 'en' ? AppStringsEn.bijbelquizGenDonationText : 'Je donatie helpt ons BijbelQuiz te onderhouden en te verbeteren voor jouw, en anderen.';

  // Following-list screen
  static String get notFollowing => _language == 'en' ? AppStringsEn.notFollowing : "Je volgt op dit moment niemand";
  static String get joinRoomToViewFollowing => _language == 'en' ? AppStringsEn.joinRoomToViewFollowing : "Je moet een ruimte toetreden om te zien wij jij volgt";
  static String get searchUsersToFollow => _language == 'en' ? AppStringsEn.searchUsersToFollow : "Zoek naar gebruikers om ze te volgen";

  // Followers-list screen
  static String get noFollowers => _language == 'en' ? AppStringsEn.noFollowers : "Je hebt op dit moment geen volgers";
  static String get joinRoomToViewFollowers => _language == 'en' ? AppStringsEn.joinRoomToViewFollowers : "Je moet een ruimte toetreden om je volgers te zien";
  static String get shareBQIDFollowers => _language == 'en' ? AppStringsEn.shareBQIDFollowers : "Deel jouw BQID met anderen om volgers te krijgen";

  // Messages
  static String get noActiveMessages => _language == 'en' ? AppStringsEn.noActiveMessages : 'Geen actieve berichten';
  static String get noActiveMessagesSubtitle => _language == 'en' ? AppStringsEn.noActiveMessagesSubtitle : 'Er zijn momenteel geen berichten om weer te geven';
  static String get errorLoadingMessages => _language == 'en' ? AppStringsEn.errorLoadingMessages : 'Fout bij laden van berichten';
  static String get expiresIn => _language == 'en' ? AppStringsEn.expiresIn : 'Verloopt over';
  static String get expiringSoon => _language == 'en' ? AppStringsEn.expiringSoon : 'Verloopt binnenkort';
  static String get days => _language == 'en' ? AppStringsEn.days : 'dagen';
  static String get noExpirationDate => _language == 'en' ? AppStringsEn.noExpirationDate : 'Geen vervaldatum';
  static String get minutes => _language == 'en' ? AppStringsEn.minutes : 'minuten';
  static String get lessThanAMinute => _language == 'en' ? AppStringsEn.lessThanAMinute : 'minder dan een minuut';
  static String get created => _language == 'en' ? AppStringsEn.created : 'Aangemaakt';

  // Username
  static String get username => _language == 'en' ? AppStringsEn.username : 'Gebruikersnaam';
  static String get enterUsername => _language == 'en' ? AppStringsEn.enterUsername : 'Voer gebruikersnaam in';
  static String get usernameHint => _language == 'en' ? AppStringsEn.usernameHint : 'Bijv. Jan2025';
  static String get saveUsername => _language == 'en' ? AppStringsEn.saveUsername : 'Bewaar gebruikersnaam';
  static String get pleaseEnterUsername => _language == 'en' ? AppStringsEn.pleaseEnterUsername : 'Voer een gebruikersnaam in';
  static String get usernameTooLong => _language == 'en' ? AppStringsEn.usernameTooLong : 'Gebruikersnaam mag maximaal 30 tekens bevatten';
  static String get usernameAlreadyTaken => _language == 'en' ? AppStringsEn.thisUsernameAlreadyTaken : 'Gebruikersnaam is al in gebruik';
  static String get usernameBlacklisted => _language == 'en' ? AppStringsEn.usernameBlacklisted : 'Deze gebruikersnaam is niet toegestaan';
  static String get usernameSaved => _language == 'en' ? AppStringsEn.usernameSaved : 'Gebruikersnaam opgeslagen!';

  // Beta
  static String get beta => _language == 'en' ? AppStringsEn.beta : 'Bèta';

  // Share functionality
  static String get shareStatsTitle => _language == 'en' ? AppStringsEn.shareStatsTitle : 'Deel je statistieken';
  static String get shareYourBijbelQuizStats => _language == 'en' ? AppStringsEn.shareYourBijbelQuizStats : 'Deel je BijbelQuiz statistieken';
  static String get correctAnswersShare => _language == 'en' ? AppStringsEn.correctAnswersShare : 'Correcte antwoorden';
  static String get currentStreakShare => _language == 'en' ? AppStringsEn.currentStreakShare : 'Huidige reeks';
  static String get bestStreakShare => _language == 'en' ? AppStringsEn.bestStreakShare : 'Beste reeks';
  static String get mistakesShare => _language == 'en' ? AppStringsEn.mistakesShare : 'Fouten';
  static String get accuracyShare => _language == 'en' ? AppStringsEn.accuracyShare : 'Accuraatheid';
  static String get timeSpentShare => _language == 'en' ? AppStringsEn.timeSpentShare : 'Tijd besteed';
  static String get shareResults => _language == 'en' ? AppStringsEn.shareResults : 'Deel je resultaten';
  static String get copyLink => _language == 'en' ? AppStringsEn.copyLink : 'Kopieer link';

  // Error Reporting Strings
  static String get success => _language == 'en' ? AppStringsEn.success : 'Succes';
  static String get reportSubmittedSuccessfully => _language == 'en' ? AppStringsEn.reportSubmittedSuccessfully : 'Je melding is succesvol verstuurd!';
  static String get reportSubmissionFailed => _language == 'en' ? AppStringsEn.reportSubmissionFailed : 'Melding kon niet worden verstuurd. Probeer het later opnieuw.';
  static String get reportBug => _language == 'en' ? AppStringsEn.reportBug : 'Meld een bug';
  static String get reportBugDescription => _language == 'en' ? AppStringsEn.reportBugDescription : 'Meld een bug of probleem met de app';
  static String get subject => _language == 'en' ? AppStringsEn.subject : 'Onderwerp';
  static String get pleaseEnterSubject => _language == 'en' ? AppStringsEn.pleaseEnterSubject : 'Voer een onderwerp in';
  static String get description => _language == 'en' ? AppStringsEn.description : 'Beschrijving';
  static String get pleaseEnterDescription => _language == 'en' ? AppStringsEn.pleaseEnterDescription : 'Voer een beschrijving in';
  static String get emailOptional => _language == 'en' ? AppStringsEn.emailOptional : 'E-mail (optioneel)';
  static String get reportQuestion => _language == 'en' ? AppStringsEn.reportQuestion : 'Meld Vraag';
  static String get questionReportedSuccessfully => _language == 'en' ? AppStringsEn.questionReportedSuccessfully : 'Vraag succesvol gemeld';
  static String get errorReportingQuestion => _language == 'en' ? AppStringsEn.errorReportingQuestion : 'Fout bij melden van vraag';

  // Additional hardcoded strings found in codebase
  static String get apiErrorPrefix => _language == 'en' ? AppStringsEn.apiErrorPrefix : 'API Fout: ';
  static String get grid => _language == 'en' ? AppStringsEn.grid : 'Raster';
  static String get list => _language == 'en' ? AppStringsEn.list : 'Lijst';
  static String get compactGrid => _language == 'en' ? AppStringsEn.compactGrid : 'Compact raster';
  static String get useTheme => _language == 'en' ? AppStringsEn.useTheme : 'Gebruik thema';
  static String get failedToRemoveDevice => _language == 'en' ? AppStringsEn.failedToRemoveDevice : 'Kon apparaat niet verwijderen';
  static String get errorRemovingDevice => _language == 'en' ? AppStringsEn.errorRemovingDevice : 'Fout bij verwijderen apparaat: ';
  static String get sharedStats => _language == 'en' ? AppStringsEn.sharedStats : 'Gedeelde statistieken';
  static String get newGame => _language == 'en' ? AppStringsEn.newGame : 'Nieuw spel';
  static String get loadingMessages => _language == 'en' ? AppStringsEn.loadingMessages : 'Berichten laden...';
  static String get errorLoadingUsernames => _language == 'en' ? AppStringsEn.errorLoadingUsernames : 'Fout bij laden gebruikersnamen: ';
  static String get urlCopiedToClipboard => _language == 'en' ? AppStringsEn.urlCopiedToClipboard : 'URL gekopieerd naar klembord!';
  static String get tryAgainButton => _language == 'en' ? AppStringsEn.tryAgainButton : 'Probeer opnieuw';
  static String get checkConnection => _language == 'en' ? AppStringsEn.checkConnection : 'Controleer verbinding';
  static String get goToQuiz => _language == 'en' ? AppStringsEn.goToQuiz : 'Naar de quiz';
  static String get errorLoadingAnalytics => _language == 'en' ? AppStringsEn.errorLoadingAnalytics : 'Fout bij laden analytics';
  static String get bibleReferenceCopied => _language == 'en' ? AppStringsEn.bibleReferenceCopied : 'Bijbelverwijzing gekopieerd: ';
  static String get bibleReferenceCopiedForSharing => _language == 'en' ? AppStringsEn.bibleReferenceCopiedForSharing : 'Bijbelverwijzing gekopieerd voor delen';
  static String get errorHandlingTest => _language == 'en' ? AppStringsEn.errorHandlingTest : 'Foutafhandeling test';
  static String get errorHandlingTestDescription => _language == 'en' ? AppStringsEn.errorHandlingTestDescription : 'Dit scherm demonstreert het nieuwe foutafhandelingssysteem';
  static String get testErrorHandling => _language == 'en' ? AppStringsEn.testErrorHandling : 'Test foutafhandeling';
  static String get testErrorDialog => _language == 'en' ? AppStringsEn.testErrorDialog : 'Test foutdialoog';
  static String get retryButton => _language == 'en' ? AppStringsEn.retryButton : 'Opnieuw proberen';

  // Settings Screen - Additional hardcoded strings
  static String get searchSettings => _language == 'en' ? AppStringsEn.searchSettings : 'Zoek instellingen...';
  static String get lessonLayoutSettings => _language == 'en' ? AppStringsEn.lessonLayoutSettings : 'Lesindeling';
  static String get chooseLessonLayoutDesc => _language == 'en' ? AppStringsEn.chooseLessonLayoutDesc : 'Kies hoe lessen worden weergegeven';
  static String get showIntroductionDesc => _language == 'en' ? AppStringsEn.showIntroductionDesc : 'Bekijk de app-introductie en tutorial';
  static String get clearQuestionCacheDesc => _language == 'en' ? AppStringsEn.clearQuestionCacheDesc : 'Verwijder gecachte vragen om opslagruimte vrij te maken';
  static String get followOnSocialMediaDesc => _language == 'en' ? AppStringsEn.followOnSocialMediaDesc : 'Verbind met ons op social media platforms';
  static String get inviteFriendDesc => _language == 'en' ? AppStringsEn.inviteFriendDesc : 'Deel een gepersonaliseerde uitnodigingslink met vrienden';
  static String get bugReport => _language == 'en' ? AppStringsEn.bugReport : 'Rapporteer een probleem';
  static String get bugReportDesc => _language == 'en' ? AppStringsEn.bugReportDesc : 'Rapporteer bugs en problemen met de app';

  // Automatic Bug Reporting
  static String get automaticBugReports => _language == 'en' ? AppStringsEn.automaticBugReports : 'Automatisch problemen melden';
  static String get automaticBugReportsDesc => _language == 'en' ? AppStringsEn.automaticBugReportsDesc : 'Automatisch bugrapporten verzenden wanneer er fouten optreden (aanbevolen)';

  // Sync Screen
  static String get dataSuccessfullySynchronized => _language == 'en' ? AppStringsEn.dataSuccessfullySynchronized : 'Gegevens succesvol gesynchroniseerd';
  static String get synchronizationFailed => _language == 'en' ? AppStringsEn.synchronizationFailed : 'Synchronisatie mislukt: ';
  static String get editProfile => _language == 'en' ? AppStringsEn.editProfile : 'Profiel bewerken';
  static String get adjustNameAndBio => _language == 'en' ? AppStringsEn.adjustNameAndBio : 'Naam en bio aanpassen';
  static String get changeUsername => _language == 'en' ? AppStringsEn.changeUsername : 'Gebruikersnaam wijzigen';
  static String get adjustYourUsername => _language == 'en' ? AppStringsEn.adjustYourUsername : 'Je gebruikersnaam aanpassen';
  static String get changePassword => _language == 'en' ? AppStringsEn.changePassword : 'Wachtwoord wijzigen';
  static String get secureYourAccount => _language == 'en' ? AppStringsEn.secureYourAccount : 'Beveilig je account';
  static String get signOut => _language == 'en' ? AppStringsEn.signOut : 'Uitloggen';
  static String get signOutFromDevice => _language == 'en' ? AppStringsEn.signOutFromDevice : 'Van dit apparaat afmelden';
  static String get deleteAccount => _language == 'en' ? AppStringsEn.deleteAccount : 'Account verwijderen';
  static String get permanentlyDeleteAccount => _language == 'en' ? AppStringsEn.permanentlyDeleteAccount : 'Account permanent verwijderen';
  static String get displayName => _language == 'en' ? AppStringsEn.displayName : 'Weergavenaam';
  static String get bioOptional => _language == 'en' ? AppStringsEn.bioOptional : 'Bio (optioneel)';
  static String get newUsername => _language == 'en' ? AppStringsEn.newUsername : 'Nieuwe gebruikersnaam';
  static String get chooseUniqueName => _language == 'en' ? AppStringsEn.chooseUniqueName : 'Kies een unieke naam';
  static String get currentPassword => _language == 'en' ? AppStringsEn.currentPassword : 'Huidig wachtwoord';
  static String get newPassword => _language == 'en' ? AppStringsEn.newPassword : 'Nieuw wachtwoord';
  static String get atLeast6Characters => _language == 'en' ? AppStringsEn.atLeast6Characters : 'Minimaal 6 karakters';
  static String get confirmNewPassword => _language == 'en' ? AppStringsEn.confirmNewPassword : 'Bevestig nieuw wachtwoord';
  static String get fillAllPasswordFields => _language == 'en' ? AppStringsEn.fillAllPasswordFields : 'Vul alle wachtwoord velden in';
  static String get newPasswordsDoNotMatch => _language == 'en' ? AppStringsEn.newPasswordsDoNotMatch : 'Nieuwe wachtwoorden komen niet overeen';
  static String get newPasswordMin6Chars => _language == 'en' ? AppStringsEn.newPasswordMin6Chars : 'Nieuw wachtwoord moet minimaal 6 karakters bevatten';
  static String get enterNewUsername => _language == 'en' ? AppStringsEn.enterNewUsername : 'Voer een nieuwe gebruikersnaam in';
  static String get usernameMin3Chars => _language == 'en' ? AppStringsEn.usernameMin3Chars : 'Gebruikersnaam moet minimaal 3 karakters bevatten';
  static String get usernameMax20Chars => _language == 'en' ? AppStringsEn.usernameMax20Chars : 'Gebruikersnaam mag maximaal 20 karakters bevatten';
  static String get usernameNotAllowed => _language == 'en' ? AppStringsEn.usernameNotAllowed : 'Deze gebruikersnaam is niet toegestaan';
  static String get thisUsernameAlreadyTaken => _language == 'en' ? AppStringsEn.thisUsernameAlreadyTaken : 'Deze gebruikersnaam is al in gebruik';
  static String get usernameSuccessfullyChanged => _language == 'en' ? AppStringsEn.usernameSuccessfullyChanged : 'Gebruikersnaam succesvol gewijzigd';
  static String get failedToChangeUsername => _language == 'en' ? AppStringsEn.failedToChangeUsername : 'Gebruikersnaam wijzigen mislukt';
  static String get displayNameRequired => _language == 'en' ? AppStringsEn.displayNameRequired : 'Weergavenaam is verplicht';
  static String get profileSuccessfullyUpdated => _language == 'en' ? AppStringsEn.profileSuccessfullyUpdated : 'Profiel succesvol bijgewerkt';
  static String get failedToUpdateProfile => _language == 'en' ? AppStringsEn.failedToUpdateProfile : 'Profiel bijwerken mislukt';
  static String get signOutFailed => _language == 'en' ? AppStringsEn.signOutFailed : 'Uitloggen mislukt';
  static String get passwordSuccessfullyChanged => _language == 'en' ? AppStringsEn.passwordSuccessfullyChanged : 'Wachtwoord succesvol gewijzigd';
  static String get failedToChangePassword => _language == 'en' ? AppStringsEn.failedToChangePassword : 'Wachtwoord wijzigen mislukt';
  static String get updated => _language == 'en' ? AppStringsEn.updated : 'Bijgewerkt';
  static String get notUpdated => _language == 'en' ? AppStringsEn.notUpdated : 'Niet bijgewerkt';
  static String get lastSync => _language == 'en' ? AppStringsEn.lastSync : 'Laatste sync';
  static String get user => _language == 'en' ? AppStringsEn.user : 'Gebruiker';
  static String get account => _language == 'en' ? AppStringsEn.account : 'Account';
  static String get syncing => _language == 'en' ? AppStringsEn.syncing : 'Syncing...';
  static String get sync => _language == 'en' ? AppStringsEn.sync : 'Sync';
  static String get save => _language == 'en' ? AppStringsEn.save : 'Opslaan';
  static String get change => _language == 'en' ? AppStringsEn.change : 'Wijzigen';
  static String get never => _language == 'en' ? AppStringsEn.never : 'Nooit';
  static String get justNow => _language == 'en' ? AppStringsEn.justNow : 'Zojuist';
  static String get minutesAgo => _language == 'en' ? AppStringsEn.minutesAgo : 'm geleden';
  static String get hoursAgo => _language == 'en' ? AppStringsEn.hoursAgo : 'u geleden';
  static String get daysAgo => _language == 'en' ? AppStringsEn.daysAgo : 'd geleden';
  static String get noEmail => _language == 'en' ? AppStringsEn.noEmail : 'Geen email';
  static String get leaderboard => _language == 'en' ? AppStringsEn.leaderboard : 'Leaderboard';
  static String get noLeaderboardData => _language == 'en' ? AppStringsEn.noLeaderboardData : 'Geen leaderboard gegevens beschikbaar';

  // ELIM50 Coupon
  static String get elim50CouponMessage => _language == 'en' ? AppStringsEn.elim50CouponMessage : 'Je hebt 50 punten gekregen en er is 50 cent gedoneerd voor de verbouwing van Elim!';

  // Auth View
  static String get loginWithBqid => _language == 'en' ? AppStringsEn.loginWithBqid : 'Login met je BQID';
  static String get socialFeaturesMessage => _language == 'en' ? AppStringsEn.socialFeaturesMessage : 'Maak een account aan om sociale functies te gebruiken, zoals het zoeken naar gebruikers, vrienden maken en berichten versturen.';
  static String get login => _language == 'en' ? AppStringsEn.login : 'Inloggen';
  static String get signup => _language == 'en' ? AppStringsEn.signup : 'Aanmelden';
  static String get email => _language == 'en' ? AppStringsEn.email : 'Email';
  static String get emailHint => _language == 'en' ? AppStringsEn.emailHint : 'jouw@email.com';
  static String get usernameSignupHint => _language == 'en' ? AppStringsEn.usernameSignupHint : 'Kies een unieke naam';
  static String get password => _language == 'en' ? AppStringsEn.password : 'Wachtwoord';
  static String get passwordHint => _language == 'en' ? AppStringsEn.passwordHint : 'Minimaal 6 karakters';
  static String get confirmPassword => _language == 'en' ? AppStringsEn.confirmPassword : 'Bevestig wachtwoord';
  static String get confirmPasswordHint => _language == 'en' ? AppStringsEn.confirmPasswordHint : 'Herhaal je wachtwoord';
  static String get accountCreatedMessage => _language == 'en' ? AppStringsEn.accountCreatedMessage : 'Account aangemaakt! Controleer je email voor verificatie.';

  // Auth errors
  static String get fillEmailAndPassword => _language == 'en' ? AppStringsEn.fillEmailAndPassword : 'Vul je email en wachtwoord in om door te gaan.';
  static String get enterValidEmail => _language == 'en' ? AppStringsEn.enterValidEmail : 'Voer een geldig emailadres in.';
  static String get fillAllFields => _language == 'en' ? AppStringsEn.fillAllFields : 'Vul alle velden in om een account aan te maken.';
  static String get passwordsDoNotMatch => _language == 'en' ? AppStringsEn.passwordsDoNotMatch : 'Wachtwoorden komen niet overeen. Controleer of je beide velden hetzelfde hebt ingevuld.';
  static String get passwordTooShort => _language == 'en' ? AppStringsEn.passwordTooShort : 'Wachtwoord moet minimaal 6 karakters bevatten voor je veiligheid.';
  static String get checkingPassword => _language == 'en' ? AppStringsEn.checkingPassword : 'Wachtwoord wordt gecontroleerd op veiligheid...';
  static String get passwordCompromised => _language == 'en' ? AppStringsEn.passwordCompromised : 'Dit wachtwoord is aangetroffen in datalekken. Kies een ander wachtwoord voor je veiligheid.';
  static String get usernameTooShort => _language == 'en' ? AppStringsEn.usernameTooShort : 'Gebruikersnaam moet minimaal 3 karakters bevatten.';
  static String get usernameSignupTooLong => _language == 'en' ? AppStringsEn.usernameSignupTooLong : 'Gebruikersnaam mag maximaal 20 karakters bevatten.';
  static String get usernameInvalidChars => _language == 'en' ? AppStringsEn.usernameInvalidChars : 'Gebruikersnaam mag alleen letters, cijfers en underscores bevatten.';
  static String get checkingUsername => _language == 'en' ? AppStringsEn.checkingUsername : 'Beschikbaarheid van gebruikersnaam wordt gecontroleerd...';
  static String get invalidEmailOrPassword => _language == 'en' ? AppStringsEn.invalidEmailOrPassword : 'Ongeldig email of wachtwoord. Controleer je gegevens en probeer opnieuw.';
  static String get emailNotConfirmed => _language == 'en' ? AppStringsEn.emailNotConfirmed : 'Je email is nog niet geverifieerd. Controleer je inbox en klik op de verificatielink.';
  static String get tooManyRequests => _language == 'en' ? AppStringsEn.tooManyRequests : 'Te veel pogingen. Wacht even voordat je opnieuw probeert.';
  static String get passwordTooShortGeneric => _language == 'en' ? AppStringsEn.passwordTooShortGeneric : 'Wachtwoord moet minimaal 6 karakters bevatten.';
  static String get invalidEmailAddress => _language == 'en' ? AppStringsEn.invalidEmailAddress : 'Ongeldig emailadres. Controleer of je een geldig emailadres hebt ingevoerd.';
  static String get userAlreadyRegistered => _language == 'en' ? AppStringsEn.userAlreadyRegistered : 'Er bestaat al een account met dit emailadres. Probeer in te loggen of gebruik een ander emailadres.';
  static String get signupDisabled => _language == 'en' ? AppStringsEn.signupDisabled : 'Aanmelden is momenteel uitgeschakeld. Probeer het later opnieuw.';
  static String get weakPassword => _language == 'en' ? AppStringsEn.weakPassword : 'Wachtwoord is te zwak. Kies een sterker wachtwoord met meer karakters.';
  static String get genericError => _language == 'en' ? AppStringsEn.genericError : 'Er is iets misgegaan. Probeer het opnieuw of neem contact op als het probleem aanhoudt.';

  // Guide Screen Additional Strings
  static String get guideAccount => _language == 'en' ? AppStringsEn.guideAccount : 'Account';
  static String get guideAccountDescription => _language == 'en' ? AppStringsEn.guideAccountDescription : 'Maak een account aan of log in om je voortgang te bewaren en sociale functies te gebruiken.';
  static String get couponRedeemDescription => _language == 'en' ? AppStringsEn.couponRedeemDescription : 'Je kunt couponcodes later verzilveren via het winkelmenu.';
  static String get termsAgreementText => _language == 'en' ? AppStringsEn.termsAgreementText : 'Als u doorgaat gaat u akkoord met onze ';
  static String get termsOfService => _language == 'en' ? AppStringsEn.termsOfService : 'algemene voorwaarden';
}
