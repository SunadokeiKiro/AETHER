import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';

/// 換算カテゴリ
enum ConversionCategory {
  length,
  weight,
  temperature,
  currency,
}

/// 換算の状態
class ConverterState {
  final ConversionCategory category;
  final String fromUnit;
  final String toUnit;
  final double inputValue;
  final double? result;

  const ConverterState({
    this.category = ConversionCategory.length,
    this.fromUnit = 'm',
    this.toUnit = 'cm',
    this.inputValue = 0,
    this.result,
  });

  ConverterState copyWith({
    ConversionCategory? category,
    String? fromUnit,
    String? toUnit,
    double? inputValue,
    double? result,
  }) {
    return ConverterState(
      category: category ?? this.category,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      inputValue: inputValue ?? this.inputValue,
      result: result,
    );
  }
}

/// 換算を管理するProvider
final converterProvider = StateNotifierProvider<ConverterNotifier, ConverterState>(
  (ref) => ConverterNotifier(),
);

class ConverterNotifier extends StateNotifier<ConverterState> {
  ConverterNotifier() : super(const ConverterState());

  static const Map<ConversionCategory, List<String>> units = {
    ConversionCategory.length: ['mm', 'cm', 'm', 'km', 'in', 'ft', 'yd', 'mi'],
    ConversionCategory.weight: ['mg', 'g', 'kg', 'oz', 'lb'],
    ConversionCategory.temperature: ['°C', '°F', 'K'],
    ConversionCategory.currency: ['JPY', 'USD', 'EUR', 'GBP', 'CNY', 'KRW'],
  };

  // メートルへの変換係数
  static const Map<String, double> lengthToMeter = {
    'mm': 0.001, 'cm': 0.01, 'm': 1, 'km': 1000,
    'in': 0.0254, 'ft': 0.3048, 'yd': 0.9144, 'mi': 1609.344,
  };

  // グラムへの変換係数
  static const Map<String, double> weightToGram = {
    'mg': 0.001, 'g': 1, 'kg': 1000, 'oz': 28.3495, 'lb': 453.592,
  };

  // JPYへの変換（仮レート）
  static const Map<String, double> currencyToJPY = {
    'JPY': 1, 'USD': 155, 'EUR': 170, 'GBP': 195, 'CNY': 21.5, 'KRW': 0.115,
  };

  void setCategory(ConversionCategory category) {
    final unitList = units[category]!;
    state = ConverterState(
      category: category,
      fromUnit: unitList[0],
      toUnit: unitList[1],
      inputValue: 0,
    );
  }

  void setFromUnit(String unit) {
    state = state.copyWith(fromUnit: unit);
    convert();
  }

  void setToUnit(String unit) {
    state = state.copyWith(toUnit: unit);
    convert();
  }

  void setInputValue(double value) {
    state = state.copyWith(inputValue: value);
    convert();
  }

  void swap() {
    state = state.copyWith(
      fromUnit: state.toUnit,
      toUnit: state.fromUnit,
    );
    convert();
  }

  void convert() {
    double? result;
    
    switch (state.category) {
      case ConversionCategory.length:
        final toMeter = state.inputValue * (lengthToMeter[state.fromUnit] ?? 1);
        result = toMeter / (lengthToMeter[state.toUnit] ?? 1);
        break;
      case ConversionCategory.weight:
        final toGram = state.inputValue * (weightToGram[state.fromUnit] ?? 1);
        result = toGram / (weightToGram[state.toUnit] ?? 1);
        break;
      case ConversionCategory.temperature:
        result = _convertTemperature(state.inputValue, state.fromUnit, state.toUnit);
        break;
      case ConversionCategory.currency:
        final toJPY = state.inputValue * (currencyToJPY[state.fromUnit] ?? 1);
        result = toJPY / (currencyToJPY[state.toUnit] ?? 1);
        break;
    }
    
    state = state.copyWith(result: result);
  }

  double _convertTemperature(double value, String from, String to) {
    // まずケルビンに変換
    double kelvin;
    switch (from) {
      case '°C':
        kelvin = value + 273.15;
        break;
      case '°F':
        kelvin = (value - 32) * 5 / 9 + 273.15;
        break;
      default:
        kelvin = value;
    }
    
    // ケルビンから目標単位へ
    switch (to) {
      case '°C':
        return kelvin - 273.15;
      case '°F':
        return (kelvin - 273.15) * 9 / 5 + 32;
      default:
        return kelvin;
    }
  }
}

/// 換算画面
class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);
    final units = ConverterNotifier.units[state.category]!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('単位換算'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'AETHER AI',
            onPressed: () => showAetherTrigger(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // カテゴリ選択
            SegmentedButton<ConversionCategory>(
              segments: const [
                ButtonSegment(value: ConversionCategory.length, label: Text('長さ')),
                ButtonSegment(value: ConversionCategory.weight, label: Text('重さ')),
                ButtonSegment(value: ConversionCategory.temperature, label: Text('温度')),
                ButtonSegment(value: ConversionCategory.currency, label: Text('通貨')),
              ],
              selected: {state.category},
              onSelectionChanged: (selection) {
                notifier.setCategory(selection.first);
                _inputController.clear();
              },
            ),
            const SizedBox(height: 32),
            
            // 入力
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: '値を入力',
                              border: InputBorder.none,
                            ),
                            style: Theme.of(context).textTheme.headlineMedium,
                            onChanged: (value) {
                              final parsed = double.tryParse(value) ?? 0;
                              notifier.setInputValue(parsed);
                            },
                          ),
                        ),
                        DropdownButton<String>(
                          value: state.fromUnit,
                          items: units.map((u) => DropdownMenuItem(
                            value: u,
                            child: Text(u),
                          )).toList(),
                          onChanged: (value) {
                            if (value != null) notifier.setFromUnit(value);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // スワップボタン
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: IconButton.filled(
                onPressed: () => notifier.swap(),
                icon: const Icon(Icons.swap_vert),
              ),
            ),
            
            // 結果
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.result?.toStringAsFixed(4) ?? '0',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    DropdownButton<String>(
                      value: state.toUnit,
                      items: units.map((u) => DropdownMenuItem(
                        value: u,
                        child: Text(u),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) notifier.setToUnit(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
