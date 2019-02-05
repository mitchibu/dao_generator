class ClassBuilder {
}

class MethodBuilder {
  static Type typeOf<T>() => T;
  final String _name;
  MethodBuilder(this._name);

  Type _returnType = typeOf<void>();
  void returnType(Type type) {
    _returnType = type??typeOf<void>();
  }

  bool _async = false;
  void asynchronous(bool flag) {
    _async = flag;
  }

  String build() {
    StringBuffer buffer = StringBuffer();
    buffer.write(_returnType.toString());
    buffer.write('${_returnType.toString()} $_name ${_async?' async ':''}(){}');
  }
}