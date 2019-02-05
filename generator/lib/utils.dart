import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

bool _checkType(DartType dartType, Type type) => TypeChecker.fromRuntime(type).isAssignableFromType(dartType);

  ElementAnnotation findAnnotation(Element method, Type target) {
    try {
    return method.metadata.firstWhere((annotation) => _checkType(annotation.constantValue.type, target));
    } catch(e) {
      return null;
    }
  }
