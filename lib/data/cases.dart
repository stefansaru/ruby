/// The shipped case packs by tier name, easiest first. The packs themselves
/// are generated files (`cases_<tier>.dart`); this index is hand-written.
library;

import 'cases_easy.dart';
import 'cases_expert.dart';
import 'cases_hard.dart';
import 'cases_normal.dart';
import 'cases_tutorial.dart';

const Map<String, List<String>> casePacks = <String, List<String>>{
  'tutorial': tutorialCases,
  'easy': easyCases,
  'normal': normalCases,
  'hard': hardCases,
  'expert': expertCases,
};
