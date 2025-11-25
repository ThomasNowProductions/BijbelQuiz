import '../models/bible_lesson.dart';
import '../services/logger.dart';

/// Service for managing Bible learning lessons with educational content.
/// These lessons are designed for new users who know nothing about the Bible,
/// providing reading material before quizzes to teach fundamentals.
class BibleLessonService {
  BibleLessonService();

  /// Generates the beginner Bible lessons for new users.
  /// These lessons cover fundamental topics from the Old and New Testament.
  ///
  /// - [language]: question language ('nl' for Dutch, 'en' for English)
  Future<List<BibleLesson>> getBeginnerLessons(String language) async {
    try {
      // Return Dutch lessons by default, with English translations
      if (language == 'en') {
        return _getEnglishLessons();
      }
      return _getDutchLessons();
    } catch (e) {
      AppLogger.error('Failed to load beginner lessons', e);
      return [];
    }
  }

  /// Get a specific lesson by ID
  Future<BibleLesson?> getLessonById(String id, String language) async {
    final lessons = await getBeginnerLessons(language);
    try {
      return lessons.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Dutch lessons for beginners
  List<BibleLesson> _getDutchLessons() {
    return [
      // Lesson 1: Introduction to the Bible
      BibleLesson(
        id: 'bible_intro_001',
        title: 'Wat is de Bijbel?',
        description: 'Leer over de structuur en inhoud van de Bijbel',
        category: 'Introductie',
        index: 0,
        estimatedReadingMinutes: 3,
        iconHint: 'menu_book',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Bijbel', 'Oude Testament', 'Nieuwe Testament', 'Boeken'],
        sections: [
          const LessonSection(
            heading: 'De Bijbel: Gods Woord',
            content:
                'De Bijbel is het heilige boek van het christendom. Het woord "Bijbel" komt van het Griekse woord "biblia" dat "boeken" betekent. De Bijbel is namelijk een verzameling van 66 verschillende boeken, geschreven door meer dan 40 verschillende auteurs over een periode van ongeveer 1500 jaar.',
          ),
          const LessonSection(
            heading: 'Twee Delen',
            content:
                'De Bijbel bestaat uit twee hoofddelen:\n\n• Het Oude Testament (39 boeken): Geschreven vóór de geboorte van Jezus, vertelt over Gods schepping, het volk Israël, en de profeten.\n\n• Het Nieuwe Testament (27 boeken): Geschreven na de geboorte van Jezus, vertelt over het leven van Jezus, de vroege kerk, en de brieven van de apostelen.',
          ),
          const LessonSection(
            heading: 'Verschillende Soorten Boeken',
            content:
                'De Bijbel bevat verschillende soorten literatuur:\n\n• Geschiedkundige boeken - verhalen over het verleden\n• Poëzie - zoals de Psalmen\n• Wijsheidsliteratuur - zoals Spreuken\n• Profetieën - voorspellingen en waarschuwingen\n• Brieven - aan vroege kerken',
          ),
        ],
      ),

      // Lesson 2: Creation
      BibleLesson(
        id: 'bible_creation_002',
        title: 'De Schepping',
        description: 'Het begin van alles: God schept de wereld',
        category: 'Genesis',
        index: 1,
        estimatedReadingMinutes: 4,
        iconHint: 'public',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Schepping', 'Adam', 'Eva', 'Hof van Eden', 'Zeven dagen'],
        sections: [
          const LessonSection(
            heading: 'In het Begin',
            content:
                'De Bijbel begint met de woorden: "In het begin schiep God de hemel en de aarde." Dit is het eerste vers van het boek Genesis, het eerste boek van de Bijbel. Genesis betekent "oorsprong" of "begin".',
            bibleReference: 'Genesis 1:1',
          ),
          const LessonSection(
            heading: 'De Zeven Dagen',
            content:
                'Volgens de Bijbel schiep God alles in zes dagen en rustte Hij op de zevende dag:\n\n'
                '• Dag 1: Licht en duisternis\n'
                '• Dag 2: De lucht\n'
                '• Dag 3: Land, zee en planten\n'
                '• Dag 4: Zon, maan en sterren\n'
                '• Dag 5: Vissen en vogels\n'
                '• Dag 6: Dieren en de mens\n'
                '• Dag 7: God rustte',
            bibleReference: 'Genesis 1:1-2:3',
          ),
          const LessonSection(
            heading: 'Adam en Eva',
            content:
                'God maakte de eerste man, Adam, uit stof van de aarde en blies hem de levensadem in. Later maakte God Eva uit een rib van Adam. Zij werden de eerste mensen en leefden in de Hof van Eden, een prachtige tuin die God voor hen had gemaakt.',
            bibleReference: 'Genesis 2:7-22',
          ),
        ],
      ),

      // Lesson 3: Noah's Ark
      BibleLesson(
        id: 'bible_noah_003',
        title: 'Noach en de Ark',
        description: 'Het verhaal van de zondvloed',
        category: 'Genesis',
        index: 2,
        estimatedReadingMinutes: 4,
        iconHint: 'sailing',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Noach', 'Ark', 'Zondvloed', 'Regenboog', 'Dieren'],
        sections: [
          const LessonSection(
            heading: 'Een Rechtvaardige Man',
            content:
                'Noach was een rechtvaardige man in een tijd dat de mensen slecht waren geworden. God was verdrietig over het kwaad in de wereld en besloot een nieuwe start te maken. Maar Noach vond genade in Gods ogen.',
            bibleReference: 'Genesis 6:8-9',
          ),
          const LessonSection(
            heading: 'De Opdracht',
            content:
                'God gaf Noach de opdracht een grote boot te bouwen, een ark. De ark moest groot genoeg zijn om zijn familie en van elk soort dier een paar te huisvesten. De ark was ongeveer 137 meter lang, 23 meter breed en 14 meter hoog.',
            bibleReference: 'Genesis 6:14-16',
          ),
          const LessonSection(
            heading: 'De Vloed en de Belofte',
            content:
                'Toen de ark klaar was, kwam Noach met zijn familie en alle dieren aan boord. Het regende veertig dagen en nachten. Na de vloed beloofde God nooit meer de aarde met water te vernietigen. De regenboog is het teken van deze belofte.',
            bibleReference: 'Genesis 9:12-16',
          ),
        ],
      ),

      // Lesson 4: Abraham
      BibleLesson(
        id: 'bible_abraham_004',
        title: 'Abraham: Vader van het Geloof',
        description: 'Het verhaal van Gods belofte aan Abraham',
        category: 'Genesis',
        index: 3,
        estimatedReadingMinutes: 4,
        iconHint: 'star',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Abraham', 'Sara', 'Isaak', 'Belofte', 'Kanaän'],
        sections: [
          const LessonSection(
            heading: 'Gods Roeping',
            content:
                'Abraham (oorspronkelijk Abram) woonde in Ur, een stad in het huidige Irak. God riep hem om zijn land te verlaten en naar een nieuw land te gaan dat God hem zou wijzen. Abraham gehoorzaamde, hoewel hij niet wist waar hij naartoe ging.',
            bibleReference: 'Genesis 12:1-4',
          ),
          const LessonSection(
            heading: 'De Belofte',
            content:
                'God beloofde Abraham drie dingen:\n\n'
                '1. Een groot nageslacht - zo talrijk als de sterren\n'
                '2. Een land - het land Kanaän\n'
                '3. Een zegen - door hem zouden alle volken gezegend worden\n\n'
                'Deze belofte werd het verbond met Abraham genoemd.',
            bibleReference: 'Genesis 15:5-6',
          ),
          const LessonSection(
            heading: 'Isaak: De Zoon van de Belofte',
            content:
                'Abraham en zijn vrouw Sara waren oud en hadden geen kinderen. Maar God beloofde hen een zoon. Toen Abraham 100 jaar oud was en Sara 90, werd Isaak geboren. Zijn naam betekent "hij lacht" omdat Sara lachte toen ze hoorde dat ze een kind zou krijgen.',
            bibleReference: 'Genesis 21:1-7',
          ),
        ],
      ),

      // Lesson 5: Moses and the Exodus
      BibleLesson(
        id: 'bible_moses_005',
        title: 'Mozes en de Uittocht',
        description: 'De bevrijding van het volk Israël uit Egypte',
        category: 'Exodus',
        index: 4,
        estimatedReadingMinutes: 5,
        iconHint: 'waves',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Mozes', 'Farao', 'Tien Plagen', 'Rode Zee', 'Uittocht'],
        sections: [
          const LessonSection(
            heading: 'Slavernij in Egypte',
            content:
                'De nakomelingen van Abraham, het volk Israël, waren slaven geworden in Egypte. Ze moesten zwaar werken voor de farao. God hoorde hun geklaag en stuurde Mozes om hen te bevrijden.',
            bibleReference: 'Exodus 3:7-10',
          ),
          const LessonSection(
            heading: 'De Tien Plagen',
            content:
                'Toen de farao weigerde het volk te laten gaan, stuurde God tien plagen over Egypte:\n\n'
                '1. Water werd bloed\n'
                '2. Kikkers\n'
                '3. Muggen\n'
                '4. Steekvliegen\n'
                '5. Veepest\n'
                '6. Zweren\n'
                '7. Hagel\n'
                '8. Sprinkhanen\n'
                '9. Duisternis\n'
                '10. Dood van de eerstgeborenen',
            bibleReference: 'Exodus 7-12',
          ),
          const LessonSection(
            heading: 'Door de Rode Zee',
            content:
                'Na de tiende plaag liet de farao het volk gaan. Maar hij veranderde van gedachten en achtervolgde hen. Bij de Rode Zee leek het volk gevangen. Maar God spleet de zee en het volk kon op droog land naar de overkant lopen. Toen de Egyptenaren volgden, sloot de zee zich.',
            bibleReference: 'Exodus 14:21-28',
          ),
        ],
      ),

      // Lesson 6: The Ten Commandments
      BibleLesson(
        id: 'bible_commandments_006',
        title: 'De Tien Geboden',
        description: 'Gods wet voor Zijn volk',
        category: 'Exodus',
        index: 5,
        estimatedReadingMinutes: 4,
        iconHint: 'gavel',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Tien Geboden', 'Sinaï', 'Wet', 'Mozes', 'Stenen Tafelen'],
        sections: [
          const LessonSection(
            heading: 'Op de Berg Sinaï',
            content:
                'Na de uittocht uit Egypte trok het volk Israël door de woestijn naar de berg Sinaï. Daar sprak God tot Mozes en gaf hem de Tien Geboden, geschreven op twee stenen tafelen.',
            bibleReference: 'Exodus 19:20-20:1',
          ),
          const LessonSection(
            heading: 'De Eerste Vier Geboden',
            content:
                'De eerste vier geboden gaan over onze relatie met God:\n\n'
                '1. Geen andere goden dienen\n'
                '2. Geen afgodsbeelden maken\n'
                '3. Gods naam niet misbruiken\n'
                '4. De sabbatdag heiligen',
            bibleReference: 'Exodus 20:3-11',
          ),
          const LessonSection(
            heading: 'De Laatste Zes Geboden',
            content:
                'De laatste zes geboden gaan over onze relatie met anderen:\n\n'
                '5. Eer je vader en moeder\n'
                '6. Niet doodslaan\n'
                '7. Niet echtbreken\n'
                '8. Niet stelen\n'
                '9. Niet vals getuigen\n'
                '10. Niet begeren wat van een ander is',
            bibleReference: 'Exodus 20:12-17',
          ),
        ],
      ),

      // Lesson 7: David and Goliath
      BibleLesson(
        id: 'bible_david_007',
        title: 'David en Goliath',
        description: 'De herdersjongen die koning werd',
        category: '1 Samuël',
        index: 6,
        estimatedReadingMinutes: 4,
        iconHint: 'sports_martial_arts',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['David', 'Goliath', 'Slinger', 'Herder', 'Israël'],
        sections: [
          const LessonSection(
            heading: 'De Reus Goliath',
            content:
                'De Filistijnen waren in oorlog met Israël. Hun kampioen was Goliath, een reus van bijna drie meter hoog. Veertig dagen lang daagde hij de Israëlieten uit, maar niemand durfde tegen hem te vechten.',
            bibleReference: '1 Samuël 17:4-10',
          ),
          const LessonSection(
            heading: 'David: Een Jonge Herder',
            content:
                'David was een jonge herdersjongen, de jongste zoon van Isaï. Hij kwam naar het slagveld om brood te brengen naar zijn broers. Toen hij Goliath hoorde, was hij verontwaardigd dat iemand Gods volk durfde te beledigen.',
            bibleReference: '1 Samuël 17:17-26',
          ),
          const LessonSection(
            heading: 'De Overwinning',
            content:
                'David weigerde het wapenrusting van koning Saul. Hij nam slechts zijn slinger en vijf gladde stenen. Met één steen raakte hij Goliath op het voorhoofd en versloeg de reus. Later werd David koning over heel Israël.',
            bibleReference: '1 Samuël 17:40-50',
          ),
        ],
      ),

      // Lesson 8: Jesus' Birth
      BibleLesson(
        id: 'bible_jesus_birth_008',
        title: 'De Geboorte van Jezus',
        description: 'Het kerstverhaal',
        category: 'Evangeliën',
        index: 7,
        estimatedReadingMinutes: 4,
        iconHint: 'child_care',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Jezus', 'Maria', 'Jozef', 'Bethlehem', 'Herders', 'Wijzen'],
        sections: [
          const LessonSection(
            heading: 'De Aankondiging',
            content:
                'De engel Gabriël werd naar een jonge vrouw genaamd Maria gestuurd in Nazareth. Hij vertelde haar dat ze een zoon zou krijgen, die ze Jezus moest noemen. Hij zou de Zoon van God zijn, de lang verwachte Messias.',
            bibleReference: 'Lukas 1:26-33',
          ),
          const LessonSection(
            heading: 'Geboren in Bethlehem',
            content:
                'Maria en haar verloofde Jozef moesten naar Bethlehem reizen voor een volkstelling. Daar, in een stal omdat er geen plaats was in de herberg, werd Jezus geboren. Maria legde hem in een kribbe.',
            bibleReference: 'Lukas 2:1-7',
          ),
          const LessonSection(
            heading: 'Herders en Wijzen',
            content:
                'Die nacht verschenen engelen aan herders in het veld en vertelden over de geboorte van de Redder. De herders gingen naar Bethlehem om het kind te zien. Later kwamen wijzen uit het oosten om Jezus te aanbidden en geschenken te brengen.',
            bibleReference: 'Lukas 2:8-20, Mattheüs 2:1-12',
          ),
        ],
      ),

      // Lesson 9: Jesus' Miracles
      BibleLesson(
        id: 'bible_miracles_009',
        title: 'Wonderen van Jezus',
        description: 'De wonderlijke daden van Jezus',
        category: 'Evangeliën',
        index: 8,
        estimatedReadingMinutes: 5,
        iconHint: 'auto_awesome',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Wonder', 'Genezing', 'Brood', 'Water', 'Wijn'],
        sections: [
          const LessonSection(
            heading: 'Jezus Geneest',
            content:
                'Jezus genas veel mensen die ziek waren. Hij genas blinden, doven, lammen en mensen met huidziekten. Hij dreef ook boze geesten uit. Door deze wonderen toonde Hij Gods macht en liefde.',
            bibleReference: 'Mattheüs 4:23-24',
          ),
          const LessonSection(
            heading: 'Water in Wijn',
            content:
                'Het eerste wonder van Jezus was op een bruiloft in Kana. Toen de wijn op was, veranderde Jezus water in wijn. Dit toonde aan dat Hij macht had over de natuur.',
            bibleReference: 'Johannes 2:1-11',
          ),
          const LessonSection(
            heading: 'Het Vermenigvuldigen van Brood',
            content:
                'Eens waren er meer dan vijfduizend mensen die naar Jezus luisterden. Ze hadden honger, maar er waren slechts vijf broden en twee vissen beschikbaar. Jezus zegende het eten en voedde de hele menigte, met twaalf manden over.',
            bibleReference: 'Mattheüs 14:13-21',
          ),
          const LessonSection(
            heading: 'Lopen op het Water',
            content:
                'Op een nacht waren de discipelen in een boot op het meer toen er een storm opstak. Jezus kwam naar hen toe, lopend over het water. Petrus probeerde het ook, maar begon te zinken toen hij bang werd. Jezus redde hem en stilte de storm.',
            bibleReference: 'Mattheüs 14:22-33',
          ),
        ],
      ),

      // Lesson 10: Easter - Death and Resurrection
      BibleLesson(
        id: 'bible_easter_010',
        title: 'Pasen: Dood en Opstanding',
        description: 'Het hart van het christelijk geloof',
        category: 'Evangeliën',
        index: 9,
        estimatedReadingMinutes: 5,
        iconHint: 'brightness_7',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: [
          'Kruisiging',
          'Opstanding',
          'Pasen',
          'Graf',
          'Vergeving'
        ],
        sections: [
          const LessonSection(
            heading: 'Het Laatste Avondmaal',
            content:
                'De avond voor Zijn dood at Jezus met Zijn discipelen. Hij brak het brood en deelde de wijn, en legde uit dat deze Zijn lichaam en bloed vertegenwoordigden. Dit wordt nu het Heilig Avondmaal genoemd.',
            bibleReference: 'Mattheüs 26:26-28',
          ),
          const LessonSection(
            heading: 'De Kruisiging',
            content:
                'Jezus werd verraden door Judas, gearresteerd en veroordeeld tot de dood aan het kruis. Hij stierf op Golgotha, buiten Jeruzalem. Christenen geloven dat Jezus stierf om de straf voor de zonden van de mensheid te dragen.',
            bibleReference: 'Lukas 23:33-46',
          ),
          const LessonSection(
            heading: 'De Opstanding',
            content:
                'Op de derde dag na Zijn dood stond Jezus op uit de dood. Vrouwen die naar Zijn graf gingen, vonden het leeg. Een engel vertelde hen dat Jezus was opgestaan. Later verscheen Jezus aan Zijn discipelen. Dit is het Paasfeest.',
            bibleReference: 'Mattheüs 28:1-10',
          ),
          const LessonSection(
            heading: 'De Betekenis',
            content:
                'De opstanding is het centrale geloof van het christendom. Het toont aan dat Jezus de dood heeft overwonnen. Christenen geloven dat wie in Jezus gelooft, vergeving van zonden ontvangt en eeuwig leven.',
            bibleReference: 'Johannes 3:16',
          ),
        ],
      ),
    ];
  }

  /// English lessons for beginners
  List<BibleLesson> _getEnglishLessons() {
    return [
      // Lesson 1: Introduction to the Bible
      BibleLesson(
        id: 'bible_intro_001',
        title: 'What is the Bible?',
        description: 'Learn about the structure and content of the Bible',
        category: 'Introduction',
        index: 0,
        estimatedReadingMinutes: 3,
        iconHint: 'menu_book',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Bible', 'Old Testament', 'New Testament', 'Books'],
        sections: [
          const LessonSection(
            heading: 'The Bible: God\'s Word',
            content:
                'The Bible is the holy book of Christianity. The word "Bible" comes from the Greek word "biblia" meaning "books." The Bible is indeed a collection of 66 different books, written by more than 40 different authors over a period of about 1500 years.',
          ),
          const LessonSection(
            heading: 'Two Parts',
            content:
                'The Bible consists of two main parts:\n\n• The Old Testament (39 books): Written before the birth of Jesus, it tells about God\'s creation, the people of Israel, and the prophets.\n\n• The New Testament (27 books): Written after Jesus\' birth, it tells about the life of Jesus, the early church, and the letters of the apostles.',
          ),
          const LessonSection(
            heading: 'Different Types of Books',
            content:
                'The Bible contains various types of literature:\n\n• Historical books - stories about the past\n• Poetry - such as the Psalms\n• Wisdom literature - such as Proverbs\n• Prophecy - predictions and warnings\n• Letters - to early churches',
          ),
        ],
      ),

      // Lesson 2: Creation
      BibleLesson(
        id: 'bible_creation_002',
        title: 'The Creation',
        description: 'The beginning of everything: God creates the world',
        category: 'Genesis',
        index: 1,
        estimatedReadingMinutes: 4,
        iconHint: 'public',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: [
          'Creation',
          'Adam',
          'Eve',
          'Garden of Eden',
          'Seven days'
        ],
        sections: [
          const LessonSection(
            heading: 'In the Beginning',
            content:
                'The Bible begins with the words: "In the beginning God created the heavens and the earth." This is the first verse of the book of Genesis, the first book of the Bible. Genesis means "origin" or "beginning".',
            bibleReference: 'Genesis 1:1',
          ),
          const LessonSection(
            heading: 'The Seven Days',
            content:
                'According to the Bible, God created everything in six days and rested on the seventh day:\n\n'
                '• Day 1: Light and darkness\n'
                '• Day 2: The sky\n'
                '• Day 3: Land, sea, and plants\n'
                '• Day 4: Sun, moon, and stars\n'
                '• Day 5: Fish and birds\n'
                '• Day 6: Animals and humans\n'
                '• Day 7: God rested',
            bibleReference: 'Genesis 1:1-2:3',
          ),
          const LessonSection(
            heading: 'Adam and Eve',
            content:
                'God made the first man, Adam, from the dust of the ground and breathed life into him. Later, God made Eve from one of Adam\'s ribs. They became the first humans and lived in the Garden of Eden, a beautiful garden God had made for them.',
            bibleReference: 'Genesis 2:7-22',
          ),
        ],
      ),

      // Lesson 3: Noah's Ark
      BibleLesson(
        id: 'bible_noah_003',
        title: 'Noah and the Ark',
        description: 'The story of the great flood',
        category: 'Genesis',
        index: 2,
        estimatedReadingMinutes: 4,
        iconHint: 'sailing',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Noah', 'Ark', 'Flood', 'Rainbow', 'Animals'],
        sections: [
          const LessonSection(
            heading: 'A Righteous Man',
            content:
                'Noah was a righteous man in a time when people had become wicked. God was grieved by the evil in the world and decided to make a fresh start. But Noah found favor in God\'s eyes.',
            bibleReference: 'Genesis 6:8-9',
          ),
          const LessonSection(
            heading: 'The Assignment',
            content:
                'God gave Noah the task of building a large boat, an ark. The ark had to be big enough to house his family and a pair of every kind of animal. The ark was about 450 feet long, 75 feet wide, and 45 feet high.',
            bibleReference: 'Genesis 6:14-16',
          ),
          const LessonSection(
            heading: 'The Flood and the Promise',
            content:
                'When the ark was finished, Noah entered with his family and all the animals. It rained for forty days and nights. After the flood, God promised never again to destroy the earth with water. The rainbow is the sign of this promise.',
            bibleReference: 'Genesis 9:12-16',
          ),
        ],
      ),

      // Lesson 4: Abraham
      BibleLesson(
        id: 'bible_abraham_004',
        title: 'Abraham: Father of Faith',
        description: 'The story of God\'s promise to Abraham',
        category: 'Genesis',
        index: 3,
        estimatedReadingMinutes: 4,
        iconHint: 'star',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Abraham', 'Sarah', 'Isaac', 'Promise', 'Canaan'],
        sections: [
          const LessonSection(
            heading: 'God\'s Calling',
            content:
                'Abraham (originally Abram) lived in Ur, a city in modern-day Iraq. God called him to leave his country and go to a new land that God would show him. Abraham obeyed, even though he didn\'t know where he was going.',
            bibleReference: 'Genesis 12:1-4',
          ),
          const LessonSection(
            heading: 'The Promise',
            content:
                'God promised Abraham three things:\n\n'
                '1. Many descendants - as numerous as the stars\n'
                '2. A land - the land of Canaan\n'
                '3. A blessing - through him all nations would be blessed\n\n'
                'This promise was called the covenant with Abraham.',
            bibleReference: 'Genesis 15:5-6',
          ),
          const LessonSection(
            heading: 'Isaac: The Son of Promise',
            content:
                'Abraham and his wife Sarah were old and had no children. But God promised them a son. When Abraham was 100 years old and Sarah was 90, Isaac was born. His name means "he laughs" because Sarah laughed when she heard she would have a child.',
            bibleReference: 'Genesis 21:1-7',
          ),
        ],
      ),

      // Lesson 5: Moses and the Exodus
      BibleLesson(
        id: 'bible_moses_005',
        title: 'Moses and the Exodus',
        description: 'The liberation of Israel from Egypt',
        category: 'Exodus',
        index: 4,
        estimatedReadingMinutes: 5,
        iconHint: 'waves',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Moses', 'Pharaoh', 'Ten Plagues', 'Red Sea', 'Exodus'],
        sections: [
          const LessonSection(
            heading: 'Slavery in Egypt',
            content:
                'The descendants of Abraham, the people of Israel, had become slaves in Egypt. They had to work hard for Pharaoh. God heard their cries and sent Moses to set them free.',
            bibleReference: 'Exodus 3:7-10',
          ),
          const LessonSection(
            heading: 'The Ten Plagues',
            content:
                'When Pharaoh refused to let the people go, God sent ten plagues on Egypt:\n\n'
                '1. Water turned to blood\n'
                '2. Frogs\n'
                '3. Gnats\n'
                '4. Flies\n'
                '5. Death of livestock\n'
                '6. Boils\n'
                '7. Hail\n'
                '8. Locusts\n'
                '9. Darkness\n'
                '10. Death of firstborn',
            bibleReference: 'Exodus 7-12',
          ),
          const LessonSection(
            heading: 'Through the Red Sea',
            content:
                'After the tenth plague, Pharaoh let the people go. But he changed his mind and chased them. At the Red Sea, the people seemed trapped. But God parted the sea and the people walked through on dry land. When the Egyptians followed, the sea closed over them.',
            bibleReference: 'Exodus 14:21-28',
          ),
        ],
      ),

      // Lesson 6: The Ten Commandments
      BibleLesson(
        id: 'bible_commandments_006',
        title: 'The Ten Commandments',
        description: 'God\'s law for His people',
        category: 'Exodus',
        index: 5,
        estimatedReadingMinutes: 4,
        iconHint: 'gavel',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: [
          'Ten Commandments',
          'Sinai',
          'Law',
          'Moses',
          'Stone Tablets'
        ],
        sections: [
          const LessonSection(
            heading: 'On Mount Sinai',
            content:
                'After the exodus from Egypt, the people of Israel journeyed through the wilderness to Mount Sinai. There God spoke to Moses and gave him the Ten Commandments, written on two stone tablets.',
            bibleReference: 'Exodus 19:20-20:1',
          ),
          const LessonSection(
            heading: 'The First Four Commandments',
            content:
                'The first four commandments are about our relationship with God:\n\n'
                '1. Have no other gods\n'
                '2. Do not make idols\n'
                '3. Do not misuse God\'s name\n'
                '4. Keep the Sabbath holy',
            bibleReference: 'Exodus 20:3-11',
          ),
          const LessonSection(
            heading: 'The Last Six Commandments',
            content:
                'The last six commandments are about our relationships with others:\n\n'
                '5. Honor your father and mother\n'
                '6. Do not murder\n'
                '7. Do not commit adultery\n'
                '8. Do not steal\n'
                '9. Do not give false testimony\n'
                '10. Do not covet what belongs to others',
            bibleReference: 'Exodus 20:12-17',
          ),
        ],
      ),

      // Lesson 7: David and Goliath
      BibleLesson(
        id: 'bible_david_007',
        title: 'David and Goliath',
        description: 'The shepherd boy who became king',
        category: '1 Samuel',
        index: 6,
        estimatedReadingMinutes: 4,
        iconHint: 'sports_martial_arts',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['David', 'Goliath', 'Sling', 'Shepherd', 'Israel'],
        sections: [
          const LessonSection(
            heading: 'The Giant Goliath',
            content:
                'The Philistines were at war with Israel. Their champion was Goliath, a giant almost nine feet tall. For forty days he challenged the Israelites, but no one dared to fight him.',
            bibleReference: '1 Samuel 17:4-10',
          ),
          const LessonSection(
            heading: 'David: A Young Shepherd',
            content:
                'David was a young shepherd boy, the youngest son of Jesse. He came to the battlefield to bring bread to his brothers. When he heard Goliath, he was outraged that someone dared to defy God\'s people.',
            bibleReference: '1 Samuel 17:17-26',
          ),
          const LessonSection(
            heading: 'The Victory',
            content:
                'David refused King Saul\'s armor. He took only his sling and five smooth stones. With one stone he struck Goliath on the forehead and defeated the giant. Later, David became king over all Israel.',
            bibleReference: '1 Samuel 17:40-50',
          ),
        ],
      ),

      // Lesson 8: Jesus' Birth
      BibleLesson(
        id: 'bible_jesus_birth_008',
        title: 'The Birth of Jesus',
        description: 'The Christmas story',
        category: 'Gospels',
        index: 7,
        estimatedReadingMinutes: 4,
        iconHint: 'child_care',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Jesus', 'Mary', 'Joseph', 'Bethlehem', 'Shepherds', 'Wise Men'],
        sections: [
          const LessonSection(
            heading: 'The Announcement',
            content:
                'The angel Gabriel was sent to a young woman named Mary in Nazareth. He told her she would have a son, whom she should name Jesus. He would be the Son of God, the long-awaited Messiah.',
            bibleReference: 'Luke 1:26-33',
          ),
          const LessonSection(
            heading: 'Born in Bethlehem',
            content:
                'Mary and her fiancé Joseph had to travel to Bethlehem for a census. There, in a stable because there was no room at the inn, Jesus was born. Mary laid him in a manger.',
            bibleReference: 'Luke 2:1-7',
          ),
          const LessonSection(
            heading: 'Shepherds and Wise Men',
            content:
                'That night, angels appeared to shepherds in the fields and told them about the birth of the Savior. The shepherds went to Bethlehem to see the child. Later, wise men from the east came to worship Jesus and bring gifts.',
            bibleReference: 'Luke 2:8-20, Matthew 2:1-12',
          ),
        ],
      ),

      // Lesson 9: Jesus' Miracles
      BibleLesson(
        id: 'bible_miracles_009',
        title: 'Miracles of Jesus',
        description: 'The miraculous deeds of Jesus',
        category: 'Gospels',
        index: 8,
        estimatedReadingMinutes: 5,
        iconHint: 'auto_awesome',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: ['Miracle', 'Healing', 'Bread', 'Water', 'Wine'],
        sections: [
          const LessonSection(
            heading: 'Jesus Heals',
            content:
                'Jesus healed many people who were sick. He healed the blind, deaf, lame, and people with skin diseases. He also cast out evil spirits. Through these miracles, He showed God\'s power and love.',
            bibleReference: 'Matthew 4:23-24',
          ),
          const LessonSection(
            heading: 'Water into Wine',
            content:
                'Jesus\' first miracle was at a wedding in Cana. When the wine ran out, Jesus turned water into wine. This showed that He had power over nature.',
            bibleReference: 'John 2:1-11',
          ),
          const LessonSection(
            heading: 'Multiplying Bread',
            content:
                'Once there were more than five thousand people listening to Jesus. They were hungry, but there were only five loaves and two fish available. Jesus blessed the food and fed the entire crowd, with twelve baskets left over.',
            bibleReference: 'Matthew 14:13-21',
          ),
          const LessonSection(
            heading: 'Walking on Water',
            content:
                'One night the disciples were in a boat on the lake when a storm arose. Jesus came to them, walking on the water. Peter tried too, but began to sink when he became afraid. Jesus saved him and calmed the storm.',
            bibleReference: 'Matthew 14:22-33',
          ),
        ],
      ),

      // Lesson 10: Easter - Death and Resurrection
      BibleLesson(
        id: 'bible_easter_010',
        title: 'Easter: Death and Resurrection',
        description: 'The heart of the Christian faith',
        category: 'Gospels',
        index: 9,
        estimatedReadingMinutes: 5,
        iconHint: 'brightness_7',
        questionCategory: 'Algemeen',
        quizQuestionCount: 5,
        keyTerms: [
          'Crucifixion',
          'Resurrection',
          'Easter',
          'Tomb',
          'Forgiveness'
        ],
        sections: [
          const LessonSection(
            heading: 'The Last Supper',
            content:
                'The night before His death, Jesus ate with His disciples. He broke the bread and shared the wine, explaining that these represented His body and blood. This is now called the Lord\'s Supper or Communion.',
            bibleReference: 'Matthew 26:26-28',
          ),
          const LessonSection(
            heading: 'The Crucifixion',
            content:
                'Jesus was betrayed by Judas, arrested, and condemned to death on the cross. He died at Golgotha, outside Jerusalem. Christians believe that Jesus died to bear the punishment for humanity\'s sins.',
            bibleReference: 'Luke 23:33-46',
          ),
          const LessonSection(
            heading: 'The Resurrection',
            content:
                'On the third day after His death, Jesus rose from the dead. Women who went to His tomb found it empty. An angel told them Jesus had risen. Later, Jesus appeared to His disciples. This is Easter.',
            bibleReference: 'Matthew 28:1-10',
          ),
          const LessonSection(
            heading: 'The Meaning',
            content:
                'The resurrection is the central belief of Christianity. It shows that Jesus conquered death. Christians believe that whoever believes in Jesus receives forgiveness of sins and eternal life.',
            bibleReference: 'John 3:16',
          ),
        ],
      ),
    ];
  }
}
