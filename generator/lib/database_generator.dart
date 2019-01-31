import 'dart:async';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dao_generator_annotation/annotation.dart';

import 'dao_generator.dart';
import 'entity_generator.dart';

String generateDatabaseClassName(String className) => '_\$$className';

class DatabaseGenerator extends GeneratorForAnnotation<Database> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if(element is! ClassElement) {
      throw InvalidGenerationSourceError('Generator can not target \'${element.name}\'.');
    }

    var classElement = element as ClassElement;
    var className = classElement.name;
    var methods = classElement.methods;
    var generatedDatabaseClassName = generateDatabaseClassName(className);

    List<DartObject> entities = annotation.read('entities').objectValue.toListValue();
    int version = annotation.read('version').intValue.toInt();

    var buffer = StringBuffer();
    entities.forEach((entity) {
      buffer.writeln('//$entity');
      buffer.writeln('//${entity.toTypeValue()}');
      buffer.writeln('//${sql(entity.toTypeValue().name)}');
    });

    buffer.writeln('$className open$className({String path = \':memory:\'}) => $generatedDatabaseClassName(path);');

    buffer.writeln('class $generatedDatabaseClassName extends $className {');
    buffer.writeln('final DatabaseHelper _helper;');
    buffer.writeln('$generatedDatabaseClassName(String path)');
    buffer.writeln(': _helper = DatabaseHelper(');
    buffer.writeln('path,');
    buffer.writeln('$version,');
    buffer.writeln('(db, version) async {');
    entities.forEach((entity) {
      buffer.writeln('await db.execute(${sql(entity.toTypeValue().name)});');
    });
    buffer.writeln('}');
    buffer.writeln(');');
    methods.forEach((method) {
      var b = StringBuffer();
      method.parameters.forEach((e) {
        if(b.isNotEmpty) b.write(',');
        b.write('${e.type} ${e.name}');
      });

      if(method.isAbstract) {
        buffer.writeln('@override');
        buffer.writeln('${method.returnType} ${method.name}(${b.toString()}) {');
        buffer.writeln('return ${generateDaoClassName(method.returnType.name)}(_helper);');
        buffer.writeln('}');
      }
    });
    buffer.writeln('}');
    return buffer.toString();
  }
}
