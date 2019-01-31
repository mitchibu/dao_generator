import 'dart:async';
import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';

import 'package:dao_generator_annotation/annotation.dart';

import 'entity_generator.dart';

String generateDaoClassName(String className) => '_\$$className';

class DaoGenerator extends GeneratorForAnnotation<Dao> {
  @override
  FutureOr<String> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    if(element is! ClassElement) {
      throw InvalidGenerationSourceError('Generator can not target \'${element.name}\'.');
    }

    var classElement = element as ClassElement;
    var className = classElement.name;
    var methods = classElement.methods;
    var generatedDaoClassName = generateDaoClassName(className);

    var buffer = StringBuffer();
    buffer.writeln('class $generatedDaoClassName extends $className {');
    buffer.writeln('final DatabaseHelper _helper;');
    buffer.writeln('$generatedDaoClassName(this._helper);');
    methods.forEach((method) {
      var b = StringBuffer();
      method.parameters.forEach((e) {
        if(b.isNotEmpty) b.write(',');
        b.write('${e.type} ${e.name}');
      });

      if(method.isAbstract && method.returnType.isDartAsyncFuture) {
        ElementAnnotation annotation;
        if((annotation = _findAnnotation(method, Query)) != null) _generateMethod(buffer, method, annotation, SqlType.Query);
        else if((annotation = _findAnnotation(method, Insert)) != null) _generateMethod(buffer, method, annotation, SqlType.Insert);
        else if((annotation = _findAnnotation(method, Update)) != null) _generateMethod(buffer, method, annotation, SqlType.Update);
        else if((annotation = _findAnnotation(method, Delete)) != null) _generateMethod(buffer, method, annotation, SqlType.Delete);
      } else {
        ElementAnnotation annotation = _findAnnotation(method, Transaction);
        if(annotation != null) {
          _generateTransactionMethod(buffer, method);
        }
      }
    });
    buffer.writeln('}');
    return buffer.toString();
  }

  List<DartType> _getGenericTypes(DartType type) => type is ParameterizedType ? type.typeArguments : const [];
  bool _checkType(DartType dartType, Type type) => TypeChecker.fromRuntime(type).isAssignableFromType(dartType);

  ElementAnnotation _findAnnotation(MethodElement method, Type target) {
    try {
    return method.metadata.firstWhere((annotation) => _checkType(annotation.constantValue.type, target));
    } catch(e) {
      return null;
    }
  }

  void _generateMethod(StringBuffer buffer, MethodElement method, ElementAnnotation annotation, SqlType sqlType) {
    DartObject object = annotation.constantValue.getField('sql');
    String sql = object == null ? null : object.toStringValue();
    if(sql == null || sql.isEmpty) return;

    var params = StringBuffer();
    method.parameters.forEach((e) {
      if(params.isNotEmpty) params.write(',');
      params.write('${e.type} ${e.name}');
    });

    String call = '${sqlType.toString().split('\.')[1].toLowerCase()}';
    buffer.writeln('@override');
    buffer.writeln('${method.returnType} ${method.name}(${params.toString()}) async {');
    buffer.writeln('var executor = await _helper.getExecutor();');
    if(sqlType == SqlType.Query) {
      buffer.writeln('var result = await executor.$call(\'$sql\');');
      var types = _getGenericTypes(method.returnType);
      if(types.isNotEmpty) {
        if(TypeChecker.fromRuntime(List).isAssignableFromType(types[0])) {
          types = _getGenericTypes(types[0]);
          if(types.isNotEmpty) {
            buffer.writeln('return ${getMethodNameForFromList(types[0].name)}(result);');
          }
        } else {
          buffer.writeln('var entities = ${getMethodNameForFromList(types[0].name)}(result);');
          buffer.writeln('return entities.isEmpty ? null : entities[0];');
        }
      }
    } else {
      buffer.writeln('return await executor.$call(\'$sql\');');
    }
    buffer.writeln('}');
  }

  void _generateTransactionMethod(StringBuffer buffer, MethodElement method) {
    var params = StringBuffer();
    method.parameters.forEach((e) {
      if(params.isNotEmpty) params.write(',');
      params.write('${e.type} ${e.name}');
    });

    buffer.writeln('@override');
    buffer.writeln('${method.returnType} ${method.name}(${params.toString()}) {');
    buffer.writeln('');
    buffer.writeln('');
    buffer.writeln('}');
  }
}

enum SqlType {
  Query,
  Insert,
  Update,
  Delete,
}
