import 'dart:async';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dao_generator_annotation/annotation.dart';

import 'utils.dart';

String sql(String className) {
  return '\$get${className}CreateTable';
}

String getMethodNameForFromList(String className) {
  return '\$get${className}FromList';
}

String getMethodNameForFromMap(String className) {
  return '\$get${className}FromMap';
}

String getMethodNameForToMap(String className) {
  return '\$get${className}ToMap';
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
      String name = field.name;
      var annotation = findAnnotation(field, ColumnInfo);
      if(annotation != null) {
        DartObject object = annotation.constantValue.getField('name');
        if(object != null) {
          name = object.toStringValue();
        }
      }
      String type = _getType(field);

      buffer.write('\'');
      if(addComma) buffer.write(',');
      else addComma = true;
      buffer.write('$name');
      buffer.write(' $type');
      if(findAnnotation(field, PrimaryKey) != null) {
        buffer.write(' primary key');
      }
      buffer.writeln('\'');
    });
    buffer.writeln('\')\';');

    buffer.writeln('$className ${getMethodNameForFromMap(className)}(Map<String, dynamic> map, {prefix = \'\'}) {');
    buffer.writeln('var entity = $className(); ');
    fields.forEach((field) {
      buffer.writeln('entity.${field.name} = map[\'\${prefix}${field.name}\'];');
    });
    buffer.writeln('return entity;');
    buffer.writeln('}');

    buffer.writeln('List<$className> ${getMethodNameForFromList(className)}(List<Map<String, dynamic>> maps, {prefix = \'\'}) =>');
    buffer.writeln('maps.map((map) => ${getMethodNameForFromMap(className)}(map, prefix: prefix));');

    buffer.writeln('Map<String, dynamic> ${getMethodNameForToMap(className)}($className entity) =>');
    buffer.writeln('{');
    fields.forEach((field) {
      buffer.writeln('\'${field.name}\': entity.${field.name},');
    });
    buffer.writeln('};');
    return buffer.toString();
  }

  String _getType(FieldElement field) {
    if(TypeChecker.fromRuntime(int).isAssignableFromType(field.type)) return 'integer';
    if(TypeChecker.fromRuntime(double).isAssignableFromType(field.type)) return 'read';
    if(TypeChecker.fromRuntime(String).isAssignableFromType(field.type)) return 'text';
    throw InvalidGenerationSourceError('Not supported type \'${field.type}\'.');
  }
}
