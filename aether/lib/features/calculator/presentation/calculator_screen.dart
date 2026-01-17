import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../../../core/data/data.dart';

// ============================================================================
// PROVIDERS
// ============================================================================

/// CalculatorHistoryRepositoryのProvider
final calculatorHistoryRepositoryProvider = Provider<CalculatorHistoryRepository>(
  (ref) => CalculatorHistoryRepository(),
);

/// 電卓履歴Provider（永続化対応）
final calculatorHistoryProvider = StateNotifierProvider<CalculatorHistoryNotifier, List<String>>(
  (ref) => CalculatorHistoryNotifier(ref.watch(calculatorHistoryRepositoryProvider)),
);

class CalculatorHistoryNotifier extends StateNotifier<List<String>> {
  final CalculatorHistoryRepository _repository;

  CalculatorHistoryNotifier(this._repository) : super([]) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final models = _repository.getAll();
    state = models.map((m) => '${m.expression} = ${m.result}').toList();
  }

  Future<void> add(String expression, String result) async {
    await _repository.add(expression, result);
    _loadFromStorage(); // 再読み込みで最大件数制限を反映
  }

  Future<void> clear() async {
    await _repository.clear();
    state = [];
  }
}

/// 電卓の状態を管理するProvider
final calculatorProvider = StateNotifierProvider<CalculatorNotifier, CalculatorState>(
  (ref) => CalculatorNotifier(ref.read(calculatorHistoryProvider.notifier)),
);

class CalculatorState {
  final String display;
  final String expression;

  const CalculatorState({
    this.display = '0',
    this.expression = '',
  });

  CalculatorState copyWith({
    String? display,
    String? expression,
  }) {
    return CalculatorState(
      display: display ?? this.display,
      expression: expression ?? this.expression,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  final CalculatorHistoryNotifier _historyNotifier;

  CalculatorNotifier(this._historyNotifier) : super(const CalculatorState());

  void input(String value) {
    if (state.display == '0' && value != '.') {
      state = state.copyWith(display: value);
    } else {
      state = state.copyWith(display: state.display + value);
    }
  }

  void operator(String op) {
    state = state.copyWith(
      expression: state.expression + state.display + ' $op ',
      display: '0',
    );
  }

  void calculate() {
    try {
      final expr = state.expression + state.display;
      final result = _evaluate(expr);
      _historyNotifier.add(expr, result);
      state = state.copyWith(
        display: result,
        expression: '',
      );
    } catch (e) {
      state = state.copyWith(display: 'Error');
    }
  }

  void clear() {
    state = state.copyWith(display: '0', expression: '');
  }

  void clearEntry() {
    state = state.copyWith(display: '0');
  }

  void backspace() {
    if (state.display.length > 1) {
      state = state.copyWith(display: state.display.substring(0, state.display.length - 1));
    } else {
      state = state.copyWith(display: '0');
    }
  }

  String _evaluate(String expr) {
    expr = expr.replaceAll(' ', '');
    expr = expr.replaceAll('×', '*').replaceAll('÷', '/');
    
    try {
      final result = _simpleEval(expr);
      if (result == result.toInt()) {
        return result.toInt().toString();
      }
      return result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    } catch (e) {
      return 'Error';
    }
  }

  double _simpleEval(String expr) {
    final addParts = expr.split(RegExp(r'(?=[+-])'));
    double result = 0;
    
    for (final part in addParts) {
      if (part.isEmpty) continue;
      result += _evalMulDiv(part);
    }
    return result;
  }

  double _evalMulDiv(String expr) {
    final parts = expr.split(RegExp(r'(?=[*/])'));
    double result = 1;
    bool isFirst = true;
    
    for (var part in parts) {
      if (part.isEmpty) continue;
      
      String op = '*';
      if (part.startsWith('*')) {
        op = '*';
        part = part.substring(1);
      } else if (part.startsWith('/')) {
        op = '/';
        part = part.substring(1);
      }
      
      final num = double.tryParse(part) ?? 0;
      
      if (isFirst) {
        result = num;
        isFirst = false;
      } else {
        if (op == '*') {
          result *= num;
        } else if (op == '/') {
          result /= num;
        }
      }
    }
    return result;
  }
}

// ============================================================================
// SCREEN
// ============================================================================

/// 電卓画面
class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final history = ref.watch(calculatorHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('電卓'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AETHER AI',
            onPressed: () => showAetherTrigger(context),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context, ref, history),
          ),
        ],
      ),
      body: Column(
        children: [
          // ディスプレイ
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (state.expression.isNotEmpty)
                    Text(
                      state.expression,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      state.display,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // キーパッド
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildRow(notifier, ['C', '⌫', '%', '÷']),
                  _buildRow(notifier, ['7', '8', '9', '×']),
                  _buildRow(notifier, ['4', '5', '6', '-']),
                  _buildRow(notifier, ['1', '2', '3', '+']),
                  _buildRow(notifier, ['±', '0', '.', '=']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(CalculatorNotifier notifier, List<String> buttons) {
    return Expanded(
      child: Row(
        children: buttons.map((btn) => _buildButton(notifier, btn)).toList(),
      ),
    );
  }

  Widget _buildButton(CalculatorNotifier notifier, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: _CalculatorButton(
          label: label,
          onPressed: () => _handleButton(notifier, label),
        ),
      ),
    );
  }

  void _handleButton(CalculatorNotifier notifier, String button) {
    switch (button) {
      case 'C':
        notifier.clear();
        break;
      case '⌫':
        notifier.backspace();
        break;
      case '=':
        notifier.calculate();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
      case '%':
        notifier.operator(button);
        break;
      case '±':
        break;
      default:
        notifier.input(button);
    }
  }

  void _showHistory(BuildContext context, WidgetRef ref, List<String> history) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('履歴（最大20件）', style: Theme.of(context).textTheme.titleMedium),
                if (history.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      ref.read(calculatorHistoryProvider.notifier).clear();
                      Navigator.pop(context);
                    },
                    child: const Text('クリア'),
                  ),
              ],
            ),
          ),
          Flexible(
            child: history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('履歴がありません'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: history.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(history[index]),
                    ),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _CalculatorButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isOperator = ['+', '-', '×', '÷', '=', '%'].contains(label);
    final isFunction = ['C', '⌫', '±'].contains(label);

    Color bgColor;
    Color fgColor;

    if (label == '=') {
      bgColor = Theme.of(context).colorScheme.primary;
      fgColor = Theme.of(context).colorScheme.onPrimary;
    } else if (isOperator) {
      bgColor = Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2);
      fgColor = Theme.of(context).colorScheme.secondary;
    } else if (isFunction) {
      bgColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      fgColor = Theme.of(context).colorScheme.onSurface;
    } else {
      bgColor = Theme.of(context).colorScheme.surface;
      fgColor = Theme.of(context).colorScheme.onSurface;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
