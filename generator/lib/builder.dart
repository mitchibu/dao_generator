import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'dao_generator.dart';
import 'database_generator.dart';
import 'entity_generator.dart';

Builder genarator(BuilderOptions options) => SharedPartBuilder(
  [
    DatabaseGenerator(),
    EntityGenerator(),
    DaoGenerator(),
  ],
  'dao_generator'
);
