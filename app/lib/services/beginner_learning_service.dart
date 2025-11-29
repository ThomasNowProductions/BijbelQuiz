import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/learning_module.dart';
import '../services/logger.dart';

/// Service for loading and managing beginner learning modules.
class LearningService {
  LearningService();

  List<LearningModule>? _cachedModules;
  List<LearningAchievement>? _cachedAchievements;

  /// Loads all learning modules from assets.
  Future<List<LearningModule>> getModules() async {
    if (_cachedModules != null) return _cachedModules!;

    try {
      final jsonString =
          await rootBundle.loadString('assets/learning_modules.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedModules =
          jsonList.map((e) => LearningModule.fromJson(e)).toList();
      return _cachedModules!;
    } catch (e) {
      AppLogger.error('Failed to load learning modules', e);
      // Return default modules if asset loading fails
      return _getDefaultModules();
    }
  }

  /// Gets a specific module by ID.
  Future<LearningModule?> getModule(String id) async {
    final modules = await getModules();
    return modules.where((m) => m.id == id).firstOrNull;
  }

  /// Gets modules by index range.
  Future<List<LearningModule>> getModulesByRange(int start, int end) async {
    final modules = await getModules();
    return modules.where((m) => m.index >= start && m.index <= end).toList();
  }

  /// Gets all available achievements.
  Future<List<LearningAchievement>> getAchievements() async {
    if (_cachedAchievements != null) return _cachedAchievements!;

    try {
      final jsonString =
          await rootBundle.loadString('assets/learning_achievements.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _cachedAchievements =
          jsonList.map((e) => LearningAchievement.fromJson(e)).toList();
      return _cachedAchievements!;
    } catch (e) {
      AppLogger.warning('Failed to load learning achievements: $e');
      return _getDefaultAchievements();
    }
  }

  /// Default learning modules for fallback.
  List<LearningModule> _getDefaultModules() {
    return [
      LearningModule(
        id: 'intro_bible',
        title: 'Wat is de Bijbel?',
        description: 'Een introductie tot het belangrijkste boek ter wereld',
        objective: 'Je leert wat de Bijbel is en waarom het zo belangrijk is',
        index: 0,
        iconHint: 'menu_book',
        estimatedMinutes: 5,
        relatedCategory: 'Algemeen',
        practiceQuestionCount: 5,
        sections: [
          const LearningSection(
            title: 'Het Woord van God',
            content:
                'De Bijbel is een verzameling van geschriften die door christenen wordt beschouwd als het Woord van God. Het woord "Bijbel" komt van het Griekse woord "biblia", wat "boeken" betekent.',
            keyPoints: [
              'De Bijbel is geschreven over een periode van ongeveer 1500 jaar',
              'Meer dan 40 verschillende auteurs hebben eraan bijgedragen',
              'Het is het meest vertaalde boek ter wereld',
            ],
          ),
          const LearningSection(
            title: 'Twee Delen',
            content:
                'De Bijbel bestaat uit twee hoofddelen: het Oude Testament en het Nieuwe Testament. Het Oude Testament vertelt over de geschiedenis van het volk Israël en Gods beloften. Het Nieuwe Testament vertelt over het leven van Jezus Christus en de vroege kerk.',
            keyPoints: [
              'Oude Testament: 39 boeken',
              'Nieuwe Testament: 27 boeken',
              'Totaal: 66 boeken',
            ],
          ),
        ],
        funFacts: [
          'De Bijbel is vertaald in meer dan 700 talen!',
          'De langste psalm is Psalm 119 met 176 verzen',
        ],
      ),
      LearningModule(
        id: 'structure_ot',
        title: 'Het Oude Testament',
        description: 'Ontdek de structuur van het Oude Testament',
        objective: 'Je leert de verschillende soorten boeken in het Oude Testament kennen',
        index: 1,
        iconHint: 'history_edu',
        estimatedMinutes: 6,
        relatedCategory: 'Oude Testament',
        practiceQuestionCount: 5,
        sections: [
          const LearningSection(
            title: 'De Wet (Torah)',
            content:
                'De eerste vijf boeken van de Bijbel worden de Torah of Pentateuch genoemd. Deze boeken zijn toegeschreven aan Mozes en bevatten de basiswetten en geschiedenis van het volk Israël.',
            keyPoints: [
              'Genesis - De schepping en de aartsvaders',
              'Exodus - De uittocht uit Egypte',
              'Leviticus - Wetten en regels voor de eredienst',
              'Numeri - De woestijnreis',
              'Deuteronomium - Herhaling van de wet',
            ],
          ),
          const LearningSection(
            title: 'Geschiedkundige Boeken',
            content:
                'Na de Torah volgen boeken die de geschiedenis van Israël vertellen, van de intocht in het beloofde land tot de ballingschap en terugkeer.',
            keyPoints: [
              'Jozua, Richteren, Ruth',
              'Samuel en Koningen',
              'Kronieken, Ezra, Nehemia, Esther',
            ],
          ),
          const LearningSection(
            title: 'Poëzie en Profeten',
            content:
                'Het Oude Testament bevat ook poëtische boeken zoals Psalmen en Spreuken, en profetische boeken waarin Gods boodschappers tot het volk spraken.',
            keyPoints: [
              'Poëzie: Job, Psalmen, Spreuken, Prediker, Hooglied',
              'Grote profeten: Jesaja, Jeremia, Ezechiël, Daniël',
              'Kleine profeten: Hosea tot Maleachi (12 boeken)',
            ],
          ),
        ],
        funFacts: [
          'Het Oude Testament werd oorspronkelijk in het Hebreeuws geschreven',
          'De Psalmen werden vaak op muziek gezongen',
        ],
      ),
      LearningModule(
        id: 'structure_nt',
        title: 'Het Nieuwe Testament',
        description: 'Leer over de structuur van het Nieuwe Testament',
        objective: 'Je leert de verschillende soorten boeken in het Nieuwe Testament kennen',
        index: 2,
        iconHint: 'auto_stories',
        estimatedMinutes: 6,
        relatedCategory: 'Nieuwe Testament',
        practiceQuestionCount: 5,
        sections: [
          const LearningSection(
            title: 'De Evangeliën',
            content:
                'De eerste vier boeken van het Nieuwe Testament worden de Evangeliën genoemd. Ze vertellen het verhaal van Jezus\' leven, leer, dood en opstanding.',
            keyPoints: [
              'Matteüs - Jezus als de beloofde Messias',
              'Marcus - Jezus als de dienende Heer',
              'Lucas - Jezus als de Zoon des mensen',
              'Johannes - Jezus als de Zoon van God',
            ],
          ),
          const LearningSection(
            title: 'Handelingen en Brieven',
            content:
                'Na de Evangeliën volgt het boek Handelingen, dat de geschiedenis van de vroege kerk vertelt. Daarna komen de brieven (epistels) van apostelen zoals Paulus, Petrus en Johannes.',
            keyPoints: [
              'Handelingen: De verspreiding van het evangelie',
              'Brieven van Paulus: Romeinen tot Filemon (13 brieven)',
              'Algemene brieven: Hebreeën tot Judas',
            ],
          ),
          const LearningSection(
            title: 'Openbaring',
            content:
                'Het laatste boek van de Bijbel is Openbaring, geschreven door de apostel Johannes. Het bevat visioenen over de eindtijd en de uiteindelijke overwinning van God.',
            keyPoints: [
              'Profetisch boek vol symboliek',
              'Boodschap van hoop voor vervolgde christenen',
              'Eindigt met een nieuw hemel en een nieuwe aarde',
            ],
          ),
        ],
        funFacts: [
          'Het Nieuwe Testament werd in het Grieks geschreven',
          'Paulus schreef de meeste brieven - 13 in totaal!',
        ],
      ),
      LearningModule(
        id: 'creation',
        title: 'De Schepping',
        description: 'Het begin van alles volgens Genesis',
        objective: 'Je leert over het scheppingsverhaal en wat het betekent',
        index: 3,
        iconHint: 'public',
        estimatedMinutes: 5,
        relatedCategory: 'Genesis',
        practiceQuestionCount: 5,
        sections: [
          const LearningSection(
            title: 'In het Begin',
            content:
                'Het boek Genesis begint met de woorden "In het begin schiep God de hemel en de aarde". In zes dagen schiep God alles wat bestaat, en op de zevende dag rustte Hij.',
            keyPoints: [
              'Dag 1: Licht gescheiden van duisternis',
              'Dag 2: Het uitspansel (hemel)',
              'Dag 3: Land, zee en planten',
              'Dag 4: Zon, maan en sterren',
              'Dag 5: Vissen en vogels',
              'Dag 6: Landdieren en de mens',
            ],
          ),
          const LearningSection(
            title: 'Adam en Eva',
            content:
                'God schiep de mens als het hoogtepunt van Zijn schepping. Adam werd geformeerd uit het stof der aarde, en Eva werd geschapen uit Adams rib. Samen leefden zij in de Hof van Eden.',
            keyPoints: [
              'De mens is geschapen naar Gods beeld',
              'Adam betekent "mens" of "van de aarde"',
              'Eva betekent "leven" of "moeder van alle levenden"',
            ],
          ),
        ],
        funFacts: [
          'Het woord "Genesis" betekent "oorsprong" of "begin"',
          'De Hof van Eden had vier rivieren',
        ],
      ),
      LearningModule(
        id: 'jesus_life',
        title: 'Het Leven van Jezus',
        description: 'Belangrijke momenten uit Jezus\' leven op aarde',
        objective: 'Je leert over de belangrijkste gebeurtenissen in Jezus\' leven',
        index: 4,
        iconHint: 'church',
        estimatedMinutes: 7,
        relatedCategory: 'Jezus',
        practiceQuestionCount: 5,
        sections: [
          const LearningSection(
            title: 'Geboorte en Jeugd',
            content:
                'Jezus werd geboren in Bethlehem, uit de maagd Maria. Engelen kondigden Zijn geboorte aan en wijzen uit het oosten kwamen Hem aanbidden. Hij groeide op in Nazareth.',
            keyPoints: [
              'Geboren in een stal in Bethlehem',
              'Bezocht door herders en wijzen',
              'Vluchtte naar Egypte voor koning Herodes',
              'Groeide op in Nazareth als timmerman',
            ],
          ),
          const LearningSection(
            title: 'Bediening',
            content:
                'Op ongeveer 30-jarige leeftijd begon Jezus Zijn openbare bediening. Hij werd gedoopt door Johannes de Doper, koos twaalf discipelen en reisde door Israël om te prediken en wonderen te doen.',
            keyPoints: [
              'Gedoopt in de Jordaan',
              '12 discipelen gekozen',
              'Predikte het Koninkrijk van God',
              'Deed vele wonderen en tekenen',
            ],
          ),
          const LearningSection(
            title: 'Kruisiging en Opstanding',
            content:
                'Jezus werd verraden, berecht en gekruisigd in Jeruzalem. Maar na drie dagen stond Hij op uit de dood! Dit is het centrale geloof van het christendom.',
            keyPoints: [
              'Verraden door Judas',
              'Gekruisigd op Golgotha',
              'Stond op na drie dagen',
              'Verscheen aan vele getuigen',
            ],
          ),
        ],
        funFacts: [
          'Jezus sprak Aramees als dagelijkse taal',
          'Hij onderwees vaak met gelijkenissen - korte verhalen met een boodschap',
        ],
      ),
    ];
  }

  /// Default achievements for fallback.
  List<LearningAchievement> _getDefaultAchievements() {
    return [
      const LearningAchievement(
        id: 'first_module',
        name: 'Eerste Stap',
        description: 'Voltooi je eerste leermodule',
        iconHint: '🎯',
        criteriaType: 'module_complete',
        criteriaValue: 1,
      ),
      const LearningAchievement(
        id: 'quiz_master',
        name: 'Quiz Meester',
        description: 'Behaal een perfecte score op een quiz',
        iconHint: '⭐',
        criteriaType: 'quiz_perfect',
        criteriaValue: 100,
      ),
      const LearningAchievement(
        id: 'five_modules',
        name: 'Snelle Leerling',
        description: 'Voltooi vijf leermodules',
        iconHint: '📚',
        criteriaType: 'module_complete',
        criteriaValue: 5,
      ),
      const LearningAchievement(
        id: 'week_streak',
        name: 'Week Reeks',
        description: 'Leer 7 dagen achter elkaar',
        iconHint: '🔥',
        criteriaType: 'streak',
        criteriaValue: 7,
      ),
      const LearningAchievement(
        id: 'bible_basics',
        name: 'Bijbel Basis',
        description: 'Voltooi alle introductiemodules',
        iconHint: '🏆',
        criteriaType: 'milestone',
        criteriaValue: 3,
      ),
    ];
  }

  /// Clears the cached data (for testing or refresh).
  void clearCache() {
    _cachedModules = null;
    _cachedAchievements = null;
  }
}
