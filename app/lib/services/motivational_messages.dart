/// Motivational messages for notifications in multiple languages
class MotivationalMessages {
  /// English motivational messages covering various themes
  static const List<String> englishMessages = [
    // Encouragement
    'Every answer you get right is progress! Keep going! 🎯',
    'You\'re doing amazing! Challenge yourself with one more quiz today.',
    'You\'ve got this! Your knowledge is growing every day.',
    'Great effort! Learning is a journey, enjoy every step.',
    'Keep shining! Your persistence will pay off. ✨',
    
    // Persistence
    'Consistency is key! Take a quiz today and build your streak.',
    'Don\'t give up now! The best results come from persistence.',
    'One more quiz is all it takes to make today count!',
    'Stay focused! Your dedication is making a real difference.',
    'Push through! Every question makes you stronger.',
    
    // Faith & Inspiration
    'Your faith is your strength! Quiz today and grow spiritually.',
    'Let the Word guide you! Test your knowledge now.',
    'Trust the journey! Your Bible knowledge is deepening daily.',
    'Find peace in learning! Take a moment for a Bible quiz.',
    'Believe in yourself! You know more than you think.',
    
    // Learning mindset
    'Learning never stops! Discover something new in a quiz today.',
    'Knowledge is power! Keep expanding your Biblical understanding.',
    'Every question is an opportunity to learn something new.',
    'Challenge accepted? Come test your Bible knowledge!',
    'Your mind is powerful! Exercise it with a quick quiz.',
  ];

  /// Dutch motivational messages covering various themes
  static const List<String> dutchMessages = [
    // Aanmoediging
    'Elk juist antwoord is vooruitgang! Ga door! 🎯',
    'Je doet het geweldig! Daag jezelf uit met nog een quiz vandaag.',
    'Je redt het! Je kennis groeit elke dag.',
    'Geweldige inspanning! Leren is een reis, geniet van elke stap.',
    'Blijf schijnen! Je doorzettingsvermogen zal beloond worden. ✨',
    
    // Doorzettingsvermogen
    'Consistentie is sleutel! Maak vandaag een quiz en bouw je reeks op.',
    'Geef niet op nu! De beste resultaten komen van doorzetting.',
    'Nog één quiz is alles wat nodig is om vandaag te laten tellen!',
    'Blijf gefocust! Je toewijding maakt een echt verschil.',
    'Zet door! Elke vraag maakt je sterker.',
    
    // Geloof & Inspiratie
    'Je geloof is je kracht! Quiz vandaag en groei spiritueel.',
    'Laat het Woord je leiden! Test je kennis nu.',
    'Vertrouw het proces! Je Bijbelkennis verdiept zich dagelijks.',
    'Vind vrede in leren! Neem even tijd voor een Bijbelquiz.',
    'Geloof in jezelf! Je weet meer dan je denkt.',
    
    // Leerhouding
    'Leren stopt nooit! Ontdek vandaag iets nieuws in een quiz.',
    'Kennis is macht! Blijf je Bijbels begrip vergroten.',
    'Elke vraag is een kans om iets nieuws te leren.',
    'Aanvaard je uitdaging? Kom je Bijbelkennis testen!',
    'Je geest is machtig! Oefen het met een snelle quiz.',
  ];

  /// Get messages for the specified language
  static List<String> getMessagesForLanguage(String languageCode) {
    if (languageCode.toLowerCase() == 'en' || 
        languageCode.toLowerCase() == 'en-us' ||
        languageCode.toLowerCase() == 'en-gb') {
      return englishMessages;
    } else if (languageCode.toLowerCase() == 'nl' || 
               languageCode.toLowerCase() == 'nl-nl') {
      return dutchMessages;
    }
    // Default to English if language not recognized
    return englishMessages;
  }

  /// Get a random message for the specified language
  static String getRandomMessage(String languageCode) {
    final messages = getMessagesForLanguage(languageCode);
    messages.shuffle();
    return messages.first;
  }
}
