import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dao_generator_annotation/annotation.dart';

String sql(String className) {
  return '\$${className}Sql';
}

String getMethodNameForFromList(String className) {
  return 'get${className}FromList';
}

class EntityGenerator extends GeneratorForAnnotation<Entity> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if(element is! ClassElement) {
      throw InvalidGenerationSourceError('Generator can not target \'${element.name}\'.');
    }

    var classElement = element as ClassElement;
    var className = classElement.name;
    var fields = classElement.fields;

    var buffer = StringBuffer();
    buffer.writeln('String get ${sql(className)} =>');
    buffer.writeln('\'create table $className(\'');
    bool addComma = false;
    fields.forEach((field) {
      buffer.write('\'');
      if(addComma) buffer.write(',');
      else addComma = true;
      buffer.write('${field.name}');
      buffer.write(' ${_getType(field)}');
      buffer.writeln('\'');
    });
    buffer.writeln('\')\';');

    buffer.writeln('$className get${className}FromMap(Map<String, dynamic> map, {prefix = \'\'}) {');
    buffer.writeln('var entity = $className(); ');
    fields.forEach((field) {
      buffer.writeln('entity.${field.name} = map[\'\${prefix}${field.name}\'];');
    });
    buffer.writeln('return entity;');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('List<${className}> get${className}FromList(List<Map<String, dynamic>> maps, {prefix = \'\'}) {');
    buffer.writeln('List<${className}> entities = [];');
    buffer.writeln('maps.forEach((map) {');
    buffer.writeln('entities.add(get${className}FromMap(map, prefix: prefix));');
    buffer.writeln('});');
    buffer.writeln('return entities;');
    buffer.writeln('}');
    buffer.writeln('');
    buffer.writeln('Map<String, dynamic> get${className}ToMap($className entity) {');
    buffer.writeln('return {');
    fields.forEach((field) {
      buffer.writeln('\'${field.name}\': entity.${field.name},');
    });
    buffer.writeln('};');
    buffer.writeln('}');
    return buffer.toString();
  }

  String _getType(FieldElement field) {
    if(TypeChecker.fromRuntime(int).isAssignableFromType(field.type)) return 'integer';
    if(TypeChecker.fromRuntime(double).isAssignableFromType(field.type)) return 'read';
    if(TypeChecker.fromRuntime(String).isAssignableFromType(field.type)) return 'text';
    throw InvalidGenerationSourceError('Not supported type \'${field.type}\'.');
  }
}
