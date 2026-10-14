class Calculator {
  static const maxDigits = 12;

  String _display = '0';
  String _expression = '';
  double? _left;
  String? _operator;
  double? _repeatOperand;
  String? _repeatOperator;
  bool _overwrite = true;
  bool _awaitingOperand = false;
  bool _hasError = false;

  String get display => _display;
  String get expression => _expression;

  /// Operador pendiente, para resaltar el botón activo.
  String? get activeOperator => _awaitingOperand ? _operator : null;

  void input(String key) {
    switch (key) {
      case 'C':
        _reset();
      case '⌫':
        _backspace();
      case '±':
        _toggleSign();
      case '%':
        _percent();
      case '.':
        _decimal();
      case '=':
        _equals();
      case '+':
      case '−':
      case '×':
      case '÷':
        _applyOperator(key);
      default:
        _digit(key);
    }
  }

  void _reset() {
    _display = '0';
    _expression = '';
    _left = null;
    _operator = null;
    _repeatOperand = null;
    _repeatOperator = null;
    _overwrite = true;
    _awaitingOperand = false;
    _hasError = false;
  }

  void _setError() {
    _display = 'Error';
    _expression = '';
    _left = null;
    _operator = null;
    _repeatOperand = null;
    _repeatOperator = null;
    _overwrite = true;
    _awaitingOperand = false;
    _hasError = true;
  }

  void _digit(String digit) {
    if (_hasError) _reset();

    if (_overwrite) {
      _display = digit;
      _overwrite = false;
      _awaitingOperand = false;
      return;
    }

    final digits = _display.replaceAll('-', '').replaceAll('.', '');
    if (digits.length >= maxDigits) return;
    if (_display == '0') {
      _display = digit;
    } else if (_display == '-0') {
      _display = '-$digit';
    } else {
      _display += digit;
    }
  }

  void _decimal() {
    if (_hasError) _reset();

    if (_overwrite) {
      _display = '0.';
      _overwrite = false;
      _awaitingOperand = false;
      return;
    }

    if (!_display.contains('.')) {
      _display = '$_display.';
    }
  }

  void _backspace() {
    if (_hasError || _overwrite || _awaitingOperand) return;

    if (_display.length <= 1 ||
        (_display.startsWith('-') && _display.length == 2)) {
      _display = '0';
      _overwrite = true;
      return;
    }

    _display = _display.substring(0, _display.length - 1);
    if (_display == '-' || _display == '') {
      _display = '0';
      _overwrite = true;
    }
  }

  void _toggleSign() {
    if (_hasError || _display == 'Error') return;
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else if (_display != '0') {
      _display = '-$_display';
    }
    if (_awaitingOperand && _left != null) {
      _left = _parse(_display);
      _expression = '${_format(_left!)} $_operator';
    }
  }

  void _percent() {
    if (_hasError) return;
    final current = _parse(_display);
    final double value;
    if ((_operator == '+' || _operator == '−') &&
        _left != null &&
        !_awaitingOperand) {
      value = _left! * current / 100;
    } else {
      value = current / 100;
    }
    _display = _format(value);
    _overwrite = true;
    _awaitingOperand = false;
  }

  void _applyOperator(String operator) {
    if (_hasError) return;
    final current = _parse(_display);

    if (_operator != null && !_awaitingOperand && !_overwrite) {
      final result = _compute(_left ?? current, current, _operator!);
      if (result == null) {
        _setError();
        return;
      }
      _left = result;
      _display = _format(result);
    } else {
      _left = current;
    }

    _operator = operator;
    _awaitingOperand = true;
    _overwrite = true;
    _repeatOperand = null;
    _repeatOperator = null;
    _expression = '${_format(_left!)} $operator';
  }

  void _equals() {
    if (_hasError) return;

    final double left;
    final double right;
    final String operator;

    if (_operator != null && _left != null) {
      operator = _operator!;
      left = _left!;
      right = _awaitingOperand ? left : _parse(_display);
    } else if (_repeatOperator != null && _repeatOperand != null) {
      operator = _repeatOperator!;
      left = _parse(_display);
      right = _repeatOperand!;
    } else {
      return;
    }

    final result = _compute(left, right, operator);
    if (result == null) {
      _setError();
      return;
    }

    _expression = '${_format(left)} $operator ${_format(right)} =';
    _display = _format(result);
    _left = result;
    _repeatOperator = operator;
    _repeatOperand = right;
    _operator = null;
    _awaitingOperand = false;
    _overwrite = true;
  }

  double _parse(String value) => double.parse(value);

  double? _compute(double left, double right, String operator) {
    switch (operator) {
      case '+':
        return left + right;
      case '−':
        return left - right;
      case '×':
        return left * right;
      case '÷':
        if (right == 0) return null;
        return left / right;
      default:
        return null;
    }
  }

  String _format(double value) {
    if (value.isNaN || value.isInfinite) return 'Error';

    final rounded = _round(value);
    if (rounded == 0) return '0';

    final negative = rounded < 0;
    final absolute = rounded.abs();
    String text;

    if (absolute >= 1e12 || absolute < 1e-9) {
      text = absolute.toStringAsExponential(6);
      text = text
          .replaceFirst(RegExp(r'\.?0+e'), 'e')
          .replaceAll('e+', 'e');
    } else {
      text = absolute.toStringAsFixed(10);
      text = text.replaceFirst(RegExp(r'0+$'), '');
      text = text.replaceFirst(RegExp(r'\.$'), '');
    }

    return negative ? '-$text' : text;
  }

  double _round(double value) => (value * 1e10).roundToDouble() / 1e10;
}
